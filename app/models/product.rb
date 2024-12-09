class Product < ApplicationRecord
  validates :name, presence: true, length: { maximum: 255 }
  validates :price, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :sku, presence: true, uniqueness: true, length: { maximum: 50 }

  has_many :publish_task_handlers

  def available_marketplaces
    [
      ::MarketplaceClients::A,
      ::MarketplaceClients::B,
    ]
  end
end
