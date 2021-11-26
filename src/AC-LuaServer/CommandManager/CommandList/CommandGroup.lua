---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"


local CommandGroup = Object:extend()


CommandGroup.name = nil

---
-- The list of commands in the format { commandName => Command }
--
-- @tfield BaseCommand[] commands
--
CommandGroup.commands = nil

---
-- If true this CommandGroup is only visible to CommandUser's that are explicitly allowed to see it
-- If false it will be visible to all CommandUser's
--
-- @tfield bool hasLimitedVisibility
--
CommandGroup.hasLimitedVisibility = nil

---
-- If true this CommandGroup is marked as existing for a limited timespan
-- If false this CommandGroup will be considered existing as long as the extension that added it is enabled
--
-- Temporary CommandGroup's will only be listed in the !help command if they are visible to the CommandUser
--
CommandGroup.isTemporary = nil


function CommandGroup:new(_name, _hasLimitedVisibility, _isTemporary)
  self.name = _name
  self.commands = {}
  self.hasLimitedVisibility = _hasLimitedVisibility and true or false
  self.isTemporary = _isTemporary and true or false
end


function CommandGroup:getName()
  return self.name
end

function CommandGroup:getCommands()
  return self.commands
end

function CommandGroup:getHasLimitedVisibility()
  return self.hasLimitedVisibility
end

function CommandGroup:getIsTemporary()
  return self.isTemporary
end


function CommandGroup:addCommand(_command)

  local commandIndex = _command:getName():lower()

  if (self.commands[commandIndex] == nil) then
    self.commands[commandIndex] = _command
  else
    error(CommandAlreadyExistsException(_command, self.commands[commandIndex], self))
  end

end

function CommandGroup:removeCommand(_command)

  local commandIndex = _command:getName():lower()

  if (self.commands[commandIndex] == nil) then
    error(CommandNotExistsException(_command, self))
  else
    self.commands[commandIndex] = nil
  end

end

function CommandGroup:getCommandByName(_commandName)
  return self.commands[_commandName:lower()]
end

function CommandGroup:getCommandByAlias(_commandAlias)

  for _, command in pairs(self.commands) do
    if (command:hasAlias(_commandAlias)) then
      return command
    end
  end

end


return CommandGroup
