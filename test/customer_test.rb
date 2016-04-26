require_relative 'test_helper'
require_relative '../lib/sales_engine'
require_relative '../lib/customer'

class CustomerTest < Minitest::Test
  attr_reader :se, :customer_repo, :customer, :invoices, :merchants
  def setup
    @se = SalesEngine.from_csv({
      :items     => "./data/small_items.csv",
      :merchants => "./data/small_merchants.csv",
      :invoice_items => "./data/small_invoice_items.csv",
      :customers => "./data/small_customers.csv",
      :transactions => "./data/small_transactions.csv",
      :invoices  => "./data/small_invoices.csv"})
    @se.merchants
    @se.invoices
    @customer_repo = @se.customers
    @customer = @customer_repo.customers[0]
  end

  # def test_can_return_id
  #   assert_equal 1, customer.id
  # end
  #
  # def test_can_return_first_name
  #   skip
  #   assert_equal "Kerry", customer.first_name
  # end
  #
  # def test_can_return_last_name
  #   skip
  #   assert_equal "Sheldon", customer.last_name
  # end
  #
  # def test_we_can_time_created_at
  #     assert_equal Time.parse("2012-03-27 14:54:09 UTC"), customer.created_at
  # end
  #
  # def test_we_can_time_updated_at
  #   assert_equal Time.parse("2012-03-27 14:54:09 UTC"), customer.updated_at
  # end

  def test_we_can_retrieve_merchant_objects
    assert_equal Merchant, customer.merchants[0].class
  end

  def test_we_can_retrieve_merchant_objects_in_array
    assert_equal Array, customer.merchants.class
  end

  def test_we_can_retrieve_correct_customer
    assert_equal 12334144, customer.merchants[0].id
  end

end
