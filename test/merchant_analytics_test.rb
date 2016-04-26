require_relative 'test_helper'
require_relative '../lib/merchant_analytics'
require_relative '../lib/sales_engine'

class MerchantAnalyticsTest < Minitest::Test

  attr_reader :se, :ma, :merchant

  def setup
    @se = SalesEngine.from_csv({
      :items     => "./data/small_items.csv",
      :merchants => "./data/small_merchants.csv",
      :invoice_items => "./data/small_invoice_items.csv",
      :customers => "./data/small_customers.csv",
      :transactions => "./data/small_transactions.csv",
      :invoices  => "./data/small_invoices.csv"})
    @ma = MerchantAnalytics.new(se)

    @se.merchant_repo = MerchantRepository.new(nil, se)
    @se.item_repo = ItemRepository.new(nil, se)
    @se.invoice_repo = InvoiceRepository.new(nil, se)
    @se.invoice_item_repo = InvoiceItemRepository.new(nil, se)
    @se.transaction_repo = TransactionRepository.new(nil, se)
    @se.customer_repo = CustomerRepository.new(nil, se)

    setup_merchants
    setup_items
    setup_invoices
    setup_invoice_items
    setup_transactions
    setup_customers
  end

  def test_it_has_ref_to_se_on_ititialization
    assert_equal true, !ma.sales_engine.nil?
  end

  def test_it_has_access_to_SD_methods
    assert_equal 1.0, ma.standard_deviation([1,2,3])
    assert_equal 2.65, ma.standard_deviation([1,2,6])
  end

  def test_it_has_access_to_SA_methods
      assert_equal 2.33, ma.average_items_per_merchant
      assert_equal 1, ma.average_item_price_for_merchant(1).to_i
  end

  def test_it_finds_correct_subset_on_num_items
    ma.generate_merchant_hash(merchant)
    assert_equal 2, ma.generate_like_subset(:items, 0.1).length
    assert_equal "Merch2", ma.generate_like_subset(:items, 0.1)[1].name
  end

  def test_it_finds_correct_subset_on_avg_price
    ma.generate_merchant_hash(merchant)
    assert_equal 2, ma.generate_like_subset(:average_price, 0.1).length
    assert_equal "Merch3", ma.generate_like_subset(:average_price, 0.1)[1].name
  end

  def test_it_finds_correct_subset_on_revenue
    assert_equal 1, ma.generate_like_subset(:revenue, 0.1).length
    assert_equal "Merch3", ma.generate_like_subset(:revenue, 0.1)[0].name
  end

  def test_setup_output_template_creates_ERB_obj
    ma.setup_output_template
    assert_equal ERB, ma.erb_template.class
  end

  def setup_merchants
    @se.merchant_repo.add_new({:id => 1, :name => "Merch1", :created_at => "2016-04-22"}, @se)
    @se.merchant_repo.add_new({:id => 2, :name => "Merch2", :created_at => "2016-10-22"}, @se)
    @se.merchant_repo.add_new({:id => 3, :name => "Merch3", :created_at => "2016-08-22"}, @se)
  end

  def setup_items
    @se.item_repo.add_new({:id => 1, :name => "Item1", :unit_price => 200, :merchant_id => 1}, @se)
    @se.item_repo.add_new({:id => 2, :name => "Item2", :unit_price => 100, :merchant_id => 1}, @se)

    @se.item_repo.add_new({:id => 3, :name => "Item3", :unit_price => 100, :merchant_id => 2}, @se)

    @se.item_repo.add_new({:id => 4, :name => "Item4", :unit_price => 500, :merchant_id => 3}, @se)
    @se.item_repo.add_new({:id => 5, :name => "Item5", :unit_price => 1000, :merchant_id => 3}, @se)
    @se.item_repo.add_new({:id => 6, :name => "Item6", :unit_price => 3000, :merchant_id => 3}, @se)
    @se.item_repo.add_new({:id => 7, :name => "Item7", :unit_price => 1250, :merchant_id => 3}, @se)
  end

  def setup_invoices
    @se.invoice_repo.add_new({:id => 1, :customer_id => 1, :merchant_id => 1, :status => "shipped", :created_at => "2016-04-18"}, @se)
    @se.invoice_repo.add_new({:id => 2, :customer_id => 1, :merchant_id => 1, :status => "shipped", :created_at => "2016-04-19"}, @se)
    @se.invoice_repo.add_new({:id => 3, :customer_id => 2, :merchant_id => 2, :status => "shipped", :created_at => "2016-04-19"}, @se)
    @se.invoice_repo.add_new({:id => 4, :customer_id => 3, :merchant_id => 3, :status => "returned", :created_at => "2016-04-20"}, @se)
    @se.invoice_repo.add_new({:id => 5, :customer_id => 1, :merchant_id => 3, :status => "shipped", :created_at => "2016-04-18"}, @se)
    @se.invoice_repo.add_new({:id => 6, :customer_id => 1, :merchant_id => 3, :status => "pending", :created_at => "2016-04-18"}, @se)
    @se.invoice_repo.add_new({:id => 7, :customer_id => 1, :merchant_id => 3, :status => "pending", :created_at => "2016-04-18"}, @se)
  end

  def setup_invoice_items
    @se.invoice_item_repo.add_new({:id => 1, :invoice_id => 1, :item_id => 1, :unit_price => "190", :quantity => "1", :created_at => "2016-04-21"}, @se)
    @se.invoice_item_repo.add_new({:id => 2, :invoice_id => 2, :item_id => 1, :unit_price => "190", :quantity => "1", :created_at => "2016-04-21"}, @se)
    @se.invoice_item_repo.add_new({:id => 3, :invoice_id => 2, :item_id => 2, :unit_price => "95", :quantity => "2", :created_at => "2016-04-21"}, @se)
    @se.invoice_item_repo.add_new({:id => 4, :invoice_id => 2, :item_id => 2, :unit_price => "100", :quantity => "3", :created_at => "2016-04-21"}, @se)
    @se.invoice_item_repo.add_new({:id => 5, :invoice_id => 3, :item_id => 3, :unit_price => "95", :quantity => "1", :created_at => "2016-04-18"}, @se)
    @se.invoice_item_repo.add_new({:id => 6, :invoice_id => 4, :item_id => 4, :unit_price => "500", :quantity => "2", :created_at => "2016-04-20"}, @se)
    @se.invoice_item_repo.add_new({:id => 7, :invoice_id => 4, :item_id => 5, :unit_price => "1000", :quantity => "1", :created_at => "2016-04-20"}, @se)
    @se.invoice_item_repo.add_new({:id => 8, :invoice_id => 4, :item_id => 6, :unit_price => "2900", :quantity => "1", :created_at => "2016-04-20"}, @se)
    @se.invoice_item_repo.add_new({:id => 9, :invoice_id => 4, :item_id => 7, :unit_price => "1250", :quantity => "1", :created_at => "2016-04-20"}, @se)
    @se.invoice_item_repo.add_new({:id => 10, :invoice_id => 5, :item_id => 5, :unit_price => "1000", :quantity => "1", :created_at => "2016-04-18"}, @se)
    @se.invoice_item_repo.add_new({:id => 11, :invoice_id => 6, :item_id => 6, :unit_price => "2900", :quantity => "1", :created_at => "2016-04-21"}, @se)
    @se.invoice_item_repo.add_new({:id => 12, :invoice_id => 7, :item_id => 7, :unit_price => "1250", :quantity => "1", :created_at => "2016-04-20"}, @se)
  end

  def setup_transactions
    @se.transaction_repo.add_new({:id => 1, :invoice_id => 1, :result => "success"}, @se)
    @se.transaction_repo.add_new({:id => 2, :invoice_id => 2, :result => "success"}, @se)
    @se.transaction_repo.add_new({:id => 3, :invoice_id => 3, :result => "success"}, @se)
    @se.transaction_repo.add_new({:id => 4, :invoice_id => 4, :result => "success"}, @se)
    @se.transaction_repo.add_new({:id => 5, :invoice_id => 5, :result => "success"}, @se)
    @se.transaction_repo.add_new({:id => 6, :invoice_id => 6, :result => "failed"}, @se)
    @se.transaction_repo.add_new({:id => 7, :invoice_id => 7, :result => "failed"}, @se)
  end

  def setup_customers
    @se.customer_repo.add_new({:id => 1, :first_name => "Kerry"}, @se)
    @se.customer_repo.add_new({:id => 2, :first_name => "Colin"}, @se)
    @se.customer_repo.add_new({:id => 3, :first_name => "Fake"}, @se)
  end

end
