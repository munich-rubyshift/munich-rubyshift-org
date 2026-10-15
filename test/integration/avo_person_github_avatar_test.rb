require "test_helper"

class AvoPersonGithubAvatarTest < ActionDispatch::IntegrationTest
  include StorageTestHelper
  include GithubTestHelper

  setup do
    @person = entities_people(:one)
    @person.update_columns(slug: "anna", github_username: "anna")
  end

  test "a person page previews their GitHub avatar next to a mirror button" do
    get "/avo/resources/entities_people/anna"

    assert_response :success
    assert_select "[data-field-id='github_avatar_url'] img[src='#{GithubTestHelper.url}/anna.png?size=460']"
    assert_select "[data-field-id='github_avatar_url'] a[href*='action_id=Avo::Actions::MirrorGithubAvatar']", text: "Mirror"
  end

  test "a person without a GitHub username has nothing to mirror" do
    @person.update_columns(github_username: "")

    get "/avo/resources/entities_people/anna"

    assert_response :success
    assert_select "[data-field-id='github_avatar_url']", count: 0
  end

  test "mirroring makes the GitHub avatar the person's own" do
    check_out_storage

    mirror

    assert_equal "anna-avatar.png", @person.reload.avatar.filename.to_s
    assert_match(/Mirrored .+ avatar from GitHub/, flash[:success][:body])
  end

  test "mirroring without the storage checked out reports an error" do
    mirror

    assert_match(/isn't checked out/, flash[:error][:body])
    assert_not @person.reload.avatar.attached?
  end

  test "mirroring someone GitHub doesn't know reports an error" do
    check_out_storage
    @person.update_columns(github_username: "nobody")

    mirror

    assert_match(/Couldn't download .+ avatar from GitHub: 404/, flash[:error][:body])
    assert_not @person.reload.avatar.attached?
  end

  private

  def mirror
    post "/avo/resources/entities_people/anna/actions",
      params: { action_id: "Avo::Actions::MirrorGithubAvatar", resource_view: "show", fields: { avo_resource_ids: "anna" } },
      as: :turbo_stream
  end
end
