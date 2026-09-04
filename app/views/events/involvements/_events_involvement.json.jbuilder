json.extract! events_involvement, :id, :role, :entity_id, :entity_type, :events_event_id
json.url events_involvement_url(events_involvement, format: :json)
