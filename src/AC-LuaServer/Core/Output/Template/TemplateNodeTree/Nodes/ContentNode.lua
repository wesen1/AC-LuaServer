---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseContentNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseContentNode"
local RowNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RowNode"

---
-- Represents the content of the text template that will be printed to the screen.
--
-- @type ContentNode
--
local ContentNode = BaseContentNode:extend()


---
-- The name of this node type
--
-- @tfield string name
--
ContentNode.name = "content"


-- Public Methods

---
-- Adds an inner text to this node.
--
-- @tparam string _text The inner text
--
-- @treturn BaseTemplateNode The template node to which the inner text was added
--
function ContentNode:addInnerText(_text)
  local rowNode = RowNode()
  self.super.addInnerNode(self, rowNode)

  return rowNode:addInnerText(_text)
end

---
-- Adds an inner node to this node.
--
-- @tparam BaseTemplateNode _node The node
--
-- @treturn BaseTemplateNode The template node to which the inner node was added
--
function ContentNode:addInnerNode(_node)

  if (_node:is(RowNode)) then
    return self.super.addInnerNode(self, _node)
  else

    local rowNode = RowNode()
    self.super.addInnerNode(self, rowNode)

    return rowNode:addInnerNode(_node)

  end

end


return ContentNode
