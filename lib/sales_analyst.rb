require 'bigdecimal'
require_relative 'standard_deviation'
require 'time'

class SalesAnalyst
  include StandardDeviation

  attr_reader :sales_engine

  def initialize(sales_engine)
    @sales_engine = sales_engine
  end

  def average_items_per_merchant
    num_items = sales_engine.items.all.length.to_f
    num_merchants = sales_engine.merchants.all.length
    (num_items/num_merchants).round(2)
  end

  def average_items_per_merchant_standard_deviation
    standard_deviation(item_count_by_merchant)
  end

  def merchants_with_high_item_count
    threshold = threshold(item_count_by_merchant, 1)
    sales_engine.merchants.all.find_all do |merchant|
      merchant.items.length >= threshold
    end
  end

  def average_item_price_for_merchant(merchant_id)
    merchant = sales_engine.merchants.find_by_id(merchant_id)
    aggregate_price = merchant.items.reduce(0) do |sum, item|
      sum + item.unit_price
    end
    (aggregate_price/merchant.items.length).round(2)
  end

  def average_average_price_per_merchant
    sum_averages = sales_engine.merchants.all.reduce(0) do |sum, merchant|
      sum + average_item_price_for_merchant(merchant.id)
    end
    num_merchants = sales_engine.merchants.all.length
    (sum_averages/num_merchants).round(2)
  end

  def golden_items
    threshold = threshold(item_price_array, 2)
    sales_engine.items.all.find_all do |item|
      item.unit_price_to_dollars >= threshold
    end
  end

  def average_invoices_per_merchant
    num_invoices = sales_engine.invoices.all.length.to_f
    num_merchants = sales_engine.merchants.all.length
    (num_invoices/num_merchants).round(2)
  end

  def average_invoices_per_merchant_standard_deviation
    standard_deviation(invoice_count_by_merchant)
  end

  def top_merchants_by_invoice_count
    threshold = threshold(invoice_count_by_merchant, 2)
    sales_engine.merchants.all.find_all do |merchant|
      merchant.invoices.length >= threshold
    end
  end

  def bottom_merchants_by_invoice_count
    threshold = threshold(invoice_count_by_merchant, -2)
    sales_engine.merchants.all.find_all do |merchant|
      merchant.invoices.length <= threshold
    end
  end

  def top_days_by_invoice_count
    threshold = threshold(group_invoices_by_day_count.values, 1)
    group_invoices_by_day_count.delete_if do | key, value |
      value <= threshold
    end.keys
  end

  def invoice_status(status)
    (group_invoices_status[status].length.to_f /
    sales_engine.invoices.all.length * 100).round(2)
  end

  def total_revenue_by_date(date)
    invoices = find_all_invoices_by_date(date)
    total =invoices.reduce(0) do |sum, invoice|
      sum += invoice.total
    end
    BigDecimal.new(total).round(2)
  end

  def top_revenue_earners(num=20)
    hash = generate_merchant_revenue_hash
    sorted = hash.sort_by {|merchant, revenue| revenue}.reverse.to_h
    sorted.keys[0...num]
  end

  def merchants_ranked_by_revenue
    top_revenue_earners(sales_engine.merchants.all.length)
  end

  def merchants_with_pending_invoices
    sales_engine.merchants.all.select do |merchant|
      merchant.invoices.any? {|invoice| !invoice.is_paid_in_full?}
    end
  end

  def merchants_with_only_one_item
    sales_engine.merchants.all.select do |merchant|
      merchant.items.length == 1
    end
  end

  def merchants_with_only_one_item_registered_in_month(month)
    all_with_one = merchants_with_only_one_item
    all_with_one.select do |merchant|
      merchant.created_at.strftime("%B") == month
    end
  end

  def revenue_by_merchant(merchant_id)
    all_invoices = sales_engine.invoices.find_all_by_merchant_id(merchant_id)
    total = all_invoices.reduce(0) do |cuml_total, invoice|
      cuml_total += invoice.total
    end
    BigDecimal.new(total).round(2)
  end

  def most_sold_item_for_merchant(merchant_id)
    most_sold = generate_most_sold_array(merchant_id)
    most_sold.map do |item_id|
      sales_engine.items.find_by_id(item_id[0])
    end
  end

  def best_item_for_merchant(merchant_id)
    best_item = generate_best_item(merchant_id)
    sales_engine.items.find_by_id(best_item)
  end

  #=========HELPER METHODS===============

  def item_price_array
    sales_engine.items.all.map do |item|
      item.unit_price_to_dollars
    end.sort
  end

  def item_price_average
    average(item_price_array).round(2)
  end

  def item_price_standard_deviation
    standard_deviation(item_price_array)
  end

  def item_count_by_merchant
    sales_engine.merchants.all.map do |merchant|
      merchant.items.length
    end.sort
  end

  def item_count_standard_deviation
    standard_deviation(item_count_by_merchant)
  end

  def invoice_count_by_merchant
    sales_engine.merchants.all.map do |merchant|
      merchant.invoices.length
    end.sort
  end

  def find_day_of_week(date)
    date.strftime("%A")
  end

  def group_invoices_by_day
    sales_engine.invoices.all.group_by do |invoice|
      find_day_of_week(invoice.created_at)
    end
  end

  def group_invoices_by_day_count
    hash = group_invoices_by_day
    hash.each do | day, invoices |
      hash[day] = invoices.length
    end
  end

  def average_invoices_per_day
    average(group_invoices_by_day_count.values).round(2)
  end

  def group_invoices_status
    sales_engine.invoices.all.group_by do |invoice|
      invoice.status
    end
  end

  def find_all_invoices_by_date(date)#
    date = Time.parse(date.to_s).strftime('%D')
    sales_engine.invoices.all.select do |invoice|
      invoice.created_at.strftime('%D') == date
    end
  end

  def generate_merchant_revenue_hash
    merchant_revenue_hash = {}
    sales_engine.merchants.all.each do |merchant|
      merchant_revenue_hash[merchant] = revenue_by_merchant(merchant.id)
    end
    merchant_revenue_hash
  end

  def find_paid_invoices_by_merchant(merchant_id)
    merchant = sales_engine.merchants.find_by_id(merchant_id)
    merchant.invoices.select do |invoice|
      invoice.is_paid_in_full?
    end
  end

  def generate_most_sold_array(merchant_id)
    invoices = find_paid_invoices_by_merchant(merchant_id)
    most_sold_hash = Hash.new(0)

    invoices.each do |invoice|
      sales_engine.invoice_items.find_all_by_invoice_id(invoice.id).each do |invoice_item|
        most_sold_hash[invoice_item.item_id] += invoice_item.quantity
      end
    end

    sorted_array = most_sold_hash.sort_by {|k, v| v}.reverse
    most_sold = sorted_array.find_all {|pair| pair[1] == sorted_array[0][1]}
  end

  def generate_best_item(merchant_id)
    invoices = find_paid_invoices_by_merchant(merchant_id)
    best_item_hash = Hash.new(0)

    invoices.each do |invoice|

      sales_engine.invoice_items.find_all_by_invoice_id(invoice.id).each do |invoice_item|
        best_item_hash[invoice_item.item_id] += invoice_item.quantity * invoice_item.unit_price
      end

    end

    best_item = best_item_hash.sort_by {|k, v| v}.reverse[0][0]
  end

end
