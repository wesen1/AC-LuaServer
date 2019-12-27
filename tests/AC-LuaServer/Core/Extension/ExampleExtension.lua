---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"

---
-- An example Extension that is used during the TestBaseExtension tests.
--
-- @type ExampleExtension
--
local ExampleExtension = BaseExtension:extend()


---
-- ExampleExtension constructor.
--
-- @tparam string _targetName The ExampleExtension's target name (optional)
--
function ExampleExtension:new(_targetName)

  local targetName
  if (type(_targetName) == "string") then
    targetName = _targetName
  else
    targetName = "just_a_example_target"
  end

  self.super.new(self, "example_extension", targetName)

end


-- Getters and Setters

---
-- Returns the ExampleExtension's current target.
--
-- @treturn ExtensionTarget The ExampleExtension's current target
--
function ExampleExtension:getTarget()
  return self.target
end


-- Protected Methods

---
-- Initializes this Extension.
--
function ExampleExtension:initialize()
  self:emit("initialized")
end

---
-- Terminates this Extension.
--
function ExampleExtension:terminate()
  self:emit("terminated")
end


return ExampleExtension
