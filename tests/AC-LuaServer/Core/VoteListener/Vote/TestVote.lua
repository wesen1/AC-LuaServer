---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the Vote works as expected.
--
-- @type TestVote
--
local TestVote = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestVote.testClassPath = "AC-LuaServer.Core.VoteListener.Vote.Vote"


---
-- Checks that a Vote can be created as expected.
--
function TestVote:testCanBeCreated()

  local Vote = self.testClass
  local vote = Vote(3, 7, "gibbed-gema11", 5, 15)

  self:assertEquals(3, vote:getCallerCn())
  self:assertEquals(7, vote:getType())
  self:assertEquals("gibbed-gema11", vote:getText())
  self:assertEquals(5, vote:getNumberA())
  self:assertEquals(15, vote:getNumberB())
  self:assertEquals(Vote.STATUS_PENDING, vote:getStatus())

end

---
-- Checks that the status of a vote can be changed as expected.
--
function TestVote:testCanChangeStatus()

  local Vote = self.testClass
  local vote = Vote(3, 7, "ac_unarmed_gema", 0, 10)

  self:assertEquals(Vote.STATUS_PENDING, vote:getStatus())

  vote:setStatus(Vote.STATUS_PASSED)
  self:assertEquals(Vote.STATUS_PASSED, vote:getStatus())

  vote:setStatus(Vote.STATUS_FAILED)
  self:assertEquals(Vote.STATUS_FAILED, vote:getStatus())

end


return TestVote
