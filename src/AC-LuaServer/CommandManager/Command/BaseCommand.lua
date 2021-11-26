---
-- @author wesen
-- @copyright 2017-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"
local StaticString = require "AC-LuaServer.Output.StaticString"
local TemplateException = require "AC-LuaServer.Util.TemplateException"

---
-- Stores the configuration for a single command.
--
-- @type BaseCommand
--
local BaseCommand = Object:extend()


---
-- The main command name (without the leading "!")
-- Command names must be lowercase and must not start with a "!"
--
-- @tfield string name
--
BaseCommand.name = nil

---
-- The alternative command names (without the leading "!")
-- The naming rules for the main name apply to aliases too
--
-- @tfield string[] aliases
--
BaseCommand.aliases = {}

---
-- The minimum player level that is necessary to call the command
-- The default levels are:
--   0: everyone
--   1: admin
--
-- Defaults to 0
--
-- @tfield int requiredLevel
--
BaseCommand.requiredLevel = 0

---
-- List of arguments that can/must be passed when calling the command
-- Arguments will be displayed in the order in which they were added in the constructor
--
-- @tfield CommandArgument[] arguments
--
BaseCommand.arguments = {}

---
-- A description of what the command does
-- This will be displayed when someone uses the !help command on this command
--
-- @tfield string description
--
BaseCommand.description = nil

---
-- Group to which the command belongs (Defaults to "General")
-- This will be used to group the command in the !cmds output
--
-- @tfield string group
--
BaseCommand.group = nil

---
-- The CommandList to which this Command is currently attached
--
-- @tfield CommandList parentCommandList
--
BaseCommand.parentCommandList = nil

---
-- The Output that can be used to print texts to the players consoles
--
-- @tfield Output output
--
BaseCommand.output = nil


---
-- BaseCommand constructor.
--
-- @tparam string _name The commands main name
-- @tparam int _requiredLevel The minimum player level that is necessary to execute the command
-- @tparam string _group The commands group (optional)
-- @tparam CommandArgument[] _arguments The commands arguments (optional)
-- @tparam string _description The commands description (optional)
-- @tparam string[] _aliases The commands aliases (optional)
--
function BaseCommand:new(_name, _requiredLevel, _group, _arguments, _description, _aliases)

  self.name = tostring(_name)

  if (_requiredLevel) then
    self.requiredLevel = _requiredLevel
  end

  if (_group) then
    self.group = tostring(_group)
  else
    self.group = StaticString("defaultCommandGroup"):getString()
  end

  if (_description) then
    self.description = tostring(_description)
  else
    self.description = StaticString("defaultCommandDescription"):getString()
  end

  if (type(_arguments) == "table") then
    self.arguments = _arguments
  end

  if (type(_aliases) == "table") then
    self.aliases = _aliases
  end

end


-- Getters and setters

---
-- Returns the main name.
--
-- @treturn string The main name
--
function BaseCommand:getName()
  return self.name
end

---
-- Returns the minimum player level that is necessary to execute this BaseCommand.
--
-- @treturn int The minimum player level that is necessary to execute this BaseCommand
--
function BaseCommand:getRequiredLevel()
  return self.requiredLevel
end

---
-- Returns the arguments.
--
-- @treturn CommandArgument[] The arguments
--
function BaseCommand:getArguments()
  return self.arguments
end

---
-- Returns the description.
--
-- @treturn string The description
--
function BaseCommand:getDescription()
  return self.description
end

---
-- Returns the group.
--
-- @treturn string The group
--
function BaseCommand:getGroup()
  return self.group
end


-- Public Methods

-- Attach/Detach from CommandList's

---
-- Attaches this BaseCommand to a specified CommandList.
--
-- @tparam CommandList _commandList The CommandList to attach this BaseCommand to
--
function BaseCommand:attachToCommandList(_commandList)

  if (self.parentCommandList) then
    error(TemplateException(
      "TextTemplate/ExceptionMessages/CommandHandler/CommandAlreadyAttachedToCommandList",
      { command = self }
    ))

  else
    self.parentCommandList = _commandList
    self.output = _commandList:getParentServer():getOutput()

    self:onCommandListAttached()
  end

end

---
-- Detaches this BaseCommand from a specified CommandList.
--
-- @tparam CommandList _commandList The CommandList to detach this BaseCommand from
--
function BaseCommand:detachFromCommandList(_commandList)

  if (self.parentCommandList == _commandList) then
    self.parentCommandList = nil
    self.output = nil

    self:onCommandListDetached()

  else
    error(TemplateException(
      "TextTemplate/ExceptionMessages/CommandHandler/CommandNotAttachedToCommandList",
      { command = self }
    ))
  end

end


-- Find aliases

---
-- Returns whether this BaseCommand has a specified alias.
--
-- @tparam string _alias The alias to look up without the leading "!"
--
-- @treturn bool True if the alias exists, false otherwise
--
function BaseCommand:hasAlias(_alias)

  local searchAlias = _alias:lower()
  for _, alias in ipairs(self.aliases) do
    if (alias == searchAlias) then
      return true
    end
  end

  return false

end


-- Fetch information about the arguments

---
-- Returns the list of required arguments of this BaseCommand.
--
-- @treturn CommandArgument[] The list of required arguments
--
function BaseCommand:getRequiredArguments()

  local requiredArguments = {}
  for _, argument in ipairs(self.arguments) do
    if (not argument:getIsOptional()) then
      table.insert(requiredArguments, argument)
    end
  end

  return requiredArguments

end

---
-- Returns the number of required arguments of this BaseCommand.
--
-- @treturn int The number of required arguments
--
function BaseCommand:getNumberOfRequiredArguments()
  return #self:getRequiredArguments()
end

---
-- Returns the total number of arguments of this BaseCommand.
--
-- @treturn int The total number of arguments
--
function BaseCommand:getNumberOfArguments()
  return #self.arguments
end


-- Methods that should be overridden by child classes

---
-- Method that will be called before the execute method.
-- This will only be called when this BaseCommand has arguments.
--
-- This method should check whether all input arguments are valid and throw exceptions if they are not.
--
-- @tparam mixed[] _arguments The list of arguments
--
-- @raise Error if one or more input arguments are invalid
--
function BaseCommand:validateInputArguments(_arguments)
end

---
-- Method that will be called after the validateInputArguments method and before the execute method.
-- This will only be called when this BaseCommand has arguments.
--
-- This method should adjust the input arguments as necessary for the execute method.
-- This can be useful if multiple notations are allowed for some arguments but only one should be used
-- in the execute method.
--
-- @tparam mixed[] _arguments The list of arguments
--
-- @treturn mixed[] The updated list of arguments
--
function BaseCommand:adjustInputArguments(_arguments)
  return _arguments
end

---
-- Method that will be called when someone executes this BaseCommand.
--
-- @tparam Player _player The player who called the command
-- @tparam mixed[] _arguments The list of arguments which were passed by the player
--
function BaseCommand:execute(_player, _arguments)
end


-- Protected Methods

---
-- Event handler that is called after this BaseCommand was attached to a CommandList.
--
function BaseCommand:onCommandListAttached()
end

---
-- Event handler that is called after this BaseCommand was detached from its current CommandList.
--
function BaseCommand:onCommandListDetached()
end


return BaseCommand
