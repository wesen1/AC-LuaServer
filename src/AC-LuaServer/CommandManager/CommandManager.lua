---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local CommandExecutor = require "AC-LuaServer.CommandManager.CommandExecutor.CommandExecutor"
local CommandGroup = require "AC-LuaServer.CommandManager.CommandList.CommandGroup"
local CommandList = require "AC-LuaServer.CommandManager.CommandList.CommandList"
local CommandSearcher = require "AC-LuaServer.CommandManager.CommandSearcher.CommandSearcher"
local CommandUserList = require "AC-LuaServer.CommandManager.CommandUserList.CommandUserList"
local HelpCommand = require "AC-LuaServer.CommandManager.DefaultCommands.HelpCommand"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local ListCommandsCommand = require "AC-LuaServer.CommandManager.DefaultCommands.ListCommandsCommand"
local ServerEventListener = require "AC-LuaServer.Core.ServerEvent.ServerEventListener"
local TemplateException = require "AC-LuaServer.Core.Util.Exception.TemplateException"

---
-- Manages the list of available commands, command users and command execution.
--
-- @type CommandManager
--
local CommandManager = BaseExtension:extend()
CommandManager:implement(ServerEventListener)


---
-- The CommandExecutor that will be used to execute commands
--
-- @tfield CommandExecutor commandExecutor
--
CommandManager.commandExecutor = nil

---
-- The CommandList that stores all available commands
--
-- @tfield CommandList commandList
--
CommandManager.commandList = nil

---
-- The CommandUserList that stores all CommandUser's
--
-- @tfield CommandUserList commandUserList
--
CommandManager.commandUserList = nil

---
-- The list of server events for which this class listens
--
-- @tfield table serverEventListeners
--
CommandManager.serverEventListeners = {
  onPlayerSayText = { ["methodName"] = "onPlayerSayText", ["priority"] = 0 }
}


---
-- CommandManager constructor.
--
function CommandManager:new()
  BaseExtension.new(self, "CommandManager", "Server")

  self.commandExecutor = CommandExecutor()
  self.commandList = CommandList()
  self.commandUserList = CommandUserList()
end


-- Getters and Setters

---
-- Returns the CommandList.
--
-- @treturn CommandList The CommandList
--
function CommandManager:getCommandList()
  return self.commandList
end


-- Event Handlers

---
-- Handles the "onPlayerSayText" event.
-- Checks if the text that the player said is a command and executes the command if required.
--
-- @tparam int _cn The client number of the player who said text
-- @tparam string _text The text that the player said
--
function CommandManager:onPlayerSayText(_cn, _text)

  local commandUser = self.commandUserList:getPlayerByCn(_cn)
  local commandSearcher = CommandSearcher(self.commandList, commandUser:getCommandSearcherFilters())
  local success, returnValue = pcall(
    self.commandExecutor.handlePotentialCommand, self.commandExecutor, commandUser, commandSearcher, _text
  )

  if (success) then
    if (returnValue == true) then
      -- Block the normal player text output of the server
      return LuaServerApi.PLUGIN_BLOCK
    end

  else
    local exception = returnValue
    if (type(exception) == "table" and type(exception.is) == "function" and exception:is(TemplateException)) then
      self.target:getOutput():printException(exception, commandUser:getPlayer())
    else
      error(exception)
    end

  end

end

-- Protected Methods

---
-- Initializes this Extension.
--
function CommandManager:initialize()
  self:registerAllServerEventListeners()

  self.commandList:addCommandGroup(CommandGroup("General"))
  self.commandList:addCommand(HelpCommand(), "General")
  self.commandList:addCommand(ListCommandsCommand(), "General")
end

---
-- Terminates this Extension.
--
function CommandManager:terminate()
  self:unregisterAllServerEventListeners()

  self.commandList:clear()
end


return CommandManager
