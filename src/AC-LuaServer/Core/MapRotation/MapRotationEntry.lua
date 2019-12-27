---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local Object = require "classic"

---
-- Stores the information of a single map rotation entry.
--
-- @type MapRotationEntry
--
local MapRotationEntry = Object:extend()


---
-- The map name
--
-- @tfield string mapName
--
MapRotationEntry.mapName = nil

---
-- The game mode id
--
-- @tfield int gameModeId
--
MapRotationEntry.gameModeId = nil

---
-- The time in minutes
--
-- @tfield int timeInMinutes
--
MapRotationEntry.timeInMinutes = nil

---
-- Stores whether non admin players are allowed to call votes to change to another game
--
-- @tfield bool areGamechangeVotesAllowed
--
MapRotationEntry.areGameChangeVotesAllowed = nil

---
-- The minimum number of players that must be connected to make this entry usable
--
-- @tfield int minimumNumberOfPlayers
--
MapRotationEntry.minimumNumberOfPlayers = nil

---
-- The maximum number of players that may be connected to keep this entry usable
--
-- @tfield int maximumNumberOfPlayers
--
MapRotationEntry.maximumNumberOfPlayers = nil

---
-- The number of usable entrys that will be skipped after this entry was used
--
-- @tfield int numberOfSkipLines
--
MapRotationEntry.numberOfSkipLines = nil


---
-- MapRotationEntry constructor.
--
-- @tparam string _mapName The map name
--
function MapRotationEntry:new(_mapName)

  self.mapName = _mapName
  self.gameModeId = LuaServerApi.GM_CTF
  self.timeInMinutes = 15
  self.areGameChangeVotesAllowed = true
  self.minimumNumberOfPlayers = 0
  self.maximumNumberOfPlayers = 16
  self.numberOfSkipLines = 0

end


-- Getters and Setters

---
-- Returns the map name.
--
-- @treturn string The map name
--
function MapRotationEntry:getMapName()
  return self.mapName
end

---
-- Returns the game mode id.
--
-- @treturn int The game mode id
--
function MapRotationEntry:getGameModeId()
  return self.gameModeId
end

---
-- Sets the game mode id.
--
-- @tparam int _gameModeId The game mode id
--
-- @treturn MapRotationEntry The MapRotationEntry to be able to chain other method calls
--
function MapRotationEntry:setGameModeId(_gameModeId)
  self.gameModeId = _gameModeId
  return self
end

---
-- Returns the time in minutes.
--
-- @treturn int The time in minutes
--
function MapRotationEntry:getTimeInMinutes()
  return self.timeInMinutes
end

---
-- Sets the time in minutes.
--
-- @tparam int _timeInMinutes The time in minutes
--
-- @treturn MapRotationEntry The MapRotationEntry to be able to chain other method calls
--
function MapRotationEntry:setTimeInMinutes(_timeInMinutes)
  self.timeInMinutes = _timeInMinutes
  return self
end

---
-- Returns whether non admin players are allowed to call game changing votes.
--
-- @treturn bool True if non admin players are allowed to call game changing votes, false otherwise
--
function MapRotationEntry:getAreGameChangeVotesAllowed()
  return self.areGameChangeVotesAllowed
end

---
-- Sets whether non admin players are allowed to call votes to change to another game.
--
-- @tparam bool _areGameChangeVotesAllowed True to allow non admin players to call game changing votes, false otherwise
--
-- @treturn MapRotationEntry The MapRotationEntry to be able to chain other method calls
--
function MapRotationEntry:setAreGameChangeVotesAllowed(_areGameChangeVotesAllowed)
  self.areGameChangeVotesAllowed = _areGameChangeVotesAllowed
  return self
end

---
-- Returns the minimum number of players that must be connected to make this entry usable.
--
-- @treturn int The minimum number of players
--
function MapRotationEntry:getMinimumNumberOfPlayers()
  return self.minimumNumberOfPlayers
end

---
-- Sets the minimum number of players that must be connected to make this entry usable.
--
-- @tparam int _minimumNumberOfPlayers The minimum number of players that must be connected to make this entry usable
--
-- @treturn MapRotationEntry The MapRotationEntry to be able to chain other method calls
--
function MapRotationEntry:setMinimumNumberOfPlayers(_minimumNumberOfPlayers)
  self.minimumNumberOfPlayers = _minimumNumberOfPlayers
  return self
end

---
-- Returns the maximum number of players that may be connected to keep this entry usable-
--
-- @treturn int The maximum number of players that may be connected to keep this entry usable
--
function MapRotationEntry:getMaximumNumberOfPlayers()
  return self.maximumNumberOfPlayers
end

---
-- Sets The maximum number of players that may be connected to keep this entry usable.
--
-- @tparam int _maximumNumberOfPlayers The maximum number of players that may be connected to keep this entry usable
--
-- @treturn MapRotationEntry The MapRotationEntry to be able to chain other method calls
--
function MapRotationEntry:setMaximumNumberOfPlayers(_maximumNumberOfPlayers)
  self.maximumNumberOfPlayers = _maximumNumberOfPlayers
  return self
end

---
-- Returns the number of usable entrys that will be skipped after this entry was used.
--
-- @treturn int The number of usable entrys that will be skipped after this entry was used
--
function MapRotationEntry:getNumberOfSkipLines()
  return self.numberOfSkipLines
end

---
-- Sets the number of usable entrys that will be skipped after this entry was used.
--
-- @tparam int _numberOfSkipLines The number of usable entrys that will be skipped after this entry was used
--
-- @treturn MapRotationEntry The MapRotationEntry to be able to chain other method calls
--
function MapRotationEntry:setNumberOfSkipLines(_numberOfSkipLines)
  self.numberOfSkipLines = _numberOfSkipLines
  return self
end


return MapRotationEntry
