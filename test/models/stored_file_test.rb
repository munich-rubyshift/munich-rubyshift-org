require "test_helper"

# StoredFile, through a person's avatar.
class StoredFileTest < ActiveSupport::TestCase
  include StorageTestHelper

  test "names the file after its record" do
    check_out_storage

    person = Entities::Person.create!(name: "Anna Smith", avatar: image_upload(filename: "Mein Foto (1).png"))

    assert_equal "anna-smith-avatar.png", person.reload.avatar.filename.to_s
  end

  test "names the file by its type" do
    check_out_storage

    person = Entities::Person.create!(name: "Anna", avatar: image_upload("image.gif", filename: "photo.png"))

    assert_equal "anna-avatar.gif", person.reload.avatar.filename.to_s
  end

  test "can't be added while the storage isn't checked out" do
    person = Entities::Person.new(name: "Anna", avatar: image_upload)

    assert_not person.valid?
    assert_match(/can't change: .+ isn't checked out, run `git submodule update --init .+` first/, person.errors[:avatar].first)
  end

  test "can't be removed while the storage isn't checked out" do
    check_out_storage
    person = Entities::Person.create!(name: "Anna", avatar: image_upload)
    FileUtils.rm(File.join(ActiveStorage::Blob.service.root, ".git"))

    person.avatar = nil

    assert_not person.valid?
    assert_match(/isn't checked out/, person.errors[:avatar].first)
  end

  test "can be removed while the storage is checked out" do
    check_out_storage
    person = Entities::Person.create!(name: "Anna", avatar: image_upload)

    person.update!(avatar: nil)

    assert_not person.reload.avatar.attached?
  end

  test "can be replaced while the storage is checked out" do
    check_out_storage
    person = Entities::Person.create!(name: "Anna", avatar: image_upload)

    person.update!(avatar: image_upload("image.gif"))

    assert_equal "anna-avatar.gif", person.reload.avatar.filename.to_s
  end

  test "leaves the record editable without the storage" do
    check_out_storage
    person = Entities::Person.create!(name: "Anna", avatar: image_upload)
    FileUtils.rm(File.join(ActiveStorage::Blob.service.root, ".git"))

    assert person.update(website: "https://example.com")
  end
end
