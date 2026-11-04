require "application_system_test_case"

class ApiSchemaTest < ApplicationSystemTestCase
  test "the API reference renders the schema without loading anything from elsewhere" do
    visit "/api/schema"

    assert_text "Show an event"
    resources = evaluate_script("performance.getEntriesByType('resource').map(entry => entry.name)")
    assert_includes resources, "#{page.server_url}/api/v1/schema.yaml"
    assert_empty resources.reject { |url| url.start_with?(page.server_url) }
  end
end
