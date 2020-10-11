utils = require 'mp.utils'
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
