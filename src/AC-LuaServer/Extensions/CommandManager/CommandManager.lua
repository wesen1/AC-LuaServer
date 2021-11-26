---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"

---
-- Manages a list of Command's and handles when a player says text that can be interpreted as a command.
--
-- @type CommandManager
--
local CommandManager = BaseExtension:extend()


---
-- The list of Command's that are managed by this CommandManager
--
-- @tfield CommandList commandList
--
CommandManager.commandList = nil

---
-- The command parser that interprets command strings
--
-- @tfield CommandParser commandParser
--
CommandManager.commandParser = nil


---
-- CommandManager constructor.
--
function CommandManager:new()
  self.commandList = CommandList()
  self.commandParser = CommandParser()
end


-- Event Listeners

---
-- Event handler that is called when a player says text.
-- Logs the text that the player said and either executes a command or outputs the text to the other players.
--
-- @tparam int _cn The client number of the player
-- @tparam string _text The text that the player said
--
-- @treturn int|nil PLUGIN_BLOCK if the text was a command, nil otherwise
--
function CommandManager:onPlayerSayText(_cn, _text)

  if (self.commandParser:isCommand(_text)) then

    local Server = require "AC-LuaServer.Core.Server"
    local server = Server.getInstance()

    local player = server:getPlayerList():getPlayerByCn(_cn)

    local status, exception = pcall(self.handleCommand, self, player, _text)
    if (not status) then
      if (type(exception) == "table" and type(exception.is) == "function" and exception:is(TemplateException)) then
        server.getOutput():printException(exception, player)

        -- Block the normal player text output of the server
        return PLUGIN_BLOCK

      else
        error(exception)
      end
    end

  end

end

---
-- Handles a command input of a player.
--
-- @tparam Player _player The player who used a command
-- @tparam string _text The text that the player said
--
-- @raise Error while parsing the command
-- @raise Error while executing the command
--
function CommandManager:handleCommand(_player, _text)

  self.commandParser:parseCommand(_text, self.commandList)

  local command = self.commandParser:getCommand()
  local parameters = self.commandParser:getParameters()

  if (_player:getLevel() < _command:getRequiredLevel()) then
    error(Exception(StaticString("exceptionNoPermissionToUseCommand"):getString()))
  end

  _command:validateInputParameters(_parameters)
  local parameters = _command:adjustInputParameters(_parameters)

  return _command:execute(_player, parameters)

end


return CommandManager
