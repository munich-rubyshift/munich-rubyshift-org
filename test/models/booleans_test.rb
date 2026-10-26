require "test_helper"

class BooleansTest < ActiveSupport::TestCase
  test "every boolean column defaults to false and refuses NULL" do
    nullable = boolean_columns.reject { |model, column| model.column_defaults[column.name] == false && !column.null }

    assert_empty nullable.map { |model, column| "#{model.table_name}.#{column.name}" },
      "All boolean columns should have `default: false, null: false`"
  end

  private

  def boolean_columns
    Rails.application.eager_load!

    columns = ApplicationRecord.descendants.reject(&:abstract_class?).flat_map do |model|
      model.columns.select { |column| column.type == :boolean }.map { |column| [ model, column ] }
    end
    assert_predicate columns, :any?, "Found no boolean columns, the detection above is broken"
    columns
  end
end
