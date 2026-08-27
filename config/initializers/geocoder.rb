Geocoder.configure(
  lookup: :nominatim,
  timeout: 5,
  # Nominatim's usage policy requires a User-Agent identifying the application.
  http_headers: {
    "User-Agent" => "munich-rubyshift.org (https://github.com/munich-rubyshift/munich-rubyshift-org)"
  }
)

# Never reach the network from tests. Individual tests can override with
# Geocoder::Lookup::Test.add_stub.
if Rails.env.test?
  Geocoder.configure(lookup: :test)
  Geocoder::Lookup::Test.set_default_stub([ { "coordinates" => [ 48.137108, 11.575382 ] } ])
end
