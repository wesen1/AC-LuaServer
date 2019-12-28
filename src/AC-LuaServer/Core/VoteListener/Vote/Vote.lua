---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Represents a Vote.
--
-- @type Vote
--
local Vote = Object:extend()


-- Available vote statuses

---
-- The "pending" status (Players can still vote YES or NO)
--
-- @tfield int STATUS_PENDING
--
Vote.STATUS_PENDING = "PENDING"

---
-- The "passed" status (The vote got enough YES votes and passed)
--
-- @tfield int STATUS_PASSED
--
Vote.STATUS_PASSED = "PASSED"

---
-- The "failed" status (Vote could not be called or got too many NO votes and failed)
--
-- @tfield int STATUS_FAILED
--
Vote.STATUS_FAILED = "FAILED"


---
-- The client number of the player who called the vote
--
-- @tfield int callerCn
--
Vote.callerCn = nil

---
-- The vote type (e.g. map, kick, ban, etc.)
--
-- @tfield int type
--
Vote.type = nil

---
-- The vote text (e.g. map name, kick reason, etc.)
--
-- @tfield string text
--
Vote.text = nil

---
-- The first vote number (e.g. game mode, target cn, etc.)
--
-- @tfield int numberA
--
Vote.numberA = nil

---
-- The second vote number (e.g. time, target team of a teamchange vote, etc.)
--
-- @tfield int numberB
--
Vote.numberB = nil

---
-- The current status of the vote
-- This is one of the STATUS constants
--
-- @tfield string status
--
Vote.status = nil


---
-- Vote constructor.
--
-- @tparam int _callerCn The client number of the player who called the vote
-- @tparam int _type The vote type
-- @tparam string _text The vote text
-- @tparam int _numberA The first vote number
-- @tparam int _numberB The second vote number
--
function Vote:new(_callerCn, _type, _text, _numberA, _numberB)
  self.callerCn = _callerCn
  self.type = _type
  self.text = _text
  self.numberA = _numberA
  self.numberB = _numberB
  self.status = Vote.STATUS_PENDING
end


-- Getters and Setters

---
-- Returns the client number of the player who called the vote.
--
-- @treturn int The client number
--
function Vote:getCallerCn()
  return self.callerCn
end

---
-- Returns the vote type.
--
-- @treturn int The vote type
--
function Vote:getType()
  return self.type
end

---
-- Returns the vote text.
--
-- @treturn string The vote text
--
function Vote:getText()
  return self.text
end

---
-- Returns the first vote number.
--
-- @treturn int The first vote number
--
function Vote:getNumberA()
  return self.numberA
end

---
-- Returns the second vote number.
--
-- @treturn int The second vote number
--
function Vote:getNumberB()
  return self.numberB
end

---
-- Returns the current status of the vote.
--
-- @treturn string The current status of the vote
--
function Vote:getStatus()
  return self.status
end

---
-- Sets the status of the vote.
--
-- @tparam string _newStatus The new status of the vote
--
function Vote:setStatus(_newStatus)
  self.status = _newStatus
end


return Vote
