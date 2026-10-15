require "test_helper"

class AvoPersonFormTest < ActionDispatch::IntegrationTest
  include StorageTestHelper

  setup do
    @person = entities_people(:one)
    @person.update_columns(slug: "anna")
  end

  test "uploading an avatar attaches it to the person" do
    check_out_storage

    patch "/avo/resources/entities_people/anna", params: { "entities/person" => { avatar: image_upload } }

    assert_response :redirect
    assert_equal "anna-avatar.png", @person.reload.avatar.filename.to_s
  end

  test "uploading an avatar without the storage checked out reports an error" do
    patch "/avo/resources/entities_people/anna", params: { "entities/person" => { avatar: image_upload } }

    assert_match(/isn't checked out/, response.body)
    assert_not @person.reload.avatar.attached?
  end

  test "a person page shows their avatar" do
    check_out_storage
    @person.update!(avatar: image_upload)

    get "/avo/resources/entities_people/anna"

    assert_response :success
    assert_select "[data-field-id='avatar'] img"
  end

  test "removing an avatar takes it off the person" do
    check_out_storage
    @person.update!(avatar: image_upload)

    delete "/avo/resources/entities_people/anna/active_storage_attachments/avatar/#{@person.avatar.id}", as: :turbo_stream

    assert_response :success
    assert_not @person.reload.avatar.attached?
  end

  test "removing an avatar without the storage checked out fails" do
    check_out_storage
    @person.update!(avatar: image_upload)
    FileUtils.rm(File.join(ActiveStorage::Blob.service.root, ".git"))

    assert_raises(StorageCheckout::NotCheckedOut) do
      delete "/avo/resources/entities_people/anna/active_storage_attachments/avatar/#{@person.avatar.id}", as: :turbo_stream
    end
    assert @person.reload.avatar.attached?
  end
end
