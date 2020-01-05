---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ContentNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ContentNode"

---
-- Represents a custom field.
-- A custom field is a field that contains a sub table
--
-- @type CustomFieldNode
--
local CustomFieldNode = ContentNode:extend()


---
-- The name of this node type
--
-- @tfield string name
--
CustomFieldNode.name = "custom-field"

---
-- The list of tag names that open a node of this type when they occur during the tree parsing
--
-- @tfield string[] openedByTagNames
--
CustomFieldNode.openedByTagNames = { "custom-field" }

---
-- The list of tag names that close a node of this type when they occur during the tree parsing
--
-- @tfield string[] closedByTagNames
--
CustomFieldNode.closedByTagNames = { "end-custom-field" }


return CustomFieldNode
