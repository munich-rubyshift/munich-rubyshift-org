class Api::V1::CFPSerializer < Api::V1::Serializer
  attribute :slug
  attribute :name
  attribute :open_date
  attribute :close_date
  attribute :external_url
end
