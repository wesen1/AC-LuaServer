---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the Player works as expected.
--
-- @type TestPlayer
--
local TestPlayer = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestPlayer.testClassPath = "AC-LuaServer.Core.PlayerList.Player"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestPlayer.dependencyPaths = {
  { id = "LuaServerApi", path = "AC-LuaServer.Core.LuaServerApi", ["type"] = "table" }
}

---
-- The mock for the LuaServerApi.isconnected() method
--
-- @tfield table isconnectedMock
--
TestPlayer.isconnectedMock = nil

---
-- The mock for the LuaServerApi.getip() method
--
-- @tfield table isconnectedMock
--
TestPlayer.getipMock = nil

---
-- The mock for the LuaServerApi.getname() method
--
-- @tfield table isconnectedMock
--
TestPlayer.getnameMock = nil


---
-- Method that is called before a test is executed.
-- Sets up the LuaServerApi mocks.
--
function TestPlayer:setUp()
  TestCase.setUp(self)

  self.isconnectedMock = self.mach.mock_function("isconnected")
  self.getipMock = self.mach.mock_function("getip")
  self.getnameMock = self.mach.mock_function("getname")

  self.dependencyMocks.LuaServerApi.isconnected = self.isconnectedMock
  self.dependencyMocks.LuaServerApi.getip = self.getipMock
  self.dependencyMocks.LuaServerApi.getname = self.getnameMock
end

---
-- Method that is called after a test was executed.
-- Clears the LuaServerApi mocks.
--
function TestPlayer:tearDown()
  TestCase.tearDown(self)

  self.isconnectedMock = nil
  self.getipMock = nil
  self.getnameMock = nil
end


---
-- Checks that a Player instance can be created from a connected player as expected.
--
function TestPlayer:testCanBeCreatedFromConnectedPlayer()

  local Player = self.testClass
  local player

  self.isconnectedMock:should_be_called_with(3)
                      :and_will_return(true)
                      :and_then(
                        self.getipMock:should_be_called_with(3)
                                      :and_will_return("192.168.0.27")
                      )
                      :and_then(
                        self.getnameMock:should_be_called_with(3)
                                        :and_will_return("random")
                      )
                      :when(
                        function()
                          player = Player.createFromConnectedPlayer(3)
                        end
                      )

  self:assertEquals(3, player:getCn())
  self:assertEquals("192.168.0.27", player:getIp())
  self:assertEquals("random", player:getName())

end

---
-- Checks that a call of Player.createFromConnectedPlayer with an invalid cn is handled as expected.
--
function TestPlayer:testCanHandleTargetPlayerNotConnected()

  local Player = self.testClass
  local PlayerNotFoundException = require "AC-LuaServer.Core.PlayerList.Exception.PlayerNotFoundException"

  self.isconnectedMock:should_be_called_with(3)
                      :and_will_return(false)
                      :when(
                        function()
                          local exception = self:expectException(
                            function()
                              Player.createFromConnectedPlayer(3)
                            end
                          )

                          self:assertTrue(exception:is(PlayerNotFoundException))
                          self:assertEquals(3, exception:getCn())
                        end
                      )

end

---
-- Checks that the name of a Player can be set as expected.
--
function TestPlayer:testCanSetName()

  local Player = self.testClass
  local player = Player(3, "192.168.0.27", "cookies")

  self:assertEquals("cookies", player:getName())

  player:setName("ipro")
  self:assertEquals("ipro", player:getName())

  player:setName("SOMETHINGELSE")
  self:assertEquals("SOMETHINGELSE", player:getName())

end


return TestPlayer
