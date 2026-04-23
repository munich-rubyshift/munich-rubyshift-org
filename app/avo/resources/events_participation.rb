class Avo::Resources::EventsParticipation < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Events::Participation
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, format_index_using: -> { content_tag(:span, "#", title: value) }
    field :entities_person, as: :belongs_to
    field :events_event, as: :belongs_to
    field :attended_as, as: :text
  end
end
