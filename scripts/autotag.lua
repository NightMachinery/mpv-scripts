local utils = require 'mp.utils'
local options = require 'mp.options'
function log(string, secs)
    secs = secs or 2.5     -- secs defaults to 2.5 when the secs parameter is absent
    mp.msg.info(string)          -- This logs to the terminal
    -- mp.osd_message(string, secs) -- This logs to mpv screen
end
function exec(cmd)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  return trim1(s)
end
function trim1(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function tagger(event)
  local path_prop = "stream-open-filename"
  -- local path_prop = "path"
  local path = mp.get_property(path_prop)
  local cwd = utils.getcwd()
  if path == nil or cwd == nil then
    do return end
  end
  -- @weird According to the doc, the path is the same as the cli arg. So why is this working with absolute path args?!
  local abs_path = utils.join_path(cwd, path)

  local new_path = (exec(("brishzq.zsh ntag-add-givedest %q green"):format(abs_path)))
  log("Greened: " .. new_path)
  mp.set_property(path_prop, new_path) -- doesn't work https://github.com/mpv-player/mpv/issues/8154
  mp.set_property("path", new_path)
  -- log("Updated path: " .. mp.get_property("path"))
  
  function mg(event)
      mp.unregister_event(mg)
      log("end-file's reason: " .. event["reason"])
      if event["reason"] == "eof" or event["reason"] == "stop" then
        log(exec(("brishzq.zsh greens2teal %q"):format(new_path)))
      else
        log(exec(("brishzq.zsh green2aqua %q"):format(new_path)))
      end
  end
  mp.register_event("end-file", mg)

  --- did not remove the hook
  -- function mg(new_path)
  --   return function(event)
  --     mp.unregister_event(mg(new_path)) -- this doesn't seem to work?
  --     log("end-file's reason: " .. event["reason"])
  --     log(exec(("brishzq.zsh green2teal %q"):format(new_path)))
  --     if event["reason"] == "eof" or event["reason"] == "stop" then

  --     end
  --   end
  -- end
  -- mp.register_event("end-file", mg(new_path))
  ---
end

mp.register_event("file-loaded", tagger)
-- mp.register_event("file-loaded", function() log("Updated path: " .. mp.get_property("path")) end)
-- mp.add_hook("on_load", 0, tagger)

local function load_renamer(hook)
  local path_prop = "stream-open-filename"
  local path = mp.get_property(path_prop)
  local cwd = utils.getcwd()
  if path == nil or cwd == nil then
    do return end
  end
  -- @weird According to the doc, the path is the same as the cli arg. So why is this working with absolute path args?!
  local abs_path = utils.join_path(cwd, path)

  local new_path = (exec(("brishzq.zsh ntag-recoverpath %q"):format(abs_path)))
  if not (abs_path == new_path) then
    log("load_renamer's new path: " .. new_path)
  end
  mp.set_property("stream-open-filename", new_path)
end
mp.add_hook("on_load", 0, load_renamer)
-- mp.add_hook("on_load_fail", 0, load_renamer) -- enabling this might provide useful redundancy in race conditions?
