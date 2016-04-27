require_relative 'test_helper'
require_relative '../lib/item'
require_relative '../lib/sales_engine'

class ItemTest < Minitest::Test

  attr_reader :se, :item, :item_repo

  def setup
      @se = SalesEngine.from_csv({
        :items         => "./data/small_items.csv",
        :merchants     => "./data/small_merchants.csv",})
        @se.merchant_repo = MerchantRepository.new(nil, se)
        @item_repo = @se.item_repo = ItemRepository.new(nil, se)
        @se.merchant_repo.add_new({:id => 1, :name => "Merch1", :created_at => "2016-04-22"}, @se)
        @se.item_repo.add_new({:id => 1, :name => "Item1", :unit_price => 200, :merchant_id => 1}, @se)
  end

  def test_can_return_id
    assert_equal 1, se.item_repo.items[0].id
  end

  def test_can_return_name
    assert_equal "Item1", se.item_repo.items[0].name
  end

  def test_can_return_unit_price_to_dollars
    assert_equal 2.0, se.item_repo.items[0].unit_price_to_dollars
  end

  def test_we_can_retrieve_merchant_objects
    item = @item_repo.items[0]
    assert_equal Merchant, se.item_repo.items[0].merchant.class
  end

  def test_we_can_retrieve_correct_merchant
    assert_equal "Merch1", se.item_repo.items[0].merchant.name
  end

end
