class Avo::Resources::EventsParticipation < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Events::Participation
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, format_index_using: -> { content_tag(:span, "#", title: value) }
    field :person, as: :belongs_to
    field :event, as: :belongs_to
    field :attended_as, as: :text
  end
end
