json.extract! events_series, :id, :slug, :name, :rubyevents_slug, :description, :kind, :frequency, :ended, :default_country_code, :language_code, :website, :twitter_username, :facebook, :mastodon, :bluesky_handle, :github, :linkedin, :meetup, :luma, :guild, :discord
json.url events_series_url(events_series, format: :json)
