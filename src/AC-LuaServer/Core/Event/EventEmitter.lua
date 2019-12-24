---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventHandlerNotAttachedException = require "AC-LuaServer.Core.Event.Exception.EventHandlerNotAttachedException"
local Object = require "classic"

---
-- Allows classes that implement this class to emit custom events.
--
-- Instances of classes that use this class must contain a "eventCallbacks" attribute
-- that stores an empty table.
--
-- @type EventEmitter
--
local EventEmitter = Object:extend()


---
-- The list of callback functions per event.
-- This list is in the format { [eventName] = { EventCallback, ... }, ... }
-- The callback order can be controlled via the priority per EventCallback
--
-- @tfield EventCallback[][] eventCallbacks
--
EventEmitter.eventCallbacks = nil


-- Public Methods

---
-- Returns whether this EventEmitter has event listeners for a specific event.
--
-- @tparam string _eventName The name of the event in question
--
-- @treturn bool True if this EventEmitter has event listeners for the specified event, false otherwise
--
function EventEmitter:hasEventListenersFor(_eventName)
  return (self.eventCallbacks[_eventName] ~= nil)
end

---
-- Attaches a callback to a specified event.
--
-- @tparam string _eventName The event name
-- @tparam EventCallback _eventCallback The callback
--
function EventEmitter:on(_eventName, _eventCallback)

  local eventCallbacks = self.eventCallbacks[_eventName]
  if (eventCallbacks) then

    local priority = _eventCallback:getPriority()
    local insertIndex
    for i, eventCallback in ipairs(eventCallbacks) do
      if (eventCallback:getPriority() > priority) then
        insertIndex = i
        break
      end
    end

    if (not insertIndex) then
      insertIndex = #self.eventCallbacks[_eventName] + 1
    end

    table.insert(self.eventCallbacks[_eventName], insertIndex, _eventCallback)

  else
    -- This is the first listener for this event
    self.eventCallbacks[_eventName] = { _eventCallback }
  end

end

---
-- Detaches a callback from a specified event.
--
-- @tparam string _eventName The event name
-- @tparam EventCallback _eventCallback The callback
--
-- @raise Error if the callback function is not attached to the event
--
function EventEmitter:off(_eventName, _eventCallback)

  local callbackExists = false

  local eventCallbacks = self.eventCallbacks[_eventName]
  if (eventCallbacks) then

    local eventCallbackIndex
    for i, eventCallback in ipairs(eventCallbacks) do
      if (eventCallback == _eventCallback) then
        eventCallbackIndex = i
        callbackExists = true
      end
    end

    if (callbackExists) then
      table.remove(self.eventCallbacks[_eventName], eventCallbackIndex)
    end

  end


  if (not callbackExists) then
    error(EventHandlerNotAttachedException(self:__tostring(), _eventName))
  end

end


-- Protected Methods

---
-- Emits a custom event.
--
-- @tparam string _eventName The event name
-- @tparam mixed[] ... The additional event paramters to pass to each callback function
--
-- @treturn The return value of the first event callback that returned a value
--
function EventEmitter:emit(_eventName, ...)

  local callbacks = self.eventCallbacks[_eventName]
  if (callbacks) then
    local returnValue
    for _, callback in ipairs(callbacks) do
      returnValue = callback:call(...)
      if (returnValue ~= nil) then
        return returnValue
      end
    end
  end

end


return EventEmitter
