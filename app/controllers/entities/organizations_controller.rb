class Entities::OrganizationsController < ApplicationController
  def index
    @entities_organizations = Entities::Organization.with_attached_logo
  end

  def show
    @entities_organization = Entities::Organization.find(params.expect(:id))
  end
end
