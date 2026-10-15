# An image uploaded to content/storage, the storage submodule (see the README).
module StoredImage
  extend ActiveSupport::Concern

  # The image types we take, with the extension each one gets.
  EXTENSIONS = {
    "image/png" => "png",
    "image/jpeg" => "jpg",
    "image/gif" => "gif",
    "image/webp" => "webp",
    "image/svg+xml" => "svg"
  }.freeze
  FORMATS = "PNG, JPEG, GIF, WebP or SVG".freeze
  MAX_SIZE = 2.megabytes

  class_methods do
    def has_stored_image(name)
      has_one_attached name

      validate(if: -> { public_send(name).attached? }) { stored_image_must_be_small_image(name) }
      # `attachment_changes` holds both a new upload and a removal until saved.
      # Avo's delete button removes the attachment directly, which
      # config/initializers/active_storage.rb guards against instead.
      validate(if: -> { attachment_changes.key?(name.to_s) }) { stored_image_must_change_in_checked_out_storage(name) }

      before_save(if: -> { attachment_changes[name.to_s].is_a?(ActiveStorage::Attached::Changes::CreateOne) }) do
        name_stored_image(name)
      end
    end
  end

  private

  def stored_image_must_be_small_image(name)
    blob = public_send(name).blob
    errors.add(name, "must be a #{FORMATS} image") unless EXTENSIONS.key?(blob.content_type)
    errors.add(name, "must be at most #{MAX_SIZE / 1.megabyte} MB") if blob.byte_size > MAX_SIZE
  end

  def stored_image_must_change_in_checked_out_storage(name)
    errors.add(name, "can't change: #{StorageCheckout.not_checked_out_message}") unless StorageCheckout.checked_out?
  end

  # The static site serves the file under its name, which therefore has to be
  # URL-safe. Named after the record, it's also recognizable once downloaded.
  def name_stored_image(name)
    blob = attachment_changes[name.to_s].blob
    blob.filename = "#{slug}-#{name}.#{EXTENSIONS.fetch(blob.content_type)}"
  end
end
