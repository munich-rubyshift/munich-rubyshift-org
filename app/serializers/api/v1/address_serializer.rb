class Api::V1::AddressSerializer < Api::V1::Serializer
  attribute :slug
  attribute :street
  attribute :zip_code

  attribute :coordinates do
    coordinates(record.coordinates)
  end

  private

  def relationships
    { city: { data: identify(record.city) } }
  end
end
