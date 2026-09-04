json.extract! locations_city, :id, :slug, :name, :rubyevents_slug, :state_code, :country_code, :locations_coordinates_id
json.url locations_city_url(locations_city, format: :json)
