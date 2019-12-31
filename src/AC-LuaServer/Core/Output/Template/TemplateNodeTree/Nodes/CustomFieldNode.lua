---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseContentNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseContentNode"
local ContentNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ContentNode"

---
-- Represents a custom field.
-- A custom field is a field that contains a sub table
--
-- @type CustomFieldNode
--
local CustomFieldNode = ContentNode:extend()


---
-- CustomFieldNode constructor.
--
function CustomFieldNode:new()
  BaseContentNode.new(self, "custom-field", { "custom-field" }, { "end-custom-field" })
end


return CustomFieldNode
