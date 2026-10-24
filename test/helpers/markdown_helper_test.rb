require "test_helper"

class MarkdownHelperTest < ActionView::TestCase
  test "a long text renders every Markdown element we support" do
    {
      "Two\n\nparagraphs" => "<p>Two</p><p>paragraphs</p>",
      "One\nparagraph" => "<p>One\nparagraph</p>",
      "A line\\\nbreak" => "<p>A line<br>\nbreak</p>",
      "See <https://example.com>, **now**." => '<p>See <a href="https://example.com">https://example.com</a>, <strong>now</strong>.</p>',
      'See [example.com](https://example.com "Example"), **now**.' =>
        '<p>See <a href="https://example.com" title="Example">example.com</a>, <strong>now</strong>.</p>',
      "[A link](https://example.com)" => '<p><a href="https://example.com">A link</a></p>',
      "*Emphasis*" => "<p><em>Emphasis</em></p>",
      "`code`" => "<p><code>code</code></p>",
      "- One\n- Two" => "<ul><li>One</li><li>Two</li></ul>",
      "1. One\n2. Two" => "<ol><li>One</li><li>Two</li></ol>",
      "# One" => "<h1>One</h1>",
      "## Two" => "<h2>Two</h2>",
      "&amp; 3 \\< 4" => "<p>&amp; 3 &lt; 4</p>",
      "\"Quoted\" -- and..." => "<p>\"Quoted\" -- and...</p>"
    }.each do |markdown, html|
      assert_dom_equal html, render_long_form_text(markdown), markdown
    end
  end

  test "a long text's headings survive at any offset" do
    (0..4).each do |offset|
      assert_dom_equal "<h#{offset + 1}>One</h#{offset + 1}><h#{offset + 2}>Two</h#{offset + 2}>",
        render_long_form_text("# One\n\n## Two", heading_offset: offset)
    end
  end

  test "a long text that skipped the validation still can't bring its own HTML" do
    assert_dom_equal "<p>Hi there</p>", render_long_form_text("Hi <span onclick='alert(1)'>there</span>")
  end

  test "a missing long text renders nothing" do
    assert_nil render_long_form_text(nil)
  end
end
