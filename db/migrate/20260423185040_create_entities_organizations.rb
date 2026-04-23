class CreateEntitiesOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :entities_organizations, id: :string, default: -> { "uuid()" }, limit: 36 do |t|
      t.string :slug
      t.string :name
      t.string :rubyevents_slug
      t.text :description
      t.string :website
      t.string :logo_background
      t.string :logo_url
      t.string :main_location

      t.timestamps
    end
  end
end
