---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Trait that must be implemented by all extension targets.
--
-- @type ExtensionTarget
--
local ExtensionTarget = Object:extend()


---
-- The name of this ExtensionTarget
-- This is needed so that extensions can reference this ExtensionTarget
--
-- @tfield string name
--
ExtensionTarget.name = nil

---
-- The list of extensions that target this ExtensionTarget
--
-- @tfield BaseExtension[] extensions
--
ExtensionTarget.extensions = nil

---
-- Stores whether this ExtensionTarget is enabled at the moment
--
-- @tfield bool isEnabled
--
ExtensionTarget.isEnabled = false


-- Getters and Setters

---
-- Returns this ExtensionTarget's name.
--
-- @treturn string The name
--
function ExtensionTarget:getName()
  return self.name
end


-- Public Methods

---
-- Adds a extension to this ExtensionTarget.
--
-- @tparam BaseExtension _extension The extension to add
--
function ExtensionTarget:addExtension(_extension)
  table.insert(self.extensions, _extension)

  if (self.isEnabled) then
    _extension:enable(self)
  end
end

---
-- Enables this ExtensionTarget.
--
function ExtensionTarget:enable()

  if (not self.isEnabled) then
    for _, extension in ipairs(self.extensions) do
      extension:enable(self)
    end

    self.isEnabled = true
  end

end

---
-- Disables this ExtensionTarget.
--
function ExtensionTarget:disable()

  if (self.isEnabled) then
    for _, extension in ipairs(self.extensions) do
      extension:disable()
    end

    self.isEnabled = false
  end

end


return ExtensionTarget
