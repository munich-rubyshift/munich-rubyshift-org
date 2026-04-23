json.extract! events_participation, :id, :entities_person_id, :events_event_id, :attended_as, :created_at, :updated_at
json.url events_participation_url(events_participation, format: :json)
