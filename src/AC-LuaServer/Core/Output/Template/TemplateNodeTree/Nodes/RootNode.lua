---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseTemplateNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode"
local ConfigNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ConfigNode"
local ContentNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ContentNode"

---
-- Represents the root of a TemplateNodeTree.
--
-- @type RootNode
--
local RootNode = BaseTemplateNode:extend()


---
-- RootNode constructor.
--
function RootNode:new()
  self.super.new(self, "root")
end


-- Public Methods

---
-- Adds an inner text to this node.
--
-- @tparam string _text The inner text
--
-- @treturn BaseTemplateNode The template node to which the inner text was added
--
function RootNode:addInnerText(_text)
  local contentNode = ContentNode()
  self.super.addInnerNode(self, contentNode)

  return contentNode:addInnerText(_text)
end

---
-- Adds an inner node to this node.
--
-- @tparam BaseTemplateNode _node The node
--
-- @treturn BaseTemplateNode The template node to which the inner node was added
--
function RootNode:addInnerNode(_node)

  if (_node:is(ConfigNode) or _node:is(ContentNode)) then
    return self.super.addInnerNode(self, _node)
  else

    local contentNode = ContentNode()
    self.super.addInnerNode(self, contentNode)

    return contentNode:addInnerNode(_node)
  end

end


return RootNode
