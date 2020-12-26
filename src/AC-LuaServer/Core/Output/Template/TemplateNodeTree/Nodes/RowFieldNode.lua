---
-- @author wesen
-- @copyright 2018-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseContentNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseContentNode"

---
-- Represents a row field.
--
-- @type RowFieldNode
--
local RowFieldNode = BaseContentNode:extend()


---
-- The name of this node type
--
-- @tfield string name
--
RowFieldNode.name = "row-field"

---
-- The list of tag names that close a node of this type when they occur during the tree parsing
--
-- @tfield string[] closedByTagNames
--
RowFieldNode.closedByTagNames = { "row", "custom-field", "end-custom-field", "row-field" }


---
-- Generates and returns a table from this node and its inner contents.
--
-- @treturn string The table representation of this node
--
function RowFieldNode:toTable()
  return table.concat(self.innerTexts)
end


return RowFieldNode
