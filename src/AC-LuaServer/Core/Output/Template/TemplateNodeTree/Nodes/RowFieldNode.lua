---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
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
-- RowFieldNode constructor.
--
function RowFieldNode:new()
  self.super.new(self, "row-field", {}, { "row", "custom-field", "custom-field-end", "row-field"})
end


return RowFieldNode
