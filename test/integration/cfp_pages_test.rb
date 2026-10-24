require "test_helper"

class CFPPagesTest < ActionDispatch::IntegrationTest
  setup do
    @cfp = events_cfps(:one)
    @cfp.update_columns(slug: "meetup-2026-11-12-call-for-proposals", close_date: nil)
    @cfp.event.update_columns(start_date: "2026-11-12", end_date: "2026-11-12")
  end

  test "a CFP without a close date of its own closes the day before its event" do
    get "/cfps/meetup-2026-11-12-call-for-proposals"

    assert_response :success
    assert_match(/Close date:\s*<\/strong>\s*2026-11-11/, response.body)
  end

  test "the CFP data carry the implied close date" do
    get "/cfps/meetup-2026-11-12-call-for-proposals.json"

    assert_response :success
    assert_equal "2026-11-11", response.parsed_body["close_date"]
  end
end
