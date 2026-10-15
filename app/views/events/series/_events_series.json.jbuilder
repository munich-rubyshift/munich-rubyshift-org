json.extract! events_series, :id, :slug, :name, :rubyevents_slug, :description, :kind, :frequency, :ended, :default_country_code, :language_code, :website, :original_website, :twitter, :facebook, :mastodon, :bsky, :github, :linkedin, :meetup, :luma, :guild, :discord
json.url events_series_url(events_series, format: :json)
