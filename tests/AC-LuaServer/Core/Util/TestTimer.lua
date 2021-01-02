---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the Timer work as expected.
--
-- @type TestTimer
--
local TestTimer = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestTimer.testClassPath = "AC-LuaServer.Core.Util.Timer"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestTimer.dependencyPaths = {
  { id = "LuaServerApi", path = "AC-LuaServer.Core.LuaServerApi", ["type"] = "table" }
}


---
-- Checks that a one-time Timer can be created and cancelled as expected.
--
function TestTimer:testCanCreateAndCancelOneTimeTimer()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  local Timer = self.testClass

  LuaServerApiMock.tmr = {
    vacantid = self.mach.mock_function("tmrVacantidMock"),
    after = self.mach.mock_function("tmrAfterMock"),
    create = self.mach.mock_function("tmrCreateMock"),
    remove = self.mach.mock_function("tmrRemoveMock")
  }

  local timerCallbackMock = self.mach.mock_function("timerCallbackMock")

  local oneTimeTimer
  LuaServerApiMock.tmr.vacantid:should_be_called()
                               :and_will_return(51)
                               :and_then(
                                 LuaServerApiMock.tmr.after:should_be_called_with(51, 4380, timerCallbackMock)
                               )
                               :when(
                                 function()
                                   oneTimeTimer = Timer(Timer.TYPE_ONCE, 4380, timerCallbackMock)
                                 end
                               )

  LuaServerApiMock.tmr.remove:should_be_called_with(51)
                             :when(
                               function()
                                 oneTimeTimer:cancel()
                               end
                             )

end

---
-- Checks that a periodic Timer can be created and cancelled as expected.
--
function TestTimer:testCanCreateAndCancelPeriodicTimer()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  local Timer = self.testClass

  LuaServerApiMock.tmr = {
    vacantid = self.mach.mock_function("tmrVacantidMock"),
    after = self.mach.mock_function("tmrAfterMock"),
    create = self.mach.mock_function("tmrCreateMock"),
    remove = self.mach.mock_function("tmrRemoveMock")
  }

  local timerCallbackMock = self.mach.mock_function("timerCallbackMock")

  local periodicTimer
  LuaServerApiMock.tmr.vacantid:should_be_called()
                               :and_will_return(719)
                               :and_then(
                                 LuaServerApiMock.tmr.create:should_be_called_with(719, 314102, timerCallbackMock)
                               )
                               :when(
                                 function()
                                   periodicTimer = Timer(Timer.TYPE_PERIODIC, 314102, timerCallbackMock)
                                 end
                               )

  LuaServerApiMock.tmr.remove:should_be_called_with(719)
                             :when(
                               function()
                                 periodicTimer:cancel()
                               end
                             )

end


return TestTimer
