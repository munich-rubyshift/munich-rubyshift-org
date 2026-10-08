require "test_helper"
require "view_component/test_helpers"

class Talks::TalkCardComponentTest < ActionView::TestCase
  include ViewComponent::TestHelpers

  def test_renders_talk_with_speakers_and_event
    talk = talks_talks(:one)
    render_inline(Talks::TalkCardComponent.new(talk))

    assert_selector ".talks---talk-card.origami-paper"
    assert_selector ".talks---talk-card--title a", text: talk.title
    assert_selector ".talks---talk-card--speakers a", count: talk.speakers.count
    assert_selector ".talks---talk-card--event a", text: talk.event.to_s
  end
end
