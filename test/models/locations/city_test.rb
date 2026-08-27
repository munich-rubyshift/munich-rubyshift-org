require "test_helper"

class Locations::CityTest < ActiveSupport::TestCase
  test "geocodes when coordinates are absent" do
    city = Locations::City.new(name: "Nürnberg", state_code: "BY", country_code: "DE")

    assert city.valid?
    assert_equal 48.137108, city.coordinates.latitude.to_f
  end

  test "does not geocode a record loaded from the database" do
    before = locations_cities(:one).coordinates.id
    loaded = Locations::City.find(locations_cities(:one).id)

    assert loaded.valid?
    assert_equal before, loaded.coordinates.id
  end

  test "fails to save when the city cannot be geocoded" do
    Geocoder::Lookup::Test.add_stub("Atlantis, XX, ZZ", [])
    city = Locations::City.new(name: "Atlantis", state_code: "XX", country_code: "ZZ")

    assert_not city.valid?
    assert_match(/could not be geocoded/, city.errors[:coordinates].to_sentence)
  end
end
