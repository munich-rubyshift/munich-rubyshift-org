class Api::V1::OrganizationsController < Api::V1::ApplicationController
  def index
    organizations = Entities::Organization.with_attached_logo.order(:slug)
    render_list organizations, serializer: Api::V1::OrganizationSerializer
  end
end
