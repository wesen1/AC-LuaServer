---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the BaseTemplateNode works as expected.
--
-- @type TestContentNode
--
local TestBaseTemplateNode = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestBaseTemplateNode.testClassPath = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode"


---
-- Checks that a parent node can be set as expected.
--
function TestBaseTemplateNode:testCanSetParentNode()

  local BaseTemplateNode = self.testClass
  local node = BaseTemplateNode()

  local otherNode = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "ParentNodeMock"
  )

  self:assertNil(node:getParentNode())
  node:setParentNode(otherNode)
  self:assertEquals(otherNode, node:getParentNode())

end

---
-- Checks that inner texts can be added as expected.
--
function TestBaseTemplateNode:testCanAddInnerText()

  local BaseTemplateNode = self.testClass
  local node = BaseTemplateNode()

  local modifiedNode = node:addInnerText("myexample-text")
  self:assertEquals(node, modifiedNode)

  modifiedNode = node:addInnerText("another-example")
  self:assertEquals(node, modifiedNode)

end

---
-- Checks that inner nodes can be added as expected.
--
function TestBaseTemplateNode:testCanAddInnerNodes()

  local BaseTemplateNode = self.testClass
  local node = BaseTemplateNode()

  local innerNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "InnerNodeMock"
  )

  local modifiedNode
  innerNodeMock.setParentNode
               :should_be_called_with(node)
               :when(
                 function()
                   modifiedNode = node:addInnerNode(innerNodeMock)
                 end
               )

  self:assertEquals(node, modifiedNode)

end

---
-- Checks that the BaseTemplateNode can return direct child nodes by their name.
--
function TestBaseTemplateNode:testCanReturnChildNodesByNodeName()

  local BaseTemplateNode = self.testClass
  local node = BaseTemplateNode()

  -- Add some example inner nodes
  local innerNodeMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "InnerNodeMockA"
  )
  innerNodeMockA.setParentNode
                :should_be_called_with(node)
                :when(
                  function()
                    node:addInnerNode(innerNodeMockA)
                  end
                )

  local innerNodeMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "InnerNodeMockB"
  )
  innerNodeMockB.setParentNode
                :should_be_called_with(node)
                :when(
                  function()
                    node:addInnerNode(innerNodeMockB)
                  end
                )

  local innerNodeMockC = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "InnerNodeMockC"
  )
  innerNodeMockC.setParentNode
                :should_be_called_with(node)
                :when(
                  function()
                    node:addInnerNode(innerNodeMockC)
                  end
                )


  local foundNodes

  -- Multiple results
  innerNodeMockA.getName
                :should_be_called()
                :and_will_return("config")
                :and_also(
                  innerNodeMockB.getName
                                :should_be_called()
                                :and_will_return("content")
                )
                :and_also(
                  innerNodeMockC.getName
                                :should_be_called()
                                :and_will_return("config")
                )
                :when(
                  function()
                    foundNodes = node:find("config")
                  end
                )

  self:assertEquals(2, #foundNodes)
  self:assertEquals({ innerNodeMockA, innerNodeMockC }, foundNodes)


  -- Single result
  innerNodeMockA.getName
                :should_be_called()
                :and_will_return("row-field")
                :and_also(
                  innerNodeMockB.getName
                                :should_be_called()
                                :and_will_return("row-field")
                )
                :and_also(
                  innerNodeMockC.getName
                                :should_be_called()
                                :and_will_return("custom-field")
                )
                :when(
                  function()
                    foundNodes = node:find("custom-field")
                  end
                )

  self:assertEquals(1, #foundNodes)
  self:assertEquals({ innerNodeMockC }, foundNodes)


  -- No results
  innerNodeMockA.getName
                :should_be_called()
                :and_will_return("row")
                :and_also(
                  innerNodeMockB.getName
                                :should_be_called()
                                :and_will_return("row")
                )
                :and_also(
                  innerNodeMockC.getName
                                :should_be_called()
                                :and_will_return("row")
                )
                :when(
                  function()
                    foundNodes = node:find("row-field")
                  end
                )

  self:assertEquals(0, #foundNodes)
  self:assertEquals({}, foundNodes)

end

---
-- Checks that a BaseTemplateNode can be converted to a table as expected.
--
function TestBaseTemplateNode:testCanBeConvertedToTable()

  local BaseTemplateNode = self.testClass
  local node = BaseTemplateNode()

  -- No child nodes and no inner texts results in empty table
  self:assertEquals({}, node:toTable())


  -- Add a child node
  local innerNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "InnerNodeMock"
  )
  innerNodeMock.setParentNode
               :should_be_called_with(node)
               :when(
                 function()
                   node:addInnerNode(innerNodeMock)
                 end
               )

  -- Add a inner text
  node:addInnerText("example")

  -- Child nodes and inner texts are ignored and the result is still an empty table
  self:assertEquals({}, node:toTable())

end

---
-- Checks that a BaseTemplateNode can be converted to a string as expected.
--
function TestBaseTemplateNode:testCanBeConvertedToString()

  local BaseTemplateNode = self.testClass
  local node = BaseTemplateNode()

  -- No child nodes and no inner texts results in empty string
  self:assertEquals("", node:toString())


  -- Add a inner text
  node:addInnerText("other-example")

  -- Add a child node
  local innerNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "InnerNodeMock"
  )
  innerNodeMock.setParentNode
               :should_be_called_with(node)
               :when(
                 function()
                   node:addInnerNode(innerNodeMock)
                 end
                    )

  -- Child nodes and inner texts are ignored and the result is still an empty string
  self:assertEquals("", node:toString())

end


return TestBaseTemplateNode
