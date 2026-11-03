class Api::V1::SponsorshipSerializer < Api::V1::Serializer
  attribute :badge

  private

  def relationships
    { organization: { data: identify(record.organization) } }
  end
end
