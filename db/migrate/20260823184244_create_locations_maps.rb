class CreateLocationsMaps < ActiveRecord::Migration[8.1]
  def change
    create_table :locations_maps, id: :string, default: -> { "uuid()" }, limit: 36 do |t|
      t.string :google_url
      t.string :apple_url
      t.string :openstreetmap_url

      t.timestamps
    end
  end
end
