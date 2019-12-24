---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the InvalidCallbackFunctionException works as expected.
--
-- @type TestInvalidCallbackFunctionException
--
local TestInvalidCallbackFunctionException = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestInvalidCallbackFunctionException.testClassPath = "AC-LuaServer.Core.Event.Exception.InvalidCallbackFunctionException"


---
-- Checks that the InvalidCallbackFunctionException can be instantiated as expected.
--
function TestInvalidCallbackFunctionException:testCanBeCreated()

  local InvalidCallbackFunctionException = self.testClass
  local exception = InvalidCallbackFunctionException()

  self:assertEquals(
    "Could not set up event callback: Invalid callback function config",
    exception:getMessage()
  )

end


return TestInvalidCallbackFunctionException
