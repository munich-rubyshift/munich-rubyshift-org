class RequireTitleOnTalksTalks < ActiveRecord::Migration[8.1]
  def change
    change_column_null :talks_talks, :title, false
  end
end
