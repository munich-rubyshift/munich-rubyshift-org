class Api::V1::CitySerializer < Api::V1::Serializer
  attribute :slug
  attribute :name
  attribute :state_code
  attribute :country_code

  attribute :coordinates do
    coordinates(record.coordinates)
  end
end
