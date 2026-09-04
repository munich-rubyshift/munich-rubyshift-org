json.extract! talks_additional_resource, :id, :kind, :name, :url, :title, :talks_talk_id
json.url talks_additional_resource_url(talks_additional_resource, format: :json)
