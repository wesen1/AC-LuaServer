---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"
local TableUtils = require "AC-LuaServer.Core.Util.TableUtils"

---
-- Represents a node in a TemplateNodeTree.
--
-- @type BaseTemplateNode
--
local BaseTemplateNode = Object:extend()


---
-- The parent node
-- May be nil if this node is the root node
--
-- @tfield BaseTemplateNode parentNode
--
BaseTemplateNode.parentNode = nil

---
-- Stores the strings inside this node that are not inside sub nodes
--
-- @tfield string[] innerTexts
--
BaseTemplateNode.innerTexts = nil

---
-- Stores the child nodes of this node
--
-- @tfield BaseTemplateNode[] innerNodes
--
BaseTemplateNode.innerNodes = nil

---
-- Stores the order in which inner texts and nodes were added
-- The values inside this list are either "text" or "node"
--
-- @tfield string[] innerContents
--
BaseTemplateNode.innerContents = nil


---
-- The name of this node type
--
-- @tfield string name
--
BaseTemplateNode.name = nil

---
-- The list of tag names that open a node of this type when they occur during the tree parsing
--
-- @tfield string[] openedByTagNames
--
BaseTemplateNode.openedByTagNames = {}

---
-- The list of tag names that close a node of this type when they occur during the tree parsing
--
-- @tfield string[] closedByTagNames
--
BaseTemplateNode.closedByTagNames = {}


---
-- BaseTemplateNode constructor.
--
-- @tparam string _name The name of this node type
--
function BaseTemplateNode:new(_name)
  self.name = _name

  self.innerTexts = {}
  self.innerNodes = {}
  self.innerContents = {}
end


-- Getters and Setters

---
-- Returns the name of this node type.
--
-- @treturn string The name
--
function BaseTemplateNode:getName()
  return self.name
end

---
-- Returns the parent node.
--
-- @treturn BaseTemplateNode The parent node
--
function BaseTemplateNode:getParentNode()
  return self.parentNode
end

---
-- Sets the parent node.
--
-- @tparam BaseTemplateNode _parentNode The parent node
--
function BaseTemplateNode:setParentNode(_parentNode)
  self.parentNode = _parentNode
end


-- Public Methods

---
-- Adds an inner text to this node.
--
-- @tparam string _text The inner text
--
-- @treturn BaseTemplateNode The template node to which the inner text was added
--
function BaseTemplateNode:addInnerText(_text)
  table.insert(self.innerTexts, _text)
  table.insert(self.innerContents, "text")

  return self
end

---
-- Adds an inner node to this node.
--
-- @tparam BaseTemplateNode _node The node
--
-- @treturn BaseTemplateNode The template node to which the inner node was added
--
function BaseTemplateNode:addInnerNode(_node)

  _node:setParentNode(self)
  table.insert(self.innerNodes, _node)
  table.insert(self.innerContents, "node")

  return self

end

---
-- Returns whether this node is closed by a specific tag.
--
-- @tparam TemplateTag _tag The tag
--
-- @treturn bool True if this node is closed by the tag, false otherwise
--
function BaseTemplateNode:isClosedByTag(_tag)
  return (TableUtils.tableHasValue(self.closedByTagNames, _tag:getName()))
end

---
-- Returns whether this node type is opened by a specific tag.
--
-- @tparam TemplateTag _tag The tag
--
-- @treturn bool True if this node is opened by the tag, false otherwise
--
function BaseTemplateNode:isOpenedByTag(_tag)
  return (TableUtils.tableHasValue(self.openedByTagNames, _tag:getName()))
end

---
-- Returns a list of inner nodes with a specific name.
--
-- @tparam string _nodeName The node name
--
-- @treturn BaseTemplateNode[] The list of inner nodes with that name
--
function BaseTemplateNode:find(_nodeName)

  local matchingNodes = {}
  for _, innerNode in ipairs(self.innerNodes) do
    if (innerNode:getName() == _nodeName) then
      table.insert(matchingNodes, innerNode)
    end
  end

  return matchingNodes

end


---
-- Generates and returns a table from this node and its inner contents.
--
-- @treturn table The table representation of this node
--
function BaseTemplateNode:toTable()
  return {}
end

---
-- Generates and returns a string from this node and its inner contents.
--
-- @treturn string The string representation of this node
--
function BaseTemplateNode:toString()
  return ""
end


-- Protected Methods

---
-- Generates and returns a function that iterates over all inner contents and can be used in a
-- "for line in <function>" expression.
--
-- @treturn function The iterator function
--
function BaseTemplateNode:innerContentsIterator()

  local numberOfInnerContents = #self.innerContents

  local innerContentIndex = 0
  local innerTextIndex = 0
  local innerNodeIndex = 0

  return function()

    innerContentIndex = innerContentIndex + 1
    if (innerContentIndex <= numberOfInnerContents) then

      local innerContentType = self.innerContents[innerContentIndex]

      local innerContent
      if (innerContentType == "text") then
        innerTextIndex = innerTextIndex + 1
        innerContent = self.innerTexts[innerTextIndex]
      elseif (innerContentType == "node") then
        innerNodeIndex = innerNodeIndex + 1
        innerContent = self.innerNodes[innerNodeIndex]
      end

      return innerContentType, innerContent
    end

  end

end


return BaseTemplateNode
