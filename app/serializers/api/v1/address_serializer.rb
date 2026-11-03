class Api::V1::AddressSerializer < Api::V1::Serializer
  private

  def attributes
    record.slice(:street, :zip_code).merge(coordinates: coordinates(record.coordinates))
  end

  def relationships
    { city: { data: identify(record.city) } }
  end
end
