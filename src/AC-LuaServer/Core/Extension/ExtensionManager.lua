---
-- @author wesen
-- @copyright 2019-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"
local ExtensionTargetNotFoundException = require "AC-LuaServer.Core.Extension.Exception.ExtensionTargetNotFoundException"

---
-- Manages the configured Extension's for a Server.
--
-- @type ExtensionManager
--
local ExtensionManager = Object:extend()


---
-- The parent Server of the ExtensionManager
--
-- @tfield Server parentServer
--
ExtensionManager.parentServer = nil

---
-- The list of extensions that were added to the Server
--
-- @tfield BaseExtension[] managedExtensions
--
ExtensionManager.managedExtensions = nil


---
-- ExtensionManager constructor.
--
-- @tparam Server _parentServer The parent Server
--
function ExtensionManager:new(_parentServer)
  self.parentServer = _parentServer
  self.managedExtensions = {}
end


-- Public Methods

---
-- Adds an Extension to this ExtensionManager.
--
-- @tparam BaseExtension _extension The extension to add
--
function ExtensionManager:addExtension(_extension)

  -- Check if the extension target exists
  local extensionTarget = self:getExtensionTargetByName(_extension:getTargetName())
  if (extensionTarget) then
    table.insert(self.managedExtensions, _extension)
    extensionTarget:addExtension(_extension)

  else
    error(ExtensionTargetNotFoundException(_extension:getName(), _extension:getTargetName()))
  end

end

---
-- Returns a Extension whose name matches a given extension name.
-- Will return nil if there is no Extension with the given name.
--
-- @tparam string _extensionName The extension name to search for
--
-- @treturn BaseExtension|nil The Extension that matches the given extension name
--
function ExtensionManager:getExtensionByName(_extensionName)

  for _, extension in ipairs(self.managedExtensions) do
    if (extension:getName() == _extensionName) then
      return extension
    end
  end

end


-- Private Methods

---
-- Returns a Extension's target by a target name.
--
-- @tparam string _targetName The target name
--
-- @treturn ExtensionTarget|nil The target or nil if no target was found for the target name
--
function ExtensionManager:getExtensionTargetByName(_targetName)

  if (_targetName == "Server") then
    return self.parentServer
  else
    return self:getExtensionByName(_targetName)
  end

end


return ExtensionManager
