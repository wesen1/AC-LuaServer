---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
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


-- Private Methods

---
-- Returns a Extension's target by a target name.
--
-- @tparam string _targetName The target name
--
-- @treturn ExtensionTarget|nil The target or nil if no target was found for the target name
--
function ExtensionManager:getExtensionTargetByName(_targetName)

  if (_targetName == "server") then
    return self.parentServer
  else

    for _, extension in ipairs(self.managedExtensions) do
      if (extension:getName() == _targetName) then
        return extension
      end
    end

  end

end


return ExtensionManager
