module ApplicationHelper
  def markdown(text)
    return "" if text.blank?

    renderer = Redcarpet::Render::HTML.new(
      filter_html: true,
      hard_wrap: true
    )

    markdown = Redcarpet::Markdown.new(
      renderer,
      autolink: true,
      tables: true,
      fenced_code_blocks: true
    )

    sanitize(
      markdown.render(text),
      tags: %w[p br strong em ul ol li a code pre h1 h2 h3 blockquote],
      attributes: %w[href target rel]
    )
  end
end
