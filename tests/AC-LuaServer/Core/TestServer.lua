---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the Server works as expected.
--
-- @type TestServer
--
local TestServer = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestServer.testClassPath = "AC-LuaServer.Core.Server"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestServer.dependencyPaths = {
  ["ExtensionManager"] = { path = "AC-LuaServer.Core.Extension.ExtensionManager" },
  ["LuaServerApi"] = { path = "AC-LuaServer.Core.LuaServerApi", ["type"] = "table" },
  ["EventCallback"] = { path = "AC-LuaServer.Core.Event.EventCallback" },
  ["PlayerList"] = { path = "AC-LuaServer.Core.PlayerList.PlayerList" },
  ["ServerEventManager"] = { path = "AC-LuaServer.Core.ServerEvent.ServerEventManager" }
}

---
-- The paths of the classes that need to be reloaded after the mocks for the test class dependencies were applied.
--
-- @tfield string[] reloadDependencies
--
TestServer.reloadDependencies = {
  "AC-LuaServer.Core.ServerEvent.ServerEventListener"
}

---
-- The ExtensionManager mock that will be injected into the test Server instance
--
-- @tparam table extensionManagerMock
--
TestServer.extensionManagerMock = nil

---
-- The PlayerList mock that will be injected into the test Server instance
--
-- @tparam table playerListMock
--
TestServer.playerListMock = nil


---
-- Method that is called before a test is executed.
-- Sets up the mocks.
--
function TestServer:setUp()
  TestCase.setUp(self)

  self.extensionManagerMock = self.mach.mock_object(
    self.originalDependencies["AC-LuaServer.Core.Extension.ExtensionManager"], "ExtensionManagerMock"
  )
  self.playerListMock = self.mach.mock_object(
    self.originalDependencies["AC-LuaServer.Core.PlayerList.PlayerList"], "PlayerListMock"
  )
end

---
-- Method that is called after a test was executed.
-- Clears the mocks.
--
function TestServer:tearDown()
  TestCase.tearDown(self)

  self.extensionManagerMock = nil
  self.playerListMock = nil
end


---
-- Checks that extensions can be added to a Server as expected.
--
function TestServer:testCanAddExtensions()

  local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
  local extensionMockA = self.mach.mock_object(BaseExtension, "BaseExtensionMock")
  local extensionMockB = self.mach.mock_object(BaseExtension, "BaseExtensionMock")

  local server = self:createTestServerInstance()

  self.extensionManagerMock.addExtension
                           :should_be_called_with(extensionMockA)
                           :when(
                             function()
                               server:addExtension(extensionMockA)
                             end
                           )

  self.extensionManagerMock.addExtension
                           :should_be_called_with(extensionMockB)
                           :when(
                             function()
                               server:addExtension(extensionMockB)
                             end
                           )

end

---
-- Checks that "playerSayText" server events are handled as expected.
--
function TestServer:testCanHandlePlayerSayTextEvent()

  local server = self:createTestServerInstance()

  local playerMock = self:getMock("AC-LuaServer.Core.PlayerList.Player", "PlayerMock")

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.logline = self.mach.mock_function("logline")
  LuaServerApiMock.ACLOG_INFO = 2

  self.playerListMock.getPlayerByCn
                     :should_be_called_with(6)
                     :and_will_return(playerMock)
                     :and_then(
                       playerMock.getIp
                                 :should_be_called()
                                 :and_will_return("172.16.0.0")
                     )
                     :and_then(
                       playerMock.getName
                                 :should_be_called()
                                 :and_will_return("newplayer")
                     )
                     :and_then(
                       LuaServerApiMock.logline
                                       :should_be_called_with(
                                         LuaServerApiMock.ACLOG_INFO,
                                         "[172.16.0.0] newplayer says: '!help cmds'"
                                       )
                     )
                     :when(
                       function()
                         server:onPlayerSayText(6, "!help cmds")
                       end
                     )

end


---
-- Creates and returns a Server test instance.
--
function TestServer:createTestServerInstance()

  local Server = self.testClass

  local ExtensionManagerMock = self.dependencyMocks.ExtensionManager
  local PlayerListMock = self.dependencyMocks.PlayerList

  local ServerEventManagerMock = self.dependencyMocks.ServerEventManager
  local serverEventManagerMock = self:getMock(
    "AC-LuaServer.Core.ServerEvent.ServerEventManager", "ServerEventManagerMock"
  )

  local EventCallbackMock = self.dependencyMocks.EventCallback
  local eventCallbackMockA = self:getMock("AC-LuaServer.Core.Event.EventCallback", "EventCallbackMock")

  local server
  ExtensionManagerMock.__call
                      :should_be_called_with(self.mach.match(Server, self.matchClassInstance))
                      :and_will_return(self.extensionManagerMock)
                      :and_also(
                        PlayerListMock.__call
                                      :should_be_called()
                                      :and_will_return(self.playerListMock)
                      )
                      :and_also(
                        ServerEventManagerMock.__call
                                              :should_be_called()
                                              :and_will_return(serverEventManagerMock)
                      )
                      :and_then(
                        EventCallbackMock.__call
                                         :should_be_called_with(
                                           self.mach.match(
                                             { object = Server, methodName = "onPlayerSayText" },
                                             TestServer.matchEventCallback
                                           ),
                                           0
                                         )
                                         :and_will_return(eventCallbackMockA)
                      )
                      :and_also(
                        serverEventManagerMock.on
                                              :should_be_called_with("onPlayerSayText", eventCallbackMockA)
                      )
                      :and_also(
                        self.playerListMock.initialize
                                           :should_be_called()
                      )
                      :when(
                        function()
                          server = Server.getInstance()
                        end
                      )

  self:assertEquals(self.playerListMock, server:getPlayerList())

  return server

end

---
-- Matches that an object parameter is an instance of a specific class.
--
-- @treturn bool True if the actual object is an instance of the expected class, false otherwise
--
function TestServer.matchClassInstance(_expected, _actual)
  return _actual:is(_expected)
end

---
-- Matches a specific event callback constructor call.
--
-- The expected object must be a class, the expected methodName a string.
-- This matcher function then checks that he object is an instance of the specified class and that the
-- method names match.
--
-- @treturn bool True if the actual value met the expectations, false otherwise
--
function TestServer.matchEventCallback(_expected, _actual)
  return (_actual.object:is(_expected.object) and _actual.methodName == _expected.methodName)
end


return TestServer