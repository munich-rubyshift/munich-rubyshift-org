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

  # The German substitutions live in config/locales/en.yml, under the locale the
  # app actually runs in. That is what lets a plain `parameterize` pick them up.
  test "slugs spell German umlauts the German way" do
    assert_equal "muenchen-hofbraeukeller", "München Hofbräukeller".parameterize
    assert_equal "aerzte-oel-ueber", "Ärzte Öl Über".parameterize
    assert_equal "tuerkenstrasse-89", "Türkenstraße 89".parameterize
  end

  # FriendlyId parameterizes without passing a locale, so this only holds while
  # the rules stay under the default locale.
  test "generated slugs get the German substitutions too" do
    assert_equal "aeussere-muenchener-strasse-7",
      Locations::Address.new.normalize_friendly_id("Äußere Münchener Straße 7")
  end

  private

  def sluggable_models
    Rails.application.eager_load!

    models = ApplicationRecord.descendants.select { |model| model.respond_to?(:friendly_id_config) }
    assert_predicate models, :any?, "Found no sluggable models, the detection above is broken"
    models
  end
end
