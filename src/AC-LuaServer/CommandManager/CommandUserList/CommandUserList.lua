---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local CommandUser = require "AC-LuaServer.CommandManager.CommandUserList.CommandUser"
local CommandUserAlreadyExistsException = require "AC-LuaServer.CommandManager.CommandUserList.Exception.CommandUserAlreadyExistsException"
local CommandUserNotExistsException = require "AC-LuaServer.CommandManager.CommandUserList.Exception.CommandUserNotExistsException"
local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local Object = require "classic"

---
-- Stores and manages all currently connected CommandUser's.
--
-- @type CommandUserList
--
local CommandUserList = Object:extend()

---
-- The list of CommandUser's
--
-- @tfield CommandUser[] commandUsers
--
CommandUserList.commandUsers = nil

---
-- The EventCallback for the "onPlayerAdded" event of the servers PlayerList
--
-- @tfield EventCallback onPlayerAddedEventCallback
--
CommandUserList.onPlayerAddedEventCallback = nil

---
-- The EventCallback for the "onPlayerRemoved" event of the servers PlayerList
--
-- @tfield EventCallback onPlayerRemovedEventCallback
--
CommandUserList.onPlayerRemovedEventCallback = nil

---
-- The EventCallback for the "onPlayerRoleChanged" event of the servers PlayerList
--
-- @tfield EventCallback onPlayerRoleChangedEventCallback
--
CommandUserList.onPlayerRoleChangedEventCallback = nil


---
-- CommandUserList constructor.
--
function CommandUserList:new()
  self.commandUsers = {}

  self.onPlayerAddedEventCallback = EventCallback({ object = self, methodName = "onPlayerAdded"})
  self.onPlayerRemovedEventCallback = EventCallback({ object = self, methodName = "onPlayeRemoved"})
  self.onPlayerRoleChangedEventCallback = EventCallback({ object = self, methodName = "onPlayerRoleChanged"})
end


-- Public Methods

---
-- Initializes this CommandUserList.
--
-- @tparam PlayerList _playerList The PlayerList of the server
--
function CommandUserList:initialize(_playerList)

  -- Add CommandUser's for all existing Player's
  for _, player in pairs(_playerList:getAllPlayers()) do
    self:addCommandUser(player)
  end

  -- Add event listeners to the PlayerList
  _playerList:on("onPlayerAdded", self.onPlayerAddedEventCallback)
  _playerList:on("onPlayerRemoved", self.onPlayerRemovedEventCallback)
  _playerList:on("onPlayerRoleChanged", self.onPlayerRoleChangedEventCallback)

end

---
-- Clears this CommandUserList.
--
-- @tparam PlayerList _playerList The PlayerList of the server
--
function CommandUserList:clear(_playerList)
  self.commandUsers = {}

  _playerList:off("onPlayerAdded", self.onPlayerAddedEventCallback)
  _playerList:off("onPlayerRemoved", self.onPlayerRemovedEventCallback)
  _playerList:off("onPlayerRoleChanged", self.onPlayerRoleChangedEventCallback)
end


---
-- Returns a CommandUser by the corresponding Player's client number.
--
-- @tparam int _cn The client number of the Player whose CommandUser instance to return
--
function CommandUserList:getCommandUserByCn(_cn)
  return self.commandUsers[_cn]
end


-- Event Handlers

---
-- Event handler that is called when a Player is added to the server's PlayerList.
--
-- @tparam Player _player The Player that was added
--
function CommandUserList:onPlayerAdded(_player)
  self:addCommandUser(_player)
end

---
-- Event handler that is called when a Player is removed from the server's PlayerList.
--
-- @tparam Player _player The Player that was removed
--
function CommandUserList:onPlayerRemoved(_player)
  self:removeCommandUser(_player)
end

---
-- Event handler that is called when the role of a Player changed.
--
-- @tparam Player _player The player whose role changed
--
function CommandUserList:onPlayerRoleChanged(_player)

  local commandUser = self:getCommandUserByCn(_player:getCn())
  if (_player:hasAdminRole()) then
    commandUser:setLevel(1)
  else
    commandUser:setLevel(0)
  end

end


-- Private Methods

---
-- Adds a CommandUser to this list.
--
-- @tparam Player _player The Player to add a CommandUser for
--
function CommandUserList:addCommandUser(_player)

  local existingCommandUser = self:getCommandUserByCn(_player:getCn())
  if (existingCommandUser) then
    error(CommandUserAlreadyExistsException(_player))
  else
    self.commandUsers[_player:getCn()] = CommandUser(_player)
  end

end

---
-- Removes a CommandUser from this list.
--
-- @tparam Player _player The Player whose CommandUser to remove
--
function CommandUserList:removeCommandUser(_player)

  local existingCommandUser = self:getCommandUserByCn(_player:getCn())
  if (existingCommandUser) then
    self.commandUsers[_player:getCn()] = nil
  else
    error(CommandUserNotExistsException(_player))
  end

end


return CommandUserList
