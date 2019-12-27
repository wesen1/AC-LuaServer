---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require "AC-LuaServer.Core.Util.Exception.Exception"

---
-- The exception for the case that the remaining time of the current active game is attempted to be set to
-- a value that would cause a integer overflow that results in an instant game end.
--
-- @type MaximumRemainingTimeExceededException
--
local MaximumRemainingTimeExceededException = Exception:extend()


---
-- The exceedance of the maximum remaining time in milliseconds
--
-- @tfield int exceedanceInMilliseconds
--
MaximumRemainingTimeExceededException.exceedanceInMilliseconds = nil


---
-- MaximumRemainingTimeExceededException constructor.
--
-- @tparam int _exceedanceInMilliseconds The exceedance of the maximum remaining time in milliseconds
--
function MaximumRemainingTimeExceededException:new(_exceedanceInMilliseconds)
  self.exceedanceInMilliseconds = _exceedanceInMilliseconds
end


-- Getters and Setters

---
-- Returns the exceedance of the maximum remaining time in milliseconds.
--
-- @treturn int The exceedance of the maximum remaining time in milliseconds
--
function MaximumRemainingTimeExceededException:getExceedanceInMilliseconds()
  return self.exceedanceInMilliseconds
end


-- Public Methods

---
-- Returns this Exception's message as a string.
--
-- @treturn string The Exception message as a string
--
function MaximumRemainingTimeExceededException:getMessage()
  return string.format(
    "Could not set remaining time: Maximum remaining time would be exceeded by %i milliseconds",
    self.exceedanceInMilliseconds
  )
end


return MaximumRemainingTimeExceededException
