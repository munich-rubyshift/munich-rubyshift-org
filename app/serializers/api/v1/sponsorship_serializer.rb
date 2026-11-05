class Api::V1::SponsorshipSerializer < Api::V1::Serializer
  private

  def attributes
    record.slice(:name, :rubyevents_slug, :badge, :description)
  end

  def relationships
    { organization: { data: identify(record.organization) } }
  end
end
