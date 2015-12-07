# Release process

This mostly applies to repository collaborators, but feel free to contribute to the process if you'd like.

## Checklist for release

- [ ] meaningful changes have taken place on master
- [ ] the CHANGELOG has been updated to reflect the changes (ideally when the pull requests were merged, or edited in a pull request if its own)
- [ ] an issue has been created on GitHub proposing the release
- [ ] that issue has been tagged with `release`
- [ ] the release issue has received approval from at least one project collaborator

## How to release

1. Ensure that any changes made to master have been documented in the `CHANGELOG` and committed to GitHub.  Ideally the `CHANGELOG` is already up to date, however if not, you will want to create a new branch, edit the `CHANGELOG`, push to GitHub and create a pull request.  Please wait until this pull request has been approved and merged before continuing.
1. Ensure you have received release approval as per the above checklist.
1. Ensure that your git working directory is clean and up to date with master.
1. Determine what version you should bump.  This project follows semver, so use the following guidelines:
  - **major** - this is for "breaking" changes and major application milestones.  This will often correspond to an actual milestone on GitHub.
  - **minor** - this is for new features and additions.
  - **patch** - this is for bugfixes.
1. Prepare the release with the `prepare-release.sh` script:
  ```shell
  $ ./scripts/prepare-release.sh [major|minor|patch]
  ```

  This script will perform some sanity checks, compute and set the new application version, and update the CHANGELOG, prompting you for confirmation and for a final git diff along the way.
1. Push to GitHub with `git push --tags` to send the new tag upstream.
1. Travis CI will then build the application, push the release to GitHub with release notes, and update the website at `gh-pages` with HTML and Sparkle XML (which pushes the update to users).
