require 'bigdecimal'
require_relative 'standard_deviation'
require_relative 'sales_analyst'
require_relative 'sales_engine'
require 'erb'

class MerchantAnalytics < SalesAnalyst
  include StandardDeviation

  attr_reader :sales_engine, :erb_template
  attr_accessor :analytics

  def initialize(sales_engine)
    @sales_engine = sales_engine
    @erb_template = nil
    @analytics = {"Merchant"                    => Hash.new(0),
                  "All"                         => Hash.new(0),
                  "Top Earners"                 => Hash.new(0),
                  "Like Merchants: Revenue"     => Hash.new(0),
                  "Like Merchants: Item Number" => Hash.new(0),
                  "Like Merchants: Item Price"  => Hash.new(0)}
  end

  def run_merchant_analytics(merchant_id)
    generate_all_data(merchant_id)
    normalize_data_for_chart
    setup_output_template
    save_report
  end

  def generate_all_data(merchant_id)
    generate_analytics_merchant(merchant_id)
    generate_analytics_all
    generate_analytics_top
    generate_analytics_like_revenue
    generate_analytics_like_item_number
    generate_analytics_like_item_price
  end

  def setup_output_template
    report_template = File.read "lib/index.html.erb"
    @erb_template = ERB.new report_template
  end

  def generate_report
    @erb_template.result(binding)
  end

  def save_report
    Dir.mkdir("public") unless Dir.exist? "public"
    filename = "public/index.html"
    File.open(filename,'w') do |file|
      file.puts generate_report
    end
  end

  def generate_analytics_merchant(merchant_id)
    merch = sales_engine.merchants.find_by_id(merchant_id)
    subhash = @analytics["Merchant"]
    subhash[:name]      = merch.name
    subhash[:revenue]   = revenue_by_merchant(merchant_id).to_i
    subhash[:items]     = merch.items.nil? ? 0 : merch.items.length
    subhash[:customers] = merch.customers.nil? ? 0 : merch.customers.length
    subhash[:average_price] = average_item_price_for_merchant(merchant_id).to_i
    subhash[:invoices]  = merch.invoices.nil? ? 0 : merch.invoices.length
  end

  def normalize_data_for_chart
    @analytics.each do |key, _v|
      @analytics[key][:revenue] = @analytics[key][:revenue]/100
      @analytics[key][:average_price] = @analytics[key][:average_price]/10
    end
  end

  def generate_analytics_all
    merchants = sales_engine.merchants.all
    subhash = @analytics["All"]
    analytics_hash_generator(subhash, merchants)
  end

  def generate_analytics_top
    merchants = top_revenue_earners(3)
    subhash = @analytics["Top Earners"]
    analytics_hash_generator(subhash, merchants)
  end

  def generate_analytics_like_revenue
    merchants = generate_like_subset(:revenue, 0.1)
    subhash = @analytics["Like Merchants: Revenue"]
    analytics_hash_generator(subhash, merchants)
  end

  def generate_analytics_like_item_number
    merchant_set = generate_like_subset(:items, 0.1)
    subhash = @analytics["Like Merchants: Item Number"]
    analytics_hash_generator(subhash, merchant_set)
  end

  def generate_analytics_like_item_price
    merchant_set = generate_like_subset(:average_price, 0.1)
    subhash = @analytics["Like Merchants: Item Price"]
    analytics_hash_generator(subhash, merchant_set)
  end

  def calculate_item_count_average(merchant_array)
    average(item_count_array(merchant_array)).round(2)
  end

  def item_count_array(merchant_array)
    merchant_array.map do |merchant|
      merchant.items.nil? ? 0 : merchant.items.length
    end
  end

  def invoice_count_array(merchant_array)
    merchant_array.map do |merchant|
      merchant.invoices.nil? ? 0 : merchant.invoices.length
    end
  end

  def calculate_invoice_count_average(merchant_array)
    average(invoice_count_array(merchant_array)).round(2)
  end

  def customer_count_array(merchant_array)
    merchant_array.map do |merchant|
      merchant.customers.nil? ? 0 : merchant.customers.length
    end
  end

  def calculate_customer_count_average(merchant_array)
    average(customer_count_array(merchant_array)).round(2)
  end

  def generate_item_price_array(merchant_array)
    merchant_array.map do |merchant|
      average_item_price_for_merchant(merchant.id).to_f
    end
  end

  def calculate_item_price_average(merchant_array)
    average(generate_item_price_array(merchant_array)).round(2)
  end

  def generate_merchant_revenue_array(merchant_array)
    merchant_array.map do |merchant|
      revenue_by_merchant(merchant.id)
    end
  end

  def calculate_revenue_average(merchant_array)
    average(generate_merchant_revenue_array(merchant_array))
  end

  def generate_like_subset(feature, range)
    if feature == :revenue
      method = "revenue_by_merchant"
    elsif feature == :items
      method = "number_of_items"
    elsif feature == :average_price
      method = "average_item_price_for_merchant"
    end
    select_subset(feature, range, method)
  end

  def select_subset(feature, range, method)
    sales_engine.merchants.all.select do |merchant|
      self.send(method, merchant.id) <= (1 + range) *
      analytics["Merchant"][feature] &&
      self.send(method, merchant.id) >= (1 - range) *
      analytics["Merchant"][feature]
    end
  end

  def number_of_items(merchant_id)
    sales_engine.merchants.find_by_id(merchant_id).items.length
  end

  def analytics_hash_generator(subhash, merchant_set)
    subhash[:revenue] =
      calculate_revenue_average(merchant_set).to_i
    subhash[:items] =
      calculate_item_count_average(merchant_set)
    subhash[:customers] =
      calculate_customer_count_average(merchant_set)
    subhash[:average_price] =
      calculate_item_price_average(merchant_set).to_i
    subhash[:invoices] =
      calculate_invoice_count_average(merchant_set)
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
