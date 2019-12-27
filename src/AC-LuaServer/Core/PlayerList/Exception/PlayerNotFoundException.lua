---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require "AC-LuaServer.Core.Util.Exception.Exception"

---
-- Exception for the case that Player.createFromConnectedPlayer is called with a client number with which
-- no client is connected at the moment.
--
-- @type PlayerNotFoundException
--
local PlayerNotFoundException = Exception:extend()


---
-- The client number that caused this Exception
--
-- @tfield int cn
--
PlayerNotFoundException.cn = nil


---
-- PlayerNotFoundException constructor.
--
-- @tparam int _cn The client number that caused the Exception
--
function PlayerNotFoundException:new(_cn)
  self.cn =_cn
end


-- Getters and Setters

---
-- Returns the client number that caused this Exception.
--
-- @treturn int The client number
--
function PlayerNotFoundException:getCn()
  return self.cn
end


-- Public Methods

---
-- Returns this Exception's message as a string.
--
-- @treturn string The Exception message as a string
--
function PlayerNotFoundException:getMessage()
  return string.format(
    "Could not create Player object from connected player: No player connected with client number %i",
    self.cn
  )
end


return PlayerNotFoundException
