# How to contribute

Community patches, bug reports and contributions are always welcome and are crucial to ensure *Radiant Player* stays stable. This should be as easy as possible for you but there are few things to consider when contributing. The following guidelines for contribution should be followed if you want to submit a Pull Request.

## How to prepare

* You need a [GitHub account](https://github.com/signup/free)
* Submit an [issue ticket](https://github.com/radiant-player/radiant-player-mac/issues) for your issue, assuming one does not already exist.
	* Clearly Describe the issue including steps to reproduce when it's a bug.
	* Check [existing pull requests](https://github.com/radiant-player/radiant-player-mac/pulls) to ensure this hasn't already been fixed.
* Fork the repository on GitHub and clone your fork to your local PC.
* Check you've [followed any required steps in the README](https://github.com/radiant-player/radiant-player-mac#development) to set up your development environment correctly.

## Make Changes

* In your own, forked repository, create a feature branch for your upcoming patch.
	* For example, if you were fixing broken CSS, you could check your local repo is looking at the master branch, before running `git checkout -b 
	broken_css` which should automatically switch you to your new branch.  Please avoid working directly on the `master` branch.
* Try to keep it to one pull request = one fix. Avoid submitting several fixes in a single pull request.
* Check for unnecessary whitespace with `git diff --check` before committing.

## Submit Changes

* Push your newly created feature branch to your fork of the repository.
* **SQUASH COMMITS INTO A SINGLE COMMIT** - a good example of how to do this is [here](http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html).
* Open a pull request ensuring the requesting a merge **from** your fork's feature branch, **to** radiant-player's `master` branch.
* If possible, update your original issue ticket with a link to the pull request so others know it's been looked at.
* Even if you have write access to the repository, do not directly push or merge pull-requests without first allowing others time to review your changes. Ideally you should have at least one :+1:, :shipit: or LGTM before you merge into master. If your changes are substantial or high risk, you may want to wait for more than one. Use your own judgement.

# Additional Resources

* [General GitHub documentation](http://help.github.com/)
* [GitHub pull request documentation](http://help.github.com/send-pull-requests/)
