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
