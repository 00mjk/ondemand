# mod_ood_proxy

An Apache httpd module implementing the Open OnDemand proxy API.

## Requirements

- Apache httpd 2.4 or newer (and the following modules)
    - mod_lua
    - mod_env
    - mod_proxy
        - mod_proxy_connect
        - mod_proxy_wstunnel
    - mod_auth_*

Installation uses a `Rakefile` so `rake` is required for installation only.

## Installation

1.  Clone/pull this repo onto the local file system
    - first time installation

        ```
        git clone <repo> /path/to/repo
        ```
    - updating

        ```
        cd /path/to/repo
        git pull
        ```

2.  Install a specific version in default location

    ```
    cd /path/to/repo
    git checkout tags/vX.Y.Z
    sudo rake install
    ```

    this will install the specifed version `X.Y.Z` in `/opt/ood/mod_ood_proxy`

    Note: Running `sudo` will sanitize your current environment. For the case
    of RHEL using Software Collections it is recommended to load the
    environment inside the `sudo` process:

    ```
    cd /path/to/repo
    git checkout tags/vX.Y.Z
    sudo scl enable rh-ruby22 -- rake install
    ```

    Examples:

    ```
    # Install v1.0.0 of mod_ood_proxy to /opt/ood/mod_ood_proxy
    git checkout tags/v1.0.0
    sudo rake install

    # Install v2.0.0 of mod_ood_proxy to /tmp/mod_ood_proxy-v2.0.0
    git checkout tags/v2.0.0
    sudo rake install PREFIX=/tmp/mod_ood_proxy-v2.0.0
    ```

    **Warning**: This will overwrite git-committed existing files.

3.  Restart your Apache server.

## API

Unless otherwise specified, any call to a `mod_ood_proxy` handler listed below
in the Apache config should be done in the `LuaHookFixups` hook. This is the
final 'fix anything' phase before the content handlers are run. This will
ensure any authentication modules are called before the `mod_ood_proxy`
handlers and then followed up by the proxy module to handle the content.

```
LuaHookFixups node_proxy.lua node_proxy_handler
```

Unfortunately there is no easy way to pass arguments to a Lua handler. The
method we have devised is by using CGI variables defined in `mod_env` that are
set in a phase that occurs before the `LuaHookFixups` hook.

```
# Argument set before LuaHookFixups phase
SetEnv ARG_FOR_LUA "value of argument"

# Use example_handler Lua code in LuaHookFixups phase
LuaHookFixups example.lua example_handler
```

The variables are then accessed in the `mod_lua` handler as

```lua
-- example.lua

function example_handler(r)
  local arg_for_lua = r.subprocess_env['ARG_FOR_LUA']

  -- do stuff

  return apache2.DONE
end
```

### nginx_handler

This handler stages & controls the per-user NGINX process for the authenticated
user. It is also responsible for staging the application configuration files,
reloading the PUN process, and re-directing the user to the application.

#### Required Arguments

Argument          | Definition
----------------- | ----------
OOD_USER_MAP_CMD  | Full path to binary that maps the authenticated user name to the system-level user name. See `osc-user-map` as example.
OOD_PUN_STAGE_CMD | Full path to the binary that stages/controls the per-user NGINX processes. See `nginx_stage` for further details on this binary.
OOD_NGINX_URI     | The sub-URI that namespaces this handler from the other handlers [`/nginx`].
OOD_PUN_URI       | The sub-URI that namespaces the PUN proxy handler [`/pun`].

#### Usage

A typical Apache config will look like...

```
<Location "/nginx">
  AuthType openid-connect
  Require valid-user

  SetEnv OOD_USER_MAP_CMD "/path/to/user-map-cmd"
  SetEnv OOD_PUN_STAGE_CMD "/path/to/nginx_stage"
  SetEnv OOD_NGINX_URI "/nginx"
  SetEnv OOD_PUN_URI "/pun"

  LuaHookFixups nginx.lua nginx_handler
</Location>
```

Assuming you define `OOD_NGINX_URI` as `/nginx` and `OOD_PUN_URI` as `/pun`,
the `nginx_handler` implements the following sub-URIs:

sub-URI example                 | Action
------------------------------- | ------
`/nginx/init?redir=/pun/my/app` | Calls `nginx_stage app -u <user> -i /pun -r /my/app` (which generates an app config for the user and reloads his/her PUN). If successful, the user's browser is redirected to `/pun/my/app`.
`/nginx/start[?redir=<redir>]`  | Calls `nginx_stage pun -u <user> -a /init?redir=$http_x_forwarded_escaped_uri` (which generates a PUN config and starts his/her PUN). The final argument in the command is used in NGINX to redirect the user if the requested app doesn't exist (i.e., it sends them to the URI listed above to generate the app). A `<redir>` URL is optional.
`/nginx/stop[?redir=<redir>]`   | Calls `nginx_stage nginx -u <user> -s stop` (which sends the `stop` signal to the PUN process). A `<redir>` URL is optional.

