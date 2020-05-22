---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the GlobalCallbackFunctionNotFoundException works as expected.
--
-- @type TestGlobalCallbackFunctionNotFoundException
--
local TestGlobalCallbackFunctionNotFoundException = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestGlobalCallbackFunctionNotFoundException.testClassPath = "AC-LuaServer.Core.Event.Exception.GlobalCallbackFunctionNotFoundException"


---
-- Checks that the GlobalCallbackFunctionNotFoundException can be instantiated as expected.
--
function TestGlobalCallbackFunctionNotFoundException:testCanBeCreated()

  local GlobalCallbackFunctionNotFoundException = self.testClass
  local exception = GlobalCallbackFunctionNotFoundException("globalOnPlayerShootHandler")

  self:assertEquals("globalOnPlayerShootHandler", exception:getFunctionName())
  self:assertEquals(
    "Could not set up event callback: Global function \"globalOnPlayerShootHandler\" not found",
    exception:getMessage()
  )

end


return TestGlobalCallbackFunctionNotFoundException
