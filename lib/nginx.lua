local user_map = require 'ood.user_map'
local http     = require 'ood.http'

--[[
  nginx_handler

  Controls the authenticated user's PUN and/or PUN related operations using the
  Apache configured pun stage command. The relevant tasks are:
    1. 'init'  = initialize PUN app and redirect user to it
    2. 'start' = initialize PUN and start PUN process
    3. 'stop'  = send `stop` signal to PUN process
--]]
function nginx_handler(r)
  -- read in OOD specific settings defined in Apache config
  local user_map_cmd  = r.subprocess_env['OOD_USER_MAP_CMD']
  local nginx_uri     = r.subprocess_env['OOD_NGINX_URI']
  local pun_uri       = r.subprocess_env['OOD_PUN_URI']
  local pun_stage_cmd = r.subprocess_env['OOD_PUN_STAGE_CMD']
  local map_fail_uri  = r.subprocess_env['OOD_MAP_FAIL_URI']

  -- get the system-level user name
  local user = user_map.map(r, user_map_cmd)
  if not user then
    if map_fail_uri then
      return http.http302(r, map_fail_uri .. "?redir=" .. r:escape(r.unparsed_uri))
    else
      return http.http404(r, "failed to map user (" .. r.user .. ")")
    end
  end

  -- grab "redir" query param
  local GET, GETMULTI = r:parseargs()
  local redir = GET['redir']

  -- grab task specified in nginx URI request
  local task = r.uri:match("^" .. nginx_uri .. "/([^/]+)$")

  -- generate shell command from requested task
  -- please see `nginx_stage` documentation for explanation of shell command
  local pun_stage_subcmd
  local pun_stage_args = "-u '" .. r:escape(user) .. "'"
  if task == "init" then
    -- initialize app based on "redir" param (require a valid redir parameter)
    pun_stage_subcmd = "app"
    if not redir then return http.http404(r, 'requires a `redir` query parameter') end
    local pun_app_request = redir:match("^" .. pun_uri .. "(/.+)$")
    if not pun_app_request then return http.http404(r, "bad `redir` request (" .. redir .. ")") end
    pun_stage_args = pun_stage_args .. " -i '" .. r:escape(pun_uri) .. "' -r '" .. r:escape(pun_app_request) .. "'"
  elseif task == "start" then
    local redir_url = r.is_https and "https://" or "http://"
    redir_url = redir_url .. r.hostname .. ":" .. r.port .. nginx_uri .. "/init?redir=$http_x_forwarded_escaped_uri"
    -- start PUN process
    pun_stage_subcmd = "pun"
    pun_stage_args = pun_stage_args .. " -a '" .. r:escape(redir_url) .. "'"
  elseif task == "stop" then
    -- send task as signal to PUN process
    pun_stage_subcmd = "nginx"
    pun_stage_args = pun_stage_args .. " -s 'stop'"
  elseif task == "noop" then
    -- do nothing
  else
    return http.http404(r, "invalid nginx task")
  end

  -- run shell command and read in stdout/stderr
  local pun_stage_output = ""
  if task ~= "noop" then
    local handle = io.popen(pun_stage_cmd .. " " .. pun_stage_subcmd .. " " .. pun_stage_args .. " 2>&1", "r")
    pun_stage_output = handle:read("*a"); handle:close()
  end

  -- properly handle pun_stage_cmd output
  -- note: pun_stage_cmd should not return any output upon successful
  --       completion
  if pun_stage_output == "" then
    if redir then
      -- success & redirect
      return http.http307(r, redir)
    else
      -- success, so inform the user
      return http.http200(r)
    end
  else
    -- something bad happened, so inform the user
    return http.http404(r, pun_stage_output)
  end
end
