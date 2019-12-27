---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the MapVote works as expected.
--
-- @type TestMapVote
--
local TestMapVote = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestMapVote.testClassPath = "AC-LuaServer.Core.VoteListener.Vote.MapVote"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestMapVote.dependencyPaths = {
  { id = "LuaServerApi", path = "AC-LuaServer.Core.LuaServerApi", ["type"] = "table" }
}


---
-- Checks that a MapVote can be created as expected.
--
function TestMapVote:testCanBeCreated()

  local Vote = require "AC-LuaServer.Core.VoteListener.Vote.Vote"
  local MapVote = self.testClass

  local LuaServerApi = self.dependencyMocks.LuaServerApi
  LuaServerApi.GM_NUM = 22

  local mapVote = MapVote(12, 7, "Gibbed-Gema10", 5, 60)

  self:assertEquals(12, mapVote:getCallerCn())
  self:assertEquals(7, mapVote:getType())
  self:assertEquals("Gibbed-Gema10", mapVote:getText())
  self:assertEquals(5, mapVote:getNumberA())
  self:assertEquals(60, mapVote:getNumberB())
  self:assertEquals(Vote.STATUS_PENDING, mapVote:getStatus())

  self:assertFalse(mapVote:getIsSetNext())
  self:assertEquals("Gibbed-Gema10", mapVote:getMapName())
  self:assertEquals(5, mapVote:getGameModeId())
  self:assertEquals(60, mapVote:getTime())

end

---
-- Checks that a MapVote can be created from a "/setnext" call as expected.
--
function TestMapVote:testCanBeCreatedFromSetNextCall()

  local Vote = require "AC-LuaServer.Core.VoteListener.Vote.Vote"
  local MapVote = self.testClass

  local LuaServerApi = self.dependencyMocks.LuaServerApi
  LuaServerApi.GM_NUM = 22

  local mapVote = MapVote(8, 7, "ac_douze", 22, -1)

  self:assertEquals(8, mapVote:getCallerCn())
  self:assertEquals(7, mapVote:getType())
  self:assertEquals("ac_douze", mapVote:getText())
  self:assertEquals(22, mapVote:getNumberA())
  self:assertEquals(-1, mapVote:getNumberB())
  self:assertEquals(Vote.STATUS_PENDING, mapVote:getStatus())

  self:assertTrue(mapVote:getIsSetNext())
  self:assertEquals("ac_douze", mapVote:getMapName())
  self:assertEquals(0, mapVote:getGameModeId())
  self:assertEquals(-1, mapVote:getTime())

end


return TestMapVote
