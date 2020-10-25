package.path = mp.command_native({"expand-path", "~~/"}) .. "/scripts-shared/?.lua;" .. package.path
require("mpv_shared")

local function load_renamer(hook)
  local abs_path = getPath()
  local new_path = getNewPath()
  if not (abs_path == new_path) and new_path ~= '' then
    log("load_renamer's new path: " .. new_path)
    mp.set_property("stream-open-filename", new_path)
  end
end
mp.add_hook("on_load", 0, load_renamer)
-- mp.add_hook("on_load_fail", 0, load_renamer) -- enabling this might provide useful redundancy in race conditions?
