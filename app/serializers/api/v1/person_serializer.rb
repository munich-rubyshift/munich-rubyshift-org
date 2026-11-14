class Api::V1::PersonSerializer < Api::V1::Serializer
  attribute :slug
  attribute :name
  attribute :website
  attribute :github_username
  attribute :twitter_username
  attribute :mastodon
  attribute :bluesky_handle
  attribute :linkedin_username
  attribute :speakerdeck_username
  attribute :meetup_id

  attribute :avatar_url do
    stored_image_path(record.avatar)
  end

  validate :slug_matches_name, on: :rubyevents

  private

  # RubyEvents' SpeakerSlugMatchesName. RubyEvents adds these to I18n's transliterations, for lowercase letters only.
  def slug_matches_name
    slug, name = exported_attributes.values_at("slug", "name")
    parameterized = name.to_s.gsub(/[äöüß]/, "ä" => "ae", "ö" => "oe", "ü" => "ue", "ß" => "ss").parameterize
    errors.add(:slug, "must be the name parameterized the way RubyEvents does: #{parameterized}") unless slug == parameterized
  end
end
