---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require "AC-LuaServer.Core.Util.Exception.Exception"

---
-- Exception for the case that a global EventCallback function could not be found.
--
-- @type GlobalCallbackFunctionNotFoundException
--
local GlobalCallbackFunctionNotFoundException = Exception:extend()


---
-- The name of the global EventCallback function that caused this Exception
--
-- @tfield string functionName
--
GlobalCallbackFunctionNotFoundException.functionName = nil


---
-- GlobalCallbackFunctionNotFoundException constructor.
--
-- @tparam string _functionName The name of the global EventCallback function that caused this Exception
--
function GlobalCallbackFunctionNotFoundException:new(_functionName)
  self.functionName = _functionName
end


-- Getters and Setters

---
-- Returns the name of the global EventCallback function that caused this Exception.
--
-- @treturn string The name of the global EventCallback function
--
function GlobalCallbackFunctionNotFoundException:getFunctionName()
  return self.functionName
end


-- Public Methods

---
-- Returns this Exception's message as a string.
--
-- @treturn string The Exception message as a string
--
function GlobalCallbackFunctionNotFoundException:getMessage()
  return string.format(
    "Could not set up event callback: Global function \"%s\" not found",
    self.functionName
  )
end


return GlobalCallbackFunctionNotFoundException
