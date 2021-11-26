---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require "AC-LuaServer.Core.Util.Exception.Exception"

---
-- Exception for the case that a CommandUser should be added to a CommandUserList in which
-- a CommandUser for the target Player's client number already exists.
--
-- @type CommandUserAlreadyExistsException
--
local CommandUserAlreadyExistsException = Exception:extend()


---
-- The target Player that caused this Exception
--
-- @tfield Player targetPlayer
--
CommandUserAlreadyExistsException.targetPlayer = nil


---
-- CommandUserAlreadyExistsException constructor.
--
-- @tparam Player _targetPlayerThe target Player that caused this Exception
--
function CommandUserAlreadyExistsException:new(_targetPlayer)
  self.targetPlayer = _targetPlayer
end


-- Getters and Setters

---
-- Returns the target Player that caused this Exception.
--
-- @treturn Player The target Player that caused this Exception
--
function CommandUserAlreadyExistsException:getTargetPlayer()
  return self.targetPlayer
end


-- Public Methods

---
-- Returns this Exception's message as a string.
--
-- @treturn string The Exception message as a string
--
function CommandUserAlreadyExistsException:getMessage()
  return string.format(
    "Could not add CommandUser for cn %s to CommandUserList: There already is a CommandUser for that cn",
    self.targetPlayer:getCn()
  )
end


return CommandUserAlreadyExistsException
