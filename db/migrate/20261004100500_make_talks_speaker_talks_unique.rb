class MakeTalksSpeakerTalksUnique < ActiveRecord::Migration[8.1]
  def change
    remove_index :talks_speaker_talks, :talks_talk_id
    add_index :talks_speaker_talks, [ :talks_talk_id, :entities_person_id ], unique: true, name: "index_talks_speaker_talks_on_talk_and_person"
  end
end
