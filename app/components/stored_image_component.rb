# Shows a StoredImage. During a Parklife build, rendering it is what copies the
# file into the build (see parklife-rails' ActiveStorage integration), so the
# image only renders when its file is there:
# - Without the storage submodule, a grey box stands in.
# - With the submodule checked out, a missing file is an error.
#
# The images show next to their record's name, so they go without alt text.
class StoredImageComponent < ApplicationComponent
  def initialize(attachment, height:)
    @attachment = attachment
    @height = height
  end

  def render?
    @attachment.attached?
  end

  def call
    if @attachment.service.exist?(@attachment.key)
      helpers.image_tag(@attachment, alt: "", height: @height, class: "stored-image")
    elsif StorageCheckout.checked_out?
      raise StorageCheckout::FileMissing, StorageCheckout.file_missing_message(@attachment.filename)
    else
      tag.span(class: "stored-image stored-image--placeholder", title: StorageCheckout.not_checked_out_message,
        style: "width: #{@height}px; height: #{@height}px")
    end
  end
end
