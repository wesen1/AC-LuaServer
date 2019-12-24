---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventEmitter = require "AC-LuaServer.Core.Event.EventEmitter"
local Object = require "classic"

---
-- An example EventEmitter that is used during the TestEventEmitter tests.
--
-- @type ExampleEventEmitter
--
local ExampleEventEmitter = Object:extend()
ExampleEventEmitter:implement(EventEmitter)


---
-- ExampleEventEmitter constructor.
--
function ExampleEventEmitter:new()
  self.eventCallbacks = {}
end


return ExampleEventEmitter
