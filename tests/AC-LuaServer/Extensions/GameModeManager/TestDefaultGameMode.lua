---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the DefaultGameMode works as expected.
--
-- @type TestDefaultGameMode
--
local TestDefaultGameMode = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestDefaultGameMode.testClassPath = "AC-LuaServer.Extensions.GameModeManager.DefaultGameMode"


---
-- Checks that the DefaultGameMode can be created as expected.
--
function TestDefaultGameMode:testCanBeCreated()

  local DefaultGameMode = self.testClass
  local defaultGameMode = DefaultGameMode()

  self:assertEquals("DefaultGameMode", defaultGameMode:getName())
  self:assertEquals("Default", defaultGameMode:getDisplayName())
  self:assertEquals("GameModeManager", defaultGameMode:getTargetName())

  -- Should not check the passed game and return true
  local gameMock = self:getMock("AC-LuaServer.Core.GameHandler.Game.Game", "GameMock")
  self:assertTrue(defaultGameMode:canBeEnabledForGame(gameMock))

end


return TestDefaultGameMode
