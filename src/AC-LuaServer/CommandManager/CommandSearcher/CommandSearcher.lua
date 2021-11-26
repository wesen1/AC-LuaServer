---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Provides methods to search a CommandList for specified commands while applying
-- command visibility filters.
--
-- @type CommandSearcher
--
local CommandSearcher = Object:extend()


---
-- The CommandList that will be searched for Command's
--
-- @tfield CommandList commandList
--
CommandSearcher.commandList = nil

---
-- The Filter's that will be applied while searching for Command's
--
-- @tfield BaseFilter[] filters
--
CommandSearcher.filters = nil


---
-- CommandSearcher constructor.
--
-- @tparam CommandList _commandList The CommandList that should be searched for Command's
-- @tparam BaseFilter[] _filters The filters that should be applied while searching
--
function CommandSearcher:new(_commandList, _filters)
  self.commandList = _commandList
  self.filters = _filters
end


---
-- Returns a command that has a specified name or alias.
--
-- @tparam string _commandName The command name without the leading "!"
--
-- @treturn BaseCommand|bool The command or false if no command with that name or alias exists
--
function CommandSearcher:getCommandByNameOrAlias(_commandNameOrAlias)

  -- Extract command group name and
  local commandGroupName, commandNameOrAlias

  if (_commandNameOrAlias:find(":") == nil) then
    -- Command name contains no ":"
    commandNameOrAlias = _commandNameOrAlias
  else
    commandGroupName, commandNameOrAlias = _commandNameOrAlias:match("^([^:]+):(.+)$")
  end


  local filteredSearchCommandGroups = self:getFilteredCommandGroups(commandGroupName)
  local commandsWithNameOrAlias = self:fetchCommandsByNameOrAlias(filteredSearchCommandGroups, commandNameOrAlias)
  local filteredCommandsWithNameOrAlias = self:filterCommands(commandsWithNameOrAlias)

  -- Check the number of resulting commands
  local numberOfMatchingCommands = #filteredCommandsWithNameOrAlias
  if (numberOfMatchingCommands == 0) then
    if (#commandsWithNameOrAlias > 0) then
      error("No permission to use command") -- TODO
    else
      error("Command not found") -- TODO
    end
    error(UnknownCommandException(_commandNameOrAlias))
  elseif (numberOfMatchingCommands > 1) then
    error("Ambiguous command, please use <group>:<commandName> instead") -- TODO
  end

  return filteredCommandsWithNameOrAlias[1]

end


-- Private Methods

function CommandSearcher:getFilteredCommandGroups(_commandGroupName)

  local filteredCommandGroups

  if (_commandGroupName == nil) then
    -- No command group name specified, fetch and filter all available command groups

    filteredCommandGroups = {}
    for _, commandGroup in pairs(self.commandList:getCommandGroups()) do
      if (self:commandGroupMatchesFilters(commandGroup, self.filters)) then
        table.insert(filteredCommandGroups, commandGroup)
      end
    end

  else

    local targetCommandGroup = self.commandList:getCommandGroupByName(_commandGroupName)
    if (targetCommandGroup == nil) then
      error("Unknown group") -- TODO
    elseif (not self:commandGroupMatchesFilters(targetCommandGroup, self.filters)) then
      error("No permission to use commands from group " .. _commandGroupName) -- TODO
    else
      filteredCommandGroups = { targetCommandGroup }
    end

  end


  return filteredCommandGroups

end

function CommandSearcher:commandGroupMatchesFilters(_commandGroup, _filters)

  for _, filter in ipairs(_filters) do
    if (not filter:commandGroupMatches(_commandGroup)) then
      return false
    end
  end

  return true

end


function CommandSearcher:fetchCommandsByNameOrAlias(_commandGroups, _commandNameOrAlias)

  local commandsWithNameOrAlias = {}
  for _, commandGroup in pairs(_commandGroups) do

    -- Try to get the command by name
    local commandWithTargetName = commandGroup:getCommandByName(_commandNameOrAlias)
    if (commandWithTargetName) then
      table.insert(commandsWithNameOrAlias, commandWithTargetName)
    else

      -- Try to get the command by alias
      local commandWithAlias = commandGroup:getCommandByAlias(_commandNameOrAlias)
      if (commandWithAlias) then
        table.insert(commandsWithNameOrAlias, commandWithAlias)
      end

    end

  end

  return commandsWithNameOrAlias

end

function CommandSearcher:filterCommands(_commands)

  local filteredCommands = {}
  for _, command in ipairs(_commands) do
    for _, filter in ipairs(self.filters) do

      if (filter:matchesCommand(command)) then
        table.insert(filteredCommands, command)
      end

    end
  end

  return filteredCommands

end


return CommandSearcher
