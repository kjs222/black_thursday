require_relative 'merchant_repository'
require_relative 'item_repository'
require_relative 'merchant_repository'
require_relative 'invoice_repository'
require_relative 'invoice_item_repository'
require_relative 'transaction_repository'
require_relative 'customer_repository'
require 'bigdecimal'

class SalesEngine

  attr_reader :files, :merchant_repo, :item_repo

  def initialize(files)
    @files = files
    @merchant_repo = nil
    @item_repo = nil
  end

  def self.from_csv(files)
    SalesEngine.new(files)
  end

  def merchants
    if @merchant_repo != nil
      @merchant_repo
    else
      @merchant_repo = MerchantRepository.new
      generate_instances(data(files[:merchants]), @merchant_repo, Merchant)
    end
  end

  def items
    if @item_repo != nil
      @item_repo
    else
      @item_repo = ItemRepository.new
      generate_instances(data(files[:items]), @item_repo, Item)
    end
  end

  def data(file)
    CSV.open(file, headers: true, header_converters: :symbol)
  end

  def generate_instances(data, repo, klass)
    data.each do |row|
      repo << klass.new(row, self)
    end
    repo
  end

end
