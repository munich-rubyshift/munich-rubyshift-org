require "test_helper"

class SlugsTest < ActiveSupport::TestCase
  # Slugs are editable in Avo. FriendlyId only generates one when the column is
  # nil, and stores a hand-written one verbatim, so `Sluggable` normalizes both.
  test "every sluggable model clears a blank slug so it gets regenerated" do
    sluggable_models.each do |model|
      record = model.new(slug: "")

      assert_nil record.slug,
        "#{model} keeps a blank slug, include `Sluggable`"
    end
  end

  test "every sluggable model keeps a hand-written slug URL-safe" do
    sluggable_models.each do |model|
      record = model.new(slug: "Not A Slug!")

      assert_equal "not-a-slug", record.slug,
        "#{model} stores a slug verbatim, include `Sluggable`"
    end
  end

  private

  def sluggable_models
    Rails.application.eager_load!

    models = ApplicationRecord.descendants.select { |model| model.respond_to?(:friendly_id_config) }
    assert_predicate models, :any?, "Found no sluggable models, the detection above is broken"
    models
  end
end
