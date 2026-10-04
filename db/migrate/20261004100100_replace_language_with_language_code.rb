class ReplaceLanguageWithLanguageCode < ActiveRecord::Migration[8.1]
  def change
    add_column :events_series, :language_code, :string
    add_column :talks_talks, :language_code, :string

    reversible do |direction|
      direction.up do
        execute <<~SQL.squish
          UPDATE events_series SET language_code = CASE language
            WHEN 'English' THEN 'en'
            WHEN 'German' THEN 'de'
          END
        SQL

        # A talk always has a language, and every talk so far was in English.
        execute <<~SQL.squish
          UPDATE talks_talks SET language_code = CASE language
            WHEN 'German' THEN 'de'
            ELSE 'en'
          END
        SQL
      end

      direction.down do
        %w[events_series talks_talks].each do |table|
          execute <<~SQL.squish
            UPDATE #{table} SET language = CASE language_code
              WHEN 'en' THEN 'English'
              WHEN 'de' THEN 'German'
            END
          SQL
        end
      end
    end

    change_column_null :talks_talks, :language_code, false

    remove_column :events_series, :language, :string
    remove_column :talks_talks, :language, :string
  end
end
