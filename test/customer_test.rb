require_relative 'test_helper'
require_relative '../lib/sales_engine'
require_relative '../lib/customer'

class CustomerTest < Minitest::Test
  attr_reader :se, :customer_repo, :customer

  def setup
    @se = SalesEngine.from_csv({
      :items         => "./data/small_items.csv",
      :merchants     => "./data/small_merchants.csv",
      :invoice_items => "./data/small_invoice_items.csv",
      :customers     => "./data/small_customers.csv",
      :transactions  => "./data/small_transactions.csv",
      :invoices      => "./data/small_invoices.csv"})

    @se.merchant_repo = MerchantRepository.new(nil, se)
    @se.invoice_repo  = InvoiceRepository.new(nil, se)
    @customer_repo = @se.customer_repo = CustomerRepository.new(nil, se)
    setup_merchants
    setup_invoices
    setup_customers
    @customer = customer_repo.customers[0]
  end

  def test_can_return_id
    assert_equal 1, customer.id
  end

  def test_can_return_first_name
    assert_equal "Kerry", customer.first_name
  end

  def test_can_return_last_name
    assert_equal "Sheldon", customer.last_name
  end

  def test_we_can_get_time_created_at
      assert_equal Time.parse("2012-03-27 14:54:09 UTC"), customer.created_at
  end

  def test_we_can_get_time_updated_at
    assert_equal Time.parse("2012-03-27 14:54:09 UTC"), customer.updated_at
  end

  def test_we_can_retrieve_merchant_objects
    assert_equal Merchant, customer.merchants[0].class
  end

  def test_we_can_retrieve_merchant_objects_in_array
    assert_equal Array, customer.merchants.class
  end

  def test_we_can_retrieve_correct_customer
    assert_equal "Merch1", customer.merchants[0].name
  end

  def setup_merchants
    @se.merchant_repo.add_new({:id => 1, :name => "Merch1", :created_at => "2016-04-22"}, @se)
    @se.merchant_repo.add_new({:id => 2, :name => "Merch2", :created_at => "2016-10-22"}, @se)
    @se.merchant_repo.add_new({:id => 3, :name => "Merch3", :created_at => "2016-08-22"}, @se)
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


  def setup_customers
    @se.customer_repo.add_new({:id => 1, :first_name => "Kerry",
       :last_name => "Sheldon", :created_at => "2012-03-27 14:54:09 UTC", :updated_at => "2012-03-27 14:54:09 UTC"}, @se)
    @se.customer_repo.add_new({:id => 2, :first_name => "Colin"}, @se)
    @se.customer_repo.add_new({:id => 3, :first_name => "Fake"}, @se)
  end

end
