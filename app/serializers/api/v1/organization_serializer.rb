class Api::V1::OrganizationSerializer < Api::V1::Serializer
  attribute :slug
  attribute :name
  attribute :legal_name
  attribute :website

  attribute :logo_url do
    stored_image_path(record.logo)
  end
end
