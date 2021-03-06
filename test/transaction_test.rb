require_relative 'test_helper'
require_relative '../lib/transaction'
require_relative '../lib/sales_engine'

class TransactionTest < Minitest::Test
 attr_reader :transactions, :transaction
  def setup
    @se = SalesEngine.from_csv({
      :items     => "./data/small_items.csv",
      :merchants => "./data/small_merchants.csv",
      :invoice_items => "./data/small_invoice_items.csv",
      :customers => "./data/small_customers.csv",
      :transactions => "./data/small_transactions.csv",
      :invoices  => "./data/small_invoices.csv"})

      @se.invoices
      @transactions = @se.transactions
      @transaction = @transactions.all[0] #first transaction

  end

  def test_we_can_return_transaction_id
    assert_equal 1, transaction.id
  end

  def test_can_return_invoice_id
    assert_equal 1, transaction.invoice_id
  end

  def test_can_return_credit_card_number
    assert_equal 4068631943231473, transaction.credit_card_number
  end

  def test_can_return_credit_card_expiration_date
    assert_equal "0217", transaction.credit_card_expiration_date
  end

  def test_can_return_transaction_result
    assert_equal "success", transaction.result
  end

  def test_can_return_time_created_at
    assert_equal Time.parse("2012-02-26 20:56:56 UTC"), transaction.created_at
  end

  def test_can_return_time_updated_at
    assert_equal Time.parse("2012-02-26 20:56:56 UTC"), transaction.updated_at
  end

  def test_we_can_retrieve_invoice_object
    assert_equal Invoice, transaction.invoice.class
  end

  def test_we_can_retrieve_correct_invoice
    assert_equal 12335938, transaction.invoice.merchant_id
  end

end
