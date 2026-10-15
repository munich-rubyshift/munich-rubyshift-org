require "test_helper"
require "view_component/test_helpers"

class Entities::PersonComponentTest < ActionView::TestCase
  include ViewComponent::TestHelpers

  # Parklife crawls every relative link, so a bare handle in an href fails the
  # static build with a routing error.
  test "links to the website and social media profiles with absolute URLs" do
    person = Entities::Person.create!(
      name: "Henning", website: "https://triskweline.de/", github_username: "triskweline", twitter_username: "triskweline", bluesky_handle: "hschne",
      linkedin_username: "triskweline", speakerdeck_username: "triskweline", mastodon: "https://ruby.social/@hschne"
    )

    render_inline(Entities::PersonComponent.new(person))

    assert_equal %w[
      https://github.com/triskweline
      https://triskweline.de/
      https://x.com/triskweline
      https://ruby.social/@hschne
      https://bsky.app/profile/hschne
      https://www.linkedin.com/in/triskweline
      https://speakerdeck.com/triskweline
    ], page.all("a[target=_blank]").map { |link| link[:href] }
  end
end
