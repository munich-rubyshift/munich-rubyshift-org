require "test_helper"

class VenuePagesTest < ActionDispatch::IntegrationTest
  test "a venue links to the organization it belongs to" do
    organization = entities_organizations(:one)
    organization.update_columns(name: "Freeletics GmbH", slug: "freeletics")
    venue = venues_venues(:one)
    venue.update_columns(slug: "freeletics-office", entities_organization_id: organization.id)

    get "/venues/freeletics-office"

    assert_response :success
    assert_select "article a[href='/organizations/freeletics']", text: "Freeletics GmbH"
  end

  test "a public place names no organization" do
    venues_venues(:one).update_columns(slug: "augustiner-keller", entities_organization_id: nil)

    get "/venues/augustiner-keller"

    assert_response :success
    assert_no_match(/Organization:/, response.body)
  end
end
