class AddMeetupIdToEntitiesPeople < ActiveRecord::Migration[8.1]
  def change
    add_column :entities_people, :meetup_id, :string
  end
end
