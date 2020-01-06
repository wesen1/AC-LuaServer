---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local DefaultGameMode = require "AC-LuaServer.Extensions.GameModeManager.DefaultGameMode"
local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"

---
-- Manages the available game modes for a server.
-- One game mode can be active at a time.
--
-- @type GameModeManager
--
local GameModeManager = BaseExtension:extend()


---
-- The list of game modes that are provided by the server
--
-- @tfield BaseGameMode[] modes
--
GameModeManager.gameModes = nil

---
-- The default game mode that will be enabled when no other game mode can be enabled for a Game
--
-- @tfield BaseGameMode defaultGameMode
--
GameModeManager.defaultGameMode = nil

---
-- The currently active game mode
--
-- @tfield BaseGameMode activeGameMode
--
GameModeManager.activeGameMode = nil

---
-- The EventCallback for the "disabled" event of the current active game mode
--
-- @tfield EventCallback onActiveGameModeDisabledEventCallback
--
GameModeManager.onActiveGameModeDisabledEventCallback = nil


---
-- GameModeManager constructor.
--
function GameModeManager:new()
  self.super.new(self, "GameModeManager", "Server")

  self.defaultGameMode = DefaultGameMode()
  self.gameModes = {}

  self.onActiveGameModeDisabledEventCallback = EventCallback({ object = self, methodName = "onActiveGameModeDisabled"})
end


-- Public Methods

---
-- Adds the DefaultGameMode extension to the server and initializes the event listeners.
--
function GameModeManager:initialize()

  local Server = require "AC-LuaServer.Core.Server"
  Server.getInstance():getExtensionManager():addExtension(self.defaultGameMode)

  local gameHandler = Server.getInstance():getGameHandler()
  gameHandler:on("onGameChangeVoteCalled", EventCallback({ object = self, methodName = "onGameChangeVoteCalled" }))
  gameHandler:on("onGameWillChange", EventCallback({ object = self, methodName = "onGameWillOrDidChange" }))
  gameHandler:on("onGameChanged", EventCallback({ object = self, methodName = "onGameWillOrDidChange" }))

end

---
-- Adds a game mode.
--
-- @tparam BaseGameMode _gameMode The game mode to add
--
function GameModeManager:addGameMode(_gameMode)
  table.insert(self.gameModes, _gameMode)
end


-- Event Handlers

---
-- Event handler that is called when a game changing vote was successfully called.
--
-- @tparam Game _game The game that would be played on the next map change if the vote passed
--
function GameModeManager:onGameChangeVoteCalled(_game)

  local potentialNextGameMode = self:getGameModeForGame(_game)
  if (potentialNextGameMode ~= self.activeGameMode) then

    local Server = require "AC-LuaServer.Core.Server"
    local output = Server.getInstance():getOutput()

    output:printTextTemplate(
      "Extensions/GameModeManager/GameModeWillChangeIfVotePasses", {
        nextGameModeName = potentialNextGameMode:getDisplayName()
    })

    self:emit("onGameModeMightChange", self.activeGameMode, potentialNextGameMode)
  end

end

---
-- Event handler that is called when the current Game ended and the next Game is about to be started.
-- It will also be called when the Game changed to handle the Game's that are started when a Player
-- connects.
--
-- @tparam Game _game The next game or the new current game
--
function GameModeManager:onGameWillOrDidChange(_game)

  local nextGameMode = self:getGameModeForGame(_game)
  if (nextGameMode ~= self.activeGameMode) then

    self:enableGameMode(nextGameMode)

    local Server = require "AC-LuaServer.Core.Server"
    local output = Server.getInstance():getOutput()

    output:printTextTemplate(
      "Extensions/GameModeManager/GameModeChanged", {
        newGameModeName = self.activeGameMode:getDisplayName()
    })

    self:emit("onGameModeChanged", self.activeGameMode, nextGameMode)
  end

end

---
-- Event handler that is called when the current active game mode is disabled before the game is changed.
--
function GameModeManager:onActiveGameModeDisabled()

  local Server = require "AC-LuaServer.Core.Server"
  local gameHandler = Server.getInstance():getGameHandler()

  local previousGameMode = self.activeGameMode
  local gameMode = self:getGameModeForGame(gameHandler:getCurrentGame())
  self:enableGameMode(gameMode)

  self:emit("onGameModeChanged", previousGameMode, self.activeGameMode)

end


-- Private Methods

---
-- Enables a specified game mode.
--
-- @tparam BaseGameMode _gameMode The game mode to enable
--
function GameModeManager:enableGameMode(_gameMode)

  if (self.activeGameMode) then
    self.activeGameMode:off("disabled", self.onActiveGameModeDisabledEventCallback)
    self.activeGameMode:disable()
  end

  self.activeGameMode = _gameMode
  self.activeGameMode:on("disabled", self.onActiveGameModeDisabledEventCallback)
  self.activeGameMode:enable(self)

end

---
-- Returns the first game mode that can be enabled for a specified game.
-- If none of the game modes can be enabled the default game mode will be returned.
--
function GameModeManager:getGameModeForGame(_game)

  for _, gameMode in ipairs(self.gameModes) do
    if (gameMode:canBeEnabledForGame(_game)) then
      return gameMode
    end
  end

  return self.defaultGameMode

end


return GameModeManager
