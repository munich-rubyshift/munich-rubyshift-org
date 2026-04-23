json.extract! venues_venue, :id, :slug, :name, :rubyevents_slug, :description, :url, :instructions, :accessibility_wheelchair, :accessibility_elevators, :accessibility_restrooms, :accessibility_notes, :nearby_public_transport, :nearby_parking, :created_at, :updated_at
json.url venues_venue_url(venues_venue, format: :json)
