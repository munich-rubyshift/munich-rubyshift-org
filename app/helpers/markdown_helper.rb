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
  LONG_FORM_TEXT_TAGS = %w[p br a strong em code ul ol li h1 h2 h3 h4 h5 h6].freeze

  def render_long_form_text(text)
    sanitize(LongFormText::Markdown.new(text).to_html, tags: LONG_FORM_TEXT_TAGS, attributes: %w[href]) if text
  end

  def pages_image_tag(path, **kwargs)
    image_tag "pages/#{@page.slug}/#{path}", **kwargs
  end
end
