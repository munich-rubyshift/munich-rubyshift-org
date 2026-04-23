class CreateTalksSpeakerTalks < ActiveRecord::Migration[8.1]
  def change
    create_table :talks_speaker_talks, id: :string, default: -> { "uuid()" }, limit: 36 do |t|
      t.references :talks_talk, null: false, foreign_key: true, type: :string
      t.references :entities_person, null: false, foreign_key: true, type: :string

      t.timestamps
    end
  end
end
