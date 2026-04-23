# This is a demo how to build categories without tying yourself to the DB.
# This keeps the "Markdown area" of your app separate from the "DB area".
# A nicer approach for faster editing via the UI would probably be to
# introduce "Category" and "CategoryPage" as models.
Category = Data.define(:slug, :title) do
  include Linkable

  id_method :slug
  label_method :title

  def self.all
    [
      new(slug: "intro", title: "How it began"),
      new(slug: "outro", title: "How it ended")
    ]
  end

  def self.where(**kwargs)
    scope = all
    kwargs.each do |key, value|
      if value.to_s != "all"
        scope.select! { |category| Array.wrap(category.send(key)).intersect?(Array.wrap(value)) }
      end
    end
    scope
  end

  def self.find(slug)
    Category.where(slug: slug).first or raise ActiveRecord::RecordNotFound
  end

  def pages
    Page.where(category_slugs: slug)
  end
end
