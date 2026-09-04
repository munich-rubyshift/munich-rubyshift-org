json.extract! events_cfp, :id, :slug, :name, :external_url, :open_date, :close_date, :events_event_id
json.url events_cfp_url(events_cfp, format: :json)
