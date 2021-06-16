-- https://github.com/mpv-player/mpv/blob/master/DOCS/man/lua.rst
---
utils = require 'mp.utils'
function log(string, secs)
  secs = secs or 2.5     -- secs defaults to 2.5 when the secs parameter is absent
  mp.msg.info(string)          -- This logs to the terminal
  -- mp.osd_message(string, secs) -- This logs to mpv screen
end
--
function exec_raw(cmd)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  return (s)
end
function exec(cmd)
  -- @alt mp.command_native, mp.commandv for args-based solutions
  return trim1(exec_raw(cmd))
end
function trim1(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end
function brishz(cmd)
  return exec("/usr/local/bin/brishzq.zsh " .. cmd)
end
--
function Set (t)
  local set = {}
  for _, v in pairs(t) do set[v] = true end
  return set
end

function SetUnion (a,b)
  local res = {}
  for k in pairs(a) do res[k] = true end
  for k in pairs(b) do res[k] = true end
  return res
end
function get_extension(path)
  match = string.match(path, "%.([^%.]+)$" )
  if match == nil then
    return "nomatch"
  else
    return string.lower(match)
  end
end
---
EXTENSIONS_VIDEO = Set {
  'mkv', 'avi', 'mp4', 'ogv', 'webm', 'rmvb', 'flv', 'wmv', 'mpeg', 'mpg', 'm4v', '3gp'
}

EXTENSIONS_AUDIO = Set {
  'mp3', 'wav', 'ogm', 'flac', 'm4a', 'wma', 'ogg', 'opus'
}

EXTENSIONS_IMAGES = Set {
  'jpg', 'jpeg', 'png', 'tif', 'tiff', 'gif', 'webp', 'svg', 'bmp'
}
---
function getPath(path_prop)
  -- local path = mp.get_property("path", "")
  -- return path
  ---
  local path_prop = path_prop or "stream-open-filename"
  local path = mp.get_property(path_prop)
  local cwd = utils.getcwd()
  if path == nil or path == "" or cwd == nil then
    mp.msg.warn("getPath: Path or cwd is nil!")
    do return end
  end
  -- @weird According to the doc, the path is the same as the cli arg. So why is this working with absolute path args?!
  local abs_path = utils.join_path(cwd, path)
  return abs_path
end
function getNewPath(path_prop)
  local new_path = ntagRecoverPath(getPath(path_prop))
  return new_path
end
function ntagRecoverPath(path)
  if path == "" then
    mp.msg.warn("ntagRecoverPath: input path is empty")
  end
  local new_path = (exec(("/usr/local/bin/brishzq.zsh reval-true ntag-recoverpath %q"):format(path)))
  if new_path == "" or not file_exists(new_path) then
    mp.msg.warn("ntagRecoverPath: new_path doesn't exist")
    return path
  end
  return new_path
end
--
function copyFile(src, dest)
  brishz(("cp %q %q"):format(src, dest))
end
--
function file_exists(name)
   -- returns false for dirs
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end
--
