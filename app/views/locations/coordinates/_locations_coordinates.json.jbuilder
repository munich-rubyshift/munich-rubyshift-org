json.extract! locations_coordinates, :id, :latitude, :longitude
json.url locations_coordinates_url(locations_coordinates, format: :json)
