json.extract! locations_coordinates, :id, :latitude, :longitude, :created_at, :updated_at
json.url locations_coordinates_url(locations_coordinates, format: :json)
