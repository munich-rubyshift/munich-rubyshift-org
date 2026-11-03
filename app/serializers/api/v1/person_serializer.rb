class Api::V1::PersonSerializer < Api::V1::Serializer
  private

  def attributes
    record.slice(:name, :rubyevents_slug, :website, :github_username, :twitter_username, :mastodon, :bluesky_handle,
      :linkedin_username, :speakerdeck_username, :meetup_id).merge(avatar_url: stored_image_path(record.avatar))
  end
end
