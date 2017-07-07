# OOD Dashboard

[![GitHub version](https://badge.fury.io/gh/OSC%2Food-dashboard.svg)](https://badge.fury.io/gh/OSC%2Food-dashboard)

This app is a Rails app for Open OnDemand that serves as a gateway to launching
other Open OnDemand apps. It is meant to be run as the user (and on behalf of
the user) using the app. Thus, at an HPC center if I log into OnDemand using
the `efranz` account, this app should run as `efranz`. This Rails app doesn't
use a database.

## New Install


1. Start in the **build directory** for all sys apps, clone and check out the
   latest version of the dashboard app (make sure the app directory's name is
   `dashboard`):

   ```sh
   scl enable git19 -- git clone https://github.com/OSC/ood-dashboard.git dashboard
   cd dashboard
   scl enable git19 -- git checkout tags/v1.13.3
   ```

2. Install the app for a production environment:

   ```sh
   RAILS_ENV=production scl enable git19 rh-ruby22 nodejs010 -- bin/setup
   ```

   this will setup a default Open OnDemand install. If you'd like a specific
   pre-defined portal such as OSC OnDemand you'd specify `OOD_SITE` and
   `OOD_PORTAL` as:

   ```sh
   OOD_SITE=osc OOD_PORTAL=ondemand RAILS_ENV=production scl enable git19 rh-ruby22 nodejs010 -- bin/setup
   ```

   assuming the corresponding `.env.local.$OOD_SITE.$OOD_PORTAL` file exists.

3. Copy the built app directory to the deployment directory, and start the
   server. i.e.:

   ```sh
   sudo mkdir -p /var/www/ood/apps/sys/dashboard
   sudo cp -r . /var/www/ood/apps/sys/dashboard
   ```

## Updating to a New Stable Version

1. Navigate to the app's build directory and check out the latest version:

   ```sh
   cd dashboard # cd to build directory
   scl enable git19 -- git fetch
   scl enable git19 -- git checkout tags/v1.13.3
   ```

2. Update the app for a production environment:

   ```sh
   RAILS_ENV=production scl enable git19 rh-ruby22 nodejs010 -- bin/setup
   ```

   You do not need to specify `OOD_SITE` and `OOD_PORTAL` if they are defined
   in the `.env.local` file.

3. Copy the built app directory to the deployment directory:

   ```sh
   sudo rsync -rlptv --delete . /var/www/ood/apps/sys/dashboard
   ```

## Configuration

See the wiki page https://github.com/OSC/ood-dashboard/wiki/Configuration-and-Branding

### Message Of The Day

See the wiki page https://github.com/OSC/ood-dashboard/wiki/Message-of-the-Day

### Site-wide announcement

See the wiki page https://github.com/OSC/ood-dashboard/wiki/Site-Wide-Announcement

### App Sharing

**This is a feature currently in development. The documentation below is for developers working on this feature.**

See the wiki page https://github.com/OSC/ood-dashboard/wiki/App-Sharing

### Safari Warning

We currently display an alert message at the top of the Dashboard mentioning
that we don't currently support the Safari browser. This is because of an issue
in Safari where it fails to connect to websockets if the Apache proxy uses
Basic Auth for user authentication (on by default for new OOD installations).

If you ever change the authentication mechanism to a cookie-based mechanism
(e.g., Shibboleth or OpenID Connect), then it is recommended you disable this
alert message in the dashboard.

You can do this by modifying the `.env.local` file as such:

```sh
# .env.local

# ... all of your other settings ...

# Set this to disable Safari + Basic Auth warning
DISABLE_SAFARI_BASIC_AUTH_WARNING=1
```

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/OSC/ood-dashboard.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
