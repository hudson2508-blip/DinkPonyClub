# frozen_string_literal: true

class GalleryPhoto < ApplicationRecord
  belongs_to :season
  belongs_to :player
  has_one_attached :image

  validates :caption, length: { maximum: 240 }
  validates :image, presence: true
  validate :supported_image

  private

  def supported_image
    return unless image.attached?

    unless image.blob.content_type.in?(%w[image/jpeg image/png image/webp image/heic image/heif])
      errors.add(:image, 'must be a JPEG, PNG, WebP or HEIC image')
    end
    errors.add(:image, 'must be smaller than 15 MB') if image.blob.byte_size > 15.megabytes
  end
end
