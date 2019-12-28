---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Game = require "AC-LuaServer.Core.GameHandler.Game.Game"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local MaximumRemainingTimeExceededException = require "AC-LuaServer.Core.GameHandler.Game.Exception.MaximumRemainingTimeExceededException"

---
-- Represents the current active Game.
--
-- @type ActiveGame
--
local ActiveGame = Game:extend()


---
-- The map name
--
-- @tfield string mapName
--
ActiveGame.mapName = nil

---
-- The game mode id
--
-- @tfield int gameModeId
--
ActiveGame.gameModeId = nil


---
-- ActiveGame constructor.
--
-- @tparam string _mapName The map name
-- @tparam int _gameModeId The game mode id
--
function ActiveGame:new(_mapName, _gameModeId)
  self.mapName = _mapName
  self.gameModeId = _gameModeId
end


-- Getters and Setters

---
-- Returns the map name.
--
-- @treturn string The map name
--
function ActiveGame:getMapName()
  return self.mapName
end

---
-- Returns the game mode id.
--
-- @treturn int The game mode id
--
function ActiveGame:getGameModeId()
  return self.gameModeId
end


-- Public Methods

---
-- Returns the remaining time in milliseconds.
--
-- @treturn int The remaining in milliseconds
--
function ActiveGame:getRemainingTimeInMilliseconds()
  return LuaServerApi.gettimeleftmillis()
end

---
-- Sets the remaining time in milliseconds.
--
-- @tparam int _newRemainingTimeInMilliseconds The new remaining time in milliseconds
--
function ActiveGame:setRemainingTimeInMilliseconds(_newRemainingTimeInMilliseconds)

  -- Check if the new remaining time in milliseconds is valid

  --
  -- The remaining time is calculated as "game limit - gamemillis (milliseconds since game start)".
  --
  -- The setmillisecondsremaining function changes the game limit, so that the gap is the desired
  -- number of milliseconds.
  --
  -- Additionally there is a intermission check (check whether the game is finished) that
  -- calculates the number of remaining minutes as "(game limit - gamemillis + 60000 - 1)/60000".
  -- If the game limit is the maximum integer value and the gamemillis value is less than 60000,
  -- the maximum integer value will be exceeded while the expression is calculated (from left to
  -- right).
  --
  local gamemillis = LuaServerApi.getgamemillis()
  local newGameLimit = gamemillis + _newRemainingTimeInMilliseconds

  --
  -- The maximum integer value for signed integers is (2 ^ 31 - 1).
  -- Exceeding this number will result in negative numbers (the number continues at -2147483647).
  --
  local maximumGameLimit = 2147483647
  if (gamemillis < 60000) then
    maximumGameLimit = maximumGameLimit - 60000
  end

  if (newGameLimit > maximumGameLimit) then
    error(MaximumRemainingTimeExceededException(newGameLimit - maximumGameLimit, (gamemillis >= 60000)))
  else
    LuaServerApi.settimeleft(_newRemainingTimeInMilliseconds)
  end

end


return ActiveGame
