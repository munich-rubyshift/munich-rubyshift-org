class Avo::Resources::EventsSeries < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Events::Series
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, format_index_using: -> { content_tag(:span, "#", title: value) }
    field :slug, as: :id, format_using: -> { link_to value, main_app.polymorphic_path(record), "data-turbo": false }
    field :name, as: :text
    field :rubyevents_slug, as: :text
    field :description, as: :textarea
    field :kind, as: :text
    field :frequency, as: :text
    field :ended, as: :boolean
    field :default_country_code, as: :text
    field :language, as: :text
    field :website, as: :text
    field :original_website, as: :text
    field :twitter, as: :text
    field :facebook, as: :text
    field :mastodon, as: :text
    field :bsky, as: :text
    field :github, as: :text
    field :linkedin, as: :text
    field :meetup, as: :text
    field :luma, as: :text
    field :guild, as: :text
    field :vimeo, as: :text
    field :discord, as: :text
    field :youtube_channel_id, as: :text
    field :youtube_channel_name, as: :text
    field :youtube_channel_handle, as: :text
    field :playlist_matcher, as: :text
  end
end
