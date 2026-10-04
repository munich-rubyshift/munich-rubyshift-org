class ReplaceAnnouncedAtWithAnnouncedOnOnTalksTalks < ActiveRecord::Migration[8.1]
  def change
    add_column :talks_talks, :announced_on, :date

    reversible do |direction|
      direction.up { execute "UPDATE talks_talks SET announced_on = date(announced_at)" }
      direction.down { execute "UPDATE talks_talks SET announced_at = announced_on" }
    end

    remove_column :talks_talks, :announced_at, :datetime
  end
end
