require 'bigdecimal'
require_relative 'standard_deviation'
require_relative 'sales_analyst'
require_relative 'sales_engine'
require 'erb'
require 'pry'

class MerchantAnalytics < SalesAnalyst
  include StandardDeviation

  attr_reader :sales_engine, :analytics, :erb_template

  def initialize(sales_engine)
    @sales_engine = sales_engine
    @erb_template = nil
    @analytics = {"Merchant" => Hash.new(0),
                  "All" => Hash.new(0),
                  "Top Earners" => Hash.new(0),
                  "Like Merchants: Revenue" => Hash.new(0),
                  "Like Merchants: Item Number" => Hash.new(0),
                  "Like Merchants: Item Price" => Hash.new(0)}
  end

  def run_merchant_analytics(merchant_id)
    generate_all_data(merchant_id)
    setup_output_template
    save_report
  end

  def generate_all_data(merchant_id)
    generate_merchant_hash(merchant_id)
    generate_all_hash
    generate_top_hash
    generate_like_rev_hash
    generate_like_item_num_hash
    generate_like_item_price_hash
  end

  def setup_output_template
    report_template = File.read "lib/index.html.erb"
    @erb_template = ERB.new report_template
  end

  def generate_report
    @erb_template.result(binding)
  end

  def save_report #test at end
    Dir.mkdir("public") unless Dir.exists? "public"
    filename = "public/index.html"
    File.open(filename,'w') do |file|
      file.puts generate_report
    end
  end

  def generate_merchant_hash(merchant_id)
    merchant = sales_engine.merchants.find_by_id(merchant_id)
    subhash = @analytics["Merchant"]
    subhash[:name] = merchant.name
    subhash[:revenue] = revenue_by_merchant(merchant_id).to_i
    subhash[:items] = merchant.items.nil? ? 0 : merchant.items.length
    subhash[:customers] = merchant.customers.nil? ? 0 : merchant.customers.length
    subhash[:average_price] = average_item_price_for_merchant(merchant_id).to_i
    subhash[:invoices] = merchant.invoices.nil? ? 0 : merchant.invoices.length
  end

  def generate_all_hash
    merchant_set = sales_engine.merchants.all
    subhash = @analytics["All"]
    generate_generic_hash(subhash, merchant_set)
  end

  def generate_top_hash
    merchant_set = top_revenue_earners(3)
    subhash = @analytics["Top Earners"]
    generate_generic_hash(subhash, merchant_set)
  end

  def generate_like_rev_hash
    merchant_set = generate_like_subset(:revenue, 0.1)
    subhash = @analytics["Like Merchants: Revenue"]
    generate_generic_hash(subhash, merchant_set)
  end

  def generate_like_item_num_hash
    merchant_set = generate_like_subset(:items, 0.1)
    subhash = @analytics["Like Merchants: Item Number"]
    generate_generic_hash(subhash, merchant_set)
  end

  def generate_like_item_price_hash
    merchant_set = generate_like_subset(:average_price, 0.1)
    subhash = @analytics["Like Merchants: Item Price"]
    generate_generic_hash(subhash, merchant_set)
  end

  def calculate_merchant_item_count_average(merchant_array)
    average(generate_merchant_item_count_array(merchant_array))
  end

  def generate_merchant_item_count_array(merchant_array)
    merchant_array.map do |merchant|
      merchant.items.nil? ? 0 : merchant.items.length
    end
  end

  def generate_merchant_invoice_count_array(merchant_array)
    merchant_array.map do |merchant|
      merchant.invoices.nil? ? 0 : merchant.invoices.length
    end
  end

  def calculate_merchant_invoice_count_average(merchant_array)
    average(generate_merchant_invoice_count_array(merchant_array))
  end

  def generate_merchant_customer_count_array(merchant_array)
    merchant_array.map do |merchant|
      merchant.customers.nil? ? 0 : merchant.customers.length
    end
  end

  def calculate_merchant_customer_count_average(merchant_array)
    average(generate_merchant_customer_count_array(merchant_array))
  end

  def generate_merchant_item_price_array(merchant_array)
    merchant_array.map do |merchant|
      average_item_price_for_merchant(merchant.id)
    end
  end

  def calculate_merchant_item_price_average(merchant_array)
    average(generate_merchant_item_price_array(merchant_array))
  end

  def generate_merchant_revenue_array(merchant_array)
    merchant_array.map do |merchant|
      revenue_by_merchant(merchant.id)
    end
  end

  def calculate_merchant_revenue_average(merchant_array)
    average(generate_merchant_revenue_array(merchant_array))
  end

  def generate_like_subset(feature, range) #tested
    if feature == :revenue
      # binding.pry
      method = "revenue_by_merchant"
    elsif feature == :items
      method = "number_of_items"
    elsif feature == :average_price
      method = "average_item_price_for_merchant"
    end
    select_subset(feature, range, method)
  end

  def select_subset(feature, range, method) #tested #prob need to handle not less than 0
    subs = sales_engine.merchants.all.select do |merchant|
      (self.send(method, merchant.id) <= (1 + range) * analytics["Merchant"][feature]) && (self.send(method, merchant.id) >= (1 - range) * analytics["Merchant"][feature])
      # binding.pry
    end
    subs
  end

  def number_of_items(merchant_id) #tested
    sales_engine.merchants.find_by_id(merchant_id).items.length
  end

  def generate_generic_hash(subhash, merchant_set)
    subhash[:revenue] =
      calculate_merchant_revenue_average(merchant_set).to_i
    subhash[:items] =
      calculate_merchant_item_count_average(merchant_set)
    subhash[:customers] =
      calculate_merchant_customer_count_average(merchant_set)
    subhash[:average_price] =
      calculate_merchant_item_price_average(merchant_set).to_i
    subhash[:invoices] =
      calculate_merchant_invoice_count_average(merchant_set)
  end

end


if __FILE__==$0
  @se = SalesEngine.from_csv({
    :items     => "./data/items_analytics.csv",
    :merchants => "./data/merchants_analytics.csv",
    :invoice_items => "./data/invoice_items_analytics.csv",
    :customers => "./data/customers_analytics.csv",
    :transactions => "./data/transactions_analytics.csv",
    :invoices  => "./data/invoices_analytics.csv"})
  ma = MerchantAnalytics.new(@se)
  ma.run_merchant_analytics(1)


end
