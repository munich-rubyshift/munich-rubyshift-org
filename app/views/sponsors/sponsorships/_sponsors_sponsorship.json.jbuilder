json.extract! sponsors_sponsorship, :id, :slug, :name, :rubyevents_slug, :entities_organization_id, :sponsors_sponsor_tier_id, :description, :website, :logo_url, :badge, :created_at, :updated_at
json.url sponsors_sponsorship_url(sponsors_sponsorship, format: :json)
