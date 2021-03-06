---
-- @author wesen
-- @copyright 2019-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the PlayerList works as expected.
--
-- @type TestPlayerList
--
local TestPlayerList = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestPlayerList.testClassPath = "AC-LuaServer.Core.PlayerList.PlayerList"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestPlayerList.dependencyPaths = {
  { id = "EventCallback", path = "AC-LuaServer.Core.Event.EventCallback" },
  { id = "LuaServerApi", path = "AC-LuaServer.Core.LuaServerApi", ["type"] = "table" },
  { id = "Player", path = "AC-LuaServer.Core.PlayerList.Player", ["type"] = "table" },
  { id = "Server", path = "AC-LuaServer.Core.Server" }
}

---
-- The event listener for the "onPlayerAdded" event of the PlayerList test instance
--
-- @tfield table onPlayerAddedListener
--
TestPlayerList.onPlayerAddedListener = nil

---
-- The event listener for the "onPlayerRemoved" event of the PlayerList test instance
--
-- @tfield table onPlayerRemovedListener
--
TestPlayerList.onPlayerRemovedListener = nil

---
-- The event listener for the "onPlayerNameChanged" event of the PlayerList test instance
--
-- @tfield table onPlayerNameChangedListener
--
TestPlayerList.onPlayerNameChangedListener = nil


---
-- Method that is called before a test is executed.
-- Sets up the PlayerList event listeners.
--
function TestPlayerList:setUp()
  self.super.setUp(self)

  self.onPlayerAddedListener = self.mach.mock_function("onPlayerAddedListener")
  self.onPlayerRemovedListener = self.mach.mock_function("onPlayerRemovedListener")
  self.onPlayerNameChangedListener = self.mach.mock_function("onPlayerNameChangedListener")

end

---
-- Method that is called after a test was executed.
-- Clears the PlayerList event listeners.
--
function TestPlayerList:tearDown()
  self.super.tearDown(self)

  self.onPlayerAddedListener = nil
  self.onPlayerRemovedListener = nil
  self.onPlayerNameChangedListener = nil
end


