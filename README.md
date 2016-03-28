# mod_ood_proxy

An Apache httpd module implementing the Open OnDemand proxy API.

## Requirements

- Apache httpd 2.4 [[Documentation](https://httpd.apache.org/docs/2.4/)]
- mod_lua [[Documentation](https://httpd.apache.org/docs/2.4/mod/mod_lua.html)]
- mod_env [[Documentaiton](https://httpd.apache.org/docs/2.4/mod/mod_env.html)]
- mod_proxy [[Documentation](https://httpd.apache.org/docs/2.4/mod/mod_proxy.html)]
    - mod_proxy_connect
    - mod_proxy_wstunnel
- mod_auth_*

## Installation

Todo...

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

Arguments required by the handler:

Argument          | Definition
----------------- | ----------
OOD_USER_MAP_CMD  | Full path to binary that maps the authenticated user name to the system-level user name. See `osc-user-map` as example.
OOD_PUN_STAGE_CMD | Full path to the binary that stages/controls the per-user NGINX processes. See `nginx_stage` for further details on this binary.
OOD_NGINX_URI     | The sub-URI that namespaces this handler from the other handlers [`/nginx`].
OOD_PUN_URI       | The sub-URI that namespaces the PUN proxy handler [`/pun`].

A typical Apache config will look like...

```
SetEnv OOD_USER_MAP_CMD "/path/to/user-map-cmd"
SetEnv OOD_PUN_STAGE_CMD "/path/to/nginx_stage"
SetEnv OOD_NGINX_URI "/nginx"
SetEnv OOD_PUN_URI "/pun"

LuaHookFixups nginx.lua nginx_handler
```

Assuming you define `OOD_NGINX_URI` as `/nginx` and `OOD_PUN_URI` as `/pun`,
the `nginx_handler` implements the following sub-URIs:

sub-URI example                 | Action
------------------------------- | ------
`/nginx/init?redir=/pun/my/app` | Calls `nginx_stage app -u <user> -i /pun -r /my/app` (which generates an app config for the user and reloads his/her PUN). If successful, the user's browser is redirected to `/pun/my/app`.
`/nginx/start[?redir=<redir>]`  | Calls `nginx_stage pun -u <user> -a /init?redir=$http_x_forwarded_escaped_uri` (which generates a PUN config and starts his/her PUN). The final argument in the command is used in NGINX to redirect the user if the requested app doesn't exist (i.e., it sends them to the URI listed above to generate the app). A `<redir>` URL is optional.
`/nginx/reload[?redir=<redir>]` | Calls `nginx_stage nginx -u <user> -s reload` (which sends the `reload` signal to the PUN process). A `<redir>` URL is optional.
`/nginx/stop[?redir=<redir>]`   | Calls `nginx_stage nginx -u <user> -s stop` (which sends the `stop` signal to the PUN process). A `<redir>` URL is optional.

### pun_proxy_handler

This handler proxies the authenticated user's traffic to his/her backend PUN
through a Unix domain socket. If the user's PUN is down, then the user will be
redirected to `OOD_NGINX_URI/start?redir=<redir>` to start up their PUN.

### node_proxy_handler

Todo...

## `OOD_USER_MAP_CMD` Details

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

2.  If successfully mapped to a system-level user, must return only the user name to `stdout`.

    **Example:**

    ```
    $ OOD_USER_MAP_CMD '383927209823098423%40accounts.google.com'
    bob123
    ```

3.  If unsuccessful at mapping to a system-level user, must return an empty string to `stdout`.

    **Example:**

    ```
    $ OOD_USER_MAP_CMD '383927209823098423%40accounts.google.com'
    <blank>
    ```

    Note: Can return error message to `stderr`.
