Page = Decant.define(dir: "content/pages", ext: "md") do
  include Linkable

  id_method :slug
  label_method { title || slug }

  frontmatter :title
  frontmatter :category_slugs

  def categories
    Category.where(slug: category_slugs)
  end
end
