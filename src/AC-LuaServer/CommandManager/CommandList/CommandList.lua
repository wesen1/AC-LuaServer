---
-- @author wesen
-- @copyright 2017-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Stores a list of commands and provides methods to get the commands.
--
-- @type CommandList
--
local CommandList = Object:extend()


---
-- The list of command groups in the format { groupName => CommandGroup }
--
-- @tfield CommandGroup[] commandGroups
--
CommandList.commandGroups = nil


---
-- CommandList constructor.
--
function CommandList:new()
  self.commandGroups = {}
end


-- Getters and Setters

---
-- Returns the list of commands.
--
-- @treturn CommandGroup[] The list of commands
--
function CommandList:getCommandGroups()
  return self.commandGroups
end


-- Public Methods

---
-- Adds a Command to a already existing CommandGroup.
--
-- @tparam BaseCommand _command The command to add
--
-- @emits The "onCommandAdded" event after the command was added
--
function CommandList:addCommand(_command, _groupName)

  if (self.commandGroups[_groupName] == nil) then
    error("Could not add Command: Command group not exists")
  else
    self.commandGroups[_groupName]:addCommand(_command)
  end

end

---
-- Removes a Command from this CommandStore.
--
-- @tparam BaseCommand _command The command to remove
--
-- @emits The "onCommandRemoved" event after the command was removed
--
function CommandList:removeCommand(_command, _groupName)

  if (self.commandGroups[_groupName] == nil) then
    error("Could not remove Command: Command group not exists")
  else
    self.commandGroups[_groupName]:removeCommand(_command)
  end

end

function CommandList:addCommandGroup(_commandGroup)

  local groupName = _commandGroup:getName()
  if (self.commandGroups[groupName] == nil) then
    self.commandGroups[groupName] = _commandGroup
  else
    error("Could not add CommandGroup: There already is a CommandGroup with that name")
  end

end

function CommandList:removeCommandGroup(_commandGroup)

  local groupName = _commandGroup:getIdentifier()
  if (self.commandGroups[groupName] == nil) then
    self.commandGroups[groupName] = _commandGroup
  else
    error("Could not add CommandGroup: There already is a CommandGroup with that name")
  end

end

function CommandList:clear()
  self.commandGroups = {}
end


function CommandList:getCommandGroupByName(_commandGroupName)
  return self.commandGroups[_commandGroupName]
end


return CommandList
