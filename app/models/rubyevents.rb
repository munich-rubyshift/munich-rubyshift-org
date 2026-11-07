# Export of our data into the file layout and schemas used by rubyevents.org.
#
# See doc/rubyevents_schema.d2 for how our tables relate to theirs. The JSON
# schemas in lib/rubyevents/schemas and transliterate.en.yml are vendored
# verbatim from their repository, last at commit 972481183 (2026-11-07).
module Rubyevents
  TRANSLITERATOR = I18n::Backend::Transliterator::HashTransliterator.new(
    YAML.load_file(Rails.root.join("lib", "rubyevents", "transliterate.en.yml")).dig("en", "i18n", "transliterate", "rule")
  )

  # Upstream derives ids and slugs with String#parameterize under their own
  # transliteration rules: "Jürgen" becomes "juergen", but "Ümit" "umit".
  def self.parameterize(string)
    TRANSLITERATOR.transliterate(string.to_s).parameterize
  end
end
