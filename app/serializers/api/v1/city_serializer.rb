class Api::V1::CitySerializer < Api::V1::Serializer
  private

  def attributes
    record.slice(:name, :rubyevents_slug, :state_code, :country_code).merge(coordinates: coordinates(record.coordinates))
  end
end
