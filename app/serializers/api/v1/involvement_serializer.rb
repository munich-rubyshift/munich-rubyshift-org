class Api::V1::InvolvementSerializer < Api::V1::Serializer
  attribute :role

  private

  def relationships
    { entity: { data: identify(record.entity) } }
  end
end
