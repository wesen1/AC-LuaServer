---
-- @author wesen
-- @copyright 2019-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

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

  exception = MaximumRemainingTimeExceededException(919293, 2147471302, 12345)
  self:assertEquals(919293, exception:getExceedanceInMilliseconds())
  self:assertEquals(2147471302, exception:getMaximumNumberOfExtendMilliseconds())
  self:assertEquals(12345, exception:getMillisecondsUntilExtraMinuteCanBeUsed())
  self:assertEquals(
    "Could not set remaining time: Maximum remaining time would be exceeded by 919293 milliseconds",
    exception:getMessage()
  )

  exception = MaximumRemainingTimeExceededException(99330088, 2146763647, -640000)
  self:assertEquals(99330088, exception:getExceedanceInMilliseconds())
  self:assertEquals(2146763647, exception:getMaximumNumberOfExtendMilliseconds())
  self:assertEquals(-640000, exception:getMillisecondsUntilExtraMinuteCanBeUsed())
  self:assertEquals(
    "Could not set remaining time: Maximum remaining time would be exceeded by 99330088 milliseconds",
    exception:getMessage()
  )

end


return TestMaximumRemainingTimeExceededException
