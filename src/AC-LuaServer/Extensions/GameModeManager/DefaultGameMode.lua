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


return DefaultGameMode
