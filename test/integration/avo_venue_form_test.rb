require "test_helper"

class AvoVenueFormTest < ActionDispatch::IntegrationTest
  test "the organization dropdown lists organizations alphabetically, ignoring case" do
    entities_organizations(:one).update_columns(name: "makandra GmbH")
    entities_organizations(:two).update_columns(name: "Freeletics GmbH")
    Entities::Organization.create!(name: "codecentric AG")

    get "/avo/resources/venues_venues/new"

    assert_response :success
    options = css_select("select[name='venues/venue[entities_organization_id]'] option[value]:not([value=''])").map(&:text)
    assert_equal [ "codecentric AG", "Freeletics GmbH", "makandra GmbH" ], options
  end
end
