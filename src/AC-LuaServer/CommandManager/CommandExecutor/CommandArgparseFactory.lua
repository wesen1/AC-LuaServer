---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

local ArgparseFactory = Object:extend()


ArgparseFactory.argparseInstances = nil

function ArgparseFactory:new()
  self.argparseInstances = {}
end



---
-- Generates and returns a argparse instance for a command.
--
-- @tparam BaseCommand _command The command to generate a argparse instance for
--
-- @treturn argparse The generated argparse instance
--
function ArgparseFactory:getArgparseInstanceForCommand(_command)

  local commandIdentifier = _command:getGroup():getName() .. ":" .. _command:getName()
  if (not self.argparseInstances[commandIdentifier]) then
    self.argparseInstances[commandIdentifier] = self:createArgparseInstanceFor(_command)
  end

  return self.argparseInstances[commandIdentifier]

end

function ArgparseFactory:createArgparseInstanceForCommand(_command)

  -- Disable the --help option because there is a !help command by default to show help texts
  local parser = argparse():name(_command:getName())
                           :description(_command:getDescription())
                           :add_help(false)

  -- Add the arguments to the parser
  local argparseArgument
  for _, commandArgument in ipairs(_command:getArguments()) do

    argparseArgument = parser:argument(commandArgument:getName())
                             :description(commandArgument:getDescription())
                             :convert(commandArgument:getValueConverter())

    if (commandArgument:getDefaultValue() ~= nil) then
      argparseArgument:default(commandArgument:getDefaultValue())
    end

    if (commandArgument:getNumberOfConsumedArguments() ~= nil) then
      argparseArgument:args(commandArgument:getNumberOfConsumedArguments())
    end

    if (commandArgument:getAllowedValues() ~= nil) then
      argparseArgument:choices(commandArgument:getAllowedValues())
    end

  end

  -- Add the options to the parser
  local argparseOption
  for _, commandOption in ipairs(_command:getOptions()) do

    optionNameConfiguration = "-" .. commandOption:getShortName() .. " --" .. commandOption:getName()

    if (commandOption:getType() == "boolean") then
      argparseOption = parser:flag(optionNameConfiguration)

    else

      argparseOption = parser:commandOption(optionNameConfiguration)
                             :description(commandOption:getDescription())
                             :convert(commandOption:getValueConverter())

      if (commandOption:getNumberOfConsumedArguments()) then
        argparseOption:args(commandOption:getNumberOfConsumedArguments())
      end

      if (commandOption:getAllowedValues() ~= nil) then
        argparseOption:choices(commandOption:getAllowedValues())
      end

    end


    if (commandOption:getNumberOfAllowedInvocations()) then
      argparseOption:count(commandOption:getNumberOfAllowedInvocations())
    end

  end


  -- TODO: mutex

  return parser

end


return ArgparseFactory
