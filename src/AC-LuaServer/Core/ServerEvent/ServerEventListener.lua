---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local Object = require "classic"

---
-- Allows classes that implement this class to listen to server events of the AssaultCube server.
--
-- Instances of classes that use this class must contain a "serverEventListeners" attribute that
-- contains a table of event names and corresponding callbacks.
--
-- @type table ServerEventListener
--
local ServerEventListener = Object:extend()


---
-- The list of server events for which this class listens
--
-- The table must be in the format { [eventFunctionName] = callbackMethodName, ... }
-- It is also possible to configure a priority by replacing callbackMethodName by:
--   { ["methodName"] = callbackMethodName, ["priority"] = x }
--
-- @tfield table[]|string[] serverEventListeners
--
ServerEventListener.serverEventListeners = nil

---
-- Stores the EventCallback's for the configured server event listeners
--
-- @tfield EventCallback[] serverEventListenerCallbacks
--
ServerEventListener.serverEventListenerCallbacks = nil


-- Protected Methods

---
-- Registers all server event listeners that are configured in the serverEventListeners attribute.
--
function ServerEventListener:registerAllServerEventListeners()

  if (self.serverEventListenerCallbacks == nil) then
    self:initializeServerEventCallbacks()
  end

  local Server = require "AC-LuaServer.Core.Server"
  local serverEventManager = Server.getInstance():getEventManager()
  for eventName, callback in pairs(self.serverEventListenerCallbacks) do
    serverEventManager:on(eventName, callback)
  end

end

---
-- Unregisters all server event listeners that are configured in the serverEventListeners attribute.
--
function ServerEventListener:unregisterAllServerEventListeners()

  if (self.serverEventListenerCallbacks ~= nil) then
    local Server = require "AC-LuaServer.Core.Server"
    local serverEventManager = Server.getInstance():getEventManager()
    for eventName, callback in pairs(self.serverEventListenerCallbacks) do
      serverEventManager:off(eventName, callback)
    end
  end

end


-- Private Methods

---
-- Initializes the EventCallback's for each configured server event listener.
--
function ServerEventListener:initializeServerEventCallbacks()

  self.serverEventListenerCallbacks = {}

  for eventName, callbackConfig in pairs(self.serverEventListeners) do

    local callbackFunction = { object = self }

    local priority
    if (type(callbackConfig) == "table") then
      priority = callbackConfig["priority"]
      callbackFunction["methodName"] = callbackConfig["methodName"]
    else
      callbackFunction["methodName"] = callbackConfig
    end

    self.serverEventListenerCallbacks[eventName] = EventCallback(callbackFunction, priority)

  end

end


return ServerEventListener
