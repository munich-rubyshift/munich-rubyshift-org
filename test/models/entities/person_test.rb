require "test_helper"

class Entities::PersonTest < ActiveSupport::TestCase
  test "links each handle to its profile" do
    person = Entities::Person.new(
      github: "triskweline", twitter: "triskweline", bluesky: "hschne",
      linkedin: "triskweline", speakerdeck: "triskweline", mastodon: "https://ruby.social/@hschne"
    )

    assert_equal "https://github.com/triskweline", person.github_url
    assert_equal "https://x.com/triskweline", person.twitter_url
    assert_equal "https://bsky.app/profile/hschne", person.bluesky_url
    assert_equal "https://www.linkedin.com/in/triskweline", person.linkedin_url
    assert_equal "https://speakerdeck.com/triskweline", person.speakerdeck_url
    assert_equal "https://ruby.social/@hschne", person.mastodon_url
  end

  test "has no profile link without a handle" do
    person = Entities::Person.new(github: "", twitter: "", bluesky: "", linkedin: "", speakerdeck: "", mastodon: "")

    assert_nil person.github_url
    assert_nil person.twitter_url
    assert_nil person.bluesky_url
    assert_nil person.linkedin_url
    assert_nil person.speakerdeck_url
    assert_nil person.mastodon_url
  end
end
