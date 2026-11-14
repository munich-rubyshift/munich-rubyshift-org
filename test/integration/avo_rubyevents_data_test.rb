require "test_helper"

class AvoRubyeventsDataTest < ActionDispatch::IntegrationTest
  setup do
    @map = locations_maps(:one)
  end

  test "RubyEvents data is saved from JSON and edited as formatted JSON" do
    patch "/avo/resources/locations_maps/#{@map.id}", params: { "locations/map" => { rubyevents_data: '{"google_url":null}' } }

    assert_response :redirect
    assert_equal({ "google_url" => nil }, @map.reload.rubyevents_data)

    get "/avo/resources/locations_maps/#{@map.id}/edit"

    assert_select "[data-field-id='rubyevents_data'] textarea", text: "{\n  \"google_url\": null\n}"
  end

  test "invalid JSON is kept to fix it" do
    patch "/avo/resources/locations_maps/#{@map.id}", params: { "locations/map" => { rubyevents_data: '{"google_url":' } }

    assert_response :unprocessable_content
    assert_select "[data-field-id='rubyevents_data']", text: /must be a JSON object/
    assert_select "[data-field-id='rubyevents_data'] textarea", text: '{"google_url":'
    assert_nil @map.reload.rubyevents_data
  end

  test "an emptied field removes the RubyEvents data" do
    @map.update!(rubyevents_data: { "google_url" => nil })

    patch "/avo/resources/locations_maps/#{@map.id}", params: { "locations/map" => { rubyevents_data: "" } }

    assert_response :redirect
    assert_nil @map.reload.rubyevents_data
  end
end
