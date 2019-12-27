---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Error exception for the error() and pcall() functions.
-- Classes that extend this class must implement a getMessage() method.
--
-- @type Exception
--
local Exception = Object:extend()


-- Getters and Setters

---
-- Returns the message.
--
-- @treturn string The message
--
function Exception:getMessage()
end


return Exception
