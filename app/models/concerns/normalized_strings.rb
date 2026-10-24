module NormalizedStrings
  extend ActiveSupport::Concern

  class_methods do
    def normalized_strings(*names)
      # Normalize all CRLF to LF for a nicer representation in YAML.
      normalizes(*names, with: ->(value) { value.gsub(/\r\n?/, "\n").presence })
    end
  end
end
