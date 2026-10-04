require "test_helper"

class Talks::SpeakerTalkTest < ActiveSupport::TestCase
  test "reads as the talk and who gave it" do
    speaker_talk = talks_speaker_talks(:one)
    speaker_talk.talk.title = "munich-rubyshift.org goes LIVE!"
    speaker_talk.speaker.name = "Klaus Weidinger"

    assert_equal "\"munich-rubyshift.org goes LIVE!\" by Klaus Weidinger", speaker_talk.to_s
  end

  test "a person speaks at a talk only once" do
    taken = talks_speaker_talks(:one)
    speaker_talk = Talks::SpeakerTalk.new(talk: taken.talk, speaker: taken.speaker)

    assert_not speaker_talk.valid?
    assert_includes speaker_talk.errors[:speaker], "has already been taken"
  end

  test "the database refuses a person speaking at a talk twice" do
    taken = talks_speaker_talks(:one)

    assert_raises ActiveRecord::RecordNotUnique do
      Talks::SpeakerTalk.insert!({ talks_talk_id: taken.talks_talk_id, entities_person_id: taken.entities_person_id })
    end
  end

  test "a person may speak at several talks" do
    speaker_talk = Talks::SpeakerTalk.new(talk: talks_talks(:two), speaker: talks_speaker_talks(:one).speaker)

    assert speaker_talk.valid?, speaker_talk.errors.full_messages.to_sentence
  end
end
