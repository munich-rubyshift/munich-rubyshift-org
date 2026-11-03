class Api::V1::VenueSerializer < Api::V1::Serializer
  attribute :slug
  attribute :name
  attribute :website
  attribute :description
  attribute :instructions
  attribute :accessibility_wheelchair
  attribute :accessibility_elevators
  attribute :accessibility_restrooms
  attribute :accessibility_notes
  attribute :nearby_public_transport
  attribute :nearby_parking

  attribute :map do
    record.map&.slice(:google_url, :apple_url, :openstreetmap_url)
  end

  private

  def relationships
    { address: { data: identify(record.address) }, organization: { data: identify(record.organization) } }
  end
end
