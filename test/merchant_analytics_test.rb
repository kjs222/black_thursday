require_relative 'test_helper'
require_relative '../lib/merchant_analytics'
require_relative '../lib/sales_engine'

class MerchantAnalyticsTest < Minitest::Test

  attr_reader :se, :ma, :merchant

  def setup
    @se = SalesEngine.from_csv({
      :items     => "./data/items_analytics.csv",
      :merchants => "./data/merchants_analytics.csv",
      :invoice_items => "./data/invoice_items_analytics.csv",
      :customers => "./data/customers_analytics.csv",
      :transactions => "./data/transactions_analytics.csv",
      :invoices  => "./data/invoices_analytics.csv"})
    @ma = MerchantAnalytics.new(@se)
    @se.merchants
    @se.items
    @se.invoices
    @se.transactions
    @se.invoice_items
    @se.customers
  end

  def test_it_has_ref_to_se_on_ititialization
    assert_equal true, !ma.sales_engine.nil?
  end

  def test_it_has_access_to_SD_methods
    assert_equal 1.0, ma.standard_deviation([1,2,3])
    assert_equal 2.65, ma.standard_deviation([1,2,6])
  end

  def test_it_has_access_to_SA_methods
      assert_equal 3, ma.average_items_per_merchant
      assert_equal 10, ma.average_item_price_for_merchant(1).to_i
  end

  def test_it_finds_correct_subset_on_num_items
    ma.generate_analytics_merchant(1)
    assert_equal 4, ma.generate_like_subset(:items, 0.1).length
    assert_equal "Mer2", ma.generate_like_subset(:items, 0.1)[1].name
  end

  def test_it_finds_correct_subset_on_avg_price
    ma.generate_analytics_merchant(1)
    assert_equal 2, ma.generate_like_subset(:average_price, 0.1).length
    assert_equal "Mer2", ma.generate_like_subset(:average_price, 0.1)[-1].name
  end

  def test_it_finds_correct_subset_on_revenue
    ma.generate_analytics_merchant(1)
    assert_equal 2, ma.generate_like_subset(:revenue, 0.1).length
    assert_equal "Mer2", ma.generate_like_subset(:revenue, 0.1)[-1].name
  end

  def test_it_finds_correct_subset_on_revenue
    ma.generate_analytics_merchant(1)
    assert_equal 2, ma.generate_like_subset(:revenue, 0.1).length
    assert_equal "Mer2", ma.generate_like_subset(:revenue, 0.1)[-1].name
  end

  def test_setup_output_template_creates_ERB_obj
    ma.setup_output_template
    assert_equal ERB, ma.erb_template.class
  end

  def test_it_calculates_average_num_items
    merchants = se.merchants.all
    assert_equal [3, 3, 3, 3, 5, 1], ma.item_count_array(merchants)
    assert_equal 3, ma.calculate_item_count_average(merchants)
  end

  def test_it_calculates_average_price
    merchants = se.merchants.all
    # assert_equal [10, 11, 9.5, 5, 2, 20], ma.item_price_array(merchants)
    # assert_equal 10, ma.calculate_item_price_average(merchants)
  end

  def test_it_calculates_average_customers
    merchants = se.merchants.all
    assert_equal [1, 1, 2, 2, 2, 2], ma.customer_count_array(merchants)
    assert_equal 1.67, ma.calculate_customer_count_average(merchants)
  end

  def test_it_calculates_average_invoices
    merchants = se.merchants.all
    assert_equal [2, 2, 2, 2, 2, 2], ma.invoice_count_array(merchants)
    assert_equal 2, ma.calculate_invoice_count_average(merchants)
  end

  def test_it_generates_correct_hash_for_merchant
    ma.run_merchant_analytics(1)
    assert_equal ({:name => "Mer1", :revenue => 300, :items => 3,  :customers => 1, :average_price => 10, :invoices => 2}), ma.analytics["Merchant"]
  end

  def test_it_generates_correct_hash_for_all
    ma.run_merchant_analytics(1)
    assert_equal ({:revenue => 1330, :items => 3.0,  :customers => 1.67, :average_price => 64, :invoices => 2.0}), ma.analytics["All"]
  end

  def test_it_generates_correct_hash_for_top
    ma.run_merchant_analytics(1)
    assert_equal ({:revenue => 2116, :items => 2.33,  :customers => 2.0, :average_price => 115, :invoices => 2.0}), ma.analytics["Top Earners"]
  end

  def test_it_generates_correct_hash_for_like_rev
    ma.run_merchant_analytics(1)
    assert_equal ({:revenue => 315, :items => 3.0,  :customers => 1.0, :average_price => 10, :invoices => 2.0}), ma.analytics["Like Merchants: Revenue"]
  end

  def test_it_generates_correct_hash_for_like_itm_num
    ma.run_merchant_analytics(1)
    assert_equal ({:revenue => 1245, :items => 3.00,  :customers => 1.5, :average_price => 41, :invoices => 2.0}), ma.analytics["Like Merchants: Item Number"]
  end

  def test_it_generates_correct_hash_for_like_itm_pr
    ma.run_merchant_analytics(1)
    assert_equal ({:revenue => 315, :items => 3.0,  :customers => 1.0, :average_price => 10, :invoices => 2.0}), ma.analytics["Like Merchants: Item Price"]
  end


end
