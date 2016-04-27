require_relative 'test_helper'
require_relative '../lib/invoice_item'
require_relative '../lib/sales_engine'

class InvoiceItemTest < Minitest::Test

  attr_reader :se, :invoice_item, :invoice_item_repo

  def setup
      @se = SalesEngine.from_csv({
        :invoice_items => "./data/small_invoice_items.csv"})
      @invoice_item_repo = @se.invoice_item_repo = InvoiceItemRepository.new(nil, se)
      setup_invoice_items
      @invoice_item = invoice_item_repo.invoice_items[1]
  end

  def test_can_return_id
    assert_equal 2, invoice_item.id
  end

  def test_can_return_first_name
    assert_equal 2, invoice_item.invoice_id
  end

  def test_can_return_item_id
    assert_equal 1, invoice_item.item_id
  end

  def test_we_can_get_time_created_at
      assert_equal Time.parse("2016-04-21"), invoice_item.created_at
  end

  def setup_invoice_items
    @se.invoice_item_repo.add_new({:id => 1, :invoice_id => 1, :item_id => 1, :unit_price => "190", :quantity => "1", :created_at => "2016-04-21"}, @se)
    @se.invoice_item_repo.add_new({:id => 2, :invoice_id => 2, :item_id => 1, :unit_price => "190", :quantity => "1", :created_at => "2016-04-21"}, @se)
  end

end
