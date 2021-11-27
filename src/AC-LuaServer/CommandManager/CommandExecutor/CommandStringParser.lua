---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local apr = require "apr"
local argparse = require "argparse"
local ArgparseException = require "AC-LuaServer.CommandManager.CommandExecutor.Exception.ArgparseException"
local Object = require "classic"

---
-- Parses command names and parameters from commands that players say.
--
-- @type CommandStringParser
--
local CommandStringParser = Object:extend()


CommandStringParser.argparseFactory = nil


-- Public Methods

function CommandStringParser:new()
  self.argparseFactory = ArgparseFactory()
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
-- Searches and returns the command that is contained in a command string.
--
-- @tparam string _commandString The string to extract the command name from
-- @tparam CommandSearcher _commandSearcher The CommandSearcher to search for the command with
--
-- @treturn BaseCommand|nil The fetched command or nil if no command was found
--
function CommandStringParser:parseCommand(_commandString, _commandSearcher)
  local commandName = _commandString:match("^!([^! ][^ ]*)")
  return _commandSearcher:getCommandByNameOrAlias(commandName)
end

---
-- Parses and returns all parameter values from a command string.
-- The resulting array is in the format { <argument or option name> = <converted value> }.
--
-- @tparam string _commandString The command string to extract the parameter values from
-- @tparam BaseCommand _command The command to parse the argument values for
--
-- @treturn mixed[] The list of parsed parameter values
--
-- @raise Error when the argparse library encounters an error while parsing the parameter values
--
function CommandStringParser:parseParameterValues(_commandString, _command)

  --
  -- Parse the command string into a list of arguments
  -- This will split the string by whitespaces but also takes care of handling quotation marks and
  -- escaped whitespaces
  --
  -- The first argument is removed because it is the name of the command
  --
  local arguments = apr.tokenize_to_argv(argString)
  table.remove(arguments, 1)

  -- Parse the raw arguments
  local parser = self.argparseFactory:getArgparseInstanceFor(_command)
  local success, result = parser:pparse(arguments)
  if (success == false) then
    error(ArgparseException(result))
  end

  return result

end


return CommandStringParser
