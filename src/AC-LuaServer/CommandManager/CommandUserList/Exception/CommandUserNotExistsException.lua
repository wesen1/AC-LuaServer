---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require "AC-LuaServer.Core.Util.Exception.Exception"

---
-- Exception for the case that a CommandUser should be removed from a CommandUserList in which
-- no CommandUser for the target Player's client number exists.
--
-- @type CommandUserNotExistsException
--
local CommandUserNotExistsException = Exception:extend()


---
-- The target Player that caused this Exception
--
-- @tfield Player targetPlayer
--
CommandUserNotExistsException.targetPlayer = nil


---
-- CommandUserNotExistsException constructor.
--
-- @tparam Player _targetPlayerThe target Player that caused this Exception
--
function CommandUserNotExistsException:new(_targetPlayer)
  self.targetPlayer = _targetPlayer
end


-- Getters and Setters

---
-- Returns the target Player that caused this Exception.
--
-- @treturn Player The target Player that caused this Exception
--
function CommandUserNotExistsException:getTargetPlayer()
  return self.targetPlayer
end


-- Public Methods

---
-- Returns this Exception's message as a string.
--
-- @treturn string The Exception message as a string
--
function CommandUserNotExistsException:getMessage()
  return string.format(
    "Could not remove CommandUser for cn %s from CommandUserList: There is no CommandUser for that cn",
    self.targetPlayer:getCn()
  )
end


return CommandUserNotExistsException
