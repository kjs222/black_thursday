require_relative 'customer'
require_relative 'find'
require_relative 'csv_io'

class CustomerRepository
  include Find
  include CSV_IO
  attr_accessor :customers
  attr_reader :file, :sales_engine, :first_name, :last_name

  def initialize(file=nil, sales_engine)
    @file = file
    @customers = []
    @sales_engine = sales_engine
  end

  def add_new(data, sales_engine)
    customers << Customer.new(data, sales_engine)
  end

  def all
    @customers
  end

  def find_by_id(id)
    find_by_num({:id => id})
  end

  def find_all_by_first_name(first_name) #changed to fragment
    find_all_by_string_fragment({:first_name => first_name})
  end

  def find_all_by_last_name(last_name) #changed to fragment
    find_all_by_string_fragment({:last_name => last_name})
  end

end
