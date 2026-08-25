class Avo::Resources::EventsInvolvement < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Events::Involvement
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, format_index_using: -> { content_tag(:span, "#", title: value) }
    field :role, as: :text
    field :entity, as: :text
    field :events_event, as: :belongs_to
  end
end
