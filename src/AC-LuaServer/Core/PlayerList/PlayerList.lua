---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventEmitter = require "AC-LuaServer.Core.Event.EventEmitter"
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
  onPlayerConnect = "onPlayerConnect",
  onPlayerDisconnectAfter = "onPlayerDisconnectAfter",
  onPlayerNameChange = "onPlayerNameChange"
}


---
-- PlayerList constructor.
--
function PlayerList:new()
  self.players = {}
  self.eventCallbacks = {}
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


-- Event handlers

---
-- Initializes the PlayerList.
--
function PlayerList:initialize()
  self:registerAllServerEventListeners()
end

---
-- Event handler that is called when a player connects to the server.
--
-- @tparam int _cn The client number of the player who connected
--
-- @emits The "onPlayerAdded" event after the player was added to this PlayerList
--
function PlayerList:onPlayerConnect(_cn)
  local connectedPlayer = Player.createFromConnectedPlayer(_cn)
  self.players[_cn] = connectedPlayer
  self:emit("onPlayerAdded", connectedPlayer)
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
  self:emit("onPlayerRemoved", disconnectedPlayer)

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


return PlayerList
