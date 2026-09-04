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
    field :name, as: :text, sortable: true
    field :rubyevents_slug, as: :text, sortable: true
    field :description, as: :textarea
    field :kind, as: :select, sortable: true, options: ::Events::Series::KINDS.index_by(&:humanize), include_blank: true
    field :frequency, as: :select, sortable: true, options: ::Events::Series::FREQUENCIES.index_by(&:humanize), include_blank: true
    field :ended, as: :boolean, sortable: true
    field :default_country_code, as: :text, sortable: true
    field :language, as: :text, sortable: true
    field :website, as: :text, sortable: true
    field :original_website, as: :text, sortable: true
    field :twitter, as: :text, sortable: true
    field :facebook, as: :text, sortable: true
    field :mastodon, as: :text, sortable: true
    field :bsky, as: :text, sortable: true
    field :github, as: :text, sortable: true
    field :linkedin, as: :text, sortable: true
    field :meetup, as: :text, sortable: true
    field :luma, as: :text, sortable: true
    field :guild, as: :text, sortable: true
    field :vimeo, as: :text, sortable: true
    field :discord, as: :text, sortable: true
    field :youtube_channel_id, as: :text, sortable: true
    field :youtube_channel_name, as: :text, sortable: true
    field :youtube_channel_handle, as: :text, sortable: true
    field :playlist_matcher, as: :text, sortable: true
  end
end
