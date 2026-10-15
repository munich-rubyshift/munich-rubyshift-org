require "test_helper"

# StoredImage, through a person's avatar.
class StoredImageTest < ActiveSupport::TestCase
  include StorageTestHelper

  test "takes a PNG" do
    check_out_storage

    assert Entities::Person.new(name: "Anna", avatar: image_upload).valid?
  end

  test "rejects an SVG" do
    check_out_storage
    person = Entities::Person.new(name: "Anna", avatar: image_upload("image.svg"))

    assert_not person.valid?
    assert_includes person.errors[:avatar], "must be a PNG, JPEG, GIF or WebP image"
  end

  test "rejects a file that isn't an image" do
    check_out_storage
    person = Entities::Person.new(name: "Anna", avatar: { io: StringIO.new("Just some notes"), filename: "notes.txt" })

    assert_not person.valid?
    assert_includes person.errors[:avatar], "must be a PNG, JPEG, GIF or WebP image"
  end

  test "rejects an image over 2 MB" do
    check_out_storage
    person = Entities::Person.new(name: "Anna", avatar: image_upload)
    person.avatar.blob.byte_size = 2.megabytes + 1

    assert_not person.valid?
    assert_includes person.errors[:avatar], "must be at most 2 MB"
  end
end
