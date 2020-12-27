---
-- @author wesen
-- @copyright 2019-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"
local ExtensionManager = require "AC-LuaServer.Core.Extension.ExtensionManager"
local ExtensionTarget = require "AC-LuaServer.Core.Extension.ExtensionTarget"
local GameHandler = require "AC-LuaServer.Core.GameHandler.GameHandler"
local MapRotation = require "AC-LuaServer.Core.MapRotation.MapRotation"
local Output = require "AC-LuaServer.Core.Output.Output"
local PlayerList = require "AC-LuaServer.Core.PlayerList.PlayerList"
local ServerEventManager = require "AC-LuaServer.Core.ServerEvent.ServerEventManager"
local VoteListener = require "AC-LuaServer.Core.VoteListener.VoteListener"

---
-- The lua server.
--
-- @type Server
--
local Server = Object:extend()
Server:implement(ExtensionTarget)


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
-- Returns the extension manager.
--
-- @treturn ExtensionManager The extension manager
--
function Server:getExtensionManager()
  return self.extensionManager
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
    if (type(_configuration["Output"]) == "table") then
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

end


return Server
