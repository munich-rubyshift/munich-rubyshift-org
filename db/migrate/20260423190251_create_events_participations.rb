class CreateEventsParticipations < ActiveRecord::Migration[8.1]
  def change
    create_table :events_participations, id: :string, default: -> { "uuid()" }, limit: 36 do |t|
      t.references :entities_person, null: false, foreign_key: true, type: :string
      t.references :events_event, null: false, foreign_key: true, type: :string
      t.string :attended_as

      t.timestamps
    end
  end
end
