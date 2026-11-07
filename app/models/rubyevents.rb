# Export of our data into the file layout and schemas used by rubyevents.org.
#
# See doc/rubyevents_schema.d2 for how our tables relate to theirs. The JSON
# schemas in lib/rubyevents/schemas are vendored verbatim from lib/schemas in
# their repository, last at commit b1af694 (2026-10-06).
module Rubyevents
  TRANSLITERATOR = I18n::Backend::Transliterator::HashTransliterator.new

  # Upstream derives ids and slugs with plain String#parameterize, so "Jürgen"
  # becomes "jurgen" there. Ours would be "juergen", because our locale
  # carries German transliteration rules for nicer slugs.
  def self.parameterize(string)
    TRANSLITERATOR.transliterate(string.to_s).parameterize
  end
end
