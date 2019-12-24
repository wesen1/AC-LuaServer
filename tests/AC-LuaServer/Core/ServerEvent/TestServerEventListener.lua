---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the ServerEventListener works as expected.
--
-- @type TestServerEventListener
--
local TestServerEventListener = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestServerEventListener.testClassPath = "tests.AC-LuaServer.Core.ServerEvent.ExampleServerEventListener"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestServerEventListener.dependencyPaths = {
  ["EventCallback"] = { path = "AC-LuaServer.Core.Event.EventCallback" },
  ["Server"] = { path = "AC-LuaServer.Core.Server" }
}


---
-- Checks that a ServerEventListener can start and stop listening for events.
--
function TestServerEventListener:testCanStartAndStopListening()

  local ExampleServerEventListener = self.testClass
  local listener = ExampleServerEventListener()

  local eventCallbackMockA = self:getEventCallbackMock()
  local eventCallbackMockB = self:getEventCallbackMock()

  local EventCallbackMock = self.dependencyMocks.EventCallback

  local serverMock = self:getMock("AC-LuaServer.Core.Server", "ServerMock")
  local serverEventManagerMock = self:getMock(
    "AC-LuaServer.Core.ServerEvent.ServerEventManager", "ServerEventManagerMock"
  )

  -- Unregistering the event handlers before registering them once should do nothing
  listener:stopListening()

  -- Initialize event callbacks and register the event handlers
  EventCallbackMock.__call
                   :should_be_called_with(
                     self.mach.match({ object = listener, methodName = "onPlayerShootHandler"}), nil
                   )
                   :and_will_return(eventCallbackMockA)
                   :and_also(
                     EventCallbackMock.__call
                                      :should_be_called_with(
                                        self.mach.match({
                                          object = listener, methodName = "onPlayerSayTextHandler"
                                        }),
                                        7
                                      )
                                      :and_will_return(eventCallbackMockB)
                   )
                   :and_then(
                     self.dependencyMocks.Server.getInstance
                                                :should_be_called()
                                                :and_will_return(serverMock)
                   )
                   :and_then(
                     serverMock.getEventManager
                               :should_be_called()
                               :and_will_return(serverEventManagerMock)
                   )
                   :and_then(
                     serverEventManagerMock.on
                                           :should_be_called_with("onPlayerShoot", eventCallbackMockA)
                   )
                   :and_also(
                     serverEventManagerMock.on
                                           :should_be_called_with("onPlayerSayText", eventCallbackMockB)
                   )
                   :when(
                     function()
                       listener:startListening()
                     end
                   )

  -- Unregister the event handlers
  self.dependencyMocks.Server.getInstance
                             :should_be_called()
                             :and_will_return(serverMock)
                             :and_then(
                               serverMock.getEventManager
                                         :should_be_called()
                                         :and_will_return(serverEventManagerMock)
                             )
                             :and_then(
                               serverEventManagerMock.off
                                                     :should_be_called_with(
                                                       "onPlayerShoot", eventCallbackMockA
                                                     )
                             )
                             :and_also(
                               serverEventManagerMock.off
                                                     :should_be_called_with(
                                                       "onPlayerSayText", eventCallbackMockB
                                                     )
                             )
                             :when(
                               function()
                                 listener:stopListening()
                               end
                             )

  -- Reigster the event handlers again to check that they aren't reinitialized
  self.dependencyMocks.Server.getInstance
                             :should_be_called()
                             :and_will_return(serverMock)
                             :and_then(
                               serverMock.getEventManager
                                         :should_be_called()
                                         :and_will_return(serverEventManagerMock)
                             )
                             :and_then(
                               serverEventManagerMock.on
                                                     :should_be_called_with(
                                                       "onPlayerShoot", eventCallbackMockA
                                                     )
                             )
                             :and_also(
                               serverEventManagerMock.on
                                                     :should_be_called_with(
                                                       "onPlayerSayText", eventCallbackMockB
                                                     )
                             )
                             :when(
                               function()
                                 listener:startListening()
                               end
                             )

end


---
-- Generates and returns a EventCallback mock.
--
-- @treturn table The EventCallback mock
--
function TestServerEventListener:getEventCallbackMock()
  return self:getMock("AC-LuaServer.Core.Event.EventCallback", "EventCallbackMock")
end


return TestServerEventListener
