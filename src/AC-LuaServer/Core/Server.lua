---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"
local ExtensionManager = require "AC-LuaServer.Core.Extension.ExtensionManager"
local ExtensionTarget = require "AC-LuaServer.Core.Extension.ExtensionTarget"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local PlayerList = require "AC-LuaServer.Core.PlayerList.PlayerList"
local ServerEventListener = require "AC-LuaServer.Core.ServerEvent.ServerEventListener"
local ServerEventManager = require "AC-LuaServer.Core.ServerEvent.ServerEventManager"

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
-- The list of connected players
--
-- @tfield PlayerList playerList
--
Server.playerList = nil

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
  self.name = "server"
  self.extensions = {}
  self.isEnabled = true

  self.eventManager = ServerEventManager()
  self.extensionManager = ExtensionManager(self)
  self.playerList = PlayerList()

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
-- Returns the list of Player's.
--
-- @treturn PlayerList The list of Player's
--
function Server:getPlayerList()
  return self.playerList
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
-- Initializes the Server.
--
function Server:initialize()
  -- Cannot register the server event listeners in the constructor because that causes a dependency loop
  self.playerList:initialize()
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
