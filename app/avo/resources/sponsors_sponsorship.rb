class Avo::Resources::SponsorsSponsorship < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Sponsors::Sponsorship
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, format_index_using: -> { content_tag(:span, "#", title: value) }
    field :slug, as: :id, format_using: -> { link_to value, main_app.polymorphic_path(record), "data-turbo": false }
    field :name, as: :text
    field :rubyevents_slug, as: :text
    field :entities_organization, as: :belongs_to
    field :sponsors_sponsor_tier, as: :belongs_to
    field :description, as: :textarea
    field :website, as: :text
    field :logo_url, as: :text
    field :badge, as: :text
  end
end
