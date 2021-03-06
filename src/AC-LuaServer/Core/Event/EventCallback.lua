---
-- @author wesen
-- @copyright 2019-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local GlobalCallbackFunctionNotFoundException = require "AC-LuaServer.Core.Event.Exception.GlobalCallbackFunctionNotFoundException"
local InvalidCallbackFunctionException = require "AC-LuaServer.Core.Event.Exception.InvalidCallbackFunctionException"
local Object = require "classic"
local tablex = require "pl.tablex"

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
-- @tfield mixed[][] additionalCallbackFunctionParameters
--
EventCallback.additionalCallbackFunctionParameters = nil

---
-- The priority of this EventCallback in the stack of EventCallback's for the target event
-- The lower the value the higher the priority (Defaults to 128)
--
-- @tfield int priority
--
EventCallback.priority = nil


---
-- EventCallback constructor.
--
-- @tparam string|function|table _callbackFunction The callback function
-- @tparam int _priority The priority (optional)
--
function EventCallback:new(_callbackFunction, _priority)
  self.additionalCallbackFunctionParameters = {}
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

  if (tablex.size(self.additionalCallbackFunctionParameters) == 0) then
    return self.callbackFunction(...)
  else

    local parameters = { ... }

    local callbackFunctionParameters = {}
    for i, parameter in ipairs(parameters) do
      if (self.additionalCallbackFunctionParameters[i] ~= nil) then
        tablex.insertvalues(callbackFunctionParameters, self.additionalCallbackFunctionParameters[i])
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
      local additionalParametersAtPosition = self.additionalCallbackFunctionParameters[i]
      if (additionalParametersAtPosition ~= nil) then
        tablex.insertvalues(callbackFunctionParameters, additionalParametersAtPosition)
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

    local object, methodName, additionalParameters

    if (type(_callbackFunction["object"]) == "table" and
        type(_callbackFunction["methodName"]) == "string") then
      object = _callbackFunction["object"]
      methodName = _callbackFunction["methodName"]
      additionalParameters = _callbackFunction["additionalParameters"]

    elseif (type(_callbackFunction[1]) == "table" and type(_callbackFunction[2]) == "string") then
      -- Alternative notation for a object method call
      object = _callbackFunction[1]
      methodName = _callbackFunction[2]
      additionalParameters = _callbackFunction[3]
    end

    if (object and methodName) then
      self.callbackFunction = object[methodName]
      self:addAdditionalParameters(1, { object })

      if (type(additionalParameters) == "table") then
        for parameterPosition, parameterValues in pairs(additionalParameters) do
          self:addAdditionalParameters(parameterPosition, parameterValues)
        end
      end
    end

  end


  if (not self.callbackFunction) then
    -- No or invalid function config found
    error(InvalidCallbackFunctionException())
  end

end

---
-- Adds additional parameters to the callback function at a specific position.
--
-- @tparam int _position The parameter position to add new values to
-- @tparam mixed[] _parameters The parameters to insert at the position
--
function EventCallback:addAdditionalParameters(_position, _parameters)
  if (self.additionalCallbackFunctionParameters[_position] == nil) then
    self.additionalCallbackFunctionParameters[_position] = {}
  end

  tablex.insertvalues(self.additionalCallbackFunctionParameters[_position], _parameters)
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
