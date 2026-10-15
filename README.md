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

Uploaded files, like people's avatars and organizations' logos, live in
`content/storage`. That's a git submodule backed by
[rubyshift-storage](https://github.com/munich-rubyshift/rubyshift-storage),
so a plain clone doesn't download all of them.

You only need the files to add, replace or remove one:

```sh
git submodule update --init content/storage
```

The submodule's URL is relative to this repo's. If you work from a fork,
fork rubyshift-storage as well.

`git pull` doesn't update the submodule. Run `git submodule update` after
pulling, or set `git config submodule.recurse true` once.

Without the submodule, the app and `bin/static-build` show a grey box in
place of each image. With the submodule checked out, a missing file is an
error, as it would be on CI.

To add or remove an image:

- Run `git -C content/storage switch main`, as `git submodule update`
  leaves the submodule on a detached HEAD.
- Upload or remove it in Avo, on the person's or organization's edit page.
  This only works with the submodule checked out.
- Commit and push the change in `content/storage`.
- Then commit the changed `content/data` YAML together with the
  submodule's new commit (`git add content/data content/storage`) in this
  repo. CI fails to check out a submodule commit that isn't pushed.

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
