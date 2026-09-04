require "test_helper"

class TimestampsTest < ActiveSupport::TestCase
  test "no model stores timestamps" do
    dumped_models.each do |model|
      leaked = model.column_names & %w[created_at updated_at]

      assert_empty leaked,
        "#{model.table_name} stores #{leaked.join(" and ")}, which would reach content/data"
    end
  end

  private

  # The model list mirrors `StaticDb::Dump#models`.
  def dumped_models
    Rails.application.eager_load!

    models = ActiveRecord::Base.descendants.reject(&:abstract_class?).select(&:table_exists?)
    assert_predicate models, :any?, "Found no models, the detection above is broken"
    models
  end
end
