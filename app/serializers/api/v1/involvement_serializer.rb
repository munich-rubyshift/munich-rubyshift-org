class Api::V1::InvolvementSerializer < Api::V1::Serializer
  # Involvements have no slug, so their id joins the slugs around them.
  def identifier
    { type: "involvements", id: [ record.event.slug, record.role&.parameterize, record.entity.slug ].compact_blank.join("-") }
  end

  private

  def attributes
    { role: record.role }
  end

  def relationships
    { entity: { data: identify(record.entity) } }
  end
end
