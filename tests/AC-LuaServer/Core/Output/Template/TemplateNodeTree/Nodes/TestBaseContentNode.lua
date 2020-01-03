---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the BaseContentNode works as expected.
--
-- @type TestContentNode
--
local TestBaseContentNode = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestBaseContentNode.testClassPath = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseContentNode"


---
-- Checks that a BaseContentNode can be converted to a table as expected.
--
function TestBaseContentNode:testCanBeConvertedToTable()

  local BaseContentNode = self.testClass
  local baseContentNode = BaseContentNode()

  -- No child nodes and no inner texts results in empty table
  self:assertEquals({}, baseContentNode:toTable())


  -- Add some inner contents

  -- "row" child node
  local innerNodeMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "InnerNodeMockA"
  )
  innerNodeMockA.setParentNode
                :should_be_called_with(baseContentNode)
                :when(
                  function()
                    baseContentNode:addInnerNode(innerNodeMockA)
                  end
                )

  -- Inner text A
  baseContentNode:addInnerText("hello world")

  -- "row" child node
  local innerNodeMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "InnerNodeMockB"
  )
  innerNodeMockB.setParentNode
                :should_be_called_with(baseContentNode)
                :when(
                  function()
                    baseContentNode:addInnerNode(innerNodeMockB)
                  end
                )

  -- Inner text B
  baseContentNode:addInnerText("another example")


  local generatedTable
  innerNodeMockA.toTable
                :should_be_called()
                :and_will_return({"fieldA", "fieldB"})
                :and_also(
                  innerNodeMockB.toTable
                                :should_be_called()
                                :and_will_return({"firstField", "secondField"})
                )
                :when(
                  function()
                    generatedTable = baseContentNode:toTable()
                  end
                )

  self:assertEquals({
      { "fieldA", "fieldB" },
      "hello world",
      { "firstField", "secondField" },
      "another example"
  }, generatedTable)

end

---
-- Checks that a BaseContentNode can be converted to a string as expected.
--
function TestBaseContentNode:testCanBeConvertedToString()

  local BaseContentNode = self.testClass
  local baseContentNode = BaseContentNode()

  -- No child nodes and no inner texts results in empty string
  self:assertEquals("", baseContentNode:toString())


  -- Add some inner contents

  -- "row" child node
  local innerNodeMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "InnerNodeMockA"
  )
  innerNodeMockA.setParentNode
                :should_be_called_with(baseContentNode)
                :when(
                  function()
                    baseContentNode:addInnerNode(innerNodeMockA)
                  end
                )

  -- Inner text A
  baseContentNode:addInnerText("hello world")

  -- "row" child node
  local innerNodeMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "InnerNodeMockB"
  )
  innerNodeMockB.setParentNode
                :should_be_called_with(baseContentNode)
                :when(
                  function()
                    baseContentNode:addInnerNode(innerNodeMockB)
                  end
                )

  -- Inner text B
  baseContentNode:addInnerText("another example")


  local generatedString
  innerNodeMockA.toString
                :should_be_called()
                :and_will_return("fieldA\tfieldB")
                :and_also(
                  innerNodeMockB.toString
                                :should_be_called()
                                :and_will_return("firstField\tsecondField")
                )
                :when(
                  function()
                    generatedString = baseContentNode:toString()
                  end
                )

  self:assertEquals("fieldA\tfieldBhello worldfirstField\tsecondFieldanother example", generatedString)

end


return TestBaseContentNode
