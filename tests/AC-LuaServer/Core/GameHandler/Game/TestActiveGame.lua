---
-- @author wesen
-- @copyright 2019-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the ActiveGame works as expected.
--
-- @type TestActiveGame
--
local TestActiveGame = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestActiveGame.testClassPath = "AC-LuaServer.Core.GameHandler.Game.ActiveGame"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestActiveGame.dependencyPaths = {
  { id = "LuaServerApi", path = "AC-LuaServer.Core.LuaServerApi", ["type"] = "table" }
}

---
-- Checks that a ActiveGame can be created as expected.
--
function TestActiveGame:testCanBeCreated()

  local ActiveGame = self.testClass
  local activeGame = ActiveGame("SE-GEMA-HACIENDA", 0)

  self:assertEquals("SE-GEMA-HACIENDA", activeGame:getMapName())
  self:assertEquals(0, activeGame:getGameModeId())

  -- Fetch the remaining time in milliseconds
  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.gettimeleftmillis = self.mach.mock_function("gettimeleftmillis")

  local remainingTimeInMilliseconds
  LuaServerApiMock.gettimeleftmillis
                  :should_be_called()
                  :and_will_return(503000) -- 08:23,00 minutes
                  :when(
                    function()
                      remainingTimeInMilliseconds = activeGame:getRemainingTimeInMilliseconds()
                    end
                  )

  self:assertEquals(503000, remainingTimeInMilliseconds)

end

---
-- Checks that the remaining time in milliseconds can be set when the new remaining time is valid.
--
function TestActiveGame:testCanSetRemainingTimeInMilliseconds()

  local ActiveGame = self.testClass
  local activeGame = ActiveGame("gema_warm_up", 5)

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.getgamemillis = self.mach.mock_function("getgamemillis")
  LuaServerApiMock.settimeleftmillis = self.mach.mock_function("settimeleftmillis")

  -- gamemillis >= 60000
  LuaServerApiMock.getgamemillis
                  :should_be_called()
                  :and_will_return(503000) -- 08:23,00 minutes
                  :and_then(
                    LuaServerApiMock.settimeleftmillis
                                    :should_be_called_with(1200000) -- 20 minutes
                  )
                  :when(
                    function()
                      activeGame:setRemainingTimeInMilliseconds(1200000) -- 20 minutes
                    end
                  )

  -- gamemillis < 60000
  LuaServerApiMock.getgamemillis
                  :should_be_called()
                  :and_will_return(20000) -- 00:20,00 minutes
                  :and_then(
                    LuaServerApiMock.settimeleftmillis
                                    :should_be_called_with(36000000) -- 600 minutes
                  )
                  :when(
                    function()
                      activeGame:setRemainingTimeInMilliseconds(36000000) -- 600 minutes
                    end
                  )

end

---
-- Checks that exceptions are thrown when an invalid remaining time is attempted to be set.
--
function TestActiveGame:testCanDetectInvalidRemainingTimeInMilliseconds()

  local ActiveGame = self.testClass
  local MaximumRemainingTimeExceededException = require "AC-LuaServer.Core.GameHandler.Game.Exception.MaximumRemainingTimeExceededException"

  local activeGame = ActiveGame("gema_warm_up", 5)
  local exception

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.getgamemillis = self.mach.mock_function("getgamemillis")
  LuaServerApiMock.settimeleftmillis = self.mach.mock_function("settimeleftmillis")


  -- gamemillis >= 60000

  -- Exactly on limit
  LuaServerApiMock.getgamemillis
                  :should_be_called()
                  :and_will_return(503000) -- 08:23,00 minutes
                  :and_then(
                    LuaServerApiMock.settimeleftmillis
                                    :should_be_called_with(2146980647)
                  )
                  :when(
                    function()
                      activeGame:setRemainingTimeInMilliseconds(2146980647)
                    end
                  )

  -- Slightly above limit
  LuaServerApiMock.getgamemillis
                  :should_be_called()
                  :and_will_return(503000) -- 08:23,00 minutes
                  :when(
                    function()
                      exception = self:expectException(
                        function()
                          activeGame:setRemainingTimeInMilliseconds(2146980648)
                        end
                      )
                    end
                  )
  self:assertTrue(exception:is(MaximumRemainingTimeExceededException))
  self:assertEquals(1, exception:getExceedanceInMilliseconds())
  self:assertEquals(2146980647, exception:getMaximumNumberOfExtendMilliseconds())
  self:assertEquals(-443000, exception:getMillisecondsUntilExtraMinuteCanBeUsed())

  -- Clearly above limit
  LuaServerApiMock.getgamemillis
                  :should_be_called()
                  :and_will_return(503000) -- 08:23,00 minutes
                  :when(
                    function()
                      exception = self:expectException(
                        function()
                          activeGame:setRemainingTimeInMilliseconds(4000000001)
                        end
                      )
                    end
                  )
  self:assertTrue(exception:is(MaximumRemainingTimeExceededException))
  self:assertEquals(1853019354, exception:getExceedanceInMilliseconds())
  self:assertEquals(2146980647, exception:getMaximumNumberOfExtendMilliseconds())
  self:assertEquals(-443000, exception:getMillisecondsUntilExtraMinuteCanBeUsed())


  -- gamemillis < 60000

  -- Exactly on limit
  LuaServerApiMock.getgamemillis
                  :should_be_called()
                  :and_will_return(20000) -- 00:20,00 minutes
                  :and_then(
                    LuaServerApiMock.settimeleftmillis
                                    :should_be_called_with(2147403647)
                  )
                  :when(
                    function()
                      activeGame:setRemainingTimeInMilliseconds(2147403647)
                    end
                  )

  -- Slightly above limit
  LuaServerApiMock.getgamemillis
                  :should_be_called()
                  :and_will_return(20000) -- 00:20,00 minutes
                  :when(
                    function()
                      exception = self:expectException(
                        function()
                          activeGame:setRemainingTimeInMilliseconds(2147403649)
                        end
                      )
                    end
                  )
  self:assertTrue(exception:is(MaximumRemainingTimeExceededException))
  self:assertEquals(2, exception:getExceedanceInMilliseconds())
  self:assertEquals(2147403647, exception:getMaximumNumberOfExtendMilliseconds())
  self:assertEquals(40000, exception:getMillisecondsUntilExtraMinuteCanBeUsed())

  -- Clearly above limit
  LuaServerApiMock.getgamemillis
                  :should_be_called()
                  :and_will_return(20000) -- 00:20,00 minutes
                  :when(
                    function()
                      exception = self:expectException(
                        function()
                          activeGame:setRemainingTimeInMilliseconds(9998887770)
                        end
                      )
                    end
                  )
  self:assertTrue(exception:is(MaximumRemainingTimeExceededException))
  self:assertEquals(7851484123, exception:getExceedanceInMilliseconds())
  self:assertEquals(2147403647, exception:getMaximumNumberOfExtendMilliseconds())
  self:assertEquals(40000, exception:getMillisecondsUntilExtraMinuteCanBeUsed())

end


return TestActiveGame
