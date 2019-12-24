---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require "AC-LuaServer.Core.Util.Exception.Exception"

---
-- The exception for the case that an invalid callback function config was passed to an EventCallback instance.
--
-- @type InvalidCallbackFunctionException
--
local InvalidCallbackFunctionException = Exception:extend()


-- Public Methods

---
-- Returns this Exception's message as a string.
--
-- @treturn string The Exception message as a string
--
function InvalidCallbackFunctionException:getMessage()
  return "Could not set up event callback: Invalid callback function config"
end


return InvalidCallbackFunctionException
