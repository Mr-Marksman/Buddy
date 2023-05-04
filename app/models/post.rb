class Post < ApplicationRecord
  belongs_to :user
  has_many :comments
  has_many :post_hashtags
  has_many :hashtags, through: :post_hashtags
  has_one_attached :image

  validates :description, :title, presence: true
end
