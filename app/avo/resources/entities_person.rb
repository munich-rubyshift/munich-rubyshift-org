class Avo::Resources::EntitiesPerson < Avo::BaseResource
  # self.includes = []
  self.attachments = [ :avatar ]
  self.model_class = ::Entities::Person
  self.translation_key = "activerecord.models.#{model_class.model_name.i18n_key}"
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id, **ID_FIELD_OPTIONS
    field :slug, as: :text, **SLUG_FIELD_OPTIONS
    field :name, as: :text, sortable: true
    field :avatar, **IMAGE_FIELD_OPTIONS
    field :rubyevents_slug, as: :text, sortable: true
    field :github_username, as: :text, sortable: true
    field :github_avatar_url, as: :text, name: "Avatar on GitHub", only_on: :show,
      visible: -> { resource.record.github_username.present? },
      format_display_using: -> {
        path, data = Avo::Actions::MirrorGithubAvatar.link_arguments(resource:)
        safe_join([ image_tag(value, alt: "", height: 64), link_to("Mirror", path, data:) ], " ")
      }
    field :twitter_username, as: :text, sortable: true
    field :website, as: :text, sortable: true
    field :mastodon, as: :text, sortable: true
    field :bluesky_handle, as: :text, sortable: true
    field :linkedin_username, as: :text, sortable: true
    field :speakerdeck_username, as: :text, sortable: true
    field :meetup_id, as: :text, sortable: true, name: "Meetup user ID"
  end

  def actions
    action Avo::Actions::MirrorGithubAvatar
  end
end
