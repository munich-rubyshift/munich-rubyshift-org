require "test_helper"
require "view_component/test_helpers"

class Events::DateBadgeComponentTest < ActionView::TestCase
  include ViewComponent::TestHelpers

  def test_day_precision
    render_inline(Events::DateBadgeComponent.new(Date.new(2026, 9, 24)))

    assert_selector "time.events---date-badge[datetime='2026-09-24']"
    assert_selector ".events---date-badge--top", text: "Sep"
    assert_selector ".events---date-badge--main", text: "24"
    assert_selector ".events---date-badge--bottom", text: "2026"
  end

  def test_year_precision
    render_inline(Events::DateBadgeComponent.new(Date.new(2014, 1, 1), precision: "year"))

    assert_selector ".events---date-badge--main", text: "2014"
  end

  def test_without_date
    render_inline(Events::DateBadgeComponent.new(nil))

    assert_no_selector "time"
    assert_selector "span.events---date-badge", text: "TBA"
  end
end
