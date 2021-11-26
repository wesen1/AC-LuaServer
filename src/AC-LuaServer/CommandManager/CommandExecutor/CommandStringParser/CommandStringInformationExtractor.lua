---
-- @author wesen
-- @copyright 2017-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Extracts command names and parameter values from a command string.
--
-- @type CommandStringInformationExtractor
--
local CommandStringInformationExtractor = Object:extend()


-- Public Methods

---
-- Returns whether a string is a command string.
-- This is the case if the string starts with "!" and is followed by at least one character other than
-- "!" and " ".
--
-- @tparam string _string The string to check
--
-- @treturn bool True if the string is a command string, false otherwise
--
function CommandStringInformationExtractor:isCommandSring(_string)
  return (_string:match("^![^! ]") ~= nil)
end

---
-- Extracts and returns the command name from a command string.
--
-- @tparam string _commandString The string to extract the command name from
--
-- @treturn string|nil The extracted command name
--
function CommandStringInformationExtractor:extractCommandName(_commandString)
  return _commandString:match("^!([^! ][^ ]*)")
end

---
-- Extracts the parameters and explicit options from a command string.
--
-- @tparam string _commandString The string to extract the parameters from
--
-- @treturn string[] The list of parameters
-- @treturn string[] The list of explicit options
--
function CommandStringInformationExtractor:extractParameters(_commandString)

  local parameters = {}
  local explicitOptions = {}

  local currentOptionName
  for _, parameter in _commandString:gmatch(" ([^ ]+)") do

    if (currentOptionName == nil) then

      -- Check if the parameter matches the format "--<name>"
      currentOptionName = parameter:match("%-%-(.+)")
      if (currentOptionName == nil) then
        table.insert(parameters, parameter)
      end

    else
      explicitOptions[currentOptionName] = parameter
      currentOptionName = nil
    end

  end

  return parameters, explicitOptions

end


return CommandStringInformationExtractor
