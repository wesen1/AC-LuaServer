---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TemplateException = require "AC-LuaServer.Core.Util.Exception.TemplateException"

---
-- Exception for the case that a value was passed to a parameter that did not match
-- the parameter's required value type.
--
-- @type InvalidParameterValueException
--
local InvalidParameterValueException = TemplateException:extend()


---
-- InvalidParameterValueException constructor.
--
-- @tparam CommandParameter _parameter The parameter that raised this Exception
-- @tparam string _value The value that caused this Exception
--
function InvalidParameterValueException:new(_parameter, _value)
  TemplateException.new(
    self,
    "CommandManager/Command/Parameter/Exception/InvalidValueType",
    {
      parameter = _parameter,
      value = _value
    }
  )
end


return InvalidParameterValueException
