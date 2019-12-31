---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Stores information about a template tag inside a string.
--
-- @type TemplateTag
--
local TemplateTag = Object:extend()


---
-- The name of the tag
--
-- @tfield string name
--
TemplateTag.name = nil

---
-- The start position of the tag inside the target string
--
-- @tfield int startPosition
--
TemplateTag.startPosition = nil

---
-- The end position of the tag inside the target string
--
-- @tfield int endPosition
--
TemplateTag.endPosition = nil


---
-- TemplateTag constructor.
--
-- @tparam string _name The tag name
-- @tparam int _startPosition The start position inside the target string
-- @tparam int _endPosition The end position inside the target string
--
function TemplateTag:new(_name, _startPosition, _endPosition)
  self.name = _name
  self.startPosition = _startPosition
  self.endPosition = _endPosition
end


-- Getters and Setters

---
-- Returns the name of this tag.
--
-- @treturn string The tag name
--
function TemplateTag:getName()
  return self.name
end

---
-- Returns the start position.
--
-- @treturn int The start position
--
function TemplateTag:getStartPosition()
  return self.startPosition
end

---
-- Returns the end position.
--
-- @treturn int The end position
--
function TemplateTag:getEndPosition()
  return self.endPosition
end


return TemplateTag
