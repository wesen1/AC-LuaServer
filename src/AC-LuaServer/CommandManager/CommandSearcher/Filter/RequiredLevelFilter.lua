---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseFilter = require "AC-LuaServer.CommandManager.CommandList.Filter.BaseFilter"


---
-- Provides methods to tell whether a command or a command group have to be included in a result set of commands.
--
-- @type BaseFilter
--
local RequiredLevelFilter = BaseFilter:extend()


---
-- Returns whether a specified Command matches this Filter.
--
-- @tparam BaseCommand _command The Command to check
--
-- @treturn bool True if the Command matches this Filter, false otherwise
--
function RequiredLevelFilter:commandMatches(_command)
  return (self.commandUser:getLevel() < _command:getRequiredLevel())

  -- TODO: v Own TemplateException
  error(Exception(StaticString("exceptionNoPermissionToUseCommand"):getString()))

end


return RequiredLevelFilter
