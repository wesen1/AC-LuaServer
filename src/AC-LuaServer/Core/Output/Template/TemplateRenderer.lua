---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"
local ClientOutputRenderer = require "AC-LuaServer.Core.Output.Template.Renderer.ClientOutputRenderer"
local StringRenderer = require "AC-LuaServer.Core.Output.Template.Renderer.StringRenderer"
local TemplateNodeTree = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TemplateNodeTree"

---
-- Handles rendering of Template's as texts and tables.
--
-- @type TemplateRenderer
--
local TemplateRenderer = Object:extend()


---
-- The ClientOutputRenderer
--
-- @tfield ClientOutputRenderer clientOutputRenderer
--
TemplateRenderer.clientOutputRenderer = nil

---
-- The StringRenderer
--
-- @tfield StringRenderer stringRenderer
--
TemplateRenderer.stringRenderer = nil


---
-- TemplateRenderer constructor.
--
function TemplateRenderer:new()
  self.clientOutputRenderer = ClientOutputRenderer()
  self.stringRenderer = StringRenderer()
end


-- Public Methods

---
-- Configures this TemplateRenderer.
--
-- @tparam table _configuration The configuration to apply
--
function TemplateRenderer:configure(_configuration)

  if (type(_configuration) == "table") then

    if (type(_configuration["StringRenderer"]) == "table") then
      self.stringRenderer:configure(_configuration["StringRenderer"])
    end

    if (type(_configuration["ClientOutputRenderer"]) == "table") then
      self.clientOutputRenderer:configure(_configuration["ClientOutputRenderer"])
    end

  end

end

---
-- Renders a Template as a table and returns the resulting output rows.
--
-- @tparam Template _template The template to render as a table
--
-- @treturn string[] The output rows
--
function TemplateRenderer:renderAsTable(_template)
  return self.clientOutputRenderer:renderAsClientOutputTable(
    self:getParsedTemplate(_template)
  ):getOutputRows()
end

---
-- Renders a Template as a string and returns the resulting output rows.
--
-- @tparam Template _template The template to render as a string
--
-- @treturn string[] The output rows
--
function TemplateRenderer:renderAsText(_template)
  return self.clientOutputRenderer:renderAsClientOutputString(
    self:getParsedTemplate(_template)
  ):getOutputRows()
end

---
-- Renders a Template as a string without using the ClientOutputRenderer to automatically break the
-- string into lines.
--
-- @tparam Template _template The template to render as a raw text
--
-- @treturn string The raw text
--
function TemplateRenderer:renderAsRawText(_template)
  local parsedTemplate = self:getParsedTemplate(_template)
  local contentNode = parsedTemplate:find("content")[1]

  return contentNode and contentNode:toString() or ""
end


-- Private Methods

---
-- Parses a Template and returns the resulting TemplateNodeTree's root node.
--
-- @tparam Template _template The Template to parse
--
-- @treturn RootNode The root node of the resulting TemplateNodeTree
--
function TemplateRenderer:getParsedTemplate(_template)

  -- Render the template to a string using the lua resty template engine
  local renderedTemplateString = self.stringRenderer:render(_template)

  -- Parse the tags in the template
  local tree = TemplateNodeTree()
  tree:parse(renderedTemplateString)

  return tree:getRootNode()

end


return TemplateRenderer
