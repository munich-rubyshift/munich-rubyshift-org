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
end
