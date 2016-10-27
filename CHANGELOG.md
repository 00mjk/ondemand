## Unreleased

Features:

  - implement nginx sendfile feature for optimal static file downloads

Bugfixes:

  - fix for app checks under restrictive NFS permissions as `root`

## 0.0.13 (2016-10-11)

Features:

  - add query parameter that forces file to be downloaded by browser

## 0.0.12 (2016-10-11)

Features

  - added a download uri that serves files directly off of the filesystem

## 0.0.11 (2016-09-22)

Bugfixes:

  - fixes/simplifications to default yaml configuration file
  - display help msg by default if CLI called with no arguments
  - added back javascript dependency for GA due to caching issues

## 0.0.10 (2016-09-14)

Features:

  - removed javascript dependency when setting GA dimensions

## 0.0.9 (2016-08-30)

Features:

  - added timestamp (hit scope) dimension in Google Analytics
  - added user id (user scope) dimension in Google Analytics

## 0.0.8 (2016-08-09)

Features:

  - added session id tracking in Google Analytics
  - use wrappers for Passenger binaries (ruby/node/python), allows apps to
    override system-installed binary

Bugfixes:

  - moved GA to end of `<head>` tag from `<body>`

## 0.0.7 (2016-06-17)

Bugfixes:

  - updated Google Analytics account number used in metrics reporting

## 0.0.6 (2016-06-03)

Features:

  - added Python as a configuration option
  - set Node.js and Python binary paths as optional
  - uses a full URL now in PUN config for redirection when app doesn't exist
  - added Google analytics (metrics reporting required by project)
  - added `nginx_show` command (lists details of currently running PUN)
  - added `nginx_list` command (lists all users with running PUNs)
  - added `nginx_clean` command (stops all running PUNs w/ no active connections)
  - added `app_reset` command (resets all app configs using current template)
  - added `app_list` command (lists all staged app configs)
  - added `app_clean` command (deletes all stale app configs)
  - check if user has disabled shell when starting PUN with `pun` command
  - changed default location for dev apps

Bugfixes:

  - fixed string concatenation bug (e867eacb31bfe1f7b03e614bd38ede1dd151ca8a)
  - set Nginx tmp root back to local disk (1be2542a249c112d12eba469281147fa6be64cd5)
  - use local disk paths for staging location of user shared apps (7546c036fc2c458b9d3f60ec2412bd26a43081e2)
  - can create `User` object from any string-like object (26ad291bf9b93e9371826e207936bf2edbf2c12a)


## 0.0.5 (2016-04-15)

  - refactored Configuration module to reduce duplication

Features:

  - move config file parsing from binary to library
  - separated paths where pun and app configs are stored for easier config
    cleanup
  - directly spawn Rails apps to keep all apps under parent process
  - removed unix group whitelists as this should be responsibility of apps and
    file permissions (provides greater flexibility)
  - set Nginx tmp root to user's home directory to allow for larger file
    uploads
  - introduced/renamed possible app environments to: `dev`, `usr`, and `sys`
  - regenerates default config file if doesn't exist or nothing set in it

Bugfixes:

  - `rake install` doesn't depend on `git` anymore
  - fixed crash when config file was empty

## 0.0.4 (2016-04-04)

Features:

  - display user name in process information
  - set maximum upload file size to 10 GB in nginx config
  - uses unix group whitelists for consumers and publishers of apps
  - sys admins can now define configuration options in `config/nginx_stage.yml`
  - sys admins can now define PUN environment in `bin/ood_ruby` wrapper script

Bugfixes:

  - uses URL escaped strings for CLI arguments (security fix)
  - app requests with periods in the app name now work
  - fixed code typo in `User` class
  - use "restart" (stop + start) instead of "reload" after generating app
    config (takes advantage of `Open3` for executing nginx binary)
  - `rake install` now only installs git version checked out (fixes strange
    behavior with older versions)

## 0.0.3 (2016-02-04)

  - refactoring & internal cleanup

Features:

  - added `rake install` for simpler installation
  - options for a command are now specified in the corresponding generator
  - user can now get individualized help messages corresponding to a command

Bugfixes:

  - the `exec` call is made more secure

## 0.0.2 (2016-01-20)

Features:

  - add app initialization redirect URI option `pun -app-init-uri` if app not
    found by nginx
  - added `nginx` subcommand for easier control of nginx process

Bugfixes:

  - sanitize user input from command line
  - refactoring, cleanup internal configuration code making it more readable

## 0.0.1 (2016-01-14)

Features:

  - Initial release
