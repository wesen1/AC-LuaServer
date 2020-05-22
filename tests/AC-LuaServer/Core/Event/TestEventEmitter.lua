---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the EventEmitter works as expected.
--
-- @type TestEventEmitter
--
local TestEventEmitter = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestEventEmitter.testClassPath = "tests.AC-LuaServer.Core.Event.ExampleEventEmitter"


---
-- Checks that a EventEmitter can return whether there are listeners for a specific event.
--
function TestEventEmitter:testCanReturnWhetherThereAreListenersForAEvent()

  local EventEmitter = self.testClass
  local eventEmitter = EventEmitter()

  self:assertFalse(eventEmitter:hasEventListenersFor("someevent"))
  self:assertFalse(eventEmitter:hasEventListenersFor("someotherevent"))
  self:assertFalse(eventEmitter:hasEventListenersFor("onPlayerSayText"))

  eventEmitter:on(
    "someevent",
    self:getMock("AC-LuaServer.Core.Event.EventCallback", "EventCallbackMock")
  )

  self:assertTrue(eventEmitter:hasEventListenersFor("someevent"))
  self:assertFalse(eventEmitter:hasEventListenersFor("someotherevent"))
  self:assertFalse(eventEmitter:hasEventListenersFor("onPlayerSayText"))

  eventEmitter:on(
    "onPlayerSayText",
    self:getMock("AC-LuaServer.Core.Event.EventCallback", "EventCallbackMock")
  )

  self:assertTrue(eventEmitter:hasEventListenersFor("someevent"))
  self:assertFalse(eventEmitter:hasEventListenersFor("someotherevent"))
  self:assertTrue(eventEmitter:hasEventListenersFor("onPlayerSayText"))

end

---
-- Checks that event listeners can be attached and detached as expected.
--
function TestEventEmitter:testCanAttachAndDetachEventListeners()

  local EventEmitter = self.testClass
  local eventEmitter = EventEmitter()

  self:assertFalse(eventEmitter:hasEventListenersFor("onPlayerShoot"))

  -- Add a event listener
  local eventCallbackMock = self:getMock("AC-LuaServer.Core.Event.EventCallback", "EventCallbackMock")
  eventEmitter:on("onPlayerShoot", eventCallbackMock)

  -- Add another event listener
  local otherEventCallbackMock = self:getMock("AC-LuaServer.Core.Event.EventCallback", "EventCallbackMock")

  otherEventCallbackMock.getPriority
                        :should_be_called()
                        :and_will_return(128)
                        :and_then(
                          eventCallbackMock.getPriority
                                           :should_be_called()
                                           :and_will_return(0)
                        )
                        :when(
                          function()
                            eventEmitter:on("onPlayerShoot", otherEventCallbackMock)
                          end
                        )

  -- Add a third event listener
  local thirdEventCallbackMock = self:getMock("AC-LuaServer.Core.Event.EventCallback", "EventCallbackMock")

  thirdEventCallbackMock.getPriority
                        :should_be_called()
                        :and_will_return(64)
                        :and_then(
                          eventCallbackMock.getPriority
                                           :should_be_called()
                                           :and_will_return(0)
                        )
                        :and_then(
                          otherEventCallbackMock.getPriority
                                                :should_be_called()
                                                :and_will_return(128)
                        )
                        :when(
                          function()
                            eventEmitter:on("onPlayerShoot", thirdEventCallbackMock)
                          end
                        )

  -- Now emit a event to check the order in which the event listeners are called
  eventCallbackMock.call
                   :should_be_called_with("Assault Rifle")
                   :and_then(
                     thirdEventCallbackMock.call
                                           :should_be_called_with("Assault Rifle")
                   )
                   :and_then(
                     otherEventCallbackMock.call
                                           :should_be_called_with("Assault Rifle")
                   )
                   :when(
                     function()
                       local returnValue = eventEmitter:emit("onPlayerShoot", "Assault Rifle")
                       self:assertNil(returnValue)
                     end
                   )

  -- Emit another event but prevent it from bubbling by returning a value in one of the event handlers
  eventCallbackMock.call
                   :should_be_called_with("Knife")
                   :and_will_return("stop bubbling")
                   :when(
                     function()
                       local returnValue = eventEmitter:emit("onPlayerShoot", "Knife")
                       self:assertEquals("stop bubbling", returnValue)
                     end
                   )

  -- Remove a event listener
  eventEmitter:off("onPlayerShoot", eventCallbackMock)

  -- Emit another event and check that the removed event listener is not called anymore
  thirdEventCallbackMock.call
                        :should_be_called_with("Pistol")
                        :and_then(
                          otherEventCallbackMock.call
                                                :should_be_called_with("Pistol")
                        )
                        :when(
                          function()
                            local returnValue = eventEmitter:emit("onPlayerShoot", "Pistol")
                            self:assertNil(returnValue)
                          end
                        )

  -- Remove all remaining event listeners
  eventEmitter:off("onPlayerShoot", otherEventCallbackMock)
  eventEmitter:off("onPlayerShoot", thirdEventCallbackMock)

  eventEmitter:emit("Submachine Gun")

end

---
-- Checks that a invalid event listener detach call is handled as expected.
--
function TestEventEmitter:testCanHandleInvalidEventListenerDetachment()

  local EventEmitter = self.testClass
  local EventHandlerNotAttachedException = require "AC-LuaServer.Core.Event.Exception.EventHandlerNotAttachedException"

  local eventEmitter = EventEmitter()

  self:assertFalse(eventEmitter:hasEventListenersFor("onPlayerShoot"))

  local exception = self:expectException(
    function()
      eventEmitter:off(
        "onPlayerShoot",
        self:getMock("AC-LuaServer.Core.Event.EventCallback", "EventCallbackMock")
      )
    end
  )

  self:assertTrue(exception:is(EventHandlerNotAttachedException))
  self:assertEquals("Object", exception:getEventEmitterClassName())
  self:assertEquals("onPlayerShoot", exception:getEventName())

end


return TestEventEmitter
