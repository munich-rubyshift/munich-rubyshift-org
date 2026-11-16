SELECT
  events_events.id AS events_event_id,
  venues_venues.entities_organization_id,
  CAST(substr(events_events.id, 1, 14) || '8' || substr(events_events.id, 16, 4) || '8' || substr(events_events.id, 21) AS TEXT) AS sponsors_sponsor_tier_id,
  CAST(substr(events_events.id, 1, 14) || '8' || substr(events_events.id, 16, 4) || '9' || substr(events_events.id, 21) AS TEXT) AS sponsors_sponsorship_id
FROM events_events
JOIN venues_venues ON venues_venues.id = events_events.venues_venue_id
WHERE venues_venues.entities_organization_id IS NOT NULL AND events_events.status IS NOT 'cancelled'
