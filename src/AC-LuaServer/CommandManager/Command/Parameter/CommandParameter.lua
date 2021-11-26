---
-- @author wesen
-- @copyright 2018-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local InvalidParameterValueException = require "AC-LuaServer.CommandManager.Command.Parameter.Exception.InvalidParameterValueException"
local InvalidParameterValueTypeException = require "AC-LuaServer.CommandManager.Command.Exceptions.InvalidParameterValueTypeException"
local Object = require "classic"
local StringTypeCaster = require "AC-LuaServer.CommandManager.Command.Parameter.StringTypeCaster"

---
-- Stores the configuration for a single command parameter.
--
-- @type CommandParameter
--
local CommandParameter = Object:extend()


---
-- The full name of the parameter
-- This name will be shown in the "!help" output for the command to which this parameter belongs
--
-- @tfield string name
--
CommandParameter.name = nil

---
-- The short name of the parameter
-- This will be the same as the full name if no short name is defined
-- This name will be shown in the "!cmds" output
--
-- @tfield string shortName
--
CommandParameter.shortName = nil

---
-- The description of the parameter that will be shown in the help text of the
-- command to which this parameter belongs
-- Defaults to "No description"
--
-- @tfield string description
--
CommandParameter.description = nil

---
-- The value converter function that will be used to convert a raw string value
-- to the type of this argument
--
-- Value converter functions will be called with a single raw string parameter and must  attempt
-- to convert that value into a different type and/or format.
-- If the conversion is successful the converted value has to be returned, otherwise an error
-- must be raised.
--
-- The default value converter function just returns the input string
--
-- @tfield function valueConverter
--
CommandParameter.valueConverter = nil


---
-- CommandParameter constructor.
--
-- @tparam string _name The name of the parameter
--
function CommandParameter:new(_name)
  self.name = tostring(_name)
  self.shortName = self.name
  self.description = "No description" -- TODO: strings.cfg
  self:setValueType("string")
end


-- Getters and Setters

---
-- Returns the parameter's full name.
--
-- @treturn string The parameter's full name
--
function CommandParameter:getName()
  return self.name
end

---
-- Returns the parameter's short name.
--
-- @treturn string The parameter's short name
--
function CommandParameter:getShortName()
  return self.shortName
end

---
-- Returns the parameter's description.
--
-- @treturn string The parameter's description
--
function CommandParameter:getDescription()
  return self.description
end


-- Public Methods

---
-- Parses a value for this parameter and returns the type casted parameter value.
--
-- @tparam string _rawValue The raw parameter value
--
-- @treturn string|int|float|bool The type casted parameter value
--
-- @raise Error if the raw value is not compatible with this parameter's value type
--
function CommandParameter:parse(_rawValue)

  local success, value = pcall(self.valueConverter, _rawValue)
  if (success) then
    return value
  else

    -- The value did not match this parameter's type
    error(InvalidParameterValueException(self, _rawValue))
  end

end


-- Protected Methods

---
-- Sets this parameter's value type.
-- The available types are "string", "integer", "float" and "boolean".
--
-- @tparam string _valueType The new value type
--
-- @raise Error if the specified value type is not "string", "integer", "float" or "boolean"
--
function CommandParameter:setValueType(_valueType)

  if (_valueType == "string") then
    self.valueConverter = function(_string)
      return _string
    end

  elseif (_valueType == "integer") then
    self.valueConverter = StringTypeCaster.toInteger
  elseif (_valueType == "float") then
    self.valueConverter = StringTypeCaster.toFloat
  elseif (_valueType == "boolean") then
    self.valueConverter = StringTypeCaster.toBoolean
  else
    error(InvalidParameterValueTypeException(self.name, tostring(_valueType)))
  end

end

---
-- Sets this parameter's short name.
--
-- @tparam string _shortName The short name
--
function CommandParameter:setShortName(_shortName)
  self.shortName = tostring(_shortName)
end

---
-- Sets this parameter's description.
--
-- @tparam string _description The description
--
function CommandParameter:setDescription(_description)
  self.description = tostring(_description)
end


return CommandParameter
