---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"
local RootNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RootNode"
local TagFinder = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TagFinder"

---
-- Parses template strings into a tree like structure of template nodes.
--
-- @type TemplateNodeTree
--
local TemplateNodeTree = Object:extend()


---
-- The tag finder
--
-- @tfield TagFinder tagFinder
--
TemplateNodeTree.tagFinder = nil

---
-- The list of available node types
--
-- @tfield BaseTemplateNode[] nodeTypes
--
TemplateNodeTree.nodeTypes = {
  require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ConfigNode",
  require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.CustomFieldNode",
  require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RowFieldNode",
  require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RowNode"
}

---
-- The root node
--
-- @tfield RootNode rootNode
--
TemplateNodeTree.rootNode = nil

---
-- The currently open node (used in the parse loop)
--
-- @tfield BaseTemplateNode currentNode
--
TemplateNodeTree.currentNode = nil


---
-- TemplateNodeTree constructor.
--
function TemplateNodeTree:new()
  self.tagFinder = TagFinder()

  self.rootNode = RootNode()
  self.currentNode = self.rootNode
end


-- Getters and Setters

---
-- Returns the root node.
--
-- @treturn RootNode The root node
--
function TemplateNodeTree:getRootNode()
  return self.rootNode
end


-- Public Methods

---
-- Parses a string into this tree.
--
-- @tparam string _targetString The string to parse into this tree
--
function TemplateNodeTree:parse(_targetString)

  local targetStringLength = #_targetString
  local currentStringPosition = 1
  local nextTag
  repeat

    -- Find the next tag
    nextTag = self.tagFinder:findNextTag(_targetString, currentStringPosition)

    -- Add the text between the next tag and the current string position to the current node
    self:addInnerTextToCurrentNode(_targetString, currentStringPosition, nextTag)

    if (nextTag) then
      self:parseTag(nextTag)
      currentStringPosition = nextTag:getEndPosition() + 1
    end

  until (not nextTag or currentStringPosition > targetStringLength)

end


-- Private Methods

---
-- Adds the text between the current string position and the next tag's start position to the current node.
--
-- @tparam string _targetString The target string
-- @tparam int _currentStringPosition The current position inside the target string
-- @tparam TemplateTag _nextTag The next tag or nil if there is no next tag
--
function TemplateNodeTree:addInnerTextToCurrentNode(_targetString, _currentStringPosition, _nextTag)

  local innerTextEndPosition
  if (_nextTag) then
    -- There is a next tag, check if there is text between the current string position
    -- and the tags start position
    innerTextEndPosition = _nextTag:getStartPosition() - 1
    if (innerTextEndPosition < _currentStringPosition) then
      return
    end

  end

  -- Extract the inner text and check if it contains other symbols than " " and "\t"
  local innerText = _targetString:sub(_currentStringPosition, innerTextEndPosition)
  if (innerText:match("^[ \t]*$") == nil) then

    -- Add the extracted inner text to the current node
    self.currentNode = self.currentNode:addInnerText(innerText)
  end

end

---
-- Parses a template tag into this tree by creating and adding the corresponding template tree nodes.
--
-- @tparam TemplateTag _tag The tag to parse
--
function TemplateNodeTree:parseTag(_tag)

  -- Close the corresponding nodes
  while (self.currentNode:isClosedByTag(_tag)) do
    self.currentNode = self.currentNode:getParentNode()
  end

  -- Open a new node if required
  for _, nodeType in ipairs(self.nodeTypes) do
    if (nodeType:isOpenedByTag(_tag)) then

      local node = nodeType()

      self.currentNode:addInnerNode(node)
      self.currentNode = node

      break

    end
  end

end


return TemplateNodeTree
