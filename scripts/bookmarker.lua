package.path = mp.command_native({"expand-path", "~~/"}) .. "/scripts-shared/?.lua;" .. package.path
require("mpv_shared")
---
local utils = require 'mp.utils'
local options = require 'mp.options'
local o = {
  -- save_interval = 60,
  enabled = true
}
options.read_options(o)
if not o.enabled then
  log("bookmarker has been disabled by options")
  return
end
---
local function bookmark_add()
  local abs_path = getPath2()

  local time_current = mp.get_property("time-pos")
  local res = brishz(("h_mpv-bookmark %q %q"):format(abs_path, time_current))
  log(res)
end
---
mp.add_key_binding('K', 'bookmark_add', bookmark_add)
---
