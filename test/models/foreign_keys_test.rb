require "test_helper"

class ForeignKeysTest < ActiveSupport::TestCase
  # Forms submit "" for an unselected association. Integer foreign keys cast that
  # to NULL. For strings, that doesn't happen and we need to do it ourselves.
  test "every belongs_to normalizes a blank foreign key" do
    Rails.application.eager_load!

    ApplicationRecord.descendants.each do |model|
      model.reflect_on_all_associations(:belongs_to).each do |reflection|
        record = model.new
        record.public_send(:"#{reflection.foreign_key}=", "")

        assert_nil record.public_send(reflection.foreign_key),
          "#{model}##{reflection.foreign_key} keeps a blank foreign key, add it to `string_fk`"
      end
    end
  end
end
