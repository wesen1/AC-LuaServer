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

  local number = StringTypeCaster.toNumber(_string)

  local _, fractionalPart = math.modf(number)
  if (fractionalPart == 0) then
    return number
  else
    error()
  end

end


function StringTypeCaster.toFloat(_string)
  return StringTypeCaster.toNumber(_string)
end

function StringTypeCaster.toNumber(_string)

  local number = tonumber(_string)
  if (number == nil) then
    error()
  else
    return number
  end

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
