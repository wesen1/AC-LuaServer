---
-- @author wesen
-- @copyright 2018-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local EventEmitter = require "AC-LuaServer.Core.Event.EventEmitter"
local Exception = require "AC-LuaServer.Core.Util.Exception.Exception"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local Object = require "classic"
local TemplateException = require "AC-LuaServer.Core.Util.Exception.TemplateException"

---
-- Wrapper for AssaultCube server events.
--
-- @type ServerEventManager
--
local ServerEventManager = Object:extend()
ServerEventManager:implement(EventEmitter)


---
-- ServerEventEmitter constructor.
--
function ServerEventManager:new()
  self.eventCallbacks = {}
end


-- Public Methods

---
-- Attaches a callback to a specified event.
--
-- @tparam string _eventName The event name
-- @tparam EventCallback _eventCallback The event callback
--
function ServerEventManager:on(_eventName, _eventCallback)

  local isInitialEventListener = (not self:hasEventListenersFor(_eventName))
  EventEmitter.on(self, _eventName, _eventCallback)

  if (isInitialEventListener) then
    self:manageServerEvent(_eventName)
  end

end


-- Private Methods

---
-- Starts managing a specific server event.
--
-- @tparam string _eventName The name of the server event to start managing
-- @private
--
function ServerEventManager:manageServerEvent(_eventName)

  -- Backup the original event handler
  local existingEventHandler = LuaServerApi[_eventName]
  if (type(existingEventHandler) == "function") then
    self:on(_eventName, EventCallback(existingEventHandler, 0))
  end

  --
  -- The AssaultCube server calls functions that are named like the corresponding event
  -- when the event occurs. Therefore a function with the event's name is set in the LuaServerApi
  -- that passes all arguments as well as the event name to the "emit" method
  --
  LuaServerApi[_eventName] = function(...)

    local success, result = pcall(self.emit, self, _eventName, ...)
    if (success) then
      return result
    else

      local exception = result
      if (exception.is and exception:is(TemplateException)) then
        local Server = require "AC-LuaServer.Core.Server"
        Server.getInstance():getOutput():printException(exception)
      elseif (exception.is and exception:is(Exception)) then
        error(exception:getMessage())
      else
        error(exception)
      end

    end

  end

end


return ServerEventManager
