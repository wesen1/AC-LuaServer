---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the EventHandlerNotAttachedException works as expected.
--
-- @type TestEventHandlerNotAttachedException
--
local TestEventHandlerNotAttachedException = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestEventHandlerNotAttachedException.testClassPath = "AC-LuaServer.Core.Event.Exception.EventHandlerNotAttachedException"


---
-- Checks that the EventHandlerNotAttachedException can be instantiated as expected.
--
function TestEventHandlerNotAttachedException:testCanBeCreated()

  local EventHandlerNotAttachedException = self.testClass
  local exception = EventHandlerNotAttachedException("ExampleEventEmitter", "onDisconnectAfter")

  self:assertEquals("ExampleEventEmitter", exception:getEventEmitterClassName())
  self:assertEquals("onDisconnectAfter", exception:getEventName())
  self:assertEquals(
    "Could not detach event handler from ExampleEventEmitter: Event handler is not attached to event \"onDisconnectAfter\"",
    exception:getMessage()
  )

end


return TestEventHandlerNotAttachedException
