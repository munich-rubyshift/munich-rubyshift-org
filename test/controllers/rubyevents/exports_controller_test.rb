require "test_helper"
require_relative "../../support/rubyevents_graph"

class Rubyevents::ExportsControllerTest < ActionDispatch::IntegrationTest
  include RubyeventsGraph

  test "serves the strict export as a zip" do
    build_graph

    get rubyevents_export_path

    assert_response :success
    assert_equal "application/zip", response.media_type
    entries = []
    Zip::File.open_buffer(response.body) { |zip| entries = zip.map(&:name) }

    assert_includes entries, "munich-rubyshift/series.yml"
  end

  test "serves the lenient export when our data is still incomplete" do
    build_graph(complete: false)

    get rubyevents_export_path(lenient: 1)

    assert_response :success
    assert_equal "application/zip", response.media_type
  end

  test "refuses to serve a strict export that violates their schema" do
    build_graph(complete: false)

    assert_raises(Rubyevents::Export::InvalidDocument) { get rubyevents_export_path }
  end
end
