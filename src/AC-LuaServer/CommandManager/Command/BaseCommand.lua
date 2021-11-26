---
-- @author wesen
-- @copyright 2017-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"
local TableUtils = require "AC-LuaServer.Core.Util.TableUtils"

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
BaseCommand.aliases = nil

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
BaseCommand.requiredLevel = nil

---
-- The list of required parameters that must be passed when calling the command
-- Arguments will be displayed in the order in which they were added to the command
--
-- @tfield CommandArgument[] arguments
--
BaseCommand.arguments = nil

---
-- The list of optional parameters that can be passed when calling the command
-- Options will be displayed after the arguments and will be in the order in which they were
-- added to the command
--
-- @tfield CommandOption[] options
--
BaseCommand.options = nil

---
-- A description of what the command does
-- This will be displayed when someone uses the !help command on this command
--
-- @tfield string description
--
BaseCommand.description = nil


---
-- BaseCommand constructor.
--
-- @tparam string _name The Command's main name
--
function BaseCommand:new(_name)

  if (_name:match(":") ~= nil) then
    error(BadNameException(_name, "Contains \":\""))
  end
  self.name = tostring(_name)
  self.aliases = {}
  self.requiredLevel = 0
  self.arguments = {}
  self.options = {}
  self.description = "No description"

end


-- Getters and setters

---
-- Returns the Command's main name.
--
-- @treturn string The Command's main name
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
-- Returns the options.
--
-- @treturn CommandOption[] The options
--
function BaseCommand:getOptions()
  return self.options
end

---
-- Returns the description.
--
-- @treturn string The description
--
function BaseCommand:getDescription()
  return self.description
end


-- Public Methods

---
-- Returns whether this BaseCommand has a specified alias.
--
-- @tparam string _alias The alias to look up without the leading "!"
--
-- @treturn bool True if the alias exists, false otherwise
--
function BaseCommand:hasAlias(_alias)
  return TableUtils.tableHasValue(self.aliases, _alias:lower())
end

---
-- Returns the total number of parameters of this BaseCommand.
--
-- @treturn int The total number of parameters
--
function BaseCommand:getNumberOfParameters()
  return #self.arguments + #self.options
end


-- Methods that should be overridden by child classes

---
-- Method that will be called before the execute method.
-- This will only be called when this BaseCommand has parameters.
--
-- This method should check whether all input arguments are valid and throw exceptions if they are not.
--
-- @tparam mixed[] _parameters The list of type casted parameters
--
-- @raise Error if one or more parameter values are invalid
--
function BaseCommand:validateInputParameters(_arguments, _options)
end

---
-- Method that will be called after the validateInputParameters method and before the execute method.
-- This will only be called when this BaseCommand has arguments.
--
-- This method should adjust the input parameters as necessary for the execute method.
-- This can be useful if multiple notations are allowed for some arguments but only one should be used
-- in the execute method.
--
-- @tparam mixed[] _parameters The list of type casted parameters
--
-- @treturn mixed[] The updated list of type casted parameters
--
function BaseCommand:adjustInputParameters(_arguments, _options)
  return _arguments, _options
end

---
-- Method that will be called when someone executes this BaseCommand.
--
-- @tparam Player _player The player who called the command
-- @tparam mixed[] _parameters The list of parameters which were passed by the player
--
function BaseCommand:execute(_player, _arguments, _options)
end


-- Protected Methods

---
-- Adds an alias to this BaseCommand.
--
-- @tparam string _alias The alias to add
--
function BaseCommand:addAlias(_alias)
  table.insert(self.aliases, tostring(_alias))
end

---
-- Sets the minimum player level that is necessary to execute this Command.
--
-- @tparam int _requiredLevel The required player level
--
function BaseCommand:setRequiredLevel(_requiredLevel)
  self.requiredLevel = tonumber(_requiredLevel)
end

---
-- Adds an argument to this Command.
--
-- @tparam CommandArgument _argument The argument to add
--
function BaseCommand:addArgument(_argument)
  table.insert(self.arguments, _argument)
end

---
-- Adds an option to this Command.
--
-- @tparam CommandOption _option The option to add
--
function BaseCommand:addOption(_option)
  table.insert(self.options, _option)
end

---
-- Sets the description.
--
-- @tparam string _description The description
--
function BaseCommand:setDescription(_description)
  self.description = tostring(_description)
end


return BaseCommand
