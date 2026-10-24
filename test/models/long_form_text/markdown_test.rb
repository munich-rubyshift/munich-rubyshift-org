require "test_helper"

class LongFormText::MarkdownTest < ActiveSupport::TestCase
  test "paragraphs, line breaks, links, emphasis, code, lists and two levels of headings are fine" do
    text = <<~MARKDOWN
      # Agenda

      ## Talk 1

      A paragraph with **strong**, *emphasis*, `code`, [a link](https://example.com "Title")
      and <https://example.org>, wrapped onto a second line.

      About our speaker\\
      Ends a line with a break.

      - one
      - two

      1. first
      2. second

      Typed as is: "quotes" -- and... &amp; 3 < 4
    MARKDOWN

    assert_empty problems(text)
  end

  test "names each construct that isn't allowed, with its line" do
    {
      "Intro\n\n    indented" => "a code block (a line indented by four spaces, or ```) on line 3",
      "```\ncode\n```" => "a code block (a line indented by four spaces, or ```) on line 1",
      "> quoted" => "a block quote (a line starting with >) on line 1",
      "---" => "a horizontal rule (a line of ---, *** or ___) on line 1",
      "a <span>b</span>" => "HTML (write a literal < as \\<) on line 1",
      "![logo](https://example.com/logo.png)" => "an image on line 1",
      "Ruby | Rails" => "a table (write a literal | as \\|) on line 1",
      "Term\n: definition" => "a definition list (a line starting with :) on line 1",
      "Costs $$5$$" => "math (text between $$) on line 1",
      "Paragraph\n{: .class}" => "an attribute list ({: …}) on line 1",
      "### Deep" => "a heading below level 2 (###) on line 1",
      "[mail](mailto:a@example.com)" => "a link that isn't a valid http(s) URL on line 1",
      "<https://example.com/\u00AD>" => "a link that isn't a valid http(s) URL on line 1",
      "<https://example.com/&shy;>" => "a link that isn't a valid http(s) URL on line 1",
      "[a](https://example.com/&#173;)" => "a link that isn't a valid http(s) URL on line 1",
      "[no host](https://)" => "a link that isn't a valid http(s) URL on line 1",
      "See\nhttps://example.com" => "a bare URL (write it as <https://…>) on line 1",
      "See xhttp://example.com" => "a bare URL (write it as <https://…>) on line 1"
    }.each do |text, problem|
      assert_equal [ problem ], problems(text), text
    end
  end

  test "accepts an escaped ampersand in a link" do
    assert_empty problems("[a](https://example.com/?a=1&amp;b=2)")
  end

  test "names the same problem once per line" do
    assert_equal [ "a bare URL (write it as <https://…>) on line 1", "a bare URL (write it as <https://…>) on line 3" ],
      problems("http://a.example and http://b.example\n\nhttp://c.example")
  end

  test "renders headings at the level they're written, unless told to move them down" do
    markdown = LongFormText::Markdown.new("# Agenda\n\n## Talk 1")

    assert_equal "<h1>Agenda</h1>\n\n<h2>Talk 1</h2>\n", markdown.to_html
    assert_equal "<h2>Agenda</h2>\n\n<h3>Talk 1</h3>\n", markdown.to_html(heading_offset: 1)
  end

  test "ending a line with a backslash renders as a regular line break" do
    assert_equal "<p>wrapped\nline<br />\nbroken</p>\n", LongFormText::Markdown.new("wrapped\nline\\\nbroken").to_html
  end

  test "renders quotes, dashes and dots as typed" do
    assert_equal "<p>\"Quoted\" -- and...</p>\n", LongFormText::Markdown.new("\"Quoted\" -- and...").to_html
  end

  private

  def problems(text)
    LongFormText::Markdown.new(text).problems
  end
end
