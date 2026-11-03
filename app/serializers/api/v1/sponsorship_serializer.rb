class Api::V1::SponsorshipSerializer < Api::V1::Serializer
  private

  def attributes
    record.slice(:name, :rubyevents_slug, :badge, :description, :website, :logo_url)
  end

  def relationships
    { organization: { data: identify(record.organization) } }
  end
end
