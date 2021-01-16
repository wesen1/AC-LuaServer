---
-- @author wesen
-- @copyright 2019-2021 wesen <wesen-ac@web.de>
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
-- You can call LuaServer Api functions like this: "LuaServerApi.<function name>()".
--
-- You may also call LuaServer Api functions like this: "LuaServerApi:<function name>()".
-- This way two events will be emitted:
-- 1. "before_<function name>": Will be emitted before the LuaServer Api function is called.
--                             If any event listener returns something other than nil the LuaServer Api
--                             function call will be cancelled
-- 2. "after_<function name>": Will be emitted after the LuaServer Api function was successfully called
--
local LuaServerApi = Object:extend()
LuaServerApi:implement(EventEmitter)


---
-- LuaServerApi constructor.
--
function LuaServerApi:new()
  self.eventCallbacks = {}
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
    -- Return the global variable that has the given index name as a last resort and assume
    -- that it is a function or constant that is provided by AC-Lua
    local globalVariableWithName = _G[_index]

    if (type(globalVariableWithName) == "function") then

      return function(...)

        local apiFunctionArguments = {...}
        local luaServerApi
        if (type(apiFunctionArguments[1]) == "table" and type(apiFunctionArguments[1].is) == "function" and
            apiFunctionArguments[1]:is(LuaServerApi)) then
          -- The LuaServerApi itself was provided as parameter, events can be fired
          luaServerApi = apiFunctionArguments[1]
          apiFunctionArguments = tablex.sub(apiFunctionArguments, 2)
        end

        if (not luaServerApi or
            (luaServerApi and luaServerApi:emit("before_" .. _index, table.unpack(apiFunctionArguments)) == nil)) then
          -- No event listener wants to cancel the lua API call
          local returnValues = { globalVariableWithName(table.unpack(apiFunctionArguments)) }

          if (luaServerApi) then
            luaServerApi:emit("after_" .. _index, table.unpack(apiFunctionArguments))
          end

          return table.unpack(returnValues)

        end

      end

    else
      return globalVariableWithName
    end

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
