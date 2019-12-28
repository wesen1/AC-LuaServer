---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ScheduledGame = require "AC-LuaServer.Core.GameHandler.Game.ScheduledGame"

---
-- Represents the game that will be played when a game changing vote passes.
--
-- @type VotedGame
--
local VotedGame = ScheduledGame:extend()


---
-- The game changing vote
--
-- @tfield MapVote vote
--
VotedGame.vote = nil


---
-- VotedGame constructor.
--
-- @tparam MapVote _vote The game changing vote
--
function VotedGame:new(_vote)
  self.vote = _vote
end


-- Public Methods

---
-- Returns the map name.
--
-- @treturn string The map name
--
function VotedGame:getMapName()
  return self.vote:getMapName()
end

---
-- Returns the game mode id.
--
-- @treturn int The game mode id
--
function VotedGame:getGameModeId()
  return self.vote:getGameModeId()
end

---
-- Returns the time in minutes.
--
-- @treturn int The time in minutes
--
function VotedGame:getTimeInMinutes()
  return self.vote:getTime()
end


return VotedGame
