require "test_helper"

class Entities::PersonGithubAvatarTest < ActiveSupport::TestCase
  include StorageTestHelper
  include GithubTestHelper

  setup do
    stub_github_avatar("anna")
    stub_unknown_github_user("nobody")
  end

  test "mirrors the avatar from GitHub" do
    check_out_storage
    person = Entities::Person.create!(name: "Anna Smith", github_username: "anna")

    assert person.mirror_github_avatar!

    assert_equal "anna-smith-avatar.png", person.reload.avatar.filename.to_s
    assert_equal file_fixture("image.png").binread, person.avatar.download
  end

  test "doesn't mirror while the storage isn't checked out" do
    person = Entities::Person.create!(name: "Anna Smith", github_username: "anna")

    assert_not person.mirror_github_avatar!

    assert_match(/isn't checked out/, person.errors[:avatar].first)
    assert_not person.reload.avatar.attached?
  end

  test "fails for someone GitHub doesn't know" do
    check_out_storage
    person = Entities::Person.create!(name: "Nobody", github_username: "nobody")

    assert_raises(OpenURI::HTTPError) { person.mirror_github_avatar! }
  end
end
