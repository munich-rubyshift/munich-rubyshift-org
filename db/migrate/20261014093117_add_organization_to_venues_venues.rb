class AddOrganizationToVenuesVenues < ActiveRecord::Migration[8.1]
  def change
    add_reference :venues_venues, :entities_organization, foreign_key: true, type: :string
  end
end
