---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require("Util/Exception")
local Object = require("classic")
local ServerEventListener = require("wesenGemaMod/Event/ServerEventListener")
local StaticString = require("Output/StaticString")

---
-- Checks if texts that players say are commands and handles the command execution if needed.
--
-- @type CommandExecutor
--
local CommandExecutor = Object:extend()
CommandExecutor:implement(ServerEventListener)


---
-- The CommandList that stores the available commands
--
-- @tfield CommandList commandList
--
CommandExecutor.commandList = nil

---
-- The CommandParser that detects commands in texts that players say
--
-- @tfield CommandParser commandParser
--
CommandExecutor.commandParser = nil

---
-- The parent server
--
-- @tfield Server parentServer
--
CommandExecutor.parentServer = nil


---
-- CommandExecutor constructor.
--
-- @tparam Server _parentServer The parent server
--
function CommandExecutor:new(_parentServer)
  self.parentServer = _parentServer
  self.commandList = CommandList(_parentServer)
  self.commandParser = CommandParser()
  self.serverEventListeners = {}
end


-- Public Methods

---
-- Enables this CommandExecutor.
--
function CommandExecutor:enable()
  -- TODO: Keep enabled/disabled state to avoid readding the same event listener
  self:registerServerEventListener("onPlayerSayText", self.onPlayerSayText, 0)
end

---
-- Disables this CommandExecutor.
--
function CommandExecutor:disable()
  self:unregisterServerEventListener("onPlayerSayText", self.onPlayerSayText)
end

function CommandExecutor:addCommands(_commands)
  self.commandList:addCommands(_commands)
end

function CommandExecutor:removeCommands(_commands)
  self.commandList:removeCommands(_commands)
end


-- Event Handlers

---
-- Handles the "onPlayerSayText" event.
-- Checks if the text that the player said is a command and executes the command if required.
--
-- @tparam int _cn The client number of the player who said text
-- @tparam string _text The text that the player said
--
function CommandExecutor:onPlayerSayText(_cn, _text)

  -- TODO: Always allow commands for server admins (!cmds, !help, !changeMode)

  if (self.commandParser:isCommand(_text)) then

    local player = self.parentServer:getPlayerList():getPlayerByCn(_cn)

    local callWasSuccessful, exception = pcall(self.parseCommand, self, player, _text)
    if (not callWasSuccessful) then

      if (type(exception) == "string") then
        error(exception)
      else
        self.parentServer:getOutput():printException(exception, player)
      end

    end

    -- Block the normal player text output of the server
    return PLUGIN_BLOCK

  end

end


-- Private Methods

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
function CommandExecutor:handleCommand(_player, _text)

  -- Fetch the command
  self.commandParser:parseCommand(_text, self.parentGemaMode:getCommandList())
  local command = self.commandParser:getCommand()

  -- Check if the player is allowed to execute the command
  if (_player:getLevel() < command:getRequiredLevel()) then
    error(Exception(StaticString("exceptionNoPermissionToUseCommand"):getString()))
  end

  -- Fetch the arguments
  self.commandParser:parseArguments()
  local arguments = self.commandParser:getArguments()

  -- Execute the command
  self:executeCommand(command, arguments, _player)

end

---
-- Executes a command.
--
-- @tparam BaseCommand _command The command
-- @tparam mixed[] _arguments The command arguments
-- @tparam int _player The player who tries to execute the command
--
-- @raise Error during the argument validation
-- @raise Error during the command execution
--
function CommandExecutor:executeCommand(_command, _arguments, _player)

  -- Validate the input arguments
  _command:validateInputArguments(_arguments)

  -- Adjust the input arguments (if needed)
  local arguments = _command:adjustInputArguments(_arguments)

  -- Execute the command
  _command:execute(_player, arguments)

end


return CommandExecutor
