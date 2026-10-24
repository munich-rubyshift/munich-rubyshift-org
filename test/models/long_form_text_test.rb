require "test_helper"

class LongFormTextTest < ActiveSupport::TestCase
  test "every text column is long-form text" do
    each_long_form_text_column do |model, column|
      record = model.new
      record.public_send(:"#{column}=", "Line one\r\nline two\r\n")

      assert_equal "Line one\nline two", record.public_send(column),
        "#{model}##{column} isn't normalized, add it to `long_form_text`"
    end
  end

  test "a long text drops trailing spaces and blanks" do
    talk = Talks::Talk.new

    talk.description = "  Line one  \n\tline two\t\n\n"
    assert_equal "Line one\n\tline two", talk.description

    talk.description = " \r\n "
    assert_nil talk.description
  end

  test "a long text must stick to our Markdown subset" do
    talk = talks_talks(:one)
    talk.description = "Intro\n\n    indented"

    assert_not talk.valid?
    assert_equal [ "contains a code block (a line indented by four spaces, or ```) on line 3" ], talk.errors[:description]
  end

  # bin/ci never loads content/data, and loading it skips validations.
  test "the long texts in content/data are valid" do
    each_long_form_text_column do |model, column|
      file = StaticDb.path.join("#{model.table_name}.yml")
      next unless file.exist?

      YAML.load_file(file).each do |key, row|
        next unless (text = row[column])

        assert_equal model.normalize_value_for(column, text), text, "#{key}: #{column} isn't normalized"
        assert_empty LongFormText::Markdown.new(text).problems, "#{key}: #{column}"
      end
    end
  end

  private

  def each_long_form_text_column
    Rails.application.eager_load!

    ApplicationRecord.descendants.each do |model|
      model.columns.each do |column|
        yield model, column.name if column.type == :text && !column.name.end_with?("_original")
      end
    end
  end
end
