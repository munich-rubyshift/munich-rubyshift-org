json.extract! locations_address, :id, :slug, :street, :zip_code, :locations_city_id
json.url locations_address_url(locations_address, format: :json)
