---
-- @author wesen
-- @copyright 2019-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventEmitter = require "AC-LuaServer.Core.Event.EventEmitter"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local Object = require "classic"
local Player = require "AC-LuaServer.Core.PlayerList.Player"
local ServerEventListener = require "AC-LuaServer.Core.ServerEvent.ServerEventListener"

---
-- Stores the list of currently connected players.
--
-- @type PlayerList
--
local PlayerList = Object:extend()
PlayerList:implement(EventEmitter)
PlayerList:implement(ServerEventListener)


---
-- The list of server events for which this class listens
--
-- @tfield table serverEventListeners
--
PlayerList.serverEventListeners = {
  onPlayerPreconnect = "onPlayerPreconnect",
  onPlayerConnect = "onPlayerConnect",
  onPlayerDisconnectAfter = "onPlayerDisconnectAfter",
  onPlayerNameChange = "onPlayerNameChange",
  onPlayerRoleChange = "onPlayerRoleChange"
}

---
-- The list of players
--
-- @tfield Player[] players
--
PlayerList.players = nil

---
-- The class that will be used to create Player objects
--
-- @tfield Object playerImplementationClass
--
PlayerList.playerImplementationClass = nil


---
-- PlayerList constructor.
--
function PlayerList:new()
  self.eventCallbacks = {}
  self.players = {}
  self.playerImplementationClass = Player
end


-- Public Methods

---
-- Returns a Player by his client number.
--
-- @tparam int _cn The client number of the Player
--
-- @treturn Player|nil The Player object for the client number
--
function PlayerList:getPlayerByCn(_cn)
  return self.players[_cn]
end

---
-- Returns the list of currently connected Player's.
--
-- @treturn Player[] The list of currently connected Player's
--
function PlayerList:getPlayers()
  return self.players
end

---
-- Sets the class that should be used to create Player objects.
--
-- @tparam Object _playerImplementationClass The class to use to create Player objects
--
function PlayerList:setPlayerImplementationClass(_playerImplementationClass)
  self.playerImplementationClass = _playerImplementationClass
end


-- Event handlers

---
-- Initializes the PlayerList.
--
function PlayerList:initialize()
  self:registerAllServerEventListeners()
end

---
-- Event handler that is called when a player connects to the server.
-- This event handler will be called before bans/blacklist entries are applied.
--
-- @tparam int _cn The client number of the player who connected
--
function PlayerList:onPlayerPreconnect(_cn)
  self.players[_cn] = self.playerImplementationClass.createFromConnectedPlayer(_cn)
end

---
-- Event handler that is called when a player connects to the server.
-- This event handler will be called after bans/blacklist entries were applied.
--
-- @tparam int _cn The client number of the player who connected
--
-- @emits The "onPlayerAdded" event after the player was added to this PlayerList
--
function PlayerList:onPlayerConnect(_cn)
  self:emit("onPlayerAdded", self.players[_cn], self:calculateNumberOfPlayers())
end

---
-- Event handler that is called after a player completely disconnected from the server.
--
-- @tparam int _cn The client number of the player who disconnected
--
-- @emits The "onPlayerRemoved" event after the player was removed from this PlayerList
--
function PlayerList:onPlayerDisconnectAfter(_cn)

  local disconnectedPlayer = self.players[_cn]

  -- The player must be removed after he fully disconnected because he can still trigger events
  -- after the "onPlayerDisconnect" event (such as a flag action when he held the flag before
  -- disconnecting)
  self.players[_cn] = nil

  self:emit("onPlayerRemoved", disconnectedPlayer, self:calculateNumberOfPlayers())

end

---
-- Event handler that is called when a player changes his name.
--
-- @tparam int _cn The client number of the player who changed his name
-- @tparam string _newName The new name of the player
--
-- @emits The "onPlayerNameChanged" event after the Player object was adjusted
--
function PlayerList:onPlayerNameChange(_cn, _newName)

  local player = self.players[_cn]

  -- Must check whether the Player object is set because it is possible that the player used a script
  -- to change his name multiple times in a row within a small time frame and got autokicked for spam
  if (player) then
    local previousName = player:getName()
    player:setName(_newName)
    self:emit("onPlayerNameChanged", player, previousName)
  end

end

---
-- Event handler that is called when the role of a player changes.
-- This will be triggered when a player claims or drops admin.
--
-- @tparam int _cn The client number of the player whose role changed
-- @tparam int _newRole The new role of the player
--
function PlayerList:onPlayerRoleChange(_cn, _newRole)

  local roleChangePlayer = self.players[_cn]

  if (_newRole == LuaServerApi.CR_ADMIN) then
    roleChangePlayer:setHasAdminRole(true)

    -- There can only be one active player with the admin role at a time
    -- If there is already a player with the admin role he will lose the role when another player
    -- claims admin
    for cn, player in pairs(self.players) do
      if (cn ~= _cn and player:getHasAdminRole()) then
        player:setHasAdminRole(false)
        break
      end
    end

  elseif (_newRole == LuaServerApi.CR_DEFAULT) then
    roleChangePlayer:setHasAdminRole(false)
  end

end


-- Private functions

---
-- Calculates and returns the number of players in this PlayerList.
--
-- @treturn int The number of players
--
function PlayerList:calculateNumberOfPlayers()

  local numberOfPlayers = 0
  for _, _ in pairs(self.players) do
    numberOfPlayers = numberOfPlayers + 1
  end

  return numberOfPlayers

end


return PlayerList
