require "test_helper"

# A blank close date means "the day before the event", which the model
# implies. The form must not store the implied date.
class AvoCFPFormTest < ActionDispatch::IntegrationTest
  setup do
    @cfp = events_cfps(:one)
    @cfp.update_columns(slug: "form-cfp", name: "Call for Proposals", open_date: "2026-11-01", close_date: nil)
    @cfp.event.update_columns(start_date: "2026-11-12", end_date: "2026-11-12")
  end

  test "a CFP form shows the CFP's own close date" do
    get "/avo/resources/events_cfps/#{@cfp.to_param}/edit"

    assert_response :success
    assert_select "[data-field-id='close_date'] input[value='2026-11-11']", count: 0
    assert_select "[data-field-id='close_date'] input[placeholder='2026-11-11']"
  end

  test "a CFP saved without a close date keeps it blank" do
    patch "/avo/resources/events_cfps/#{@cfp.to_param}", params: { "events/cfp" => { name: "Call for Talks", close_date: "" } }

    assert_response :redirect
    assert_equal "Call for Talks", @cfp.reload.name
    assert_nil @cfp.read_attribute(:close_date)
  end

  test "a CFP page shows the implied close date" do
    get "/avo/resources/events_cfps/#{@cfp.to_param}"

    assert_response :success
    assert_select "[data-field-id='close_date']", text: /2026-11-11/
  end
end
