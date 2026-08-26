class Avo::Resources::TalksAdditionalResource < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Talks::AdditionalResource
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, format_index_using: -> { content_tag(:span, "#", title: value) }
    field :kind, as: :select, options: ::Talks::AdditionalResource::KINDS.index_by(&:humanize), include_blank: true
    field :name, as: :text
    field :url, as: :text
    field :title, as: :text
    field :talk, as: :belongs_to
  end
end
