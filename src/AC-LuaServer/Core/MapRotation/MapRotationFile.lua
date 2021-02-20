---
-- @author wesen
-- @copyright 2018-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Represents a map rotation config file.
--
-- @type MapRotationFile
--
local MapRotationFile = Object:extend()


---
-- The path to the map rotation config file
-- The path must be relative from the server root directory, e.g. "config/maprot.cfg"
--
-- @tfield string filePath
--
MapRotationFile.filePath = nil


---
-- MapRotFile constructor.
--
-- @tparam string _filePath The path to the map rotation config file
--
function MapRotationFile:new(_filePath)
  self.filePath = _filePath
end


-- Getters and Setters

---
-- Returns the map rotation config file path.
--
-- @treturn string The map rotation config file path
--
function MapRotationFile:getFilePath()
  return self.filePath
end


-- Public Methods

---
-- Appends a new entry to the map rotation config file.
--
-- @tparam MapRotationEntry _mapRotationEntry The entry to append
--
function MapRotationFile:appendEntry(_mapRotationEntry)
  self:writeConfigLinesToConfigFile({
    self:convertMapRotationEntryToConfigLine(_mapRotationEntry)
  })
end

---
-- Replaces all entries in the map rotation config file by a given list of MapRotationEntry's.
--
-- @tparam MapRotationEntry[] _mapRotationEntries The MapRotationEntry's to set
--
function MapRotationFile:setEntries(_mapRotationEntries)
  local configLines = {}
  for _, mapRotationEntry in ipairs(_mapRotationEntries) do
    table.insert(configLines, self:convertMapRotationEntryToConfigLine(mapRotationEntry))
  end

  self:writeConfigLinesToConfigFile(configLines)
end

---
-- Removes all map rotation entries for a specific map from the map rotation config file.
--
-- @tparam string _mapName The map name to search for
--
function MapRotationFile:removeEntriesForMap(_mapName)

  -- Open a temporary file in mode "write"
  local tmpFile = io.open(self.filePath .. ".tmp", "w")

  -- Add all map rotation entries to the file that are not for the search map name
  for line in io.lines(self.filePath) do

    --
    -- Escaping all non alphanumeric characters with a leading "%" to prevent characters in map names
    -- from breaking the pattern (e.g. "-")
    --
    if (not line:match("^" .. _mapName:gsub("([^%w])", "%%%1") .. ":")) then
      tmpFile:write(line .. "\n")
    end
  end

  -- Close the temporary file
  tmpFile:close()

  -- Replace the map rotation config file by the temporary file
  os.rename(self.filePath .. ".tmp", self.filePath)

end

---
-- Removes the map rotation config file.
--
function MapRotationFile:remove()
  os.remove(self.filePath)
end


-- Private Methods

---
-- Writes a given list of map rotation config lines to the map rotation config file.
--
-- @tparam string[] The list of map rotation config lines to write
--
function MapRotationFile:writeConfigLinesToConfigFile(_configLines)

  -- Open the map rotation cfg file in "append" mode
  local cfgFile = io.open(self.filePath , "a");

  -- Append a new line for the new map rotation entry
  cfgFile:write(table.concat(_configLines, "\n") .. "\n")

  -- Close the file
  cfgFile:close()

end

---
-- Converts a given MapRotationEntry to a map rotation entry config line that can be inserted into the
-- map rotation config file.
--
-- @tparam MapRotationEntry _mapRotationEntry The MapRotationEntry to convert
--
-- @treturn string The generated map rotation entry config line
--
function MapRotationFile:convertMapRotationEntryToConfigLine(_mapRotationEntry)

  return string.format(
    "%s:%i:%i:%i:%i:%i:%i",
    _mapRotationEntry:getMapName(),
    _mapRotationEntry:getGameModeId(),
    _mapRotationEntry:getTimeInMinutes(),
    _mapRotationEntry:getAreGameChangeVotesAllowed() and 1 or 0,
    _mapRotationEntry:getMinimumNumberOfPlayers(),
    _mapRotationEntry:getMaximumNumberOfPlayers(),
    _mapRotationEntry:getNumberOfSkipLines()
  )

end


return MapRotationFile
