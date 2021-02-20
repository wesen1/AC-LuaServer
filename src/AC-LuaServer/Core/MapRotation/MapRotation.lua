---
-- @author wesen
-- @copyright 2018-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ActiveMapRotation = require "AC-LuaServer.Core.MapRotation.ActiveMapRotation"
local MapRotationFile = require "AC-LuaServer.Core.MapRotation.MapRotationFile"
local Object = require "classic"

---
-- Represents the active map rotation and its corresponding config file.
--
-- @type MapRotation
--
local MapRotation = Object:extend()


---
-- The active map rotation
--
-- @tfield ActiveMapRotation activeMapRotation
--
MapRotation.activeMapRotation = nil

---
-- The map rotation config file from which the current active map rotation was loaded
--
-- @tfield MapRotationFile mapRotationFile
--
MapRotation.mapRotationFile = nil


---
-- MapRotation constructor.
--
-- @tparam string _mapRotationConfigFilePath The path to the map rotation config file to use (Defaults to "config/maprot.cfg")
--
function MapRotation:new(_mapRotationConfigFilePath)

  self.activeMapRotation = ActiveMapRotation()

  local mapRotationConfigFilePath
  if (type(_mapRotationConfigFilePath) == "string") then
    mapRotationConfigFilePath = _mapRotationConfigFilePath
  else
    mapRotationConfigFilePath = "config/maprot.cfg"
  end

  self.mapRotationFile = MapRotationFile(mapRotationConfigFilePath)

end


-- Public Methods

---
-- Changes the map rotation config file.
--
-- @tparam string _mapRotationConfigFilePath The path to the map reotation config file to use
--
function MapRotation:changeMapRotationConfigFile(_mapRotationConfigFilePath)
  self.mapRotationFile = MapRotationFile(_mapRotationConfigFilePath)
  self.activeMapRotation:loadFromFile(_mapRotationConfigFilePath)
end

---
-- Returns the next map rotation entry.
--
-- @treturn MapRotationEntry The next map rotation entry
--
function MapRotation:getNextEntry()
  return self.activeMapRotation:getNextEntry()
end

---
-- Appends a map rotation entry to the active map rotation and to its config file.
--
-- @tparam MapRotationEntry _mapRotationEntry The entry to append
--
function MapRotation:appendEntry(_mapRotationEntry)
  self.activeMapRotation:appendEntry(_mapRotationEntry)
  self.mapRotationFile:appendEntry(_mapRotationEntry)
end

---
-- Replaces all entries in the map rotation by a given list of MapRotationEntry's.
--
-- @tparam MapRotationEntry[] _mapRotationEntries The MapRotationEntry's to set
--
function MapRotation:setAllEntries(_mapRotationEntries)
  self:clear()

  self.activeMapRotation:setEntries(_mapRotationEntries)
  self.mapRotationFile:setEntries(_mapRotationEntries)
end

---
-- Removes all map rotation entries for a specific map from the active map rotation and from its config file.
--
-- @tparam string _mapName The map name to search for
--
function MapRotation:removeEntriesForMap(_mapName)
  self.activeMapRotation:removeEntriesForMap(_mapName)
  self.mapRotationFile:removeEntriesForMap(_mapName)
end


-- Private Methods

---
-- Clears the active map rotation and its config file.
--
function MapRotation:clear()
  self.activeMapRotation:clear()
  self.mapRotationFile:remove()
end


return MapRotation
