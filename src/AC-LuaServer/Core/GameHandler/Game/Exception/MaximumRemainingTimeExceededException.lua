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
-- Stores whether the extra minute that may be unavailable because of the integer overflow
-- in the intermission check is currently available
--
-- @tfield bool isExtraMinuteAvailable
--
MaximumRemainingTimeExceededException.isExtraMinuteAvailable = nil


---
-- MaximumRemainingTimeExceededException constructor.
--
-- @tparam int _exceedanceInMilliseconds The exceedance of the maximum remaining time in milliseconds
-- @tparam bool _isExtraMinuteAvailable True if the extra minute is currently available, false otherwise
--
function MaximumRemainingTimeExceededException:new(_exceedanceInMilliseconds, _isExtraMinuteAvailable)
  self.exceedanceInMilliseconds = _exceedanceInMilliseconds
  self.isExtraMinuteAvailable = _isExtraMinuteAvailable
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

---
-- Returns whether the extra minute is currently available.
--
-- @treturn bool True if the extra minute is currently available, false otherwise
--
function MaximumRemainingTimeExceededException:getIsExtraMinuteAvailable()
  return self.isExtraMinuteAvailable
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
