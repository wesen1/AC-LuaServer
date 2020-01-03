---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Represents a template and the values to fill the template with.
--
-- @type Template
--
local Template = Object:extend()


---
-- The path to the template file
-- This must be relative from the template base folder
--
-- @tfield string templatePath
--
Template.templatePath = nil

---
-- The template values that will be used to fill the template
-- This table may be multidimensional and may contain objects.
--
-- @tfield mixed[] templateValues
--
Template.templateValues = nil


---
-- Template constructor.
--
-- @tparam string _templatePath The path to the template file
-- @tparam mixed[] _templateValues The template values
--
function Template:new(_templatePath, _templateValues)

  self.templatePath = _templatePath

  if (type(_templateValues) == "table") then
    self.templateValues = _templateValues
  else
    self.templateValues = {}
  end

end


-- Getters and Setters

---
-- Returns the template path.
--
-- @treturn string The template path
--
function Template:getTemplatePath()
  return self.templatePath
end

---
-- Returns the template values.
--
-- @treturn mixed[] The template values
--
function Template:getTemplateValues()
  return self.templateValues
end


return Template
