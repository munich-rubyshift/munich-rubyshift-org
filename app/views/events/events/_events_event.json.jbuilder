json.extract! events_event, :id, :slug, :title, :rubyevents_slug, :venues_venue_id, :description, :kind, :attendance_mode, :status, :start_date, :start_time, :end_date, :end_time, :announced_on, :date_precision, :website, :twitter_username, :mastodon, :github, :meetup, :luma, :tickets_url
json.url events_event_url(events_event, format: :json)
