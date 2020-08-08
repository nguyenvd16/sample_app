class Micropost < ApplicationRecord
  MICROPOST_PARAMS = %i(content picture).freeze

  belongs_to :user
  has_one_attached :image
  scope :microposts, ->{order created_at: :desc}

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: Settings.micropost.content.length_max }
  validates :image, content_type: { in: Settings.micropost.image.content_type,
    message: t(microposts.image.valid_image_format) },
    size: { less_than: Settings.micropost.image.megabytes,
    message: t(microposts.image.valid_image_size) }

  def display_image
    image.variant(resize_to_limit: [Settings.micropost.image.resize_to_limit,
      Settings.micropost.image.resize_to_limit])
  end
end
