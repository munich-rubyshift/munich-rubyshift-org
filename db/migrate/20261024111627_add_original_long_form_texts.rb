class AddOriginalLongFormTexts < ActiveRecord::Migration[8.1]
  # The only long texts that hold anything so far.
  COLUMNS = {
    entities_organizations: :internal_notes,
    events_events: :description,
    talks_talks: :description
  }.freeze

  def change
    COLUMNS.each do |table, column|
      add_column table, :"#{column}_original", :text

      up_only do
        execute <<~SQL.squish
          UPDATE #{table} SET #{column}_original = #{column} WHERE TRIM(#{column}) <> ''
        SQL
      end
    end
  end
end
