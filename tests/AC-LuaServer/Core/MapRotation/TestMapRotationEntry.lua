---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the MapRotationEntry works as expected.
--
-- @type TestMapRotationEntry
--
local TestMapRotationEntry = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestMapRotationEntry.testClassPath = "AC-LuaServer.Core.MapRotation.MapRotationEntry"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestMapRotationEntry.dependencyPaths = {
  { id = "LuaServerApi", path = "AC-LuaServer.Core.LuaServerApi", ["type"] = "table" }
}


---
-- Checks that a MapRotationEntry can be created with only the mandatory values.
--
function TestMapRotationEntry:testCanBeCreatedWithDefaultValues()

  local MapRotationEntry = self.testClass
  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.GM_CTF = 5

  local entry = MapRotationEntry("15-minutes-gema")

  self:assertEquals("15-minutes-gema", entry:getMapName())
  self:assertEquals(5, entry:getGameModeId())
  self:assertEquals(15, entry:getTimeInMinutes())
  self:assertTrue(entry:getAreGameChangeVotesAllowed())
  self:assertEquals(0, entry:getMinimumNumberOfPlayers())
  self:assertEquals(16, entry:getMaximumNumberOfPlayers())
  self:assertEquals(0, entry:getNumberOfSkipLines())

end

---
-- Checks that a MapRotationEntry can be configured by calling the setters on a instance.
--
function TestMapRotationEntry:testCanBeConfigured()

  local MapRotationEntry = self.testClass
  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.GM_CTF = 5

  local entry = MapRotationEntry("gema_shorty")

  entry:setGameModeId(0)
  entry:setTimeInMinutes(30)
  entry:setAreGameChangeVotesAllowed(false)
  entry:setMinimumNumberOfPlayers(4)
  entry:setMaximumNumberOfPlayers(11)
  entry:setNumberOfSkipLines(6)

  self:assertEquals("gema_shorty", entry:getMapName())
  self:assertEquals(0, entry:getGameModeId())
  self:assertEquals(30, entry:getTimeInMinutes())
  self:assertFalse(entry:getAreGameChangeVotesAllowed())
  self:assertEquals(4, entry:getMinimumNumberOfPlayers())
  self:assertEquals(11, entry:getMaximumNumberOfPlayers())
  self:assertEquals(6, entry:getNumberOfSkipLines())

end

---
-- Checks that a MapRotationEntry can be configured by calling the setters on a instance fluently.
--
function TestMapRotationEntry:testCanBeConfiguredFluently()

  local MapRotationEntry = self.testClass
  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.GM_CTF = 5

  local entry = MapRotationEntry("Gema-Magic")

  entry:setGameModeId(1)
       :setTimeInMinutes(25)
       :setAreGameChangeVotesAllowed(false)
       :setMinimumNumberOfPlayers(8)
       :setMaximumNumberOfPlayers(13)
       :setNumberOfSkipLines(2)

  self:assertEquals("Gema-Magic", entry:getMapName())
  self:assertEquals(1, entry:getGameModeId())
  self:assertEquals(25, entry:getTimeInMinutes())
  self:assertFalse(entry:getAreGameChangeVotesAllowed())
  self:assertEquals(8, entry:getMinimumNumberOfPlayers())
  self:assertEquals(13, entry:getMaximumNumberOfPlayers())
  self:assertEquals(2, entry:getNumberOfSkipLines())

end


return TestMapRotationEntry
