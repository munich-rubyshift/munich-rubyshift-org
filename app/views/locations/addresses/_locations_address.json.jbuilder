json.extract! locations_address, :id, :slug, :street, :zip_code, :locations_city_id, :created_at, :updated_at
json.url locations_address_url(locations_address, format: :json)
