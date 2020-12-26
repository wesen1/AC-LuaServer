---
-- @author wesen
-- @copyright 2019-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local BaseGameMode = require "AC-LuaServer.Extensions.GameModeManager.BaseGameMode"
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
-- Stores whether this ExtensionTarget automatically enables child extensions when this ExtensionTarget
-- is enabled
--
-- @tfield bool autoEnableChildExtensions
--
GameModeManager.autoEnableChildExtensions = false

---
-- The list of game modes that are provided by the server
--
-- @tfield BaseGameMode[] modes
--
GameModeManager.gameModes = nil

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

  self.gameModes = {}
  self.onActiveGameModeDisabledEventCallback = EventCallback({ object = self, methodName = "onActiveGameModeDisabled"})
end


-- Getters and Setters

---
-- Returns the currently active game mode.
--
-- @treturn BaseGameMode The currently active game mode
--
function GameModeManager:getActiveGameMode()
  return self.activeGameMode
end


-- Public Methods

---
-- Adds the DefaultGameMode extension to the server and initializes the event listeners.
--
function GameModeManager:initialize()

  self.target:getExtensionManager():addExtension(DefaultGameMode())

  local gameHandler = self.target:getGameHandler()
  gameHandler:on("onGameChangeVoteCalled", EventCallback({ object = self, methodName = "onGameChangeVoteCalled" }))
  gameHandler:on("onGameWillChange", EventCallback({ object = self, methodName = "onGameWillOrDidChange" }))
  gameHandler:on("onGameChangedPlayerConnected", EventCallback({ object = self, methodName = "onGameWillOrDidChange" }))


  -- Enable non GameMode extensions
  for _, extension in ipairs(self.extensions) do
    if (not extension:is(BaseGameMode)) then
      extension:enable(self)
    end
  end

end

---
-- Adds a extension to this GameModeManager.
--
-- @tparam BaseExtension _extension The extension to add
--
function GameModeManager:addExtension(_extension)
  self.super.addExtension(self, _extension)

  if (_extension:is(BaseGameMode)) then
    self:addGameMode(_extension)
  else
    if (self.isEnabled) then
      _extension:enable(self)
    end
  end

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

    self.target:getOutput():printTextTemplate(
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

    local previousGameMode = self.activeGameMode
    self:enableGameMode(nextGameMode)

    self.target:getOutput():printTextTemplate(
      "Extensions/GameModeManager/GameModeChanged", {
        newGameModeName = self.activeGameMode:getDisplayName()
    })

    self:emit("onGameModeChanged", previousGameMode, self.activeGameMode)
  end

end

---
-- Event handler that is called when the current active game mode is disabled before the game is changed.
--
function GameModeManager:onActiveGameModeDisabled()

  local gameHandler = self.target:getGameHandler()

  local previousGameMode = self.activeGameMode
  local gameMode = self:getGameModeForGame(gameHandler:getCurrentGame())
  self:enableGameMode(gameMode)

  self:emit("onGameModeChanged", previousGameMode, self.activeGameMode)

end


-- Private Methods

---
-- Adds a game mode.
--
-- @tparam BaseGameMode _gameMode The game mode to add
--
function GameModeManager:addGameMode(_gameMode)

  if (_gameMode:is(DefaultGameMode)) then
    -- The game mode is the default game mode, append it to the end of the game modes list
    table.insert(self.gameModes, _gameMode)
  else
    -- The game mode is not the default game mode, insert it as the second last item of the game modes list
    local numberOfGameModes = #self.gameModes
    if (numberOfGameModes == 0) then
      table.insert(self.gameModes, _gameMode)
    else
      table.insert(self.gameModes, numberOfGameModes, _gameMode)
    end
  end

end

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
-- @treturn GameMode The game mode that can be enabled for the specified game
--
function GameModeManager:getGameModeForGame(_game)

  for _, gameMode in ipairs(self.gameModes) do
    if (gameMode:canBeEnabledForGame(_game)) then
      return gameMode
    end
  end

end


return GameModeManager
