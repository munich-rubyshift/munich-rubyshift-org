class CreateEventsCFPs < ActiveRecord::Migration[8.1]
  def change
    create_table :events_cfps, id: :string, default: -> { "uuid()" }, limit: 36 do |t|
      t.string :slug
      t.string :name
      t.string :external_url
      t.date :open_date
      t.date :close_date
      t.references :events_event, null: false, foreign_key: true, type: :string

      t.timestamps
    end
  end
end
