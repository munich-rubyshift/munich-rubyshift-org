# Long texts are Markdown, cut down to what fits into a narrow column and still
# reads well when cut short: paragraphs, line breaks, links, emphasis, inline
# code, lists, and two levels of headings.
class LongFormText::Markdown
  OPTIONS = {
    input: "GFM",
    # A single line break is a space, as in CommonMark.
    hard_wrap: false,
    auto_ids: false,
    # Keep quotes, dashes and dots as typed.
    smart_quotes: %w[apos apos quot quot],
    typographic_symbols: { hellip: "...", mdash: "---", ndash: "--", laquo: "<<", raquo: ">>", laquo_space: "<< ", raquo_space: " >>" }
  }.freeze

  ALLOWED = %i[root blank p text br a strong em codespan ul ol li header entity smart_quote typographic_sym].freeze

  MAX_HEADING_LEVEL = 2

  # The HTML that the allowed elements render to, at any heading offset.
  TAGS = %w[p br a strong em code ul ol li h1 h2 h3 h4 h5 h6].freeze

  # How an author most likely typed an element we don't allow.
  FORBIDDEN = {
    blockquote: "a block quote (a line starting with >)",
    codeblock: "a code block (a line indented by four spaces, or ```)",
    dl: "a definition list (a line starting with :)",
    footnote: "a footnote ([^…])",
    hr: "a horizontal rule (a line of ---, *** or ___)",
    html_element: "HTML (write a literal < as \\<)",
    img: "an image",
    math: "math (text between $$)",
    table: "a table (write a literal | as \\|)",
    xml_comment: "an HTML comment"
  }.freeze

  def initialize(text)
    @document = Kramdown::Document.new(text.to_s, **OPTIONS)
  end

  # Each problem names what isn't allowed, and on which line.
  def problems
    problems_in(@document.root).uniq
  end

  def to_html(heading_offset: 0)
    Kramdown::Converter::Html.convert(@document.root, @document.options.merge(header_offset: heading_offset)).first
  end

  private

  def problems_in(element, line: nil, in_link: false)
    line = element.options[:location] || line
    problem = problem_with(element, in_link:)
    return [ "#{problem} on line #{line}" ] if problem

    element.children.flat_map { |child| problems_in(child, line:, in_link: in_link || element.type == :a) }
  end

  def problem_with(element, in_link:)
    if !ALLOWED.include?(element.type)
      FORBIDDEN.fetch(element.type) { element.type.to_s.humanize(capitalize: false) }
    elsif element.attr.except("href", "title").any?
      "an attribute list ({: …})"
    elsif element.type == :header && element.options[:level] > MAX_HEADING_LEVEL
      "a heading below level #{MAX_HEADING_LEVEL} (###)"
    elsif element.type == :a && !web_url?(element.attr["href"])
      "a link that isn't a valid http(s) URL"
    elsif element.type == :text && !in_link && element.value.match?(%r{https?://})
      "a bare URL (write it as <https://…>)"
    end
  end

  # Parklife's crawler parses every link of a page and would stop at an invalid one.
  # Read the href from HTML like Parklife does, which decodes entities.
  def web_url?(href)
    decoded_href = Nokogiri::HTML.fragment(%(<a href="#{href}"></a>)).at_css("a")[:href]
    uri = URI.parse(decoded_href)
    uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    false
  end
end
