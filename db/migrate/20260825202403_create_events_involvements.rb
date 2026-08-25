class CreateEventsInvolvements < ActiveRecord::Migration[8.1]
  def change
    create_table :events_involvements, id: :string, default: -> { "uuid()" }, limit: 36 do |t|
      t.string :role
      t.references :entity, polymorphic: true, null: false, type: :string
      t.references :events_event, null: false, foreign_key: true, type: :string

      t.timestamps
    end
  end
end
