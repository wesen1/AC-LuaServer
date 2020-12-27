---
-- @author wesen
-- @copyright 2019-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

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
  { id = "ExtensionManager", path = "AC-LuaServer.Core.Extension.ExtensionManager" },
  { id = "LuaServerApi", path = "AC-LuaServer.Core.LuaServerApi", ["type"] = "table" },
  { id = "EventCallback", path = "AC-LuaServer.Core.Event.EventCallback" },
  { id = "PlayerList", path = "AC-LuaServer.Core.PlayerList.PlayerList" },
  { id = "GameHandler", path = "AC-LuaServer.Core.GameHandler.GameHandler" },
  { id = "MapRotation", path = "AC-LuaServer.Core.MapRotation.MapRotation" },
  { id = "Output", path = "AC-LuaServer.Core.Output.Output" },
  { id = "VoteListener", path = "AC-LuaServer.Core.VoteListener.VoteListener" },
  { id = "ServerEventManager", path = "AC-LuaServer.Core.ServerEvent.ServerEventManager" }
}

---
-- The ExtensionManager mock that will be injected into the test Server instance
--
-- @tfield table extensionManagerMock
--
TestServer.extensionManagerMock = nil

---
-- The GameHandler mock that will be injected into the test Server instance
--
-- @tfield table gameHandlerMock
--
TestServer.gameHandlerMock = nil

---
-- The MapRotation mock that will be injected into the test Server instance
--
-- @tfield table mapRotationMock
--
TestServer.mapRotationMock = nil

---
-- The Output mock that will be injected into the test Server instance
--
-- @tfield table outputMock
--
TestServer.outputMock = nil

---
-- The PlayerList mock that will be injected into the test Server instance
--
-- @tfield table playerListMock
--
TestServer.playerListMock = nil

---
-- The VoteListener mock that will be injected into the test Server instance
--
-- @tfield table voteListenerMock
--
TestServer.voteListenerMock = nil


---
-- Method that is called before a test is executed.
-- Sets up the mocks.
--
function TestServer:setUp()
  TestCase.setUp(self)

  self.extensionManagerMock = self:getMock(
    "AC-LuaServer.Core.Extension.ExtensionManager", "ExtensionManagerMock"
  )
  self.gameHandlerMock = self:getMock(
    "AC-LuaServer.Core.GameHandler.GameHandler", "GameHandlerMock"
  )
  self.mapRotationMock = self:getMock(
    "AC-LuaServer.Core.MapRotation.MapRotation", "MapRotationMock"
  )
  self.outputMock = self:getMock(
    "AC-LuaServer.Core.Output.Output", "OutputMock"
  )
  self.playerListMock = self:getMock(
    "AC-LuaServer.Core.PlayerList.PlayerList", "PlayerListMock"
  )
  self.voteListenerMock = self:getMock(
    "AC-LuaServer.Core.VoteListener.VoteListener", "VoteListenerMock"
  )
end

---
-- Method that is called after a test was executed.
-- Clears the mocks.
--
function TestServer:tearDown()
  TestCase.tearDown(self)

  self.extensionManagerMock = nil
  self.gameHandlerMock = nil
  self.mapRotationMock = nil
  self.outputMock = nil
  self.playerListMock = nil
  self.voteListenerMock = nil
end


---
-- Checks that the internally used Output can be configured as expected.
--
function TestServer:testCanConfigureOutput()

  local server = self:createTestServerInstance()

  self.outputMock.configure
                 :should_be_called_with(
                   self.mach.match(
                     { TemplateRenderer = { StringRenderer = { suffix = ".luatpl" } } }
                   )
                 )
                 :when(
                   function()
                     server:configure({
                         Output = {
                           TemplateRenderer = {
                             StringRenderer = { suffix = ".luatpl" }
                           }
                         }
                     })
                   end
                 )

end


---
-- Creates and returns a Server test instance.
--
-- @treturn Server The test Server instance
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
                      :and_also(
                        self.dependencyMocks.GameHandler.__call
                                                        :should_be_called()
                                                        :and_will_return(self.gameHandlerMock)
                      )
                      :and_also(
                        self.dependencyMocks.MapRotation.__call
                                                        :should_be_called()
                                                        :and_will_return(self.mapRotationMock)
                      )
                      :and_also(
                        self.dependencyMocks.Output.__call
                                                   :should_be_called()
                                                   :and_will_return(self.outputMock)
                      )
                      :and_also(
                        self.dependencyMocks.VoteListener.__call
                                                         :should_be_called()
                                                         :and_will_return(self.voteListenerMock)
                      )
                      :and_also(
                        self.playerListMock.initialize
                                           :should_be_called()
                      )
                      :and_also(
                        self.gameHandlerMock.initialize
                                            :should_be_called()
                      )
                      :and_also(
                        self.voteListenerMock.initialize
                                             :should_be_called()
                      )
                      :when(
                        function()
                          server = Server.getInstance()
                        end
                      )

  self:assertEquals(serverEventManagerMock, server:getEventManager())
  self:assertEquals(self.extensionManagerMock, server:getExtensionManager())
  self:assertEquals(self.gameHandlerMock, server:getGameHandler())
  self:assertEquals(self.mapRotationMock, server:getMapRotation())
  self:assertEquals(self.outputMock, server:getOutput())
  self:assertEquals(self.playerListMock, server:getPlayerList())
  self:assertEquals(self.voteListenerMock, server:getVoteListener())

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
