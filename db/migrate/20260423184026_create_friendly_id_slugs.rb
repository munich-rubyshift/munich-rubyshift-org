class CreateFriendlyIdSlugs < ActiveRecord::Migration[8.1]
  def change
    create_table :friendly_id_slugs, id: :string, default: -> { "uuid()" }, limit: 36 do |t|
      t.string :slug, null: false
      t.string :sluggable_id, limit: 36, null: false
      t.string :sluggable_type, limit: 50
      t.string :scope
      t.datetime :created_at
    end
    add_index :friendly_id_slugs, [ :sluggable_type, :sluggable_id ]
    add_index :friendly_id_slugs, [ :slug, :sluggable_type ], length: { slug: 140, sluggable_type: 50 }
    add_index :friendly_id_slugs, [ :slug, :sluggable_type, :scope ], length: { slug: 70, sluggable_type: 50, scope: 70 }, unique: true
  end
end
