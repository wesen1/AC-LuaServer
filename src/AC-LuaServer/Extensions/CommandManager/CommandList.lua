---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Stores a list of all commands and provides methods to get the commands.
--
-- @type CommandList
--
local CommandList = setmetatable({}, {})


---
-- The list of commands in the format { commandName => Command }
--
-- @tfield BaseCommand[] commands
--
CommandList.commands = nil

---
-- The list of grouped commands by levels and group names
-- This table is in the format { level => { groupName => { CommandNames } } }
--
-- This table is generated once when loading the commands since the command list does not change after being loaded.
--
-- This tables purpose is to provide pre sorted command names for the CommandListTemplate (used by !cmds).
--
-- @tfield table groupedCommands
--
CommandList.groupedCommands = nil

---
-- The list of sorted command levels
-- This table is in the format { levelA, levelB, ... }
-- The table is necessary because you can't ensure the order of elements in a table,
-- therefore you have to sort the element keys and get the elements of the table by key.
--
-- This table is generated once when loading the commands since the command list does not change after being loaded.
--
-- This tables purpose is to provide pre sorted command levels for the CommandListTemplate (used by !cmds).
--
-- @tfield int[] sortedCommandLevels
--
CommandList.sortedCommandLevels = nil

---
-- The list of sorted command group names
-- This table is in the format { level => { groupNameA, groupNameB, ...} }
-- The table is necessary because you can't ensure the order of elements in a table,
-- therefore you have to sort the element keys and get the elements of the table by key.
--
-- This table is generated once when loading the commands since the command list does not change after being loaded.
--
-- This tables purpose is to provide pre sorted command group names for the CommandListTemplate (used by !cmds).
--
-- @tfield table sortedCommandGroupNames
--
CommandList.sortedCommandGroupNames = nil

---
-- The parent gema mode
--
-- @tfield GemaMode parentGemaMode
--
CommandList.parentGemaMode = nil


---
-- CommandList constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn CommandList The CommandList instance
--
function CommandList:__construct(_parentGemaMode)

  local instance = setmetatable({}, {__index = CommandList})

  instance.commands = {}
  instance.groupedCommands = {}
  instance.sortedCommandLevels = {}
  instance.sortedCommandGroupNames = {}
  instance.parentGemaMode = _parentGemaMode

  return instance

end

getmetatable(CommandList).__call = CommandList.__construct


-- Getters and setters

---
-- Returns the unsorted command list.
--
-- @treturn BaseCommand[] The unsorted command list
--
function CommandList:getCommands()
  return self.commands
end

---
-- Sets the unsorted command list.
--
-- @tparam BaseCommand[] _commands The unsorted command list
--
function CommandList:setCommands(_commands)
  self.commands = _commands
end

---
-- Returns the grouped command list.
--
-- @treturn table The grouped command list
--
function CommandList:getGroupedCommands()
  return self.groupedCommands
end

---
-- Sets the grouped command list.
--
-- @tparam table _groupedCommands The grouped command list
--
function CommandList:setGroupedCommands(_groupedCommands)
  self.groupedCommands = _groupedCommands
end

---
-- Returns the list of sorted command levels.
--
-- @treturn int[] The list of sorted command levels
--
function CommandList:getSortedCommandLevels()
  return self.sortedCommandLevels
end

---
-- Sets the list of sorted command levels.
--
-- @tparam int[] _sortedCommandLevels The list of sorted command levels
--
function CommandList:setSortedCommandLevels(_sortedCommandLevels)
  self.sortedCommandLevels = _sortedCommandLevels
end

---
-- Returns the list of sorted command group names.
--
-- @treturn table The list of sorted command group names
--
function CommandList:getSortedCommandGroupNames()
  return self.sortedCommandGroupNames
end

---
-- Sets the list of sorted command group names.
--
-- @tparam table _sortedCommandGroupNames The list of sorted command group names
--
function CommandList:setSortedCommandGroupNames(_sortedCommandGroupNames)
  self.sortedCommandGroupNanmes = _sortedCommandGroupNames
end

---
-- Returns the parent gema mode.
--
-- @treturn GemaMode The parent gema mode
--
function CommandList:getParentGemaMode()
  return self.parentGemaMode
end


-- Public Methods

---
-- Adds a command to the unsorted command list and the grouped command list.
--
-- @tparam BaseCommand _command The command
--
function CommandList:addCommand(_command)

  _command:initialize(self)

  self:addCommandToUnsortedCommandList(_command)
  self:addCommandToGroupedCommandList(_command)

end

---
-- Returns a command with the name or alias _commandName.
--
-- @tparam string _commandName The command name with leading "!"
--
-- @treturn BaseCommand|bool The command or false if no command with that name or alias exists
--
function CommandList:getCommand(_commandName)

  if (self.commands[_commandName] ~= nil) then
    return self.commands[_commandName]
  end

  -- Check aliases
  for _, command in pairs(self.commands) do
    if (command:hasAlias(_commandName)) then
      return command
    end
  end

  return false

end


-- Private Methods

---
-- Adds a command to the unsorted command list.
--
-- @tparam BaseCommand _command The command
--
function CommandList:addCommandToUnsortedCommandList(_command)

  -- Saving the command in lowercase in order to be able to correctly parse commands
  -- that contain uppercase letters (user inputted commands are converted to lowercase
  -- while parsing to make the command parsing case insensitive)
  self.commands[string.lower(_command:getName())] = _command

end

---
-- Adds a command to the grouped command list.
--
-- @tparam BaseCommand _command The command
--
function CommandList:addCommandToGroupedCommandList(_command)

  local level = _command:getRequiredLevel()
  local groupName = _command:getGroup()

  if (self.groupedCommands[level] == nil) then
    self:addLevel(level)
  end

  if (self.groupedCommands[level][groupName] == nil) then
    self:addLevelGroupName(level, groupName)
  end

  -- Saving the command in lowercase because it is saved in lowercase in the commands list too
  table.insert(self.groupedCommands[level][groupName], string.lower(_command:getName()))
  table.sort(self.groupedCommands[level][groupName])

end


---
-- Adds a new field to the grouped commands list and adds the level to the sorted levels list.
--
-- @tparam int _level The command level
--
function CommandList:addLevel(_level)

  self.groupedCommands[_level] = {}
  self.sortedCommandGroupNames[_level] = {}

  table.insert(self.sortedCommandLevels, _level)
  table.sort(self.sortedCommandLevels)

end

---
-- Adds a new field to the grouped commands list and adds the group name to the sorted group names list.
--
-- @tparam int _level The commandlevel
-- @tparam string _groupName The group name
--
function CommandList:addLevelGroupName(_level, _groupName)

  self.groupedCommands[_level][_groupName] = {}

  table.insert(self.sortedCommandGroupNames[_level], _groupName)
  table.sort(self.sortedCommandGroupNames[_level])

end


return CommandList
