require "test_helper"

class PersonPagesTest < ActionDispatch::IntegrationTest
  include StorageTestHelper

  test "a person page shows their avatar" do
    check_out_storage
    Entities::Person.create!(name: "Anna", avatar: image_upload)

    get "/people/anna"

    assert_select "article h2 img.stored-image[src*='anna-avatar.png']"
  end
end
