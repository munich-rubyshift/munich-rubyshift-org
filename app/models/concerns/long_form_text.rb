# Long texts are Markdown, see LongFormText::Markdown.
#
# A textarea submits CRLF line endings, and "" when left empty. Trailing spaces
# are invisible there, but would turn into line breaks in Markdown.
module LongFormText
  extend ActiveSupport::Concern

  class_methods do
    def long_form_text(*names)
      normalizes(*names, with: ->(text) { text.gsub(/\r\n?/, "\n").gsub(/[ \t]+$/, "").strip.presence })

      validates_each(*names, allow_nil: true) do |record, name, text|
        LongFormText::Markdown.new(text).problems.each { |problem| record.errors.add(name, "contains #{problem}") }
      end
    end
  end
end
