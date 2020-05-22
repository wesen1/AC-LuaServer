---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the ExtensionTargetNotFoundException works as expected.
--
-- @type TestExtensionTargetNotFoundException
--
local TestExtensionTargetNotFoundException = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestExtensionTargetNotFoundException.testClassPath = "AC-LuaServer.Core.Extension.Exception.ExtensionTargetNotFoundException"


---
-- Checks that the ExtensionTargetNotFoundException can be instantiated as expected.
--
function TestExtensionTargetNotFoundException:testCanBeCreated()

  local ExtensionTargetNotFoundException = self.testClass
  local exception = ExtensionTargetNotFoundException("GemaMode", "GameModeManager")

  self:assertEquals("GemaMode", exception:getExtensionName())
  self:assertEquals("GameModeManager", exception:getExtensionTargetName())
  self:assertEquals(
    "Could not add extension \"GemaMode\": Extension target \"GameModeManager\" not found",
    exception:getMessage()
  )

end


return TestExtensionTargetNotFoundException
