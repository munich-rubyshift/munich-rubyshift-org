require "test_helper"

class Talks::SpeakerTalkTest < ActiveSupport::TestCase
  test "reads as the talk and who gave it" do
    speaker_talk = talks_speaker_talks(:one)
    speaker_talk.talk.title = "munich-rubyshift.org goes LIVE!"
    speaker_talk.speaker.name = "Klaus Weidinger"

    assert_equal "\"munich-rubyshift.org goes LIVE!\" by Klaus Weidinger", speaker_talk.to_s
  end
end
