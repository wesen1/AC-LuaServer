---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the VotedGame works as expected.
--
-- @type TestVotedGame
--
local TestVotedGame = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestVotedGame.testClassPath = "AC-LuaServer.Core.GameHandler.Game.VotedGame"


---
-- Checks that a VotedGame can be created as expected.
--
function TestVotedGame:testCanBeCreated()

  local VotedGame = self.testClass

  local mapVoteMock = self:getMock("AC-LuaServer.Core.VoteListener.Vote.MapVote", "MapVoteMock")
  local votedGame = VotedGame(mapVoteMock)

  -- Fetch the map name
  local mapName
  mapVoteMock.getMapName
             :should_be_called()
             :and_will_return("Gibbed-Gema12")
             :when(
               function()
                 mapName = votedGame:getMapName()
               end
             )
  self:assertEquals("Gibbed-Gema12", mapName)

  -- Fetch the game mode id
  local gameModeId
  mapVoteMock.getGameModeId
             :should_be_called()
             :and_will_return(5)
             :when(
               function()
                 gameModeId = votedGame:getGameModeId()
               end
             )
  self:assertEquals(5, gameModeId)

  -- Fetch the time in minutes
  local timeInMinutes
  mapVoteMock.getTime
             :should_be_called()
             :and_will_return(20)
             :when(
               function()
                 timeInMinutes = votedGame:getTimeInMinutes()
               end
             )
  self:assertEquals(20, timeInMinutes)

end


return TestVotedGame
