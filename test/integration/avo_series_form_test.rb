require "test_helper"

class AvoSeriesFormTest < ActionDispatch::IntegrationTest
  test "a series may leave its language blank" do
    get "/avo/resources/events_series/new"

    assert_response :success
    assert_select "select[name='events/series[language_code]'] option[value='']"
  end
end
