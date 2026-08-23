class CreateLocationsAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :locations_addresses, id: :string, default: -> { "uuid()" }, limit: 36 do |t|
      t.string :slug
      t.string :street
      t.string :zip_code
      t.references :locations_city, null: false, foreign_key: true, type: :string

      t.timestamps
    end
  end
end
