---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"
local ServerEventListener = require "AC-LuaServer.Core.ServerEvent.ServerEventListener"

---
-- An example ServerEventListener that is used during the TestServerEventListener tests.
--
-- @type ExampleServerEventListener
--
local ExampleServerEventListener = Object:extend()
ExampleServerEventListener:implement(ServerEventListener)


---
-- The list of server events for which this class listens
--
-- @tfield table[]|string[] serverEventListeners
--
ExampleServerEventListener.serverEventListeners = {
  onPlayerShoot = "onPlayerShootHandler",
  onPlayerSayText = { ["methodName"] = "onPlayerSayTextHandler", ["priority"] = 7 }
}


-- Public Methods

---
-- Starts listening for the configured server events.
--
function ExampleServerEventListener:startListening()
  self:registerAllServerEventListeners()
end

---
-- Stops listening for the configured server events.
--
function ExampleServerEventListener:stopListening()
  self:unregisterAllServerEventListeners()
end

---
-- Event handler method for the "onPlayerShoot" event.
--
function ExampleServerEventListener:onPlayerShootHandler()
end

---
-- Event handler for the "onPlayerSayText" event.
--
function ExampleServerEventListener:onPlayerSayTextHandler()
end


return ExampleServerEventListener
