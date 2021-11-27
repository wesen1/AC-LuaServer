---
-- @author wesen
-- @copyright 2018-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local CommandStringParser = require "AC-LuaServer.CommandManager.CommandExectutor.CommandStringParser.CommandStringParser"
local Exception = require "AC-LuaServer.Core.Util.Exception.Exception"
local Object = require "classic"

---
-- Checks if texts that players say are commands and handles the command execution if needed.
--
-- @type CommandExecutor
--
local CommandExecutor = Object:extend()


---
-- The CommandParser that detects commands in texts that players say
--
-- @tfield CommandParser commandParser
--
CommandExecutor.commandStringParser = nil


---
-- CommandExecutor constructor.
--
function CommandExecutor:new()
  self.commandStringParser = CommandStringParser()
end


-- Public Methods

---
-- Handles a command input of a player.
-- Parses the input and executes the command.
--
-- @tparam Player _player The player who tries to execute the command
-- @tparam string _text The text that the player said
--
-- @raise Error while parsing the command
-- @raise Error while executing the command
--
-- @raise Error in case of unknown command
-- @raise Error while parsing the arguments
-- @tparam CommandList _commandList The command list
function CommandExecutor:handlePotentialCommand(_commandUser, _text)

  -- Fetch the command
  if (not self.commandStringParser:isCommandString(_text)) then
    return false
  end


  local commandSearcher = CommandSearcher(_commandList, _commandUser:getCommandSearcherFilters())
  local command = self.commandStringParser:parseCommand(_text, commandSearcher)
  local parameters = self.commandStringParser:parseParameterValues(command)

  -- Validate the input arguments
  command:validateInputParameters(parameters)

  -- Adjust the input arguments (if needed)
  arguments, options = command:adjustInputParameters(parameters)

  -- Execute the command
  command:execute(_commandUser, arguments, options)

  return true

end


return CommandExecutor
