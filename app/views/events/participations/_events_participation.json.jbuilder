json.extract! events_participation, :id, :entities_person_id, :events_event_id, :attended_as
json.url events_participation_url(events_participation, format: :json)
