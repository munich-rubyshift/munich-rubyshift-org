# README

## Setup

- Install Ruby (see `.ruby-version`) and bundler
- Install Node (see `.nvmrc`) and yarn
- Run `bin/setup`

## Development

- Run `yarn build --watch` in one terminal
- Run `bin/rails s` in another terminal

CAUTION: Even though this project has a `bin/dev` file which starts
both of these processes, using it is NOT RECOMMENDED. You will probably
run into annoying issues as `foreman` will kill the Ruby process before
`static_db` has finished writing.

## Files

ActiveStorage attachments live in `content/storage`. That's a git submodule
backed by [rubyshift-storage](https://github.com/munich-rubyshift/rubyshift-storage).

Without the submodule, the app and `bin/static-build` show a grey box in
place of each image. With the submodule checked out, a missing file is an
error, as it would be on CI.

If you don't want to modify attachments, you can do a regular `git clone`
(without the submodule) and avoid downloading those files.

NOTE: If you fork this project, you will also need to replace the submodule
repo with your own one. Please don't fork `rubyshift-storage`!

Initializing all submodules (or clone with `git clone --recurse-submodules`):
```sh
git submodule update --init
```

Keeping the submodule in sync (only for your clone of this repo):
```sh
git config submodule.recurse true
```
With that, `git pull` and `git checkout` update the submodule too, and
`git push` refuses to push a commit whose files aren't pushed yet.
Otherwise, run `git submodule update` after each pull.

To add or remove an image:

1. Upload or remove it in Avo, or "Mirror" a person's GitHub avatar.
2. Commit and push the files. The submodule sits on a detached HEAD, so
   push to `main` explicitly:
   ```sh
   git -C content/storage add -A
   git -C content/storage commit -m "Add Anna's avatar"
   git -C content/storage push origin HEAD:main
   ```
3. Commit `content/data` and `content/storage` in this repo as usual.

## API

`/api/v1` publishes our data as JSON files. Its OpenAPI schema is served at
`/api/v1/schema.yaml` and rendered with Swagger UI at `/api/schema`.

`/api/rubyevents-v1` publishes the same documents for RubyEvents: there, each
record's `rubyevents_data` (a JSON object, edited in Avo) replaces or adds to
its attributes. Put what RubyEvents needs differently there, like their slugs,
instead of bending our own columns.

The schema's sources live in `doc/api/v1`. The RubyEvents schema is the same
bundle with `doc/api/rubyevents-v1/overlay.yaml` applied, an
[OpenAPI Overlay](https://spec.openapis.org/overlay/v1.0.0.html) of everything
that differs, like its title and the series' colors, so the v1 sources stay
untouched: each action targets a node of the bundle, like
`$.components.schemas.Series.properties.attributes.properties`. After editing
either, run `yarn schema:bundle` to regenerate both `public/api/*/schema.yaml`;
a test fails until you do. `redocly.yaml` turns off Redocly CLI's telemetry,
and the script turns off its update check.

Like v1, the RubyEvents schema allows no properties beyond those it lists, so
RubyEvents can rely on it. `test/integration/rubyevents_export_test.rb` checks
the documents of `content/data` against it. To export a new value for
RubyEvents:

1. Document it in `doc/api/rubyevents-v1/overlay.yaml`, in the attributes of its
   resource.
2. Run `yarn schema:bundle`.
3. Add it to the `rubyevents_data` of the records that have it, in Avo.
4. Run `bin/rails test test/integration/rubyevents_export_test.rb`.

The overlay only describes values. Add a rule of RubyEvents as a validation
`on: :rubyevents` in the serializer of its resource, like their slug rule in
`Api::V1::PersonSerializer`, never as a restriction in the overlay: a constraint
that suits our own data belongs in the v1 schema. Such a validation neither
touches v1 nor runs on save: `test/integration/rubyevents_export_test.rb` checks
every record that RubyEvents gets from `content/data`, each with its own
serializer, on CI. Without a `rubyevents_data` override, a rule constrains our
own column.

## Troubleshooting

Data:
- After a failed shutdown (e.g. due to validation errors):
  - `bin/rails s` discards all data changes from your `.sqlite3` files and recreates your DB from the YAML files.
  - There is currently no convenient way to boot your server without discarding changes in this case.
    - This will be added later, but getting invalid data into your DB should also be a rare occurrence.
- After an interrupted shutdown (e.g. due to `bin/dev` / `foreman` killing your Rails process too early):
  - Data from your `.sqlite3` files might have been dumped to YAML partially or not at all.
  - Retry dumping your data with `bin/rails static:dump`.
- Use `git` to discard changes and restore data from earlier commits.

Assets:
- When adding new assets, they might not get picked up automatically. Restart `yarn build --watch`.
