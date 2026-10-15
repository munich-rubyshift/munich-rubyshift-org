# A file uploaded to content/storage, the storage submodule (see the README).
# Which files it takes is up to the including concern, like StoredImage.
module StoredFile
  extend ActiveSupport::Concern

  class_methods do
    def has_stored_file(name)
      has_one_attached name

      # Runs when a save adds, replaces or removes the file. Avo's delete button
      # destroys the attachment without saving the record, so
      # config/initializers/active_storage.rb guards that case instead.
      validate(if: -> { attachment_changes.key?(name.to_s) }) { stored_file_must_change_in_checked_out_storage(name) }

      before_save(if: -> { attachment_changes[name.to_s].is_a?(ActiveStorage::Attached::Changes::CreateOne) }) do
        name_stored_file(name)
      end
    end
  end

  private

  def stored_file_must_change_in_checked_out_storage(name)
    errors.add(name, "can't change: #{StorageCheckout.not_checked_out_message}") unless StorageCheckout.checked_out?
  end

  def name_stored_file(name)
    blob = attachment_changes[name.to_s].blob
    extension = Marcel::Magic.new(blob.content_type).extensions.first
    blob.filename = "#{slug}-#{name}.#{extension}"
  end
end
