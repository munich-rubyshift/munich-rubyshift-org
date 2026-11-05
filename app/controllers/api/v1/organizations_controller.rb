class Api::V1::OrganizationsController < Api::V1::ApplicationController
  def index
    organizations = Entities::Organization.with_attached_logo.order(:slug)
    render_document organizations.map { |organization| Api::V1::OrganizationSerializer.new(organization).resource }
  end
end
