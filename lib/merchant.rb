class Merchant
  attr_reader :id, :name, :sales_engine, :revenue

  def initialize(data, sales_engine)
    @id           = data[:id].to_i
    @name         = data[:name]
    @sales_engine = sales_engine
    @created_at   = data[:created_at]
  end

  def created_at
    Time.parse(@created_at)
  end

  def items
    sales_engine.items.find_all_by_merchant_id(id)
  end

  def invoices
    sales_engine.invoices.find_all_by_merchant_id(id)
  end

  def customers
    customer_ids = invoices.map {|invoice| invoice.customer_id}
    customer_ids.map do |customer_id|
      sales_engine.customers.find_by_id(customer_id)
    end.uniq
  end

  def num_items
    items.length
  end

  def num_invoices
    invoices.length
  end

  def revenue
    all_invoices = sales_engine.invoices.find_all_by_merchant_id(merchant_id)
    total = all_invoices.reduce(0) do |cuml_total, invoice|
      cuml_total += invoice.total
    end
    @revenue = BigDecimal.new(total).round(2)
  end








end
