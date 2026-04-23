json.extract! entities_person, :id, :slug, :name, :rubyevents_slug, :github, :twitter, :website, :mastodon, :bluesky, :linkedin, :speakerdeck, :created_at, :updated_at
json.url entities_person_url(entities_person, format: :json)
