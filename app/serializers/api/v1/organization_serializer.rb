class Api::V1::OrganizationSerializer < Api::V1::Serializer
  private

  def attributes
    record.slice(:name, :legal_name, :rubyevents_slug, :website).merge(logo_url: stored_image_path(record.logo))
  end
end
