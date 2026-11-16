SELECT id, badge, entities_organization_id, rubyevents_data, sponsors_sponsor_tier_id
FROM sponsors_sponsorships
UNION ALL
SELECT sponsors_sponsorship_id, NULL, entities_organization_id, NULL, sponsors_sponsor_tier_id
FROM events_meetup_hosts
