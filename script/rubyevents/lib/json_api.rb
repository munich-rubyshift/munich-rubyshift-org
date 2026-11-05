require "json"
require "net/http"
require "uri"

# A small JSON:API client. It remembers every resource it has fetched, so a
# relationship resolves across documents, like a talk's speakers from /people.json.
module JsonApi
  class Error < StandardError; end

  class Resource
    attr_reader :type, :id, :attributes

    def initialize(store, data)
      @store = store
      @type = data.fetch("type")
      @id = data.fetch("id")
      @attributes = data.fetch("attributes", {})
      @relationships = data.fetch("relationships", {})
    end

    # nil for an attribute the server left out, as JSON:API allows.
    def [](name)
      attributes[name]
    end

    # The related resource, nil for an empty to-one relationship, or a list.
    def related(name)
      linkage = linkage(name)
      linkage.is_a?(Array) ? linkage.map { |identifier| @store.find(identifier) } : linkage && @store.find(linkage)
    end

    # The identifiers of the related resources, which may not be fetched yet.
    def linkage(name)
      @relationships.fetch(name).fetch("data")
    end
  end

  class Store
    def initialize
      @resources = {}
    end

    def add(data)
      resource = Resource.new(self, data)
      @resources[[ resource.type, resource.id ]] = resource
    end

    def find(identifier)
      type, id = identifier.values_at("type", "id")
      @resources.fetch([ type, id ]) { raise Error, "#{type} #{id} hasn't been fetched" }
    end

    def all(type)
      @resources.values.select { |resource| resource.type == type }
    end
  end

  class Client
    attr_reader :store

    def initialize(base_url, store: Store.new)
      @base_url = base_url.chomp("/")
      @store = store
    end

    # Fetches a document, keeps its resources and returns its primary data.
    def get(path)
      document = JSON.parse(fetch("#{@base_url}/#{path}"))
      document.fetch("included", []).each { |data| store.add(data) }

      data = document.fetch("data")
      data.is_a?(Array) ? data.map { |resource| store.add(resource) } : store.add(data)
    end

    private

    def fetch(url)
      response = Net::HTTP.get_response(URI(url))
      raise Error, "GET #{url} answered #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end
  end
end

# Everything the Munich Rubyshift API publishes: its lists, and the documents of
# the events that each series refers to.
module MunichRubyshift
  def self.fetch(api_url)
    client = JsonApi::Client.new(api_url)
    %w[people organizations cities series].each { |list| client.get("#{list}.json") }

    client.store.all("series").each do |series|
      series.linkage("events").each { |event| client.get("events/#{event.fetch("id")}.json") }
    end

    client.store
  end
end
