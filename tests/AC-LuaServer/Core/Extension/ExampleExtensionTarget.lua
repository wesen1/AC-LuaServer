---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ExtensionTarget = require "AC-LuaServer.Core.Extension.ExtensionTarget"
local Object = require "classic"

---
-- An example ExtensionTarget that is used during the TestExtensionTarget tests.
--
-- @type ExampleExtensionTarget
--
local ExampleExtensionTarget = Object:extend()
ExampleExtensionTarget:implement(ExtensionTarget)


---
-- ExampleExtensionTarget constructor.
--
-- @tparam string _name The ExampleExtensionTarget's name (optional)
--
function ExampleExtensionTarget:new(_name)

  if (type(_name) == "string") then
    self.name = _name
  else
    self.name = "just_a_example"
  end

  self.extensions = {}
  self.isEnabled = false
end


return ExampleExtensionTarget
