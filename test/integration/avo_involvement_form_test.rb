require "test_helper"

class AvoInvolvementFormTest < ActionDispatch::IntegrationTest
  test "a new involvement starts as a person organizing" do
    get "/avo/resources/events_involvements/new"

    assert_response :success
    assert_select "select[name='events/involvement[entity_type]'] option[selected]", text: "Person"
    assert_select "input[name='events/involvement[role]'][value='Organizer']"
  end

  test "a new involvement leaves the person to pick" do
    get "/avo/resources/events_involvements/new"

    assert_response :success
    assert_select "template[data-type='Entities::Person']" do |template|
      assert_no_match(/selected/, template.inner_html)
    end
  end

  test "an existing involvement keeps its own entity and role" do
    involvement = events_involvements(:two)
    involvement.update_columns(role: "Sponsor")

    get "/avo/resources/events_involvements/#{involvement.to_param}/edit"

    assert_response :success
    assert_select "select[name='events/involvement[entity_type]'] option[selected]", text: "Organization"
    assert_select "input[name='events/involvement[role]'][value='Sponsor']"
  end
end
