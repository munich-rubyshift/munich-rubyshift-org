class CreateTalksAdditionalResources < ActiveRecord::Migration[8.1]
  def change
    create_table :talks_additional_resources, id: :string, default: -> { "uuid()" }, limit: 36 do |t|
      t.string :kind
      t.string :name
      t.string :url
      t.string :title
      t.references :talks_talk, null: false, foreign_key: true, type: :string

      t.timestamps
    end
  end
end
