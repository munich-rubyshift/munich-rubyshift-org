SELECT id, description, events_event_id, level, name, rubyevents_data, slug
FROM sponsors_sponsor_tiers
UNION ALL
SELECT sponsors_sponsor_tier_id, NULL, events_event_id, NULL, 'Meetup Host', NULL, 'meetup-host'
FROM events_meetup_hosts
