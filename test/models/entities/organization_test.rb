require "test_helper"

class Entities::OrganizationTest < ActiveSupport::TestCase
  test "the slug follows the brand" do
    organization = Entities::Organization.create!(name: "Freeletics", legal_name: "Freeletics GmbH")

    assert_equal "freeletics", organization.slug
  end

  test "the slug falls back to the legal name without a brand" do
    organization = Entities::Organization.create!(legal_name: "makandra GmbH")

    assert_equal "makandra-gmbh", organization.slug
  end

  test "the rubyevents slug transliterates like rubyevents.org, unlike our slug" do
    organization = Entities::Organization.create!(name: "Café Größenwahn & Söhne")

    assert_equal "cafe-groessenwahn-soehne", organization.slug
    assert_equal "cafe-grossenwahn-sohne", organization.rubyevents_slug
    assert_equal "https://www.rubyevents.org/organizations/cafe-grossenwahn-sohne", organization.rubyevents_url
  end

  test "an organization without a brand has no rubyevents url" do
    organization = Entities::Organization.new(legal_name: "makandra GmbH")

    assert_nil organization.rubyevents_url
  end

  test "a brand marked as a guess slugs as the plain brand" do
    organization = Entities::Organization.create!(name: "? Zavvy ?", legal_name: "? Zavvy GmbH ?")

    assert_equal "zavvy", organization.slug
  end
end
