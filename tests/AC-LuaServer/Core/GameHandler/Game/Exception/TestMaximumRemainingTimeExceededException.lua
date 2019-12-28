---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the MaximumRemainingTimeExceededException works as expected.
--
-- @type TestMaximumRemainingTimeExceededException
--
local TestMaximumRemainingTimeExceededException = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestMaximumRemainingTimeExceededException.testClassPath = "AC-LuaServer.Core.GameHandler.Game.Exception.MaximumRemainingTimeExceededException"


---
-- Checks that the MaximumRemainingTimeExceededException can be instantiated as expected.
--
function TestMaximumRemainingTimeExceededException:testCanBeCreated()

  local MaximumRemainingTimeExceededException = self.testClass
  local exception

  exception = MaximumRemainingTimeExceededException(1234, true)

  self:assertEquals(1234, exception:getExceedanceInMilliseconds())
  self:assertTrue(exception:getIsExtraMinuteAvailable())
  self:assertEquals(
    "Could not set remaining time: Maximum remaining time would be exceeded by 1234 milliseconds",
    exception:getMessage()
  )


  exception = MaximumRemainingTimeExceededException(99330088, false)

  self:assertEquals(99330088, exception:getExceedanceInMilliseconds())
  self:assertFalse(exception:getIsExtraMinuteAvailable())
  self:assertEquals(
    "Could not set remaining time: Maximum remaining time would be exceeded by 99330088 milliseconds",
    exception:getMessage()
  )

end


return TestMaximumRemainingTimeExceededException
