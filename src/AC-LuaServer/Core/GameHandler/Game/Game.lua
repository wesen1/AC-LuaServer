---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Represents a single game.
-- This includes the map name, game mode and remaining time.
--
-- @type Game
--
local Game = Object:extend()


-- Public Methods

---
-- Returns the map name.
--
-- @treturn string The map name
--
function Game:getMapName()
end

---
-- Returns the game mode id.
--
-- @treturn int The game mode id
--
function Game:getGameModeId()
end


return Game
