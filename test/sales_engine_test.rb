require './test/test_helper'
require './lib/sales_engine'
# require './test/merchant_repository'
# require './test/item_repository'
# require './test/merchant_repository'
# require './test/invoice_repository'
# require './test/invoice_item_repository'
# require './test/transaction_repository'
# require './test/customer_repository'


class SalesEngineTest < Minitest::Test

  attr_accessor :se

  def setup
    @se = SalesEngine.from_csv({
      :items     => "./data/small_items.csv",
      :merchants => "./data/small_merchants.csv",})
  end

  def test_sales_engine_from_csv_creates_se_object
    assert_equal SalesEngine, se.class
  end

  def test_sales_engine_from_csv_stores_ivar
    assert_equal ({
      :items     => "./data/small_items.csv",
      :merchants => "./data/small_merchants.csv"}), se.files
  end

  def test_merchants_makes_merch_repo_object
    @se.merchants
    refute se.merchant_repo.nil?
  end

  def test_merchants_populates_merch_repo_with_merch_objs
    @se.merchants
    assert_equal Merchant, se.merchant_repo.merchants[0].class
  end

  def test_merchants_populates_merch_repo_with_all
    @se.merchants
    assert_equal 10, se.merchant_repo.merchants.length
  end

  def test_merchants_repo_merch_objects_have_id
    @se.merchants
    assert_equal 12334112, se.merchant_repo.merchants[1].id
  end

  def test_merchants_repo_merch_objs_have_name
    @se.merchants
    assert_equal "Shopin1901", se.merchant_repo.merchants[0].name
  end

  def test_merchants_repo_merch_objs_have_ref_to_se
    @se.merchants
    assert_equal SalesEngine, se.merchant_repo.merchants[9].sales_engine.class
  end

  def test_items_makes_item_repo_object
    @se.items
    refute se.item_repo.nil?
  end

  def test_items_populates_item_repo_with_item_objs
    @se.items
    assert_equal Item, se.item_repo.items[0].class
  end

  def test_items_populates_item_repo_with_all
    @se.items
    assert_equal 19, se.item_repo.items.length
  end

  def test_items_repo_item_objects_have_id
    @se.items
    assert_equal 263395721, se.item_repo.items[1].id
  end

  def test_item_repo_item_objects_have_name
    @se.items
    assert_equal "Glitter scrabble frames", se.item_repo.items[0].name
  end

  def test_item_repo_item_objects_have_desc
    @se.items
    assert_equal true, se.item_repo.items[0].description.include?("Any colour glitter")
  end

  def test_item_repo_item_objects_have_price
    @se.items
    #why does this pass because its really a BD obj
    assert_equal 13.00, se.item_repo.items[0].unit_price
  end

  def test_item_objs_have_price_as_big_decimal
    @se.items
    assert_equal BigDecimal, se.item_repo.items[0].unit_price.class
  end

  def test_item_objs_have_price_as_float_when_transformed
    @se.items
    assert_equal Float, se.item_repo.items[0].unit_price_to_dollars.class
  end

  def test_item_repo_item_objs_have_created_at
    @se.items
    assert_equal Time.parse("2016-01-11 11:51:37 UTC"), se.item_repo.items[1].created_at
  end

  def test_item_objs_have_created_by_as_time_obj
    @se.items
    assert_equal Time, se.item_repo.items[1].created_at.class
  end

  def test_item_repo_item_objs_have_updated_at
    @se.items
    assert_equal Time.parse("2008-04-02 13:48:57 UTC"), se.item_repo.items[1].updated_at
  end

  def test_item_objects_have_updated_at_as_time_obj
    @se.items
    assert_equal Time, se.item_repo.items[1].updated_at.class
  end

  def test_item_objects_have_ref_to_se
    @se.items
    assert_equal SalesEngine, se.item_repo.items[9].sales_engine.class
  end


end
