---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require("wesenGemaMod/Util/Exception")
local Object = require("classic")
local StaticString = require("wesenGemaMod/Output/StaticString")
local TemplateException = require("wesenGemaMod/Util/TemplateException")

---
-- Stores the configuration for a single command argument.
--
-- @type CommandArgument
--
local CommandArgument = Object:extend()


---
-- The full name of the argument
-- This name will be shown in the "!help" output for the parent command
--
-- @tfield string name
--
CommandArgument.name = nil

---
-- The short name of the argument
-- This will be the same as the full name if no short name is defined
-- This name will be shown in the "!cmds" output
--
-- @tfield string shortName
--
CommandArgument.shortName = nil

---
-- Defines whether this argument is optional or required
-- Defaults to "required"
--
-- @tfield bool isOptional
--
CommandArgument.isOptional = false

---
-- The description of the argument that will be shown in the help text of the parent command
-- Defaults to the "defaultArgumentDescription" static string
--
-- @tfield string description
--
CommandArgument.description = nil

---
-- The type to which this arguments value will be converted
-- Valid types are: integer, float, bool, string
-- Defaults to "string"
--
-- @tfield string type
--
CommandArgument.type = "string"

---
-- The list of valid argument types
--
-- @tfield bool[] validTypes
--
CommandArgument.validTypes = {
  ["integer"] = true,
  ["float"] = true,
  ["bool"] = true,
  ["string"] = true
}


---
-- CommandArgument constructor.
--
-- @tparam string _name The name of the argument
-- @tparam bool _isOptional Defines whether the argument is optional or required (optional)
-- @tparam string _type The type to which this arguments value will be converted (integer, float, bool, string) (optional)
-- @tparam string _shortName The short name of the argument (used in !cmds) (optional)
-- @tparam string _description The description of the argument (optional)
--
-- @raise Error if the specified type is not valid
--
function CommandArgument:new(_name, _isOptional, _type, _shortName, _description)

  -- Set type
  if (_type) then

    if (CommandArgument.validTypes[_type]) then
      self.type = _type
    else
      error(TemplateException(
        "TextTemplate/ExceptionMessages/CommandHandler/InvalidArgumentType",
        { ["argumentName"] = _name, ["type"] = _type }
      ))
    end

  end

  -- Set name
  self.name = tostring(_name)

  -- Set isOptional
  if (_isOptional) then
    self.isOptional = true
  end

  -- Set shortName
  if (_shortName) then
    self.shortName = tostring(_shortName)
  else
    self.shortName = _name
  end

  -- Set description
  if (_description) then
    self.description = tostring(_description)
  else
    self.description = StaticString("defaultArgumentDescription"):getString()
  end

end


-- Getters and Setters

---
-- Returns the arguments full name.
--
-- @treturn string The arguments full name
--
function CommandArgument:getName()
  return self.name
end

---
-- Returns the arguments short name.
--
-- @treturn string The arguments short name
--
function CommandArgument:getShortName()
  return self.shortName
end

---
-- Returns whether the argument is required or optional.
--
-- @treturn bool True if the argument is optional, false if it is required
--
function CommandArgument:getIsOptional()
  return self.isOptional
end

---
-- Returns the arguments description.
--
-- @treturn string The arguments description
--
function CommandArgument:getDescription()
  return self.description
end


-- Public Methods

---
-- Parses a argument value for this argument and returns the type casted argument value.
--
-- @tparam string _argumentValue The argument value
--
-- @treturn string|int|float|bool The type casted argument value
--
-- @raise Error if the argument value is not valid for this arguments type
--
function CommandArgument:parse(_argumentValue)
  return self:castArgumentToType(_argumentValue)
end


-- Private Methods

---
-- Casts a argument value for this argument to this arguments type and returns the result.
--
-- @tparam string _argumentValue The argument value
--
-- @raise Error if the argument value is not valid for this arguments type
--
function CommandArgument:castArgumentToType(_argumentValue)

  if (self.type == "string") then
    return _argumentValue

  elseif (self.type == "integer") then

    -- Check if the argument contains only digits
    if (_argumentValue:match("^%d+$")) then
      return tonumber(_argumentValue)
    end

  elseif (self.type == "float") then

    -- Check if the argument contains only digits and an optional dot
    if (_argumentValue:match("^%d+%.?%d?$")) then
      return tonumber(_argumentValue)
    end

  elseif (self.type == "bool") then
    if (_argumentValue == "true") then
      return true
    elseif (_argumentValue == "false") then
      return false
    end

  end

  -- The argument value did not match this arguments type
  error(TemplateException(
    "TextTemplate/ExceptionMessages/CommandHandler/InvalidValueType", { argument = self }
  ))

end


return CommandArgument
