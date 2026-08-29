require "test_helper"

class Locations::AddressTest < ActiveSupport::TestCase
  setup do
    @city = locations_cities(:one)
  end

  test "geocodes when coordinates are absent" do
    address = Locations::Address.new(street: "Marienplatz 1", zip_code: "80331", city: @city)

    assert address.valid?
    assert_equal 48.137108, address.coordinates.latitude.to_f
  end

  test "geocodes again when a geocoded attribute changes" do
    address = create_address
    before = address.coordinates.id

    address.street = "Andere Straße 2"

    assert address.valid?
    assert address.coordinates.new_record?, "expected a fresh coordinates record"
    assert_not_equal before, address.coordinates.id
  end

  test "does not geocode when an unrelated attribute changes" do
    address = create_address
    before = address.coordinates.id

    address.slug = "a-different-slug"

    assert address.valid?
    assert_equal before, address.coordinates.id
  end

  # `static_db` calls `valid?` on every record and must not trigger a geocoding request.
  test "does not geocode a record loaded from the database" do
    before = create_address.coordinates.id
    loaded = Locations::Address.find_by!(street: "Marienplatz 1")

    assert loaded.valid?
    assert_equal before, loaded.coordinates.id
  end

  test "keeps coordinates that were assigned by hand" do
    manual = Locations::Coordinates.create!(latitude: 1.5, longitude: 2.5)
    address = Locations::Address.new(street: "Marienplatz 1", zip_code: "80331", city: @city, coordinates: manual)

    assert address.valid?
    assert_equal manual.id, address.coordinates.id
  end

  test "keeps coordinates that were assigned by hand via the foreign key" do
    manual = Locations::Coordinates.create!(latitude: 1.5, longitude: 2.5)
    address = Locations::Address.new(street: "Marienplatz 1", zip_code: "80331", city: @city, locations_coordinates_id: manual.id)

    assert address.valid?
    assert_equal manual.id, address.coordinates.id
  end

  test "saves an address that cannot be geocoded when coordinates are assigned by hand" do
    stub_missing_geocoding
    manual = Locations::Coordinates.create!(latitude: 1.5, longitude: 2.5)
    address = Locations::Address.new(street: "Nirgendwo 1", zip_code: "00000", city: @city, locations_coordinates_id: manual.id)

    assert address.valid?, address.errors.full_messages.to_sentence
    assert_equal manual.id, address.coordinates.id
  end

  test "fails to save when a changed address cannot be geocoded, rather than keeping stale coordinates" do
    address = create_address
    stub_missing_geocoding

    address.street = "Nirgendwo 1"
    address.zip_code = "00000"

    assert_not address.valid?
    assert_match(/could not be geocoded/, address.errors[:coordinates].to_sentence)
  end

  test "saves a changed address that cannot be geocoded when coordinates are assigned by hand" do
    address = create_address
    manual = Locations::Coordinates.create!(latitude: 1.5, longitude: 2.5)
    stub_missing_geocoding

    address.street = "Nirgendwo 1"
    address.zip_code = "00000"
    address.coordinates = manual

    assert address.valid?, address.errors.full_messages.to_sentence
    assert_equal manual.id, address.coordinates.id
  end

  test "fails to save when the address cannot be geocoded" do
    stub_missing_geocoding
    address = Locations::Address.new(street: "Nirgendwo 1", zip_code: "00000", city: @city)

    assert_not address.valid?
    assert_match(/could not be geocoded/, address.errors[:coordinates].to_sentence)
  end

  private

  def create_address
    Locations::Address.create!(street: "Marienplatz 1", zip_code: "80331", city: @city)
  end

  def stub_missing_geocoding
    Geocoder::Lookup::Test.add_stub("Nirgendwo 1, 00000 #{@city.name}, #{@city.state_code}, #{@city.country_code}", [])
  end
end
