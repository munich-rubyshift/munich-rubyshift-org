json.extract! locations_map, :id, :google_url, :apple_url, :openstreetmap_url
json.url locations_map_url(locations_map, format: :json)
