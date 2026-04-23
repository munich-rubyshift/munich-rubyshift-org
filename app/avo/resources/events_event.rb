class Avo::Resources::EventsEvent < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Events::Event
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, format_index_using: -> { content_tag(:span, "#", title: value) }
    field :slug, as: :id, format_using: -> { link_to value, main_app.polymorphic_path(record), "data-turbo": false }
    field :title, as: :text
    field :rubyevents_slug, as: :text
    field :venues_venue, as: :belongs_to
    field :description, as: :textarea
    field :kind, as: :text
    field :hybrid, as: :boolean
    field :status, as: :text
    field :last_edition, as: :boolean
    field :start_date, as: :date
    field :end_date, as: :date
    field :published_at, as: :date_time
    field :announced_on, as: :date
    field :year, as: :number
    field :date_precision, as: :text
    field :frequency, as: :text
    field :channel_id, as: :text
    field :playlist, as: :text
    field :website, as: :text
    field :twitter, as: :text
    field :mastodon, as: :text
    field :github, as: :text
    field :meetup, as: :text
    field :luma, as: :text
    field :youtube, as: :text
    field :tickets_url, as: :text
    field :banner_background, as: :text
    field :featured_background, as: :text
    field :featured_color, as: :text
    field :online_event, as: :boolean
  end
end
