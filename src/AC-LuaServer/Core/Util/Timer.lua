---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local Object = require "classic"

---
-- Wrapper around the tmr module that is provided by AC-Lua.
-- Provides a way to call functions in x milliseconds (one time or periodically).
--
-- @type Timer
--
local Timer = Object:extend()

-- The available timer types
Timer.TYPE_ONCE = 1
Timer.TYPE_PERIODIC = 2

---
-- The id of this Timer
--
-- @tfield int id
--
Timer.id = nil


---
-- Timer constructor.
--
-- @tparam int _type The Timer type (One of the TYPE_* constants)
-- @tparam int _intervalInMilliseconds The Timer interval in milliseconds
-- @tparam function|string The callback that should be called by the Timer
--
function Timer:new(_type, _intervalInMilliseconds, _callback)

  -- Fetch a new available ID
  self.id = LuaServerApi.tmr.vacantid()

  -- Set up the timer
  local methodName
  if (_type == Timer.TYPE_ONCE) then
    methodName = "after"
  else
    methodName = "create"
  end
  LuaServerApi.tmr[methodName](self.id, _intervalInMilliseconds, _callback)

end


-- Public Methods

---
-- Cancels this Timer.
--
function Timer:cancel()
  LuaServerApi.tmr.remove(self.id)
end


return Timer
