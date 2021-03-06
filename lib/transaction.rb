class Transaction
  attr_reader :id, :invoice_id, :credit_card_number,
              :credit_card_expiration_date, :result, :sales_engine

  def initialize(data, sales_engine)
    @id           = data[:id].to_i
    @invoice_id   = data[:invoice_id].to_i
    @credit_card_number = data[:credit_card_number].to_i
    @credit_card_expiration_date = data[:credit_card_expiration_date]
    @result       = data[:result]
    @created_at   = data[:created_at]
    @updated_at   = data[:updated_at]
    @sales_engine = sales_engine
  end

  def created_at
    Time.parse(@created_at)
  end

  def updated_at
    Time.parse(@updated_at)
  end

  def invoice
    sales_engine.invoices.find_by_id(invoice_id)
  end

end
