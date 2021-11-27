---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Provides static methods to convert strings to other types.
--
-- @type StringTypeCaster
--
local StringTypeCaster = Object:extend()


---
-- Converts a string to an integer.
--
-- @tparam string _string The string to convert
--
-- @raise Exception The exception when the string cannot be converted to a number
--
function StringTypeCaster.toInteger(_string)

  local number, errorMessage = tonumber(_string)

  if (number ~= nil) then

    local _, fractionalPart = math.modf(number)
    if (fractionalPart ~= 0) then
      errorMessage = "Malformed integer"
    end

  end

  return number, errorMessage

end


function StringTypeCaster.toFloat(_string)
  return tonumber(_string)
end


function StringTypeCaster.toBoolean(_string)

  if (_string == "true") then
    return true
  elseif (_string == "false") then
    return false
  else
    error()
  end

end


return StringTypeCaster
