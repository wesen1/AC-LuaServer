---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"

---
-- Base class for game modes.
--
-- @type BaseGameMode
--
local BaseGameMode = BaseExtension:extend()


---
-- The name of this GameMode that will be displayed to players
--
-- @tfield string displayName
--
BaseGameMode.displayName = nil


---
-- BaseGameMode constructor.
--
-- @tparam string _name The name of this GameMode (in the extension context)
-- @tparam string _displayName The name of this GameMode that will be displayed to players
--
function BaseGameMode:new(_name, _displayName)
  BaseExtension.new(self, _name, "GameModeManager")
  self.displayName = _displayName
end


-- Getters and Setters

---
-- Returns this GameMode's display name.
--
-- @treturn string The display name
--
function BaseGameMode:getDisplayName()
  return self.displayName
end


-- Public Methods

---
-- Returns whether this GameMode can be enabled for a specified Game.
--
-- @tparam Game _game The game to check
--
-- @treturn bool True if this GameMode can be enabled for the specified Game, false otherwise
--
function BaseGameMode:canBeEnabledForGame(_game)
  return false
end


return BaseGameMode
