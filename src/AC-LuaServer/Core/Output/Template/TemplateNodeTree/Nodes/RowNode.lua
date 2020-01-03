---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseContentNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseContentNode"
local RowFieldNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RowFieldNode"

---
-- Represents a row.
--
-- @type RowNode
--
local RowNode = BaseContentNode:extend()


---
-- RowNode constructor.
--
function RowNode:new()
  self.super.new(self, "row", { "row" }, { "row", "end-custom-field" })
end


-- Public Methods

---
-- Adds an inner text to this node.
--
-- @tparam string _text The inner text
--
-- @treturn BaseTemplateNode The template node to which the inner text was added
--
function RowNode:addInnerText(_text)
  local rowFieldNode = RowFieldNode()
  self.super.addInnerNode(self, rowFieldNode)

  return rowFieldNode:addInnerText(_text)
end


return RowNode
