class AddOriginalLongFormTexts < ActiveRecord::Migration[8.1]
  # The long texts we hold so far, before they get reformatted as Markdown.
  COLUMNS = {
    entities_organizations: :internal_notes,
    events_events: :description,
    talks_talks: :description
  }.freeze

  def change
    COLUMNS.each do |table, column|
      add_column table, :"#{column}_original", :text

      reversible do |direction|
        direction.up do
          execute <<~SQL.squish
            UPDATE #{table} SET #{column}_original = #{column} WHERE TRIM(#{column}) <> ''
          SQL
        end
      end
    end
  end
end
