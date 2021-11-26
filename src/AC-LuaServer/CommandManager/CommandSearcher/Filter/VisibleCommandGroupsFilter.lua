---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseFilter = require "AC-LuaServer.CommandManager.CommandList.Filter.BaseFilter"
local TableUtils = require "AC-LuaServer.Core.Util.TableUtils"

---
-- Provides methods to tell whether a command or a command group have to be included in a result set of commands.
--
-- @type VisibleCommandGroupsFilter
--
local VisibleCommandGroupsFilter = BaseFilter:extend()


---
-- Returns whether a specified Command matches this Filter.
--
-- @tparam BaseCommand _command The Command to check
--
-- @treturn bool True if the Command matches this Filter, false otherwise
--
function VisibleCommandGroupsFilter:commandGroupMatches(_commandGroup)

  if (_commandGroup:getHasLimitedVisibility()) then
    return (TableUtils.tableHasValue(
      self.commandUser:getExplicitlyVisibleCommandGroupNames(), _commandGroup:getName()
    ))
  else
    return true
  end

end


return VisibleCommandGroupsFilter
