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

  test "an organization shows where rubyevents.org would have it" do
    entities_organizations(:one).update_columns(slug: "pharos", name: "PHAROS – Die Größte")

    get "/avo/resources/entities_organizations/pharos/edit"

    assert_response :success
    assert_match(/their slug derives from this value: pharos-die-grosste/, response.body)

    get "/avo/resources/entities_organizations/pharos"

    assert_response :success
    assert_select "a[href='https://www.rubyevents.org/organizations/pharos-die-grosste'][target='_blank']"
  end
end
