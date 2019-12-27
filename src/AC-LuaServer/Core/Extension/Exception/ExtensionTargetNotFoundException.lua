---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require "AC-LuaServer.Core.Util.Exception.Exception"

---
-- Exception for the case that a Extension's target could not be found.
--
-- @type ExtensionTargetNotFoundException
--
local ExtensionTargetNotFoundException = Exception:extend()


---
-- The name of the Extension that caused this Exception
--
-- @tfield string extensionName
--
ExtensionTargetNotFoundException.extensionName = nil

---
-- The name of the target of the Extension that caused this Exception
--
-- @tfield string extensionTargetName
--
ExtensionTargetNotFoundException.extensionTargetName = nil


---
-- ExtensionTargetNotFoundException constructor.
--
-- @tparam string _extensionName The name of the Extension that caused this Exception
-- @tparam string _extensionTargetName The name of the target of the Extension that caused this Exception
--
function ExtensionTargetNotFoundException:new(_extensionName, _extensionTargetName)
  self.extensionName = _extensionName
  self.extensionTargetName = _extensionTargetName
end


-- Getters and Setters

---
-- Returns the name of the Extension that caused this Exception.
--
-- @treturn string The name of the Extension
--
function ExtensionTargetNotFoundException:getExtensionName()
  return self.extensionName
end

---
-- Returns the name of the target of the Extension that caused this Exception.
--
-- @treturn string The name of the target of the Extension
--
function ExtensionTargetNotFoundException:getExtensionTargetName()
  return self.extensionTargetName
end


-- Public Methods

---
-- Returns this Exception's message as a string.
--
-- @treturn string The Exception message as a string
--
function ExtensionTargetNotFoundException:getMessage()
  return string.format(
    "Could not add extension \"%s\": Extension target \"%s\" not found",
    self.extensionName,
    self.extensionTargetName
  )
end


return ExtensionTargetNotFoundException
