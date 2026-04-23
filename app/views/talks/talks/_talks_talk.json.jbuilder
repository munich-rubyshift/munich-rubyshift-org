json.extract! talks_talk, :id, :slug, :title, :rubyevents_slug, :events_event_id, :description, :raw_title, :original_title, :slides_url, :external_id, :kind, :status, :date, :time, :published_at, :announced_at, :removed, :location, :video_provider, :video_id, :external_player, :external_player_url, :track, :language, :created_at, :updated_at
json.url talks_talk_url(talks_talk, format: :json)
