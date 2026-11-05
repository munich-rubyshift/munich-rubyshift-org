require "minitest/autorun"
require "webmock/minitest"
require "tmpdir"
require_relative "../lib/json_api"
require_relative "../lib/rubyevents"

module ResourceHelper
  def resource_data(type, id, relationships: {}, **attributes)
    {
      "type" => type,
      "id" => id,
      "attributes" => attributes.transform_keys(&:to_s),
      "relationships" => relationships.transform_keys(&:to_s).transform_values { |data| { "data" => data } }
    }
  end

  def identifier(type, id)
    { "type" => type, "id" => id }
  end
end
