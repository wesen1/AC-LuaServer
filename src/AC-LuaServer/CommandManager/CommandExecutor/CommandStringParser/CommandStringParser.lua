---
-- @author wesen
-- @copyright 2017-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local CommandStringInformationExtractor = require "AC-LuaServer.CommandManager.CommandExecutor.CommandStringParser.CommandStringInformationExtractor"
local Object = require "classic"


local CommandStringParser = Object:extend()


function CommandStringParser:new()
  self.infoExtractor = CommandStringInformationExtractor()
end


---
-- Returns whether a string is a command string.
-- This is the case if the string starts with "!" and is followed by at least one character other than
-- "!" and " ".
--
-- @tparam string _string The string to check
--
-- @treturn bool True if the string is a command string, false otherwise
--
function CommandStringParser:isCommandString(_string)
  return (_string:match("^![^! ]") ~= nil)
end

---
-- Searches a FilteredCommandList for the command name that is contained in a string and returns the result.
--
-- @tparam string _commandString The string to extract the command name from
-- @tparam CommandSearcher _commandSearcher The CommandSearcher to search for the command with
--
-- @treturn BaseCommand The fetched command
--
function CommandStringParser:parseCommand(_commandString, _commandSearcher)

  local commandName = _commandString:match("^!([^! ][^ ]*)")
  return _commandSearcher:getCommandByNameOrAlias(commandName)

end

---
-- Parses the argument values that are contained in the parse string and returns the
-- list of parsed argument values.
--
-- @tparam BaseCommand _command The command to parse the argument values for
--
-- @treturn ArgumentValueList The list of parsed argument values
-- @treturn OptionValueList The list of parsed option values
--
function CommandStringParser:parseParameterValues(_commandString, _command)

  local parameters, explicitOptions = self.infoExtractor:extractParameters(_commandString)

  local argumentValues = self:parseArgumentValues(parameters, _command)
  local optionValues = self:parseOptionValues(parameters, explicitOptions, _command)

  return argumentValues, optionValues

end


-- Private Methods

---
-- Parses the argument values from the list of raw parameters and returns the list of parsed argument values.
--
-- @tparam string[] _parameters The list of raw parameters
-- @tparam BaseCommand _command The command to parse the argument values for
--
-- @treturn ArgumentValueList The list of parsed argument values
--
---
-- Fetches the arguments from the input text parts.
-- Creates a table in the format { argumentName => inputArgumentValue }.
--
-- @tparam BaseCommand _command The command for which the arguments are used
-- @tparam string[] _argumentTextParts The argument text parts
--
-- @raise Error while casting the input arguments to types
--
function CommandStringParser:parseArgumentValues(_parameters, _command)

  -- Check if the number of arguments is valid
  local numberOfArguments = _command:getNumberOfArguments()
  local numberOfPassedArguments = #_parameters
  if (numberOfPassedArguments < numberOfArguments) then
    error(NotEnoughArgumentsException(_command:getName(), numberOfCommandArguments, numberOfPassedArguments))
  end


  local argumentValues = {}

  -- Parse the argument values
  local rawArgumentValue
  for i, argument in ipairs(_command:getArguments()) do
    rawArgumentValue = _parameters[i]
    argumentValues[argument:getName()] = argument:parse(rawArgumentValue)
  end

  return argumentValues

end


---
-- Parses the options that are contained in the parse string and returns the list of parsed options.
--
-- @tparam BaseCommand _command The command to parse the options for
--
-- @treturn OptionList The list of parsed arguments
--
function CommandStringParser:parseOptionValues(_parameters, _explicitOptions, _command)

  -- Check if the number of options is valid
  local numberOfExplicitOptions = 0
  for _, _ in pairs(_explicitOptions) do
    numberOfExplicitOptions = numberOfExplicitOptions + 1
  end

  local numberOfCommandOptions = _command:getNumberOfOptions()
  local numberOfPassedOptions = numberOfExplicitOptions + #_parameters - _command:getNumberOfArguments()
  if (numberOfPassedOptions > numberOfCommandOptions) then
    error(TooManyParametersException(
      _command:getName(), _command:getNumberOfArguments(), numberOfCommandOptions, numberOfPassedOptions
    ))
  end


  local optionValues = {}

  -- Parse the explicit option values
  local option
  for optionName, rawOptionValue in pairs(_explicitOptions) do

    option = _command:getOptionByNameOrShortName(optionName)
    if (option == nil) then
      error(UnknownOptionException(_command:getName(), optionName))
    else
      optionValues[option:getName()] = option:parse(rawOptionValue)
    end

  end

  -- Parse the remaining parameter values
  local parameterIndex = _command:getNumberOfArguments() + 1
  local numberOfParameters = #_parameters

  local rawOptionValue
  for _, option in ipairs(_command:getOptions()) do

    if (parameterIndex > numberOfParameters) then
      break
    end

    if (optionValues[option:getName()] == nil) then
      rawOptionValue = _parameters[parameterIndex]
      optionValues[option:getName()] = option:parse(rawOptionValue)

      parameterIndex = parameterIndex + 1
    end

  end

  return optionValues

end


return CommandStringParser
