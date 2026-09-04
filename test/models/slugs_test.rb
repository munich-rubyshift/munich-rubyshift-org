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

  # By switching from autoincrement integer IDs to UUIDv4, we made FriendlyId
  # destroy and recreate records unnecessarily. This regression test demonstrates
  # that and only passes due to the patch in `config/initializers/friendly_id.rb`.
  test "slug history is append-only and survives repeated saves" do
    venue = Venues::Venue.create!(name: "One", address: locations_addresses(:one))
    venue.update!(slug: nil, name: "Two")
    venue.update!(slug: nil, name: "Three")

    pin_slug_ids venue,
      "three" => "00000000-0000-4000-8000-000000000000",
      "two" => "88888888-8888-4888-8888-888888888888",
      "one" => "ffffffff-ffff-4fff-8fff-ffffffffffff"

    history = venue.slugs.reorder(:slug).pluck(:id, :slug)
    assert_equal %w[one three two], history.map(&:last)

    3.times { venue.update!(description: "touched") }

    assert_equal history, venue.reload.slugs.reorder(:slug).pluck(:id, :slug),
      "a save that left the slug alone rewrote the slug history"
    assert_equal "three", venue.to_param
    assert_equal venue, Venues::Venue.find("one")
  end

  private

  def sluggable_models
    Rails.application.eager_load!

    models = ApplicationRecord.descendants.select { |model| model.respond_to?(:friendly_id_config) }
    assert_predicate models, :any?, "Found no sluggable models, the detection above is broken"
    models
  end

  def pin_slug_ids(record, ids)
    ids.each { |slug, id| record.slugs.find_by!(slug: slug).update_column(:id, id) }
    record.slugs.reset
  end
end
