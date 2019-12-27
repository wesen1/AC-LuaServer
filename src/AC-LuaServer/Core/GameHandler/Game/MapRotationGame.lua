---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ScheduledGame = require "AC-LuaServer.Core.GameHandler.Game.ScheduledGame"

---
-- Represents a game that is stored in a map rotation entry.
--
-- @type MapRotationGame
--
local MapRotationGame = ScheduledGame:extend()


---
-- The MapRotationEntry from which the Game info will be extracted
--
-- @tfield MapRotationEntry mapRotationEntry
--
MapRotationGame.mapRotationEntry = nil


---
-- MapRotationGame constructor.
--
-- @tparam MapRotationEntry _mapRotationEntry The MapRotationEntry from which the Game info will be extracted
--
function MapRotationGame:new(_mapRotationEntry)
  self.mapRotationEntry = _mapRotationEntry
end


-- Public Methods

---
-- Returns the map name.
--
-- @treturn string The map name
--
function MapRotationGame:getMapName()
  return self.mapRotationEntry:getMapName()
end

---
-- Returns the game mode id.
--
-- @treturn int The game mode id
--
function MapRotationGame:getGameModeId()
  return self.mapRotationEntry:getGameModeId()
end

---
-- Returns the time in minutes.
--
-- @treturn int The time in minutes
--
function MapRotationGame:getTimeInMinutes()
  return self.mapRotationEntry:getTimeInMinutes()
end


return MapRotationGame
