require "test_helper"

class AvoOrganizationPageTest < ActionDispatch::IntegrationTest
  test "an organization page lists its venues" do
    organization = entities_organizations(:one)
    organization.update_columns(slug: "freeletics")
    venues_venues(:one).update_columns(entities_organization_id: organization.id, name: "Freeletics Office")
    venues_venues(:two).update_columns(entities_organization_id: organization.id, name: "Freeletics Office 2")

    get "/avo/resources/entities_organizations/freeletics"

    assert_response :success
    frame = css_select("turbo-frame#has_many_field_show_venues").first
    assert frame, "expected a venues panel"

    get frame["src"]

    assert_response :success
    assert_equal [ "Freeletics Office", "Freeletics Office 2" ], css_select("td[data-field-id='name']").map { |cell| cell.text.squish }.sort
  end
end
