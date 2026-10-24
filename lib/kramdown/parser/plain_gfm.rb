require "kramdown/parser/gfm"

# kramdown's own {: …} and {::…} syntax isn't Markdown, and would let a text set
# attributes or override our options. As on GitHub, it stays plain text.
#
# Kramdown::Document requires this file by itself for `input: "PlainGFM"`.
class Kramdown::Parser::PlainGFM < Kramdown::Parser::GFM
  def initialize(source, options)
    super
    @block_parsers.delete(:block_extensions)
    @span_parsers.delete(:span_extensions)
  end
end
