---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

--
-- Fetch the path that was used with the require function to get this file
--
local requirePath = ...

local Object = require "classic"
local path = require "pl.path"

---
-- Provides static methods to fetch absolute paths to specific directories.
--
-- @type Path
--
local Path = Object:extend()


---
-- The absolute path to the "src" directory of AC-LuaServer.
--
-- @tfield string sourceDirectoryPath
--
Path.sourceDirectoryPath = nil


-- Public Methods

---
-- Returns the path to the "src" directory of AC-LuaServer.
--
-- @treturn string The path to the "src" directory
--
function Path.getSourceDirectoryPath()
  if (not Path.searchDirectoryPath) then
    Path.searchDirectoryPath = Path.searchSourceDirectoryPath()
  end

  return Path.searchDirectoryPath
end


-- Private Methods

---
-- Searches for and returns the path to the "src" directory of AC-LuaServer.
--
-- @treturn string The path to the "src" directory
--
function Path.searchSourceDirectoryPath()
  local pathClassFilePath = package.searchpath(requirePath, package.path)
  local pathClassDirectoryPath = path.dirname(pathClassFilePath)

  return path.abspath(pathClassDirectoryPath .. "/../..")
end


return Path
