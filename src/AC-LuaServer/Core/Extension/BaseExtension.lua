---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventEmitter = require "AC-LuaServer.Core.Event.EventEmitter"
local ExtensionTarget = require "AC-LuaServer.Core.Extension.ExtensionTarget"
local Object = require "classic"

---
-- Extends a ExtensionTarget and will be enabled as long as the target is enabled.
--
-- @type BaseExtension
--
local BaseExtension = Object:extend()
BaseExtension:implement(EventEmitter)
BaseExtension:implement(ExtensionTarget)


---
-- The name of the target that is extended by this Extension
-- Available targets are the Server or other Extension's
--
-- @tfield string targetName
--
BaseExtension.targetName = nil

---
-- The target that is extended by this Extension
--
-- @tfield Server|BaseExtension target
--
BaseExtension.target = nil


---
-- BaseExtension constructor.
--
-- @tparam string _name The name of this Extension
-- @tparam string _targetName The name of the target that is extended by this Extension (Defaults to "Server")
--
function BaseExtension:new(_name, _targetName)

  -- EventEmitter
  self.eventCallbacks = {}

  -- ExtensionTarget
  self.name = _name
  self.extensions = {}
  self.isEnabled = false

  self.targetName = _targetName

end


-- Getters and Setters

---
-- Returns the name of this BaseExtension's target.
--
-- @treturn string The name
--
function BaseExtension:getTargetName()
  return self.targetName
end


-- Public Methods

---
-- Enables this extension.
--
-- @tparam ExtensionTarget _target The target that this extension extends
--
function BaseExtension:enable(_target)

  if (not self.isEnabled) then
    self.target = _target
    self:initialize()
    self:emit("enabled")
  end

  ExtensionTarget.enable(self)

end

---
-- Disables this extension.
--
function BaseExtension:disable()

  if (self.isEnabled) then
    self:terminate()
    self.target = nil
    self:emit("disabled")
  end

  ExtensionTarget.disable(self)

end


-- Protected Methods

---
-- Initializes this Extension.
-- Event handlers should be added here.
--
function BaseExtension:initialize()
end

---
-- Terminates this Extension.
-- Active event handlers should be removed here.
--
function BaseExtension:terminate()
end


return BaseExtension
