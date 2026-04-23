class Avo::Resources::TalksSpeakerTalk < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Talks::SpeakerTalk
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, format_index_using: -> { content_tag(:span, "#", title: value) }
    field :talks_talk, as: :belongs_to
    field :entities_person, as: :belongs_to
  end
end
