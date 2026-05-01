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
- If your server fails to shut down cleanly or fails to boot, delete the `.sqlite3` files from `storage/`.
- Use `git` to restore data from the `main` branch.
- Data that you entered during your current session might not have been written to `content/data/` and might be lost (unless you want to extract it from SQLite manually). We'll try to make this less annoying in the future. In the meantime, don't enter data
for extended periods of time without stopping your Rails server and committing a save state.

Assets:
- When adding new assets, they might not get picked up automatically. Restart `yarn build --watch`.
