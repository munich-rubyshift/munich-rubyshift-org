class CreateLocationsCities < ActiveRecord::Migration[8.1]
  def change
    create_table :locations_cities, id: :string, default: -> { "uuid()" }, limit: 36 do |t|
      t.string :slug
      t.string :name
      t.string :rubyevents_slug
      t.string :state_code
      t.string :country_code
      t.references :locations_coordinates, null: false, foreign_key: true, type: :string

      t.timestamps
    end
  end
end
