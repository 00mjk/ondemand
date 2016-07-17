# OSC OnDemand Dashboard

This app is a PUN based Rails app for Open OnDemand that serves as a gateway to launching other Open OnDemand apps.

## Install

This Rails app doesn't use a database.

1\. First enable software collections, checkout the code, and install the dependencies:

```
scl enable nodejs010 rh-ruby22 git19 bash

cd /path/to/build/directory/sys
git clone clone git@github.com:OSC/ood-ondemand.git dashboard
cd dashboard
git checkout v1.0.3 # latest version
bin/bundle install --path vendor/bundle
```

2\. At this point, configure the app and its branding by copying .env to .env.local and modifying the values of the environment variables. See below for details on configuration and branding.

Update the dataroot of the `.env.production` file. This tells the production instance where to write user data - which is the user's home directory. By convention, it is `~/<PORTAL>/data`. So for OSC's OnDemand instance, our portal name is "ondemand" and thus the .env.production file has this line:

```
OOD_DATAROOT=$HOME/ondemand/data/$APP_TOKEN
```

3\. After updating the .env.local file, build the assets to complete the installation. Make sure that `RAILS_RELATIVE_URL_ROOT` is unset before running this command, as this will then be set by the `dot-env` gem, as `RAILS_RELATIVE_URL_ROOT` is set in `.env.production`.

```
RAILS_ENV=production bin/rake assets:precompile
bin/rake tmp:clear
```

4\. At this point, you should copy the directory to the deployment directory, if that location is not the same place as the build directory. For more explanation of how this is done, see https://github.com/OSC/Open-OnDemand#app-deployment-strategy.

### Update

When updating a deployed version of the Open OnDemand dashboard: 

1. do a git fetch
2. checkout the latest tag
3. rebuild the assets
4. clear the cache and touch the tmp/restart.txt file so Passenger reloads the app

## Configuration and Branding

Configuration is done within the .env file. Look at the .env file to see an example configuration for OSC.

Here are some example configuration values:

```
OOD_DASHBOARD_TITLE="OSC OnDemand <sup>beta</sub>"
OOD_PORTAL="ondemand"
MOTD_PATH="/etc/motd"
OOD_DASHBOARD_SUPPORT_URL="https://www.osc.edu/contact/supercomputing_support"
OOD_DASHBOARD_DOCS_URL="https://www.osc.edu/ondemand"
OOD_DASHBOARD_PASSWD_URL="https://my.osc.edu"
OOD_DASHBOARD_SHOW_ALL_APPS=true
```

* `OOD_PORTAL="ondemand"` - the lowercase portal name that matches the name of the installation directory and the data directory created in the user's home directory; this should also be set in the path for `OOD_DATAROOT` in the `.env.production` file
* `MOTD_PATH="/etc/motd"` - optional: the message of the day, if you have one (see below)
* `OOD_DASHBOARD_DOCS_URL` - URL to access OnDemand documentation for users
* `OOD_DASHBOARD_PASSWD_URL` - URL to access page to change your HPC password
* `OOD_DASHBOARD_SUPPORT_URL` - URL for users to get HPC support

To brand the site, you can change the title, colors, and logo of the dashboard app:

* `OOD_DASHBOARD_TITLE="OSC OnDemand <sup>beta</sub>"` - set the title of the dashboard; this can include HTML tags, such as superscript text "beta" or "1.0"
* Bootstrap variables are overridden using OodAppkit (https://github.com/OSC/ood_appkit#override-bootstrap-variables) so the nav bar colors can be modified to match the brand of the site. This is an example of changing the nav bar color to OH-TECH colors:

    ```
BOOTSTRAP_NAVBAR_INVERSE_BG='rgb(200,16,46)'
BOOTSTRAP_NAVBAR_INVERSE_LINK_COLOR='rgb(255,255,255)'
```


## Message Of The Day

* **TODO**
