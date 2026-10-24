# Long texts are Markdown, see LongFormText::Markdown.
module LongFormText
  extend ActiveSupport::Concern

  class_methods do
    def long_form_text(*names)
      # Normalize all CRLF to LF for a nicer representation in YAML.
      # Strip trailing whitespace which would get turned into a newline by Markdown rendering.
      normalizes(*names, with: ->(text) { text.gsub(/\r\n?/, "\n").gsub(/[ \t]+$/, "").strip.presence })

      validates_each(*names, allow_nil: true) do |record, name, text|
        LongFormText::Markdown.new(text).problems.each { |problem| record.errors.add(name, "contains #{problem}") }
      end
    end
  end
end
