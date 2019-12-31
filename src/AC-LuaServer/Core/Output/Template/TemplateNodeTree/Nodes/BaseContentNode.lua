---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseTemplateNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode"

---
-- Base class for nodes that contain output content.
--
-- @type BaseContentNode
--
local BaseContentNode = BaseTemplateNode:extend()


-- Public Methods

---
-- Generates and returns a table from this node and its inner contents.
--
-- @treturn table The table representation of this node
--
function BaseContentNode:toTable()

  local mergedContents = {}
  for innerContentType, innerContent in self:innerContentsIterator() do

    if (innerContentType == "text" and #innerContent > 0) then
      table.insert(mergedContents, innerContent)
    elseif (innerContentType == "node") then
      table.insert(mergedContents, innerContent:toTable())
    end

  end

  return mergedContents

end

---
-- Generates and returns a string from this node and its inner contents.
--
-- @treturn string The string representation of this node
--
function BaseContentNode:toString()

  local mergedContents = ""
  for innerContentType, innerContent in self:innerContentsIterator() do

    if (innerContentType == "text" and #innerContent > 0) then
      mergedContents = mergedContents .. innerContent
    elseif (innerContentType == "node") then
      mergedContents = mergedContents .. innerContent:toString()
    end

  end

  return mergedContents

end


return BaseContentNode