### pun_proxy_handler

This handler proxies the authenticated user's traffic to his/her backend PUN
through a Unix domain socket. If the user's PUN is down, then the user will be
redirected to `OOD_NGINX_URI/start?redir=<redir>` to start up their PUN.

#### Required Arguments

Argument            | Definition
------------------- | ----------
OOD_USER_MAP_CMD    | Full path to binary that maps the authenticated user name to the system-level user name. See `osc-user-map` as example.
OOD_PUN_SOCKET_ROOT | Full path to the root location where all the PUNs keep their sockets. In most typical installations this will be `/var/run/nginx`.
OOD_NGINX_URI       | The sub-URI that namespaces this handler from the other handlers [`/nginx`].

#### Usage

A typical Apache config will look like...

```
<Location "/pun">
  AuthType openid-connect
  Require valid-user

  SetEnv OOD_USER_MAP_CMD "/path/to/user-map-cmd"
  SetEnv OOD_PUN_SOCKET_ROOT "/path/to/nginx/sockets"
  SetEnv OOD_NGINX_URI "/nginx"

  LuaHookFixups pun_proxy.lua pun_proxy_handler
</Location>
```

All requests underneath this sub-URI are proxied to the backend PUN. Very
little logic is handled in this handler aside from connecting the authenticated
user to their correct Unix domain socket.

### node_proxy_handler

This handler proxies the authenticated user's traffic to a backend node web
server though an IP socket. The backend node webserver is defined by a hostname
and port that is specified in the URL request.

#### Required Arguments

Argument         | Definition
---------------- | ----------
OOD_USER_MAP_CMD | Full path to binary that maps the authenticated user name to the system-level user name. See `osc-user-map` as example.
OOD_NODE_URI     | The sub-URI that namespaces this handler from the other handlers [`/node`].
OOD_IS_RELATIVE  | Whether the base sub-URI (`/node/HOST/PORT`) should be stripped off when sent to backend proxy.

#### Usage

A typical Apache config will look like...

```
<Location "/node">
  AuthType openid-connect
  Require valid-user

  SetEnv OOD_USER_MAP_CMD "/path/to/user-map-cmd"
  SetEnv OOD_NODE_URI "/node"
  #SetEnv OOD_IS_RELATIVE "true"

  LuaHookFixups node_proxy.lua node_proxy_handler
</Location>
```

Assuming you define `OOD_NODE_URI` as `/node`, the `node_proxy_handler`
implements the following sub-URI strategy:

```
https://apps.ondemand.org/node/HOST/PORT/index.html
#=> http://HOST:PORT/node/HOST/PORT/index.html

wss://apps.ondemand.org/node/HOST/PORT/socket.io
#=> ws://HOST:PORT/node/HOST/PORT/socket.io
```

The backend web server will need to use `/node/HOST/PORT` as its base URI. This
should be programmatically determined before the backed web server is started
depending on the host and port it will listen on.

If you define `OOD_IS_RELATIVE` to any value, the following sub-URI strategy is
used instead:


```
https://apps.ondemand.org/node/HOST/PORT/index.html
#=> http://HOST:PORT/index.html

wss://apps.ondemand.org/node/HOST/PORT/socket.io
#=> ws://HOST:PORT/socket.io
```

Any links on the backend web server must be relative links for this to work:

```html
<!-- this will WORK -->
<img src="images/header.png">

<!-- this will FAIL -->
<img src="/images/header.png">
```

## `OOD_USER_MAP_CMD` Specification

All of the above API handlers make use of the `OOD_USER_MAP_CMD` to map the
authenticated user to the system-level user. Whatever binary or script that is
used must follow the below guidelines for it to work with `mod_ood_proxy`.

1.  Must accept a single argument that is URL encoded

    **Example:**

    User is authenticated as `383927209823098423@accounts.google.com`.

    The below command will be called:

    ```
    OOD_USER_MAP_CMD '383927209823098423%40accounts.google.com'
    ```

2.  If successfully mapped to a system-level user, must return only the user
    name to `stdout` in the first line.

    **Example:**

    ```
    $ OOD_USER_MAP_CMD '383927209823098423%40accounts.google.com'
    bob123
    ```

3.  If unsuccessful at mapping to a system-level user, must return an empty
    string to `stdout` in the first line.

    **Example:**

    ```
    $ OOD_USER_MAP_CMD '383927209823098423%40accounts.google.com'
    <blank>
    ```

    Note: Can return error message to `stderr` for debugging purposes as it is ignored in production.
