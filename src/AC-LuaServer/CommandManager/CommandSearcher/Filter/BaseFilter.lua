---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Provides methods to tell whether a command or a command group have to be included in a result set of commands.
--
-- @type BaseFilter
--
local BaseFilter = Object:extend()


---
-- The CommandUser for which this Filter is used
--
-- @tfield CommandUser commandUser
--
BaseFilter.commandUser = nil


---
-- BaseFilter constructor.
--
-- @tparam CommandUser _commandUser The CommandUser for which this Filter is used
--
function BaseFilter:new(_commandUser)
  self.commandUser = _commandUser
end


-- Public Methods

---
-- Returns whether a specific CommandGroup matches this Filter.
--
-- @tparam CommandGroup _commandGroup The CommandGroup to check
--
-- @treturn bool True if the CommandGroup matches this Filter, false otherwise
--
function BaseFilter:matchesCommandGroup(_commandGroup)
  return true
end

---
-- Returns whether a specified Command matches this Filter.
--
-- @tparam BaseCommand _command The Command to check
--
-- @treturn bool True if the Command matches this Filter, false otherwise
--
function BaseFilter:matchesCommand(_command)
  return true
end


return BaseFilter