---
-- Checks that AssaultCube server events are handled as expected by the PlayerList.
--
function TestPlayerList:testCanHandleServerEvents()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.CR_ADMIN = 1
  LuaServerApiMock.CR_DEFAULT = 0

  local list = self:createPlayerListInstance()

  self:assertNil(list:getPlayerByCn(5))
  self:assertEquals({}, list:getPlayers())

  local PlayerMock = self.dependencyMocks.Player
  local playerMockA = self:getMock("AC-LuaServer.Core.PlayerList.Player", "PlayerMockA")
  local playerMockB = self:getMock("AC-LuaServer.Core.PlayerList.Player", "PlayerMockB")

  -- Connect a player
  PlayerMock.createFromConnectedPlayer
            :should_be_called_with(5)
            :and_will_return(playerMockA)
            :and_then(
              self.onPlayerAddedListener
                  :should_be_called_with(playerMockA, 1)
            )
            :when(
              function()
                list:onPlayerPreconnect(5)
                list:onPlayerConnect(5)
              end
            )
  self:assertEquals(playerMockA, list:getPlayerByCn(5))
  self:assertEquals({ [5] = playerMockA }, list:getPlayers())

  -- Connect another playyer
  PlayerMock.createFromConnectedPlayer
            :should_be_called_with(7)
            :and_will_return(playerMockB)
            :and_then(
              self.onPlayerAddedListener
                  :should_be_called_with(playerMockB, 2)
            )
            :when(
              function()
                list:onPlayerPreconnect(7)
                list:onPlayerConnect(7)
              end
            )

  -- Check that the two players are connected
  self:assertEquals(playerMockA, list:getPlayerByCn(5))
  self:assertEquals(playerMockB, list:getPlayerByCn(7))
  self:assertEquals({ [5] = playerMockA, [7] = playerMockB }, list:getPlayers())


  -- Rename the second player
  playerMockB.getName
             :should_be_called()
             :and_will_return("unarmed")
             :and_then(
               playerMockB.setName
                          :should_be_called_with("knife")
             )
             :and_then(
               self.onPlayerNameChangedListener
                   :should_be_called_with(playerMockB, "unarmed")
             )
             :when(
               function()
                 list:onPlayerNameChange(7, "knife")
               end
             )

  -- Rename the first player
  playerMockA.getName
             :should_be_called()
             :and_will_return("cookies")
             :and_then(
               playerMockA.setName
                          :should_be_called_with("random")
             )
             :and_then(
               self.onPlayerNameChangedListener
                   :should_be_called_with(playerMockA, "cookies")
             )
             :when(
               function()
                 list:onPlayerNameChange(5, "random")
               end
             )


  -- Make the first player claim admin
  playerMockA.setHasAdminRole
             :should_be_called_with(true)
             :and_also(
               playerMockB.getHasAdminRole
                          :should_be_called()
                          :and_will_return(false)
             )
             :when(
               function()
                 list:onPlayerRoleChange(5, 1)
               end
             )

  -- Make the second player claim admin
  playerMockB.setHasAdminRole
             :should_be_called_with(true)
             :and_also(
               playerMockA.getHasAdminRole
                          :should_be_called()
                          :and_will_return(true)
                          :and_then(
                            playerMockA.setHasAdminRole
                                       :should_be_called_with(false)
                          )
             )
             :when(
               function()
                 list:onPlayerRoleChange(7, 1)
               end
             )

  -- Make the second player drop admin
  playerMockA.setHasAdminRole
             :should_be_called_with(false)
             :when(
               function()
                 list:onPlayerRoleChange(5, 0)
               end
             )


  -- Disconnect the first player
  self.onPlayerRemovedListener
      :should_be_called_with(playerMockA, 1)
      :when(
        function()
          list:onPlayerDisconnectAfter(5)
        end
      )

  self:assertEquals(nil, list:getPlayerByCn(5))
  self:assertEquals(playerMockB, list:getPlayerByCn(7))
  self:assertEquals({ [7] = playerMockB }, list:getPlayers())


  -- Disconnect the second player
  self.onPlayerRemovedListener
      :should_be_called_with(playerMockB, 0)
      :when(
        function()
          list:onPlayerDisconnectAfter(7)
        end
      )

  self:assertEquals(nil, list:getPlayerByCn(5))
  self:assertEquals(nil, list:getPlayerByCn(7))
  self:assertEquals({}, list:getPlayers())

end

---
-- Checks that a custom Player implementation class can be set as expected.
--
function TestPlayerList:testCanUseCustomPlayerImplementationClass()

  -- Fake class that just provides a mocked static method "createFromConnectedPlayer"
  local playerImplementationClass = {
    createFromConnectedPlayer = self.mach.mock_function("createFromConnectedPlayer")
  }

  local list = self:createPlayerListInstance()
  list:setPlayerImplementationClass(playerImplementationClass)

  self:assertNil(list:getPlayerByCn(12))
  self:assertEquals({}, list:getPlayers())

  local playerMock = {}

  -- Connect a player
  playerImplementationClass.createFromConnectedPlayer
                           :should_be_called_with(12)
                           :and_will_return(playerMock)
                           :and_then(
                             self.onPlayerAddedListener
                                 :should_be_called_with(playerMock, 1)
                           )
                           :when(
                             function()
                               list:onPlayerPreconnect(12)
                               list:onPlayerConnect(12)
                             end
                           )
  self:assertEquals(playerMock, list:getPlayerByCn(12))
  self:assertEquals({ [12] = playerMock }, list:getPlayers())

end


