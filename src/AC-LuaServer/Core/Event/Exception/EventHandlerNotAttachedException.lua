---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require "AC-LuaServer.Core.Util.Exception.Exception"

---
-- Exception for the case that a EventHandler should be detached from a EventEmitter's event to which it
-- is not connected at the moment.
--
-- @type EventHandlerNotAttachedException
--
local EventHandlerNotAttachedException = Exception:extend()


---
-- The name of the EventEmitter's class that raised this Exception
--
-- @tfield string eventEmitterClassName
--
EventHandlerNotAttachedException.eventEmitterClassName = nil

---
-- The event name that caused this Exception
--
-- @tfield string eventName
--
EventHandlerNotAttachedException.eventName = nil


---
-- EventHandlerNotAttachedException constructor.
--
-- @tparam string _eventEmitterClassName The name of the EventEmitter's class that raised this Exception
-- @tparam string _eventName The event name that caused this Exception
--
function EventHandlerNotAttachedException:new(_eventEmitterClassName, _eventName)
  self.eventEmitterClassName = _eventEmitterClassName
  self.eventName = _eventName
end


-- Getters and Setters

---
-- Returns the name of the EventEmitter's class that raised this Exception.
--
-- @treturn string The name of the EventEmitter's class
--
function EventHandlerNotAttachedException:getEventEmitterClassName()
  return self.eventEmitterClassName
end

---
-- Returns the event name that caused this Exception.
--
-- @treturn string The event name
--
function EventHandlerNotAttachedException:getEventName()
  return self.eventName
end


-- Public Methods

---
-- Returns this Exception's message as a string.
--
-- @treturn string The Exception message as a string
--
function EventHandlerNotAttachedException:getMessage()
  return string.format(
    "Could not detach event handler from %s: Event handler is not attached to event \"%s\"",
    self.eventEmitterClassName,
    self.eventName
  )
end


return EventHandlerNotAttachedException
