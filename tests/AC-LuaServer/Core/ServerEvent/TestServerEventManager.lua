---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the ServerEventManager works as expected.
--
-- @type TestServerEventManager
--
local TestServerEventManager = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestServerEventManager.testClassPath = "AC-LuaServer.Core.ServerEvent.ServerEventManager"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestServerEventManager.dependencyPaths = {
  ["LuaServerApi"] = { path = "AC-LuaServer.Core.LuaServerApi", ["type"] = "table" }
}


---
-- Checks that a server event without predefined handler function can be handled as expected.
--
function TestServerEventManager:testCanHandleEventThatHasNoPredefinedHandler()

  local ServerEventEmitter = self.testClass
  local eventEmitter = ServerEventEmitter()

  local eventCallback = self:getEventCallbackMock()

  eventEmitter:on("onPlayerSayText", eventCallback)

  eventCallback.call
               :should_be_called_with("/quit gravity")
               :and_will_return("PLUGIN_BLOCK")
               :when(function()
                 local returnValue = self.dependencyMocks.LuaServerApi.onPlayerSayText("/quit gravity")
                 self:assertEquals("PLUGIN_BLOCK", returnValue)
               end)
end

---
-- Checks that a server event with a predefined handler function can be handled as expected.
--
function TestServerEventManager:testCanHandleEventThatHasPredefinedHandler()

  local ServerEventEmitter = self.testClass
  local eventEmitter = ServerEventEmitter()

  local eventCallback = self:getEventCallbackMock()

  -- Define a event handler for the example event
  local onFlagActionHandlerMock = self.mach.mock_function("onFlagAction")
  self.dependencyMocks.LuaServerApi.onFlagAction = function(...)
    onFlagActionHandlerMock(...)
  end

  -- Add a event listener to the ServerEventEmitter
  eventCallback.getPriority
               :should_be_called()
               :and_will_return(128)
               :when(
                 function()
                   eventEmitter:on("onFlagAction", eventCallback)
                 end
               )

  onFlagActionHandlerMock:should_be_called_with("FA_SCORE")
                         :and_then(
                           eventCallback.call
                                        :should_be_called_with("FA_SCORE")
                         )
                         :when(function()
                                local returnValue = self.dependencyMocks.LuaServerApi.onFlagAction("FA_SCORE")
                                self:assertNil(returnValue)
                               end
                         )

end


---
-- Generates and returns a EventCallback mock.
--
-- @treturn table The EventCallback mock
--
function TestServerEventManager:getEventCallbackMock()
  local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
  return self.mach.mock_object(EventCallback, "EventCallbackMock")
end


return TestServerEventManager
