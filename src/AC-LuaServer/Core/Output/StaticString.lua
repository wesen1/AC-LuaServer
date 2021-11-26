---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Stores a string id of a static string and provides methods to fetch the static string from the config file.
--
-- @type StaticString
--
local StaticString = Object:extend()


---
-- The id of the static string in the Strings.cfg file
--
-- @tfield string stringId
--
StaticString.stringId = nil


---
-- StaticString constructor.
--
-- @tparam string _stringId The id of the static string in the Strings.cfg file
--
function StaticString:new(_stringId)
  self.stringId = _stringId
end


---
-- Converts the static string object to the static string to which it points.
--
-- @treturn string The static string
--
function StaticString:__tostring()
  return self:getString()
end


-- Public Methods

---
-- Returns the static string with the static string id of this static string object.
--
-- @treturn string The static string
--
function StaticString:getString()

  local staticString = cfg.getvalue("templates/Strings", self.stringId)

  -- Discard the first and last symbol in the string (which are the '"' delimiters)
  return staticString:sub(2, -2)
end


return StaticString
