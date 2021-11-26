---
-- @author wesen
-- @copyright 2017-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local CmdsCommand = require("wesenGemaMod/CommandExecutor/DefaultCommands/CmdsCommand")
local EventEmitter = require("wesenGemaMod/Event/EventEmitter")
local HelpCommand = require("wesenGemaMod/CommandExecutor/DefaultCommands/HelpCommand")
local Object = require("classic")
local SortedCommandList = require("wesenGemaMod/CommandExecutor/CommandList/SortedCommandList")

---
-- Stores a list of all available commands and provides methods to get the commands.
--
-- @type CommandList
--
local CommandList = Object:extend()
CommandList:implement(EventEmitter)


---
-- The list of commands in the format { commandName => Command }
--
-- @tfield BaseCommand[] commands
--
CommandList.commands = nil

---
-- The parent server
--
-- @tfield Server parentServer
--
CommandList.parentServer = nil


---
-- CommandList constructor.
--
-- @tparam Server _parentServer The parent server
--
function CommandList:new(_parentServer)
  self.commands = {}
  self.parentServer = _parentServer
  self.eventCallbacks = {}
end


-- Getters and setters

---
-- Returns the parent server.
--
-- @treturn Server The parent server
--
function CommandList:getParentServer()
  return self.parentServer
end


-- Public Methods

---
-- Initializes this CommandList with the default commands "!commands" and "!help".
--
function CommandList:initialize()
  self:addCommand(CmdsCommand())
  self:addCommand(HelpCommand())
end

---
-- Adds a list of commands to this CommandList.
--
-- @tparam BaseCommand[] _commands The list of commands to add
--
-- @emits The "onCommandsAdded" event after the commands were added
--
function CommandList:addCommands(_commands)
  for _, command in ipairs(_commands) do
    self:addCommand(command)
  end

  self:emit("onCommandsAdded")
end

---
-- Removes a list of commands from this CommandList.
--
-- @tparam BaseCommand[] _commands The list of commands to remove
--
-- @emits The "onCommandsRemoved" event after the commands were removed
--
function CommandList:removeCommands(_commands)
  for _, command in ipairs(_commands) do
    self:removeCommand(command)
  end

  self:emit("onCommandsRemoved")
end

---
-- Returns a command that has a specified name or alias.
--
-- @tparam string _commandName The command name without the leading "!"
--
-- @treturn BaseCommand|bool The command or false if no command with that name or alias exists
--
function CommandList:getCommandByNameOrAlias(_commandName)

  local command = self.commands[_commandName]
  if (command) then
    return command
  else

    -- Check aliases
    for _, command in pairs(self.commands) do
      if (command:hasAlias(_commandName)) then
        return command
      end
    end

    return false

  end

end

---
-- Generates and returns a SortedCommandList for the commands that are stored inside this CommandList.
--
-- @treturn SortedCommandList The SortedCommandList
--
function CommandList:generateSortedCommandList()
  local sortedCommandList = SortedCommandList()
  sortedCommandList:parse(self.commands)

  return sortedCommandList
end


-- Private Methods

---
-- Adds a command to this CommandList.
--
-- @tparam BaseCommand _command The command to add
--
function CommandList:addCommand(_command)
  _command:attachToCommandList(self)
  self.commands[_command:getName():lower()] = _command
end

---
-- Removes a command from this CommandList.
--
-- @tparam BaseCommand _command The command to remove
--
function CommandList:removeCommand(_command)
  _command:detachFromCommandList(self)
  self.commands[_command:getName():lower()] = _command
end


return CommandList
