class Avo::Resources::EventsSeries < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  self.model_class = ::Events::Series
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :slug, as: :text, **SLUG_FIELD_OPTIONS
    field :name, as: :text
    field :rubyevents_slug, as: :text
    field :description, as: :textarea
    field :kind, as: :select, options: ::Events::Series::KINDS.index_by(&:humanize), include_blank: true
    field :frequency, as: :select, options: ::Events::Series::FREQUENCIES.index_by(&:humanize), include_blank: true
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