---
-- Creates and returns a PlayerList instance to which the event listeners are attached.
--
-- @treturn PlayerList The test PlayerList instance
--
function TestPlayerList:createPlayerListInstance()

  local PlayerList = self.testClass
  local list = PlayerList()

  local EventCallbackMock = self.dependencyMocks.EventCallback

  local serverMock = self:getMock("AC-LuaServer.Core.Server", "ServerMock")
  local serverEventManagerMock = self:getMock(
    "AC-LuaServer.Core.ServerEvent.ServerEventManager", "ServerEventManagerMock"
  )

  local eventCallbackPath = "AC-LuaServer.Core.Event.EventCallback"
  local eventCallbackMockA = self:getMock(eventCallbackPath, "EventCallbackMock")
  local eventCallbackMockB = self:getMock(eventCallbackPath, "EventCallbackMock")
  local eventCallbackMockC = self:getMock(eventCallbackPath, "EventCallbackMock")
  local eventCallbackMockD = self:getMock(eventCallbackPath, "EventCallbackMock")
  local eventCallbackMockE = self:getMock(eventCallbackPath, "EventCallbackMock")

  -- Initialize event callbacks and register the event handlers
  EventCallbackMock.__call
                   :should_be_called_with(
                     self.mach.match(
                       { object = PlayerList, methodName = "onPlayerConnect"},
                       TestPlayerList.matchEventCallback
                     ),
                     nil
                   )
                   :and_will_return(eventCallbackMockA)
                   :and_also(
                     EventCallbackMock.__call
                                      :should_be_called_with(
                                        self.mach.match(
                                          { object = PlayerList, methodName = "onPlayerPreconnect" },
                                          TestPlayerList.matchEventCallback
                                        ),
                                        nil
                                      )
                                      :and_will_return(eventCallbackMockB)
                   )
                   :and_also(
                     EventCallbackMock.__call
                                      :should_be_called_with(
                                        self.mach.match(
                                          { object = PlayerList, methodName = "onPlayerDisconnectAfter" },
                                          TestPlayerList.matchEventCallback
                                        ),
                                        nil
                                      )
                                      :and_will_return(eventCallbackMockC)
                   )
                   :and_also(
                     EventCallbackMock.__call
                                      :should_be_called_with(
                                        self.mach.match(
                                          { object = PlayerList, methodName = "onPlayerNameChange" },
                                          TestPlayerList.matchEventCallback
                                        ),
                                        nil
                                      )
                                      :and_will_return(eventCallbackMockD)
                   )
                   :and_also(
                     EventCallbackMock.__call
                                      :should_be_called_with(
                                        self.mach.match(
                                          { object = PlayerList, methodName = "onPlayerRoleChange" },
                                          TestPlayerList.matchEventCallback
                                        ),
                                        nil
                                      )
                                      :and_will_return(eventCallbackMockE)
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
                                           :should_be_called_with("onPlayerConnect", eventCallbackMockA)
                   )
                   :and_also(
                     serverEventManagerMock.on
                                           :should_be_called_with("onPlayerPreconnect", eventCallbackMockB)
                   )
                   :and_also(
                     serverEventManagerMock.on
                                           :should_be_called_with("onPlayerDisconnectAfter", eventCallbackMockC)
                   )
                   :and_also(
                     serverEventManagerMock.on
                                           :should_be_called_with("onPlayerNameChange", eventCallbackMockD)
                   )
                   :and_also(
                     serverEventManagerMock.on
                                           :should_be_called_with("onPlayerRoleChange", eventCallbackMockE)
                   )
                   :when(
                     function()
                       list:initialize()
                     end
                   )


  -- Attach the event listeners to the PlayerList instance
  local EventCallback = self.originalDependencies["AC-LuaServer.Core.Event.EventCallback"]
  list:on("onPlayerAdded", EventCallback(function(...) self.onPlayerAddedListener(...) end))
  list:on("onPlayerRemoved", EventCallback(function(...) self.onPlayerRemovedListener(...) end))
  list:on("onPlayerNameChanged", EventCallback(function(...) self.onPlayerNameChangedListener(...) end))

  return list

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
function TestPlayerList.matchEventCallback(_expected, _actual)
  return (_actual.object:is(_expected.object) and _actual.methodName == _expected.methodName)
end


return TestPlayerList
