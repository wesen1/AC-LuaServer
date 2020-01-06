---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseGameMode = require "AC-LuaServer.Extensions.GameModeManager.BaseGameMode"

---
-- The default game mode.
-- This makes the server act like a regular AssaultCube server.
--
-- @type DefaultGameMode
--
local DefaultGameMode = BaseGameMode:extend()


---
-- DefaultGameMode constructor.
--
function DefaultGameMode:new()
  -- TODO: Add display name to strings table
  self.super.new(self, "DefaultGameMode", "Default")
end


---
-- Returns whether this GameMode can be enabled for a specified Game.
--
-- @tparam Game _game The game to check
--
-- @treturn bool True if this GameMode can be enabled for the specified Game, false otherwise
--
function DefaultGameMode:canBeEnabledForGame(_game)
  return true
end


return DefaultGameMode
