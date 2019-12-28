---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
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

  -- Open the map rotation cfg file in "append" mode
  local cfgFile = io.open(self.filePath , "a");

  -- Append a new line for the new map rotation entry
  cfgFile:write(string.format(
    "%s:%i:%i:%i:%i:%i:%i\n",
    _mapRotationEntry:getMapName(),
    _mapRotationEntry:getGameModeId(),
    _mapRotationEntry:getTimeInMinutes(),
    _mapRotationEntry:getAreGameChangeVotesAllowed() and 1 or 0,
    _mapRotationEntry:getMinimumNumberOfPlayers(),
    _mapRotationEntry:getMaximumNumberOfPlayers(),
    _mapRotationEntry:getNumberOfSkipLines()
  ))

  -- Close the file
  cfgFile:close()

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


return MapRotationFile
