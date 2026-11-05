class Api::V1::VenueSerializer < Api::V1::Serializer
  private

  def attributes
    record.slice(:name, :rubyevents_slug, :website, :description, :instructions, :accessibility_wheelchair,
      :accessibility_elevators, :accessibility_restrooms, :accessibility_notes, :nearby_public_transport,
      :nearby_parking).merge(map: record.map&.slice(:google_url, :apple_url, :openstreetmap_url))
  end

  def relationships
    { address: { data: identify(record.address) }, organization: { data: identify(record.organization) } }
  end
end
