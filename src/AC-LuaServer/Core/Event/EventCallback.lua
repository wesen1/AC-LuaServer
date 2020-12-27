---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local GlobalCallbackFunctionNotFoundException = require "AC-LuaServer.Core.Event.Exception.GlobalCallbackFunctionNotFoundException"
local InvalidCallbackFunctionException = require "AC-LuaServer.Core.Event.Exception.InvalidCallbackFunctionException"
local Object = require "classic"

---
-- Represents a callback function with a priority for EventEmitter's.
--
-- @type EventCallback
--
local EventCallback = Object:extend()


---
-- The callback function that will be called when this EventCallback is called
--
-- @tfield function callbackFunction
--
EventCallback.callbackFunction = nil

---
-- The additional parameters that will be passed to the callback function
-- This table is in the format { index = parameter }, the additional parameters will be inserted into the
-- list of parameters at the specified indexes
--
-- @tfield mixed[] additionalParameters
--
EventCallback.additionalParameters = nil

---
-- The priority of this EventCallback in the stack of EventCallback's for the target event
-- The lower the value the higher the priority (Defaults to 128)
--
-- @tfield int priority
EventCallback.priority = nil


---
-- EventCallback constructor.
--
-- @tparam string|function|table _callbackFunction The callback function
-- @tparam int _priority The priority (optional)
--
function EventCallback:new(_callbackFunction, _priority)
  self:initializeCallbackFunction(_callbackFunction)
  self:initializePriority(_priority)
end


-- Getters and Setters

---
-- Returns the priority of this EventCallback.
--
-- @treturn int The priority
--
function EventCallback:getPriority()
  return self.priority
end


-- Public Methods

---
-- Calls this EventCallback's callback function.
--
-- @tparam mixed[] ... The parameters to pass to the callback function
--
-- @treturn mixed|void The return value of the callback function
--
function EventCallback:call(...)

  if (self.additionalCallbackFunctionParameters == nil) then
    return self.callbackFunction(...)
  else

    local parameters = { ... }

    local callbackFunctionParameters = {}
    for i, parameter in ipairs(parameters) do
      if (self.additionalCallbackFunctionParameters[i] ~= nil) then
        table.insert(callbackFunctionParameters, self.additionalCallbackFunctionParameters[i])
      end

      table.insert(callbackFunctionParameters, parameter)
    end

    -- Add the additional parameters to the function parameters that were not checked yet
    local highestAdditionalParameterNumber = 0
    for i, _ in pairs(self.additionalCallbackFunctionParameters) do
      if (i > highestAdditionalParameterNumber) then
        highestAdditionalParameterNumber = i
      end
    end

    for i = #parameters + 1, highestAdditionalParameterNumber, 1 do
      if (self.additionalCallbackFunctionParameters[i] ~= nil) then
        table.insert(callbackFunctionParameters, self.additionalCallbackFunctionParameters[i])
      else
        table.insert(callbackFunctionParameters, nil)
      end
    end

    return self.callbackFunction(table.unpack(callbackFunctionParameters))
  end

end


-- Private Methods

---
-- Initializes the callback function and its additional parameters.
-- Supported function descriptors are function names, a literal function or a table in the format
-- { ["object"] = object, ["methodName"] = methodName }.
--
-- @tparam string|function|table _callbackFunction The callback function
--
-- @private
--
function EventCallback:initializeCallbackFunction(_callbackFunction)

  local callbackFunctionType = type(_callbackFunction)

  if (callbackFunctionType == "string") then
    -- Function name
    self.callbackFunction = _G[_callbackFunction]
    if (self.callbackFunction == nil) then
      error(GlobalCallbackFunctionNotFoundException(_callbackFunction))
    end

  elseif (callbackFunctionType == "function") then
    -- Function
    self.callbackFunction = _callbackFunction

  elseif (callbackFunctionType == "table") then
    -- Configuration for a object method call

    if (type(_callbackFunction["object"]) == "table" and
        type(_callbackFunction["methodName"]) == "string") then

      local object = _callbackFunction["object"]
      local methodName = _callbackFunction["methodName"]

      self.callbackFunction = object[methodName]
      self.additionalCallbackFunctionParameters = { object }
    end

  end


  if (not self.callbackFunction) then
    -- No or invalid function config found
    error(InvalidCallbackFunctionException())
  end

end

---
-- Initializes the priority.
--
-- @tparam int _priority The priority (optional)
-- @private
--
function EventCallback:initializePriority(_priority)

  if (_priority == nil) then
    self.priority = 128
  else
    self.priority = _priority
  end

end


return EventCallback
