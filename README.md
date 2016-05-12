# ood-portal-generator

Generates an Open OnDemand portal config for an Apache server.

## Requirements

### Generate OOD Portal config

- Ruby 1.9 or newer

### Run OOD Portal config

- Apache httpd 2.4.12 or newer (and the following modules)

| module requirements                                |
| -------------------------------------------------- |
| mod_ood_proxy                                      |
| mod_lua                                            |
| mod_env                                            |
| mod_proxy (mod_proxy_connect + mod_proxy_wstunnel) |
| mod_auth_* (e.g., mod_auth_openidc)                |

If using OOD recommended authentication (built with `OOD_AUTH_SETUP='true'`):

- mod_auth_openidc / CILogon Client ID and Client Secret ([Discussed Here](#cilogon-setup))
- ood_auth_discovery (PHP scripts)
- ood_auth_registration (PHP scripts)
- ood_auth_map (ruby CLI script)
- mapdn (also relevant python scripts)

Note: The above authentication setup utilizes a `grid-mapfile` for
storing/accessing the mapping of the authenticated user to the system-level
user.

## Installation

1.  Clone/pull this repo onto the local file system
    - first time installation

        ```bash
        git clone <repo> /path/to/repo
        ```
    - updating

        ```bash
        cd /path/to/repo
        git pull
        ```

2.  Checkout a specific version of the `ood-portal-generator`

    ```bash
    git checkout tags/vX.Y.Z
    ```

    where `X.Y.Z` is the version number. For example

    ```bash
    git checkout tags/v1.0.0
    ```

    will checkout `v1.0.0` of the `ood-portal-generator`.

3.  Build the Apache config using the default **environment variables**
    outlined [below](#default-options).

    ```bash
    # Generate Apache config in `/build`
    rake

    # If using Software Collections, set Ruby environment
    #scl enable rh-ruby22 -- rake
    ```

    To modify any configuration options from the default, specify it after the
    `rake` command

    ```bash
    # Generate Apache config in `/build`
    rake OOD_PUBLIC_ROOT='/var/www/docroot' OOD_PUBLIC_URI='/public'

    # If using Software Collections, set Ruby environment
    #scl enable rh-ruby22 -- rake OOD_AUTH_TYPE='openid-connect'
    ```

4.  Verify that the Apache config file is generated correctly in

    ```
    build/ood-portal.conf
    ```

    If you'd like to make a change to the above file, then run

    ```
    # Clean up config file
    rake clean

    # If using Software Collections, set Ruby environment
    #scl enable rh-ruby22 -- rake clean
    ```

    and re-build the config file from step `#3` with the desired configuration
    options.

5.  Install the Apache config that defines the OOD portal

    ```bash
    # Install Apache config in default PREFIX
    sudo rake install

    # Using Software Collections, use this instead
    #sudo scl enable rh-ruby22 -- rake install
    ```

    The default install location is

    ```
    PREFIX=/opt/rh/httpd24/root/etc/httpd/conf.d
    ```

    To change this run


    ```bash
    # Install Apache config in different PREFIX
    sudo rake install PREFIX='/etc/httpd/conf.d'
    ```

## Default Options

The default options used to generate the Apache config are listed below. You
can modify any of these by setting the corresponding environment variable when
calling the `rake` task.

#### Build Options

```bash
# Path for installation in `rake install`
#
PREFIX='/opt/rh/httpd24/root/etc/httpd/conf.d'

# Directory with ERB templates
#
SRCDIR='templates'

# Directory for temporary rendered configs
#
OBJDIR='build'

# Filename of rendered config
#
OBJFILE='ood-portal.conf'
```

#### Server Options

```bash
# IP used for Open OnDemand portal
# Blank: Remove `Listen` & `<VirtualHost>` directives
#
OOD_IP=''

# Port used for Open OnDemand portal
#
OOD_PORT='443'

# Whether SSL is used
#
OOD_SSL='true'

# Whether http traffic is redirected to https
#
OOD_SSL_REDIRECT='true'

# ServerName used for the Open OnDemand portal
#
OOD_SERVER_NAME='www.example.com'
```

#### System Options

```bash
# Path to the Open OnDemand Lua scripts
# Blank: Remove `LuaRoot` directive
#
OOD_LUA_ROOT='/opt/ood/mod_ood_proxy/lib'

# Command used to stage PUNs
#
OOD_PUN_STAGE_CMD='sudo /opt/ood/nginx_stage/sbin/nginx_stage'

# Maximum number of retries when trying to start the PUN
#
OOD_PUN_MAX_RETRIES='5'

# Command used to map users to system level users
#
OOD_USER_MAP_CMD='/opt/ood/osc-user-map/bin/osc-user-map'

# Path to the root location of PUN socket files
#
OOD_PUN_SOCKET_ROOT='/var/run/nginx'

# Path to publicly available assets
#
OOD_PUBLIC_ROOT='/var/www/docroot/ood/public'
```

#### OOD Portal URIs

```bash
# Reverse proxy to backend PUNs
# Blank: Removes the availability of this URI in the config
#
OOD_PUN_URI='/pun'

# Reverse proxy to backend nodes
# Blank: Removes the availability of this URI in the config
#
OOD_NODE_URI='/node'

# "Relative" reverse proxy to backend nodes
# Blank: Removes the availability of this URI in the config
#
OOD_RNODE_URI='/rnode'

# Control the backend PUN (e.g., start, stop, reload, ...)
# Blank: Removes the availability of this URI in the config
#
OOD_NGINX_URI='/nginx'

# Serve up publicly available assets
# Blank: Removes the availability of this URI in the config
#
OOD_PUBLIC_URI='/public'

# Redirect root URI "/" to this URI
# Blank: Removes this redirection
#
OOD_ROOT_URI='/pun/sys/dashboard'
```

#### OOD Authentication Options

**Use Recommended OOD Authentication Setup**

This authentication mechanism takes advantage of:

- `mod_auth_openidc` for the authentication handler in Apache
- CILogon for the OpenID Connect Identity Provider
- PHP for handling discovery and registration
- `grid-mapfile` for mapping authenticated user to system user
- LDAP for authenticating system user in PHP

```bash
# Whether you want to use OOD recommended authentication
#
OOD_AUTH_SETUP='true'

# The mod_auth_openidc redirect URI
#
OOD_AUTH_OIDC_URI='/oidc'

# Path to OpenID Connect discovery php scripts
#
OOD_AUTH_DISCOVER_ROOT='/var/www/ood/discover'

# The mod_auth_openidc discovery URI
#
OOD_AUTH_DISCOVER_URI='/discover'

# Path to the registration php scripts
#
OOD_AUTH_REGISTER_ROOT='/var/www/ood/register'

# The URI user is redirected to if they aren't registered in grid-mapfile
#
OOD_AUTH_REGISTER_URI='/register'
```

**Custom Authentication Setup**

This is used if admin provides their own authentication mechanism.

```bash
# Whether you want to use OOD recommended authentication
# Default: 'true'
#
OOD_AUTH_SETUP='false'

# Type of user authentication used for Open OnDemand portal
#
OOD_AUTH_TYPE='Basic'

# Redirect user to this URI if fail to map to system level user
# Blank: Removes the redirection upon a failed user mapping
#
OOD_MAP_FAIL_URI=''
```

## Configuration File

If the default options or using environment variables to make changes do not
meet your needs, then you can specify the configuration options in
`config.rake` as such

```ruby
# config.rake

OOD_USER_MAP_COMMAND = '/usr/local/bin/my-usr-map'
OOD_PUBLIC_ROOT = '/var/www/docroot'
```

Options specified in `config.rake` take precendence over the corresponding
environment variable set.

## CILogon Setup

If using the OOD recommended authentication scheme, you will need an
appropriate Apache config that specifies the global `mod_auth_openidc` settings
you want. An example of such is given here:

```
# /path/to/httpd/conf.d/auth_openidc.conf

OIDCMetadataDir      /path/to/oidc/metadata
OIDCDiscoverURL      https://www.example.com/discover
OIDCRedirectURI      https://www.example.com/oidc
OIDCCryptoPassphrase "<Chosen Passphrase>"

# Keep sessions alive for 8 hours
OIDCSessionInactivityTimeout 28800
OIDCSessionMaxDuration 28800
```

This sets the global `mod_auth_openidc` settings used by all IdP's. Now we
setup the CILogon IdP specific settings in three separate json files:

- `/path/to/oidc/metadata/cilogon.org.provider`

    ```json
    {
      "issuer": "https://cilogon.org",
      "authorization_endpoint": "https://cilogon.org/authorize",
      "token_endpoint": "https://cilogon.org/oauth2/token",
      "userinfo_endpoint": "https://cilogon.org/oauth2/userinfo",
      "response_types_supported": [
        "code"
      ],
      "token_endpoint_auth_methods_supported": [
        "client_secret_post"
      ]
    }
    ```

- `/path/to/oidc/metadata/cilogon.org.client`

    ```json
    {
      "client_id": "<CLIENT ID>",
      "client_secret": "<CLIENT SECRET>"
    }
    ```

- `/path/to/oidc/metadata/cilogon.org.conf`

    ```json
    {
      "scope": "openid email profile org.cilogon.userinfo",
      "response_type": "code",
      "auth_request_params": "skin=default"
    }
    ```


## Version

To list the current version being used when building an OOD Portal config file,
use:

```bash
rake version
```

For individual configs, the version is listed in the header of the file.
