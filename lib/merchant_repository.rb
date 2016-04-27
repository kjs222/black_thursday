require_relative 'merchant'
require_relative 'csv_io'
require_relative 'find'

class MerchantRepository
  include Find
  include CSV_IO

  attr_accessor :merchants
  attr_reader   :file, :sales_engine, :revenue_array

  def initialize(file=nil, sales_engine)
    @file         = file
    @merchants    = []
    @sales_engine = sales_engine
  end

  def add_new(data, sales_engine)
    merchants << Merchant.new(data, sales_engine)
  end

  def all
    @merchants
  end

  def find_by_id(id)
    find_by_num({:id => id})
  end

  def find_by_name(name)
    find_by_string({:name => name})
  end

  def find_all_by_name(partial)
    find_all_by_string_fragment({:name => partial})
  end

  def generate_revenue_array
    revenue_array = all.map do |merchant|
      {merchant => merchant.revenue}
    end
    @revenue_array = revenue_array.sort_by { |hash| -hash.values[0]}
  end



end
