class RequireKindOnTalksTalks < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE talks_talks SET kind = 'talk' WHERE kind IS NULL OR kind = ''"

    change_column_null :talks_talks, :kind, false
  end

  def down
    change_column_null :talks_talks, :kind, true
  end
end
