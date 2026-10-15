json.data do
  json.array! @entities_people do |entities_person|
    json.extract! entities_person, :id
    json.type "people"
    json.attributes do
      json.extract! entities_person, :slug, :name, :rubyevents_slug, :github_username, :twitter_username, :website, :mastodon, :bluesky_handle, :linkedin_username, :speakerdeck_username
    end
    json.relationships do
      json.talks do
        json.data do
          json.array! entities_person.talks do |talk|
            json.extract! talk, :id
            json.type "talks"
          end
        end
      end
    end
  end
end
