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

  self:enableGameMode(self.defaultGameMode)
end




-- Public Methods

---
-- Initializes the event listeners.
--
function GameModeManager:initialize()

  local Server = require "AC-LuaServer.Core.Server"

  local gameHandler = Server.getInstance():getGameHandler()
  gameHandler:on("onGameChangeVoteCalled", EventCallback({ object = self, method = "onGameChangeVoteCalled" }))
  gameHandler:on("onGameWillChange", EventCallback({ object = self, method = "onGameWillChange" }))

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
    -- TODO: Print message that game mode will change to x when vote passes
  end

end

---
-- Event handler that is called when the current Game ended and the next Game is about to be started.
--
-- @tparam Game _game The next game
--
function GameModeManager:onGameWillChange(_game)

  local nextGameMode = self:getGameModeForGame(_game)
  if (nextGameMode ~= self.activeGameMode) then
    self:enableGameMode(nextGameMode)
    -- TODO: Print game mode changed

  end

end

---
-- Event handler that is called when the current active game mode is disabled before the game is changed.
--
function GameModeManager:onActiveGameModeDisabled()

  local Server = require "AC-LuaServer.Core.Server"

  local gameHandler = Server.getInstance():getGameHandler()
  local gameMode = self:getGameModeForGame(gameHandler:getCurrentGame())

  self:enableGameMode(gameMode)

end


-- Private Methods

---
-- Enables a specified game mode.
--
-- @tparam BaseGameMode _gameMode The game mode to enable
--
function GameModeManager:enableGameMode(_gameMode)

  self.activeGameMode:off("disabled", self.onActiveGameModeDisabledEventCallback)
  self.activeGameMode:disable()

  self.activeGameMode = _gameMode
  self.activeGameMode:on("disabled", self.onActiveGameModeDisabledEventCallback)
  self.activeGameMode:enable()

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
