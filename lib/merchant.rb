class Merchant

  attr_reader :id, :name

  def initialize(args)
    @id = args[:id].to_i
    @name = args[:name]
  end

end
