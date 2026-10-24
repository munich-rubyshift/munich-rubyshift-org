module MarkdownHelper
  def render_content_from(page)
    erb_processed_content = render(inline: page.content, layout: false)
    Kramdown::Document.new(
      erb_processed_content,
      input: "GFM",
      syntax_highlighter: :rouge
    ).to_html.html_safe
  end

  # The validation keeps anything else out of a long text, but data loaded
  # from content/data skips it.
  def render_long_form_text(text)
    return unless text

    sanitize(LongFormText::Markdown.new(text).to_html, tags: LongFormText::Markdown::TAGS, attributes: %w[href title])
  end

  def pages_image_tag(path, **kwargs)
    image_tag "pages/#{@page.slug}/#{path}", **kwargs
  end
end
