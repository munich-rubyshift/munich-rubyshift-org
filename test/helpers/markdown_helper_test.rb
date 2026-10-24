require "test_helper"

class MarkdownHelperTest < ActionView::TestCase
  test "a long text renders as Markdown" do
    assert_dom_equal '<p>See <a href="https://example.com" title="Example">example.com</a>, <strong>now</strong>.</p>',
      render_long_form_text('See [example.com](https://example.com "Example"), **now**.')
  end

  test "a long text that skipped the validation still can't bring its own HTML" do
    assert_dom_equal "<p>Hi there</p>", render_long_form_text("Hi <span onclick='alert(1)'>there</span>")
  end

  test "a missing long text renders nothing" do
    assert_nil render_long_form_text(nil)
  end
end
