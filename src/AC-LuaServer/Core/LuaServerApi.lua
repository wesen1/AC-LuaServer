---
-- @author wesen
-- @copyright 2019-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventEmitter = require "AC-LuaServer.Core.Event.EventEmitter"
local Object = require "classic"
local tablex = require "pl.tablex"

---
-- Wrapper for the LuaServer Api.
-- The LuaServerApi consists of global variables and functions.
--
-- Functions that are overwritten by this class must be called like this: "LuaServerApi:<method>()".
-- All other functions must be called like this: "LuaServerApi.<function>()"
--
local LuaServerApi = Object:extend()
LuaServerApi:implement(EventEmitter)


---
-- LuaServerApi constructor.
--
function LuaServerApi:new()
  self.eventCallbacks = {}
end


-- Public Methods

---
-- Removes the cgz and cfg files of a given map from the Server.
--
function LuaServerApi:removemap(...)

  if (self:emit("beforeMapRemove", ...) == nil) then
    -- The map removal should not be cancelled
    _G.removemap(...)
    self:emit("mapRemoved", ...)
  end

end


-- Metamethods

---
-- Metamethod that is called when the value of an unknown index should be returned.
-- For example `LuaServerApi["clientprint"]`.
--
-- @tparam mixed _index The index for which a corresponding value should be returned
--
-- @treturn mixed The value to return for the given index
--
function LuaServerApi:__index(_index)

  if (tablex.find(tablex.keys(LuaServerApi), _index) ~= nil) then
    -- The LuaServerApi class has its own definition for the given index
    return LuaServerApi[_index]
  elseif (Object[_index] ~= nil) then
    -- The parent class has a definition for the given index
    return Object[_index]
  else
    -- Return the global variable that has the given index name as a last resort
    return _G[_index]
  end

end

---
-- Metamethod that is called when the value of an unknown index should be set.
-- For example `LuaServerApi["onPlayerSayText"] = function() print("Someone said text") end`
--
-- @tparam mixed _index The index that should be set
-- @tparam mixed _value The value that should be set at the given index
--
function LuaServerApi:__newindex(_index, _value)
  -- Always create a global variable with the given index name
  _G[_index] = _value
end


-- Return a instance of this class, not the class itself
return LuaServerApi()
