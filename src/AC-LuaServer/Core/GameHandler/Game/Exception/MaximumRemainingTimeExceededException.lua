---
-- @author wesen
-- @copyright 2019-2020 wesen <wesen-ac@web.de>
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
-- The maximum allowed number of extend milliseconds
--
-- @tfield int maximumNumberOfExtendMilliseconds
--
MaximumRemainingTimeExceededException.maximumNumberOfExtendMilliseconds = nil

---
-- The time in milliseconds until the extra minute that may be unavailable because of the
-- integer overflow in the intermission check is available
--
-- @tfield int millisecondsUntilExtraMinuteCanBeUsed
--
MaximumRemainingTimeExceededException.millisecondsUntilExtraMinuteCanBeUsed = nil


---
-- MaximumRemainingTimeExceededException constructor.
--
-- @tparam int _exceedanceInMilliseconds The exceedance of the maximum remaining time in milliseconds
-- @tparam int _maximumNumberOfExtendMilliseconds The maxmimum allowed number of extend milliseconds
-- @tparam int _millisecondsUntilExtraMinuteCanBeUsed The time until the extra minute is available
--
function MaximumRemainingTimeExceededException:new(_exceedanceInMilliseconds, _maximumNumberOfExtendMilliseconds, _millisecondsUntilExtraMinuteCanBeUsed)
  self.exceedanceInMilliseconds = _exceedanceInMilliseconds
  self.maximumNumberOfExtendMilliseconds = _maximumNumberOfExtendMilliseconds
  self.millisecondsUntilExtraMinuteCanBeUsed = _millisecondsUntilExtraMinuteCanBeUsed
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
-- Returns the maxmimum allowed number of extend milliseconds.
--
-- @treturn int The maxmimum allowed number of extend milliseconds
--
function MaximumRemainingTimeExceededException:getMaximumNumberOfExtendMilliseconds()
  return self.maximumNumberOfExtendMilliseconds
end

---
-- Returns the time until the extra minute is available.
--
-- @treturn int The time until the extra minute is available
--
function MaximumRemainingTimeExceededException:getMillisecondsUntilExtraMinuteCanBeUsed()
  return self.millisecondsUntilExtraMinuteCanBeUsed
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
