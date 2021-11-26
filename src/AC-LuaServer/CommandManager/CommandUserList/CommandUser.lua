---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

local CommandUser = Object:extend()


CommandUser.player = nil

---
-- The CommandUser's current level (0 = unarmed, 1 = admin)
--
-- @tfield int level
--
CommandUser.level = 0


function CommandUser:new(_player)
  self.player = _player
  self.level = 0
end


-- Getters and Setters

---
-- Returns the player level.
--
-- @treturn int The player level
--
function CommandUser:getLevel()
  return self.level
end

---
-- Sets the player Level.
--
-- @tparam int _level The player level
--
function CommandUser:setLevel(_level)
  self.level = _level
end


return CommandUser
