json.extract! entities_organization, :id, :slug, :name, :rubyevents_slug, :description, :website, :logo_background, :logo_url, :main_location
json.url entities_organization_url(entities_organization, format: :json)
