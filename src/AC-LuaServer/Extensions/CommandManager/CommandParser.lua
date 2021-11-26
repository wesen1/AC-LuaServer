---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require("Util/Exception")
local StaticString = require("Output/StaticString")
local StringUtils = require("Util/StringUtils")
local TableUtils = require("Util/TableUtils")
local TemplateException = require("Util/TemplateException")

---
-- Parses command input strings.
--
-- @type CommandParser
--
local CommandParser = setmetatable({}, {})


---
-- The last parsed command
--
-- @tfield Output output
--
CommandParser.command = nil

---
-- The last parsed arguments
--
-- @tfield String[] arguments
--
CommandParser.arguments = nil


---
-- CommandParser constructor.
--
-- @tparam Output _output The output
--
-- @treturn CommandParser The CommandParser instance
--
function CommandParser:__construct(_output)
  local instance = setmetatable({}, {__index = CommandParser})
  return instance
end

getmetatable(CommandParser).__call = CommandParser.__construct


-- Getters and Setters

---
-- Returns the last parsed command.
--
-- @treturn BaseCommand The last parsed command
--
function CommandParser:getCommand()
  return self.command
end

---
-- Returns the last parsed arguments.
--
-- @treturn String[] The last parsed arguments
--
function CommandParser:getArguments()
  return self.arguments
end


-- Public Methods

---
-- Checks whether a string starts with "!" followed by other characters than "!".
--
-- @tparam string _text The string
--
-- @treturn Bool True if the string is a command, false otherwise
--
function CommandParser:isCommand(_text)
  -- If the first character is "!" and the second character is anything but "!" and whitespace
  return (_text:match("^![^! ].*$"))
end

---
-- Splits an input text into command name and arguments and saves the results in
-- the class attributes command and arguments.
--
-- @tparam string _inputText The input text in the format "!commandName args"
-- @tparam CommandList _commandList The command list
--
-- @raise Error in case of unknown command
-- @raise Error while parsing the arguments
--
function CommandParser:parseCommand(_inputText, _commandList)

  self.command = nil
  self.arguments = nil

  local inputTextParts = StringUtils:split(_inputText, " ")

  -- Find the command
  local commandName = string.lower(inputTextParts[1])
  local command = _commandList:getCommand(commandName)

  if (not command) then
    error(TemplateException(
      "TextTemplate/ExceptionMessages/CommandHandler/UnknownCommand",
      { ["commandName"] = commandName }
    ))
  end

  self.command = command
  self.arguments = self:parseArguments(command, TableUtils:slice(inputTextParts, 2))

end


-- Private Methods

---
-- Fetches the arguments from the input text parts.
-- Creates and returns a table in the format { argumentName => inputArgumentValue }.
--
-- @tparam BaseCommand _command The command for which the arguments are used
-- @tparam String[] _argumentTextParts The argument text parts
--
-- @treturn String[] The associative array of arguments
--
-- @raise Error while casting the input arguments to types
--
function CommandParser:parseArguments(_command, _argumentTextParts)

  local numberOfArgumentTextParts = #_argumentTextParts

  -- Check whether the number of arguments is valid
  if (numberOfArgumentTextParts < _command:getNumberOfRequiredArguments()) then
    error(TemplateException(
      "TextTemplate/ExceptionMessages/CommandHandler/NotEnoughCommandArguments",
      { numberOfPassedArguments = numberOfArgumentTextParts, command = _command }
    ))

  elseif (numberOfArgumentTextParts > _command:getNumberOfArguments()) then
    error(Exception(StaticString("exceptionTooManyCommandArguments"):getString()))
  end

  -- Create an associative array from the input text parts
  local inputArguments = {}
  if (numberOfArgumentTextParts > 0) then

    -- Fetch the argument names
    local arguments = _command:getArguments()

    for index, argument in ipairs(arguments) do
      local argumentValue = _argumentTextParts[index]
      inputArguments[argument:getName()] = self:castArgumentToType(argument, argumentValue)
    end

  end

  return inputArguments

end

---
-- Casts an argument input string to the arguments type.
--
-- @tparam CommandArgument _argument The argument
-- @tparam string _argumentValue The input argument value
--
-- @raise Error in case of wrong input value type
-- @raise Error in case of invalid argument type
--
function CommandParser:castArgumentToType(_argument, _argumentValue)

  if (_argument:getType() == "string") then
    return _argumentValue

  elseif (_argument:getType() == "integer") then
    if (_argumentValue:match("^%d+$") ~= nil) then
      return tonumber(_argumentValue)
    end

  elseif (_argument:getType() == "float") then
    if (_argumentValue:match("^%d+%.?%d?$") ~= nil) then
      return tonumber(_argumentValue)
    end

  elseif (_argument:getType() == "bool") then
    if (_argumentValue == "true") then
      return true
    elseif (_argumentValue == "false") then
      return false
    end

  else
    -- Argument type is invalid
    error(TemplateException(
      "TextTemplate/ExceptionMessages/CommandHandler/InvalidArgumentType", { argument = _argument }
    ))
  end

  -- Argument type is valid but value type did not match argument type
  error(TemplateException(
    "TextTemplate/ExceptionMessages/CommandHandler/InvalidValueType", { argument = _argument }
  ))

end


return CommandParser
