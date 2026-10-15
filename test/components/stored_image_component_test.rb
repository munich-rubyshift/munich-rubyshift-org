require "test_helper"
require "view_component/test_helpers"

class StoredImageComponentTest < ActionView::TestCase
  include ViewComponent::TestHelpers
  include StorageTestHelper

  test "shows the image" do
    person = person_with_avatar

    render_inline(StoredImageComponent.new(person.avatar, height: 64))

    assert_selector "img.stored-image[height='64'][src*='anna-avatar.png']"
  end

  test "stands in a box while the storage isn't checked out" do
    person = person_with_avatar
    root = ActiveStorage::Blob.service.root
    FileUtils.rm_rf(Dir.children(root).map { |child| File.join(root, child) })

    render_inline(StoredImageComponent.new(person.avatar, height: 64))

    assert_no_selector "img"
    assert_match(/run `git submodule update --init .+` first/, page.find(".stored-image--placeholder")[:title])
  end

  test "fails when the checked-out storage lacks the image" do
    person = person_with_avatar
    FileUtils.rm(ActiveStorage::Blob.service.path_for(person.avatar.key))

    error = assert_raises(StorageCheckout::FileMissing) do
      render_inline(StoredImageComponent.new(person.avatar, height: 64))
    end
    assert_match(/anna-avatar.png is missing from .+, run `git submodule update`/, error.message)
  end

  test "shows nothing without an image" do
    render_inline(StoredImageComponent.new(Entities::Person.new.avatar, height: 64))

    assert_no_selector ".stored-image"
  end

  private

  def person_with_avatar
    check_out_storage
    Entities::Person.create!(name: "Anna", avatar: image_upload)
  end
end
