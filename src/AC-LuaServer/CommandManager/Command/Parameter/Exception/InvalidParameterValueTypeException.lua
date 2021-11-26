---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require "AC-LuaServer.Core.Util.Exception.Exception"

---
-- Exception for the case that someone tried to set a invalid parameter value type.
--
-- @type InvalidParameterValueTypeException
--
local InvalidParameterValueTypeException = Exception:extend()


---
-- The name of the CommandParameter that raised this Exception
--
-- @tfield string parameterName
--
InvalidParameterValueTypeException.parameterName = nil

---
-- The value type name that caused this Exception
--
-- @tfield string valueTypeName
--
InvalidParameterValueTypeException.valueTypeName = nil


---
-- InvalidParameterValueTypeException constructor.
--
-- @tparam string _parameterName The name of the CommandParameter that raised this Exception
-- @tparam string _valueTypeName The value type name that caused this Exception
--
function InvalidParameterValueTypeException:new(_parameterName, _valueTypeName)
  self.parameterName = _parameterName
  self.valueTypeName = _valueTypeName
end


-- Public Methods

---
-- Returns this Exception's message as a string.
--
-- @treturn string The Exception message as a string
--
function InvalidParameterValueTypeException:getMessage()
  return string.format(
    "Invalid parameter type \"%s\" set for parameter \"%s\"",
    self.parameterName,
    self.valueTypeName
  )
end


return InvalidParameterValueTypeException
