require "test_helper"

class OrganizationPagesTest < ActionDispatch::IntegrationTest
  test "an organization shows its legal name but keeps its internal notes to itself" do
    organization = entities_organizations(:one)
    organization.update_columns(slug: "crewmeister", name: "Crewmeister", legal_name: "Crewmeister GmbH",
      internal_notes: "Acquired by:\n- ATOSS Aloud GmbH")

    get "/organizations/crewmeister"

    assert_response :success
    assert_select "article", text: /Legal name:\s+Crewmeister GmbH\s/
    assert_no_match(/ATOSS/, response.body)

    get "/organizations/crewmeister.json"

    assert_equal "Crewmeister GmbH", response.parsed_body["legal_name"]
    assert_not response.parsed_body.key?("internal_notes")
  end

  test "an organization links to its website" do
    entities_organizations(:one).update_columns(slug: "makandra", website: "https://makandra.de")

    get "/organizations/makandra"

    assert_response :success
    assert_select "article a[href='https://makandra.de'][target='_blank']", text: "https://makandra.de"
  end
end
