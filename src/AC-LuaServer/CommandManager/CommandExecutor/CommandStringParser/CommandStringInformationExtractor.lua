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
-- Extracts the parameters and explicit options from a command string.
-- Parameter values may contain multiple words but have to be enclosed in "", '' or [] in that case.
-- Delimiter strings can be escaped via backslashes.
--
-- @tparam string _commandString The string to extract the parameters from
--
-- @treturn string[] The list of parameters
-- @treturn string[] The list of explicit options
--
function CommandStringInformationExtractor:extractParameters(_commandString)

  local parameters = {}
  local explicitOptions = {}

  -- TODO: Add support for "multi word parameter" (delimiters = "", '' or [] <- cube style)
  local currentOptionName, currentOptionNameEndPosition
  local nextParameterStartDelimiterPosition, nextParameterEndDelimiterPosition
  local nextParameterStartPosition, nextParameterEndPosition, nextParameterValue

  -- Find the first whitespace after the command name
  local stringOffset = _commandString:find("[^ ] ")
  if (stringOffset ~= nil) then
    -- There is more text after the command name, parse it

    repeat

      -- Find the next explicit option name
      _, currentOptionNameEndPosition, currentOptionName = _commandString:find("^ *%-%-([^ ]+)", stringOffset)
      if (currentOptionNameEndPosition ~= nil) then
        stringOffset = currentOptionNameEndPosition + 1
      end

      -- Find the next parameter value
      nextParameterStartDelimiterPosition, nextParameterEndDelimiterPosition = self:findClosestParameterDelimiterPositions(_commandString, stringOffset)

      if (nextParameterStartDelimiterPosition == nil) then
        nextParameterValue = nil
      else

        nextParameterStartPosition = nextParameterStartDelimiterPosition + 1
        if (nextParameterEndDelimiterPosition ~= nil) then
          nextParameterEndPosition = nextParameterEndDelimiterPosition - 1
          stringOffset = nextParameterEndDelimiterPosition + 1
        end

        nextParameterValue = _commandString:sub(nextParameterStartPosition, nextParameterEndPosition)
      end

      -- Save the next parameter value
      if (nextParameterValue) then

        if (currentOptionName) then
          explicitOptions[currentOptionName] = nextParameterValue
        else
          table.insert(parameters, nextParameterValue)
        end

      end


    until (nextParameterEndDelimiterPosition == nil)

  end



  --[[
  for parameter in _commandString:gmatch(" ([^ ]+)") do

    if (currentParameterEndDelimiter) then

      if (parameter:sub(-1, 1) == currentParameterEndDelimiter) then
        currentParameterEndDelimiter = nil
      end

    end

    if (currentOptionName == nil) then

      -- Check if the parameter matches the format "--<name>"
      currentOptionName = parameter:match("%-%-([^ ]+)")
      if (currentOptionName == nil) then


        table.insert(parameters, parameter)
      end

    else
      explicitOptions[currentOptionName] = parameter
      currentOptionName = nil
    end

  end
  --]]

  return parameters, explicitOptions

end

function CommandStringInformationExtractor:findClosestParameterDelimiterPositions(_commandString, _stringOffset)

  local closestParameterDelimiterType, closestParameterStartDelimiterPosition, closestParameterEndDelimiterPosition

  local parameterStartDelimiterPosition
  for _, parameterDelimiterType in ipairs(self.parameterDelimiterTypes) do

    _, parameterStartDelimiterPosition = _commandString:find("^[^\\]-" .. parameterDelimiterType["start"], _stringOffset)
    if (parameterStartDelimiterPosition ~= nil and
        (closestParameterStartDelimiterPosition == nil or parameterStartDelimiterPosition < closestParameterStartDelimiterPosition)) then
      closestParameterDelimiterType = parameterDelimiterType
      closestParameterStartDelimiterPosition = parameterStartDelimiterPosition
    end

  end

  if (closestParameterStartDelimiterPosition ~= nil) then
    closestParameterEndDelimiterPosition = _commandString:find("[^\\]" .. closestParameterDelimiterType["end"], closestParameterStartDelimiterPosition + 1)

    if (closestParameterEndDelimiterPosition ~= nil) then
      closestParameterEndDelimiterPosition = closestParameterEndDelimiterPosition + 1
    end

  end

  return closestParameterStartDelimiterPosition, closestParameterEndDelimiterPosition

end


return CommandStringInformationExtractor
