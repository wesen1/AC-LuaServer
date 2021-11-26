---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require("classic")

---
-- Provides a pre sorted and grouped list of commands for the "CmdsCommandList" Template.
--
-- @type SortedCommandList
--
local SortedCommandList = Object:extend()


---
-- The list of grouped commands by levels and group names
-- This list is in the format { [level] = { [groupName] = { command, ... }, ... }, ... }
--
-- @tfield table groupedCommands
--
SortedCommandList.groupedCommands = nil

---
-- The list of sorted command levels
-- This list is in the format { levelA, levelB, ... }
--
-- @tfield int[] sortedCommandLevels
--
SortedCommandList.sortedCommandLevels = nil

---
-- The list of sorted command group names
-- This list is in the format { [level] = { groupNameA, groupNameB, ...}, ... }
--
-- @tfield table sortedCommandGroupNames
--
SortedCommandList.sortedCommandGroupNames = nil


---
-- SortedCommandList constructor.
--
function SortedCommandList:new()
  self.groupedCommands = {}
  self.sortedCommandLevels = {}
  self.sortedCommandGroupNames = {}
end


-- Public Methods

---
-- Parses a list of commands into this SortedCommandList.
--
-- @tparam BaseCommand[] _commands The commands
--
function SortedCommandList:parse(_commands)
  for _, command in ipairs(_commands) do
    self:addCommand(_command)
  end

  self:sort()
end

---
-- Returns a function that can be used to iterate over the group names.
-- The function will return the level and the group name per iteration.
--
-- @treturn function The iterator function
--
function SortedCommandList:groupNamesIterator()

  -- Counters
  local levelNumber = 1
  local groupNumber = 1

  -- Counter limits
  local numberOfLevels = #self.sortedCommandLevels

  return function()

    if (levelNumber <= numberOfLevels) then

      -- Fetch the level
      local level = self.sortedCommandLevels[levelNumber]

      -- Fetch the group name
      local groupNames = self.sortedCommandGroupNames[level]
      local groupName = groupNames[groupNumber]


      -- Increase the counters
      if (groupNumber <= numberOfGroupNames) then
        groupNumber = groupNumber + 1
      else
        levelNumber = levelNumber + 1
        groupNumber = 1
      end

    end

  end

end

---
-- Returns a iterator function for the commands of a group with a specific level.
--
-- @tparam int _level The command level
-- @tparam string _groupName The group name
--
-- @treturn function The iterator function
--
function SortedCommandList:groupCommandsIterator(_level, _groupName)

  local commands = self.groupedCommands[_level][_groupName]
  if (commands) then
    return ipairs(commands)
  else
    return function() end
  end

  --[[
  local commandNumber = 1
  return function()

    if (commandNames) then
      if (commandNumber <= #commandNames) then

        local commandName = commandNames[commandNumber]
        commandNumber = commandNumber + 1

        return commandName

      end
    end
  --]]
end


-- Private Methods

---
-- Adds a command's name to the grouped commands list.
--
-- @tparam BaseCommand _command The command
--
function SortedCommandList:addCommand(_command)

  local level = _command:getRequiredLevel()
  local groupName = _command:getGroup()

  local isNewLevel = (self.groupedCommands[level] == nil)
  local isNewGroupName = (isNewLevel or self.groupedCommands[level][groupName] == nil)

  -- Add the command level if required
  if (isNewLevel) then
    self.groupedCommands[level] = {}
    self.sortedCommandGroupNames[level] = {}
    table.insert(self.sortedCommandLevels, level)
  end

  -- Add the command group name if required
  if (isNewGroupName) then
    self.groupedCommands[level][groupName] = {}
    table.insert(self.sortedCommandGroupNames[level], groupName)
  end

  -- Add the command name to the grouped commands list
  table.insert(self.groupedCommands[level][groupName], _command)

end

---
-- Sorts the grouped commands, command group names and command levels lists.
--
function SortedCommandList:sort()

  -- Sort the command names
  for _, levelGroupedCommands in pairs(self.groupedCommands) do
    for _, commands in pairs(levelGroupedCommands) do

      -- Sort the commands by command names
      table.sort(
        commands,
        function(_commandA, _commandB)
          return (_commandA:getName():lower() < _commandB:getName():lower())
        end
      )

    end
  end

  -- Sort the command group names
  for _, groupNames in pairs(self.sortedCommandGroupNames) do
    table.sort(groupNames)
  end

  -- Sort the command levels
  table.sort(self.sortedCommandLevels)

end


return SortedCommandList
