---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Game = require "AC-LuaServer.Core.GameHandler.Game.Game"

---
-- Represents a game that will be played at some point after the current active game.
-- This can be a game that is voted by a player or a game in the map rotation.
--
-- @type ScheduledGame
--
local ScheduledGame = Game:extend()


---
-- Returns the time in minutes.
--
-- @treturn int The time in minutes
--
function ScheduledGame:getTimeInMinutes()
end


return ScheduledGame
