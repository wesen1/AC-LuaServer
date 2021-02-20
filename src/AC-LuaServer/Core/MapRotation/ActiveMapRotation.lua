---
-- @author wesen
-- @copyright 2018-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local MapRotationEntry = require "AC-LuaServer.Core.MapRotation.MapRotationEntry"
local Object = require "classic"

---
-- Represents the currently loaded map rotation.
--
-- @type ActiveMapRotation
--
local ActiveMapRotation = Object:extend()


-- Public Methods

---
-- Loads the map rotation from a config file.
--
-- @tparam string _mapRotationConfigFilePath The map rotation config file to load
--
function ActiveMapRotation:loadFromFile(_mapRotationConfigFilePath)
  LuaServerApi.setmaprot(_mapRotationConfigFilePath)
end

---
-- Returns the next map rotation entry.
--
-- @treturn MapRotationEntry The next map rotation entry
--
function ActiveMapRotation:getNextEntry()

  local rawNextEntry = LuaServerApi.getmaprotnextentry()

  local nextEntry = MapRotationEntry(rawNextEntry["map"])
  nextEntry:setGameModeId(rawNextEntry["mode"])
           :setTimeInMinutes(rawNextEntry["time"])
           :setAreGameChangeVotesAllowed((rawNextEntry["allowVote"] == 1))
           :setMinimumNumberOfPlayers(rawNextEntry["minplayer"])
           :setMaximumNumberOfPlayers(rawNextEntry["maxplayer"])
           :setNumberOfSkipLines(rawNextEntry["skiplines"])

  return nextEntry

end

---
-- Appends a entry to the active map rotation.
--
-- @tparam MapRotationEntry _mapRotationEntry The entry to append
--
function ActiveMapRotation:appendEntry(_mapRotationEntry)
  LuaServerApi.addmaprotentry(self:convertMapRotationEntryToConfigTable(_mapRotationEntry))
end

---
-- Replaces all entries in the active map rotation by a given list of MapRotationEntry's.
--
-- @tparam MapRotationEntry[] _mapRotationEntries The MapRotationEntry's to set
--
function ActiveMapRotation:setEntries(_mapRotationEntries)
  local mapRotationConfigTables = {}
  for _, mapRotationEntry in ipairs(_mapRotationEntries) do
    table.insert(mapRotationConfigTables, self:convertMapRotationEntryToConfigTable(mapRotationEntry))
  end

  LuaServerApi.setwholemaprot(mapRotationConfigTables)
end

---
-- Removes all map rotation entries for a specific map from the active map rotation.
--
-- @tparam string _mapName The map name to search for
--
function ActiveMapRotation:removeEntriesForMap(_mapName)

  local updatedMapRotation = {}
  for _, rawMapRotationEntry in ipairs(LuaServerApi.getwholemaprot()) do
    if (rawMapRotationEntry["map"] ~= _mapName) then
      table.insert(updatedMapRotation, rawMapRotationEntry)
    end
  end

  LuaServerApi.setwholemaprot(updatedMapRotation)

end

---
-- Clears the active map rotation.
--
function ActiveMapRotation:clear()
  LuaServerApi.setwholemaprot({})
end


-- Private Methods

---
-- Converts a given MapRotationEntry to a map rotation entry config table that can be used for LuaServerApi functions.
--
-- @tparam MapRotationEntry _mapRotationEntry The MapRotationEntry to convert
--
-- @treturn table The generated map rotation entry config table
--
function ActiveMapRotation:convertMapRotationEntryToConfigTable(_mapRotationEntry)

  return {
    ["map"] = _mapRotationEntry:getMapName(),
    ["mode"] = _mapRotationEntry:getGameModeId(),
    ["time"] = _mapRotationEntry:getTimeInMinutes(),
    ["allowVote"] = _mapRotationEntry:getAreGameChangeVotesAllowed() and 1 or 0,
    ["minplayer"] = _mapRotationEntry:getMinimumNumberOfPlayers(),
    ["maxplayer"] = _mapRotationEntry:getMaximumNumberOfPlayers(),
    ["skiplines"] = _mapRotationEntry:getNumberOfSkipLines()
  }

end


return ActiveMapRotation
