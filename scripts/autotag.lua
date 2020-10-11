package.path = os.getenv("HOME") .. "/.config/mpv/scripts-shared/?.lua;" .. package.path
require("mpv_shared")

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
  mp.osd_message("Playing: " .. new_path, 10)

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
