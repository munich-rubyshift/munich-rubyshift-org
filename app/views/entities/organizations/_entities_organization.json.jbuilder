json.extract! entities_organization, :id, :slug, :name, :legal_name, :rubyevents_slug, :website
json.url entities_organization_url(entities_organization, format: :json)
