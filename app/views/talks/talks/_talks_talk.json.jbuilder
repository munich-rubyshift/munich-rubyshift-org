json.extract! talks_talk, :id, :slug, :title, :rubyevents_slug, :events_event_id, :description, :slides_url, :kind, :announced_at, :language
json.url talks_talk_url(talks_talk, format: :json)
