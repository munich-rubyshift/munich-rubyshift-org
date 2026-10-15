require "test_helper"

class StorageCheckoutTest < ActiveSupport::TestCase
  include StorageTestHelper

  test "storage counts as checked out once it holds a git checkout" do
    assert_not StorageCheckout.checked_out?

    check_out_storage

    assert StorageCheckout.checked_out?
  end

  test "an attachment can't be removed while the storage isn't checked out" do
    check_out_storage
    attachment = attach_file
    FileUtils.rm(File.join(ActiveStorage::Blob.service.root, ".git"))

    error = assert_raises(StorageCheckout::NotCheckedOut) { attachment.destroy! }

    assert_match(/run `git submodule update --init .+` first/, error.message)
    assert ActiveStorage::Attachment.exists?(attachment.id)
  end

  test "an attachment can be removed while the storage is checked out" do
    check_out_storage
    attachment = attach_file

    attachment.destroy!

    assert_not ActiveStorage::Attachment.exists?(attachment.id)
  end

  private

  def attach_file
    blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new("content"), filename: "file.txt")
    ActiveStorage::Attachment.create!(name: "file", record: talks_talks(:one), blob: blob)
  end
end
