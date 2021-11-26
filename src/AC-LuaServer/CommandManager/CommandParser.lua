---
-- @author wesen
-- @copyright 2017-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require("Util/Exception")
local Object = require("classic")
local StaticString = require("Output/StaticString")
local StringUtils = require("Util/StringUtils")
local TableUtils = require("Util/TableUtils")
local TemplateException = require("Util/TemplateException")

---
-- Parses command input strings.
--
-- @type CommandParser
--
local CommandParser = Object:extend()


---
-- The last detected command
--
-- @tfield BaseCommand command
--
CommandParser.command = nil

---
-- The list of raw (string) arguments
--
-- @tfield string[] rawArguments
--
CommandParser.rawArguments = nil

---
-- The last detected arguments
--
-- @tfield mixed[] arguments
--
CommandParser.arguments = nil


-- Getters and Setters

---
-- Returns the last detected command.
--
-- @treturn BaseCommand The last detected command
--
function CommandParser:getCommand()
  return self.command
end

---
-- Returns the last detected arguments.
--
-- @treturn string[] The last detected arguments
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
-- @treturn bool True if the string is a command, false otherwise
--
function CommandParser:isCommand(_text)
  -- If the first character is "!" and the second character is anything but "!" and whitespace
  return (_text:match("^![^! ]"))
end

---
-- Splits an input text into command name and arguments.
-- The result can be fetched with getCommand().
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

  -- Remove the leading "!" and convert the command name to lowercase
  local commandName = inputTextParts[1]:sub(2):lower()
  local command = _commandList:getCommandByNameOrAlias(commandName)

  if (not command) then
    error(TemplateException(
      "TextTemplate/ExceptionMessages/CommandHandler/UnknownCommand",
      { ["commandName"] = commandName }
    ))
  end

  self.command = command
  self.rawArguments = TableUtils:slice(inputTextParts, 2)

end

---
-- Fetches the arguments from the input text parts.
-- Creates a table in the format { argumentName => inputArgumentValue }.
--
-- @tparam BaseCommand _command The command for which the arguments are used
-- @tparam string[] _argumentTextParts The argument text parts
--
-- @raise Error while casting the input arguments to types
--
function CommandParser:parseArguments()

  local numberOfArgumentTextParts = #self.rawArguments

  -- Check whether the number of arguments is valid
  if (numberOfArgumentTextParts < _command:getNumberOfRequiredArguments()) then
    error(TemplateException(
      "TextTemplate/ExceptionMessages/CommandHandler/NotEnoughCommandArguments",
      { numberOfPassedArguments = numberOfArgumentTextParts, command = _command }
    ))

  elseif (numberOfArgumentTextParts > _command:getNumberOfArguments()) then
    error(Exception(StaticString("exceptionTooManyCommandArguments"):getString()))
  end

  self.arguments = {}

  -- Create an associative array from the input text parts
  if (numberOfArgumentTextParts > 0) then

    -- Fetch the arguments
    local arguments = _command:getArguments()

    for index, argument in ipairs(arguments) do
      local argumentValue = self.rawArguments[index]
      self.arguments[argument:getName()] = argument:parse(argumentValue)
    end

  end

end


return CommandParser
