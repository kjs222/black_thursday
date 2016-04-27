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
    item_threshold = threshold(item_count_by_merchant, 1)
    sales_engine.merchants.all.find_all do |merchant|
      merchant.num_items >= item_threshold
    end
  end

  def average_item_price_for_merchant(merchant_id)
    merchant = sales_engine.merchants.find_by_id(merchant_id)
    aggregate_price = merchant.items.reduce(0) do |sum, item|
      sum + item.unit_price
    end
    (aggregate_price/merchant.num_items).round(2)
  end

  def average_average_price_per_merchant
    sum_averages = sales_engine.merchants.all.reduce(0) do |sum, merchant|
      sum + average_item_price_for_merchant(merchant.id)
    end
    total_merchants = sales_engine.total_merchants
    (sum_averages/total_merchants).round(2)
  end

  def golden_items
    golden_price_threshold = threshold(item_price_array, 2)
    sales_engine.items.all.find_all do |item|
      item.unit_price_to_dollars >= golden_price_threshold
    end
  end

  def average_invoices_per_merchant
    total_invoices = sales_engine.total_invoices.to_f
    total_merchants = sales_engine.total_merchants
    (total_invoices/total_merchants).round(2)
  end

  def average_invoices_per_merchant_standard_deviation
    standard_deviation(invoice_count_by_merchant)
  end

  def top_merchants_by_invoice_count
    invoice_count_threshold = threshold(invoice_count_by_merchant, 2)
    sales_engine.merchants.all.find_all do |merchant|
      merchant.num_invoices >= invoice_count_threshold
    end
  end

  def bottom_merchants_by_invoice_count
    invoice_count_threshold = threshold(invoice_count_by_merchant, -2)
    sales_engine.merchants.all.find_all do |merchant|
      merchant.num_invoices <= invoice_count_threshold
    end
  end

  def top_days_by_invoice_count
    top_day_threshold = threshold(group_invoices_by_day_count.values, 1)
    group_invoices_by_day_count.delete_if do | key, value |
      value <= top_day_threshold
    end.keys
  end

  def invoice_status(status)
    num_with_status_provided = group_invoices_by_status[status].length.to_f
    total_invoices = sales_engine.total_invoices
    (num_with_status_provided/total_invoices * 100).round(2)
  end

  def total_revenue_by_date(date)
    invoices_on_date = find_all_invoices_by_date(date)
    total = invoices_on_date.reduce(0) do |sum, invoice|
      sum += invoice.total
    end
    BigDecimal.new(total).round(2)
  end

  def top_revenue_earners(num=20)
    revenue_hash = generate_merchant_revenue_hash
    sorted = revenue_hash.sort_by {|merchant, revenue| revenue}.reverse.to_h
    sorted.keys[0...num]
  end

  def merchants_ranked_by_revenue
    top_revenue_earners(sales_engine.total_merchants)
  end

  def merchants_with_pending_invoices
    sales_engine.merchants.all.select do |merchant|
      merchant.invoices.any? {|invoice| !invoice.is_paid_in_full?}
    end
  end

  def merchants_with_only_one_item
    sales_engine.merchants.all.select do |merchant|
      merchant.num_items == 1
    end
  end

  def merchants_with_only_one_item_registered_in_month(month)
    all_with_one_item = merchants_with_only_one_item
    all_with_one_item.select do |merchant|
      merchant.created_at.strftime("%B") == month
    end
  end

  def revenue_by_merchant(merchant_id)
    sales_engine.merchants.find_by_id(merchant_id).revenue
    # all_invoices = sales_engine.invoices.find_all_by_merchant_id(merchant_id)
    # total = all_invoices.reduce(0) do |cuml_total, invoice|
    #   cuml_total += invoice.total
    # end
    # BigDecimal.new(total).round(2)
  end

  def most_sold_item_for_merchant(merchant_id)
    hash = generate_item_hash_for_merchant(merchant_id)
    top = hash.max_by {|item, values| values[:quantity]}
    quantity = top[1][:quantity]
    most_sold = hash.find_all {|k, v| v[:quantity] == quantity}
    most_sold.map do |item|
      sales_engine.items.find_by_id(item[0])
    end
  end

  def best_item_for_merchant(merchant_id)
    hash = generate_item_hash_for_merchant(merchant_id)
    best_id = hash.max_by {|item, values| values[:revenue]}
    sales_engine.items.find_by_id(best_id[0])
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

  def group_invoices_by_status
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

  # def generate_merchant_revenue_hash
  #   merchant_revenue_hash = {}
  #   sales_engine.merchants.all.each do |merchant|
  #     merchant_revenue_hash[merchant] = revenue_by_merchant(merchant.id)
  #   end
  #   merchant_revenue_hash
  # end

  def find_paid_invoices_by_merchant(merchant_id)
    merchant = sales_engine.merchants.find_by_id(merchant_id)
    merchant.invoices.select do |invoice|
      invoice.is_paid_in_full?
    end
  end

  def generate_item_hash_for_invoice(invoice_id)
    all_items = sales_engine.invoice_items.find_all_by_invoice_id(invoice_id)
    all_items.map do |invoice_item|
      {invoice_item.item_id => {:quantity => invoice_item.quantity,
      :revenue => invoice_item.unit_price * invoice_item.quantity}}
    end
  end

  def generate_item_hash_for_merchant(merchant_id)
    cuml_array = find_paid_invoices_by_merchant(merchant_id).map do |invoice|
      generate_item_hash_for_invoice(invoice.id)
    end.flatten
    cuml_array.reduce({}) do |items, stats|
      items.merge(stats) do |_, prev_hsh, new_hsh|
        prev_hsh.merge(new_hsh) {|_, prev_val, new_val| prev_val + new_val }
      end
    end
  end

end
