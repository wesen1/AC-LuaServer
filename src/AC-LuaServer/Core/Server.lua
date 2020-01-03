---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"
local ExtensionManager = require "AC-LuaServer.Core.Extension.ExtensionManager"
local ExtensionTarget = require "AC-LuaServer.Core.Extension.ExtensionTarget"
local GameHandler = require "AC-LuaServer.Core.GameHandler.GameHandler"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local MapRotation = require "AC-LuaServer.Core.MapRotation.MapRotation"
local Output = require "AC-LuaServer.Core.Output.Output"
local PlayerList = require "AC-LuaServer.Core.PlayerList.PlayerList"
local ServerEventListener = require "AC-LuaServer.Core.ServerEvent.ServerEventListener"
local ServerEventManager = require "AC-LuaServer.Core.ServerEvent.ServerEventManager"
local VoteListener = require "AC-LuaServer.Core.VoteListener.VoteListener"

---
-- The lua server.
--
-- @type Server
--
local Server = Object:extend()
Server:implement(ExtensionTarget)
Server:implement(ServerEventListener)


---
-- The list of server events for which this class listens
--
-- @tfield table serverEventListeners
--
Server.serverEventListeners = {
  onPlayerSayText = { methodName = "onPlayerSayText", priority = 0 }
}


---
-- The event manager for AssaultCube server events
--
-- @tfield ServerEventManager eventManager
--
Server.eventManager = nil

---
-- The extension manager
--
-- @tfield ExtensionManager extensionManager
--
Server.extensionManager = nil

---
-- The game handler
--
-- @tfield GameHandler gameHandler
--
Server.gameHandler = nil

---
-- The map rotation
--
-- @tfield MapRotation mapRotation
--
Server.mapRotation = nil

---
-- The output
--
-- @tfield Output output
--
Server.output = nil

---
-- The list of connected players
--
-- @tfield PlayerList playerList
--
Server.playerList = nil

---
-- The vote listener
--
-- @tfield VoteListener voteListener
--
Server.voteListener = nil

---
-- The global Server instance that will be returned by Server.getInstance()
--
-- @tfield Server globalInstance
--
Server.globalInstance = nil


---
-- Server constructor.
--
function Server:new()

  -- ExtensionTarget
  self.name = "Server"
  self.extensions = {}
  self.isEnabled = true

  self.eventManager = ServerEventManager()
  self.extensionManager = ExtensionManager(self)
  self.gameHandler = GameHandler()
  self.mapRotation = MapRotation()
  self.output = Output()
  self.playerList = PlayerList()
  self.voteListener = VoteListener()

end


-- Getters and Setters

---
-- Returns the event manager for AssaultCube server events.
--
-- @treturn ServerEventManager The event manager
--
function Server:getEventManager()
  return self.eventManager
end

---
-- Returns the game handler.
--
-- @treturn GameHandler The game handler
--
function Server:getGameHandler()
  return self.gameHandler
end

---
-- Returns the map rotation.
--
-- @treturn MapRotation The map rotation
--
function Server:getMapRotation()
  return self.mapRotation
end

---
-- Returns the Output.
--
-- @treturn Output The Output
--
function Server:getOutput()
  return self.output
end

---
-- Returns the list of Player's.
--
-- @treturn PlayerList The list of Player's
--
function Server:getPlayerList()
  return self.playerList
end

---
-- Returns the vote listener.
--
-- @treturn VoteListener The vote listener
--
function Server:getVoteListener()
  return self.voteListener
end


-- Public Methods

---
-- Returns the global Server instance.
-- Will create the global Server instance if it is not set yet.
--
-- @treturn Server The global Server instance
--
function Server.getInstance()

  if (Server.globalInstance == nil) then
    Server.globalInstance = Server()
    Server.globalInstance:initialize()
  end

  return Server.globalInstance

end


---
-- Configures this Server.
--
-- @tparam table _configuration The configuration to apply
--
function Server:configure(_configuration)

  if (type(_configuration) == "table") then
    if (type(_configuration["Output"] == "table")) then
      self.output:configure(_configuration["Output"])
    end
  end

end

---
-- Initializes the Server.
--
function Server:initialize()
  -- Cannot register the server event listeners in the constructor because that causes a dependency loop
  self.gameHandler:initialize()
  self.playerList:initialize()
  self.voteListener:initialize()
  self:registerAllServerEventListeners()
end


---
-- Adds an extension to this Server or to one of its extensions.
--
-- @tparam BaseExtension _extension The extension to add
--
function Server:addExtension(_extension)
  self.extensionManager:addExtension(_extension)
end


---
-- Event handler which is called when a player says text.
--
-- @tparam int _cn The client number of the player
-- @tparam string _text The text that the player sent
--
function Server:onPlayerSayText(_cn, _text)

  local player = self.playerList:getPlayerByCn(_cn)

  LuaServerApi.logline(
    LuaServerApi.ACLOG_INFO,
    string.format(
      "[%s] %s says: '%s'",
      player:getIp(), player:getName(), _text
    )
  )

end


return Server
