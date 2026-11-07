require "test_helper"

class Rubyevents::TalkIdsTest < ActiveSupport::TestCase
  test "names a talk after its one or two speakers" do
    one = talk("Gems are overrated")
    two = talk("Pairing")

    ids = ids(one => [ "Hans Schnedlitz" ], two => [ "Ada Lovelace", "Grace Hopper" ])

    assert_equal "hans-schnedlitz-ev", ids[one]
    assert_equal "ada-lovelace-grace-hopper-ev", ids[two]
  end

  test "transliterates names the way upstream does, not the way our slugs do" do
    one = talk("Ruby")

    assert_equal "umit-muessig-ev", ids(one => [ "Ümit Müßig" ])[one]
  end

  test "names a talk without one or two speakers after its kind, or its title for a plain talk" do
    panel = talk("Ruby in 2030", kind: "panel")
    plain = talk("Three of us")
    unknown = talk("Mystery", kind: "lightning_talk")

    ids = ids(panel => [ "A", "B", "C" ], plain => [ "A", "B", "C" ], unknown => [ "TODO" ])

    assert_equal "panel-ev", ids[panel]
    assert_equal "three-of-us-ev", ids[plain]
    assert_equal "lightning-talk-ev", ids[unknown]
  end

  test "adds the kind when a speaker gives two talks, and leaves the plain one alone" do
    plain = talk("Gems are overrated")
    lightning = talk("Gems again", kind: "lightning_talk")

    ids = ids(plain => [ "Hans Schnedlitz" ], lightning => [ "Hans Schnedlitz" ])

    assert_equal "hans-schnedlitz-ev", ids[plain]
    assert_equal "hans-schnedlitz-lightning-talk-ev", ids[lightning]
  end

  test "falls back to the title, then to a number" do
    first = talk("Gems are overrated")
    second = talk("Gems are underrated")
    third = talk("Gems are underrated")

    ids = ids(first => [ "Hans Schnedlitz" ], second => [ "Hans Schnedlitz" ], third => [ "Hans Schnedlitz" ])

    assert_equal "gems-are-overrated-ev", ids[first]
    assert_equal "gems-are-underrated-1-ev", ids[second]
    assert_equal "gems-are-underrated-2-ev", ids[third]
  end

  test "keeps a hand-maintained id and moves derived ones out of its way" do
    kept = talk("Old talk", rubyevents_slug: "hans-schnedlitz-ev")
    derived = talk("New talk")

    ids = ids(kept => [ "Someone Else" ], derived => [ "Hans Schnedlitz" ])

    assert_equal "hans-schnedlitz-ev", ids[kept]
    assert_equal "new-talk-ev", ids[derived]
  end

  test "derives nothing without an event id" do
    one = talk("Gems are overrated")

    assert_nil Rubyevents::TalkIds.new(nil, one => [ "Hans Schnedlitz" ])[one]
  end

  private

  def talk(title, kind: "talk", rubyevents_slug: nil)
    Talks::Talk.new(title: title, kind: kind, rubyevents_slug: rubyevents_slug)
  end

  def ids(talks)
    Rubyevents::TalkIds.new("ev", talks)
  end
end
