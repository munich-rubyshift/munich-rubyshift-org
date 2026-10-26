require "test_helper"

class BlankStringsTest < ActiveSupport::TestCase
  test "every string column stores blank input as nil" do
    kept = string_columns.reject do |model, name|
      [ "", " " ].all? { |blank| model.normalize_value_for(name, blank).nil? }
    end

    assert_empty kept.map { |model, name| "#{model.name}##{name}" },
      "These keep blank strings, which reach content/data as ''. Add them to `normalized_strings`"
  end

  test "all models have a valid to_s method" do
    models.each { |model| assert_kind_of String, model.new.to_s, "#{model.name}#to_s" }
  end

  private

  # Gem models like FriendlyId::Slug inherit from ActiveRecord::Base directly, so
  # they aren't ApplicationRecord descendants. Only their gems write to them.
  def models
    Rails.application.eager_load!

    models = ApplicationRecord.descendants.reject(&:abstract_class?)
    assert_predicate models, :any?, "Found no models, the detection above is broken"
    models
  end

  def string_columns
    models.flat_map do |model|
      model.columns
        .select { |column| column.type.in?(%i[string text]) && column.name != model.primary_key }
        .map { |column| [ model, column.name ] }
    end
  end
end
