require "test_helper"

class LongFormTextTest < ActiveSupport::TestCase
  test "every text column is long-form text" do
    Rails.application.eager_load!

    ApplicationRecord.descendants.each do |model|
      model.columns.each do |column|
        next if column.type != :text || column.name.end_with?("_original")

        record = model.new
        record.public_send(:"#{column.name}=", "Line one\r\nline two\r\n")

        assert_equal "Line one\nline two", record.public_send(column.name),
          "#{model}##{column.name} isn't normalized, add it to `long_form_text`"
      end
    end
  end

  test "a long text drops trailing spaces and blanks" do
    talk = Talks::Talk.new

    talk.description = "  Line one  \n\tline two\t\n\n"
    assert_equal "Line one\n\tline two", talk.description

    talk.description = " \r\n "
    assert_nil talk.description
  end
end
