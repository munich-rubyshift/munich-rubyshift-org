# rubyevents import prototype

Builds rubyevents' data files for Munich Rubyshift from our JSON:API, the way
rubyevents' `bin/update_lrug_meetups` takes LRUG's playlist: fetch, write the
YAML, `yerba apply`, commit what changed.

```sh
bin/rails server                      # the API at localhost:3000/api/v1
YERBA=path/to/yerba script/rubyevents/import [--api URL]
```

It writes to `tmp/rubyevents` and lists what it merged.

## Layers

- `lib/json_api.rb`: a JSON:API client and what to fetch from us. Stable as long
  as our API is.
- `lib/rubyevents.rb`: how our resources become rubyevents' files. rubyevents
  adapts this one whenever their schemas or rules change.
  `lib/talk_kind.rb` is a copy of their `Talk::Kind`.

## Rules

- `data/munich-rubyshift/` is replaced as a whole, without cancelled events.
  Event ids are the series id plus our event slug; talk ids follow their
  `Talk::StaticID`.
- `speakers.yml`, `organizations.yml` and `featured_cities.yml` are merged: ours
  wins for every value we have, theirs stays for the rest, and entries we don't
  change keep their text. A record is found by its `rubyevents_slug`, then its
  slug (and GitHub handle for people), then its name. A renamed speaker or
  organization keeps the old name as an alias.

## snapshot/

rubyevents' Yerbafile, `lib/schemas` and the three global lists, copied from
their branch `dunkelziffer/create-data-organizations-yml` at 7cb4aa786. Inside
rubyevents the script would work on the checkout instead.

## Checking the result in rubyevents

Copy `tmp/rubyevents/data/munich-rubyshift` and the three lists into a
rubyevents checkout and run `bin/rails validate:all`. The first import also
needs their assets moved from `app/assets/images/events/munich-rubyshift/munich-rubyshift`
to `.../munich-rubyshift/default`, because the single meetup event they keep for
us today becomes one event per meetup.

## Tests

```sh
bundle exec ruby -e 'Dir["script/rubyevents/test/*_test.rb"].each { |file| require "./#{file}" }'
```
