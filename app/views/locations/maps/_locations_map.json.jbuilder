json.extract! locations_map, :id, :google_url, :apple_url, :openstreetmap_url, :created_at, :updated_at
json.url locations_map_url(locations_map, format: :json)
