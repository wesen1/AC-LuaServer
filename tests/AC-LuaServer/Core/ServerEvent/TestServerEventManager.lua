---
-- @author wesen
-- @copyright 2019-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

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
  { id = "LuaServerApi", path = "AC-LuaServer.Core.LuaServerApi", ["type"] = "table" },
  { id = "Server", path = "AC-LuaServer.Core.Server" }
}


---
-- Checks that a server event without predefined handler function can be handled as expected.
--
function TestServerEventManager:testCanHandleEventThatHasNoPredefinedHandler()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  local ServerEventEmitter = self.testClass
  local eventEmitter = ServerEventEmitter()

  local eventCallback = self:getEventCallbackMock()

  self:assertNil(LuaServerApiMock.onPlayerSayText)
  eventEmitter:on("onPlayerSayText", eventCallback)
  self:assertNotNil(LuaServerApiMock.onPlayerSayText)

  eventCallback.call
               :should_be_called_with("/quit gravity")
               :and_will_return("PLUGIN_BLOCK")
               :when(function()
                 local returnValue = LuaServerApiMock.onPlayerSayText("/quit gravity")
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
-- Checks that exceptions of the event consumers are handled as expected.
--
function TestServerEventManager:testCanHandleExceptionsOfEventConsumers()

  local Exception = require "AC-LuaServer.Core.Util.Exception.Exception"
  local TemplateException = require "AC-LuaServer.Core.Util.Exception.TemplateException"
  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  local ServerEventEmitter = self.testClass
  local eventEmitter = ServerEventEmitter()

  local eventCallback = self:getEventCallbackMock()

  eventEmitter:on("onPlayerSendMap", eventCallback)

  -- TemplateException
  local templateException = self:getMock(TemplateException, "TemplateExceptionMock")
  templateException.is = self.mach.mock_method("is")
  local serverMock = self:getMock("AC-LuaServer.Core.Server", "ServerMock")
  local outputMock = self:getMock("AC-LuaServer.Core.Output.Output", "OutputMock")
  eventCallback.call
               :should_be_called_with(7, "gema_la_momie")
               :and_will_raise_error(templateException)
               :and_then(
                 templateException.is
                                  :should_be_called_with(TemplateException)
                                  :and_will_return(true)
               )
               :and_then(
                 self.dependencyMocks.Server.getInstance
                                            :should_be_called()
                                            :and_will_return(serverMock)
                                            :and_then(
                                              serverMock.getOutput
                                                        :should_be_called()
                                                        :and_will_return(outputMock)
                                            )
                                            :and_then(
                                              outputMock.printException
                                                        :should_be_called_with(templateException)
                                            )
               )
               :when(
                 function()
                   local returnValue = LuaServerApiMock.onPlayerSendMap(7, "gema_la_momie")
                   self:assertNil(returnValue)
                 end
               )

  -- Exception
  local normalException = self:getMock(Exception, "ExceptionMock")
  normalException.is = self.mach.mock_method("is")
  eventCallback.call
               :should_be_called_with(3, "Gibbed-Gema10")
               :and_will_raise_error(normalException)
               :and_then(
                 normalException.is
                                :should_be_called_with(TemplateException)
                                :and_will_return(false)
               )
               :and_then(
                 normalException.is
                                :should_be_called_with(Exception)
                                :and_will_return(true)
               )
               :and_then(
                 normalException.getMessage
                                :should_be_called()
                                :and_will_return("just a normal Exception but it is readable in the logs.")
               )
               :when(
                 function()
                   local success, result = pcall(LuaServerApiMock.onPlayerSendMap, 3, "Gibbed-Gema10")
                   self:assertFalse(success)
                   self:assertStrContains(result, "just a normal Exception but it is readable in the logs.")
                 end
               )

  -- string
  local errorMessage = "Something went wrong, don't tell the players!"
  eventCallback.call
               :should_be_called_with(13, "RoofTopGema")
               :and_will_raise_error(errorMessage)
               :when(
                 function()
                   local success, result = pcall(LuaServerApiMock.onPlayerSendMap, 13, "RoofTopGema")
                   self:assertFalse(success)
                   self:assertStrContains(result, "Something went wrong, don't tell the players!")
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
