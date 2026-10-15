# An image in the storage submodule.
module StoredImage
  extend ActiveSupport::Concern
  include StoredFile

  # No SVG: opened on its own, an SVG runs its scripts with our site as their origin.
  CONTENT_TYPES = %w[image/png image/jpeg image/gif image/webp].freeze
  FORMATS = "PNG, JPEG, GIF or WebP".freeze
  MAX_SIZE = 2.megabytes

  class_methods do
    def has_stored_image(name)
      has_stored_file name

      validate(if: -> { public_send(name).attached? }) { stored_image_must_be_small_image(name) }
    end
  end

  private

  def stored_image_must_be_small_image(name)
    blob = public_send(name).blob
    errors.add(name, "must be a #{FORMATS} image") unless CONTENT_TYPES.include?(blob.content_type)
    errors.add(name, "must be at most #{MAX_SIZE / 1.megabyte} MB") if blob.byte_size > MAX_SIZE
  end
end
