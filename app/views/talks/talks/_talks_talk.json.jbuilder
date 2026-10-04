json.extract! talks_talk, :id, :slug, :title, :rubyevents_slug, :events_event_id, :position, :description, :slides_url, :kind, :announced_on, :language_code
json.url talks_talk_url(talks_talk, format: :json)
