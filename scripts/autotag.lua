package.path = mp.command_native({"expand-path", "~~/"}) .. "/scripts-shared/?.lua;" .. package.path
require("mpv_shared")
---
-- https://github.com/AN3223/dotfiles/blob/master/.config/mpv/scripts/auto-save-state.lua
-- Runs write-watch-later-config periodically

local utils = require 'mp.utils'
local options = require 'mp.options'
local o = {
  save_interval = 60,
  enabled = true
}
options.read_options(o)
if not o.enabled then
  log("autotag has been disabled by options")
  return
end

local function save()
  mp.commandv("set", "msg-level", "cplayer=warn")
  mp.command("write-watch-later-config")
  -- FIXME this overwrites msg-level=cplayer=? original value
  mp.commandv("set", "msg-level", "cplayer=status")
end

local function save_if_pause(_, pause)
  if pause then save() end
end

local function pause_timer_while_paused(_, pause)
  if pause then
    timer:stop()
  end

  if not pause and not timer:is_enabled() then
    timer:resume()
  end
end

timer = mp.add_periodic_timer(o.save_interval, save)
mp.observe_property("pause", "bool", pause_timer_while_paused)
mp.observe_property("pause", "bool", save_if_pause)

---

local function tagger(event)
  save()
  local abs_path = getPath2(false)
  local ext = get_extension(abs_path)
  local hash = brishz(("md5m %q"):format(abs_path))
  local watch_later = mp.find_config_file("watch_later")
  if hash == nil or watch_later == nil then
    log("empty watch_later or hash")
    return
  end
  local hashfile = utils.join_path(watch_later, hash)

  local new_path = getNewPath()
  if new_path == "" then
    mp.msg.warn("autotag has empty path")
  else
    -- log("new_path: " .. new_path)
  end
  local tagMode = (EXTENSIONS_VIDEO[ext] ~= nil)
  if tagMode then
    new_path = (exec(("brishzq.zsh ntag-add-givedest %q green"):format(new_path)))
    log("Greened: " .. new_path)
  else
    log("Skipped tagging: " .. abs_path)
  end
  _, filename, _ = string.match(new_path, "(.-)([^\\/]-%.?([^%.\\/]*))$")
  -- mp.osd_message("test: " .. filename .. ", " .. new_path, 10)
  mp.osd_message(filename, 10)

  function mg(event)
    mp.unregister_event(mg)
    log("end-file's reason: " .. event["reason"])
    if event["reason"] == "eof" or event["reason"] == "stop" then
      os.remove(hashfile)
      if tagMode then
        log(exec(("/usr/local/bin/brishzq.zsh greens2teal %q"):format(new_path)))
      end
    else
      if tagMode then
        log(exec(("/usr/local/bin/brishzq.zsh green2aqua %q"):format(new_path)))
      end
      local new_path = ntagRecoverPath(new_path)
      if new_path ~= abs_path then
        local new_hash = brishz(("md5m %q"):format(new_path))
        local new_hashfile = utils.join_path(watch_later, new_hash)
        copyFile(hashfile, new_hashfile)
      end
    end
  end
  mp.register_event("end-file", mg)
end

mp.register_event("file-loaded", tagger)
-- mp.register_event("file-loaded", function() log("Updated path: " .. mp.get_property("path")) end)
-- mp.add_hook("on_load", 0, tagger)
