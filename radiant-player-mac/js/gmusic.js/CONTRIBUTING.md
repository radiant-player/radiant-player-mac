# Contributing
Community patches, bug reports, and contributions are always welcome and are crucial to ensure `gmusic.js` stays stable. Here are steps/guidelines to follow when contributing.

## Opening an issue
Before starting work on an issue, please make sure that the issue isn't being worked on by anyone else. This can be verified by searching in open issues and pull requests:

https://github.com/gmusic-utils/gmusic.js/issues

- If an issue already exists, please use that issue instead of creating a new one
- Otherwise, please create a new issue
    - Please restrict issues to a single feature/issue
    - If the issue is a bug report, then please provide information about your setup as well as steps to reproduce
- If the issue is time sensitive, then feel free to start work immediately
    - Please communicate that via the issue (e.g. via a comment on the thread)
- Otherwise, please wait for a core contributor to approve your work
    - This is prevent unnecessary rejection when a pull request is opened

## Making changes
To make sure that there is no duplicate work across contributors, please always [Open an issue][] before beginning work.

[Open an issue]: #opening-an-issue

When you start work, please comment on the issue that you are starting work. This is to prevent duplicate work by contributors.

- If you are a core contributor, then you may create a branch on the main repository
    - However, please clean up your branches once the PR is landed. We suggest using git-extras' `delete-branch` command for this (https://github.com/tj/git-extras)
    - We prefer to name branches to indicate the intent of the branch
        - Additionally, a prefix is nice to indicate development (`dev/`), a bug patch (`bug/`), or who is working on the issue (e.g. `todd/`)
        - Examples of good branch names: `dev/add.toggle.rating`, `bug/repair.song.title`, `marshall/fix.track.info`
- Please restrict work to 1 issue/pull request at a time
    - If there are inter-dependent issues, then please work on inter-dependent branches (e.g. `bug/fix.track.tests`, `dev/alter.track.info`)
- If you can, please run the test suite as noted in the [Testing section of the README][testing-readme]
    - Otherwise, please run our linter via `npm run lint`

[testing-readme]: /README.md#testing

## Submitting changes
To submit your changes, please open a pull request from your branch to the `gmusic.js` `master` branch. If this is for an inter-dependent branch, please still point to the `master` branch. When one PR is landed, then the other should automatically land as well.

While we don't require squashing commits for historical reasons, please avoid unnecessary commits in the final pull request. These can be cleaned up via `squash` in `git rebase -i`.

If there is a particular contributor that should review the pull request, then please add them via a "/cc @username" on the pull request.

## Approval process
Due to the brittle nature of `gmusic.js`, we must be flexible to allow for quick deployment of fixes. Please use the following guidelines when approving/landing changes.

- If the issue is time sensitive, please wait up to 24 hours to hear from another core contributor
    - If you don't hear from anyone else, then use your best judgement to land the PR or not
- If the issue is not time sensitive, please wait for at least 1 other core contributor to approve the PR (e.g. via a ":+1:", ":shipit:", or "lgtm")
    - If the PR is a large change (e.g. refactoring the library), then please use your judgement and consider waiting for more contributors
