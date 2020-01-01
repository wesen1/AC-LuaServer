---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the RootNode works as expected.
--
-- @type TestRootNode
--
local TestRootNode = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestRootNode.testClassPath = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RootNode"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestRootNode.dependencyPaths = {
  { id = "TableUtils", path = "AC-LuaServer.Core.Util.TableUtils", ["type"] = "table" },
  { id = "ConfigNode", path = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ConfigNode" },
  { id = "ContentNode", path = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ContentNode" }
}


---
-- Checks that the RootNode can return its name as expected.
--
function TestRootNode:testCanReturnName()
  local RootNode = self.testClass
  local rootNode = RootNode()

  self:assertEquals("root", rootNode:getName())
end

---
-- Checks that a parent node can be set as expected.
--
function TestRootNode:testCanSetParentNode()

  local RootNode = self.testClass
  local rootNode = RootNode()

  local otherNode = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "ParentNodeMock"
  )

  self:assertNil(rootNode:getParentNode())
  rootNode:setParentNode(otherNode)
  self:assertEquals(otherNode, rootNode:getParentNode())

end

---
-- Checks that inner text can be added as expected.
--
function TestRootNode:testCanAddInnerText()

  local RootNode = self.testClass
  local rootNode = RootNode()

  local ContentNodeMock = self.dependencyMocks.ContentNode
  local contentNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ContentNode", "ContentNodeMock"
  )
  contentNodeMock.setParentNode = self.mach.mock_method("setParentNode")

  local modifiedNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "ModifiedNodeMock"
  )

  local modifiedNode
  ContentNodeMock.__call
                 :should_be_called()
                 :and_will_return(contentNodeMock)
                 :and_then(
                   contentNodeMock.setParentNode
                                  :should_be_called_with(rootNode)
                 )
                 :and_also(
                   contentNodeMock.addInnerText
                                  :should_be_called_with("myexample-text")
                                  :and_will_return(modifiedNodeMock)
                 )
                 :when(
                   function()
                     modifiedNode = rootNode:addInnerText("myexample-text")
                   end
                 )

  self:assertEquals(modifiedNodeMock, modifiedNode)

end

---
-- Checks that a inner "config" node can be added as expected.
--
function TestRootNode:testCanAddInnerConfigNode()

  local RootNode = self.testClass
  local rootNode = RootNode()

  local configNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ConfigNode", "ConfigNodeMock"
  )
  configNodeMock.is = self.mach.mock_method("is")
  configNodeMock.setParentNode = self.mach.mock_method("setParentNode")

  local ConfigNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ConfigNode"

  local modifiedNode
  configNodeMock.is
                :should_be_called_with(ConfigNode)
                :and_will_return(true)
                :and_then(
                  configNodeMock.setParentNode
                                :should_be_called_with(rootNode)
                )
                :when(
                  function()
                    modifiedNode = rootNode:addInnerNode(configNodeMock)
                  end
                )

  self:assertEquals(rootNode, modifiedNode)

end

---
-- Checks that a inner "content" node can be added as expected.
--
function TestRootNode:testCanAddInnnerContentNode()

  local RootNode = self.testClass
  local rootNode = RootNode()

  local contentNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ContentNode", "ContentNode"
  )
  contentNodeMock.is = self.mach.mock_method("is")
  contentNodeMock.setParentNode = self.mach.mock_method("setParentNode")

  local ConfigNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ConfigNode"
  local ContentNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ContentNode"

  local modifiedNode
  contentNodeMock.is
                 :should_be_called_with(ConfigNode)
                 :and_will_return(false)
                 :and_also(
                   contentNodeMock.is
                                  :should_be_called_with(ContentNode)
                                  :and_will_return(true)
                 )
                 :and_then(
                   contentNodeMock.setParentNode
                                  :should_be_called_with(rootNode)
                 )
                 :when(
                   function()
                     modifiedNode = rootNode:addInnerNode(contentNodeMock)
                   end
                 )

  self:assertEquals(rootNode, modifiedNode)

end

---
-- Checks that other inner nodes that are no "config" and no "content" nodes can be added as expected.
--
function TestRootNode:testCanAddOtherInnerNodes()

  local RootNode = self.testClass
  local rootNode = RootNode()

  local ContentNodeMock = self.dependencyMocks.ContentNode
  local contentNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ContentNode", "ContentNodeMock"
  )
  contentNodeMock.setParentNode = self.mach.mock_method("setParentNode")

  local modifiedNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "ModifiedNodeMock"
  )
  local innerNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "InnerNodeMock"
  )
  innerNodeMock.is = self.mach.mock_method("is")

  local ConfigNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ConfigNode"
  local ContentNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ContentNode"

  local modifiedNode
  innerNodeMock.is
               :should_be_called_with(ConfigNode)
               :and_will_return(false)
               :and_then(
                 innerNodeMock.is
                              :should_be_called_with(ContentNode)
                              :and_will_return(false)
               )
               :and_then(
                 ContentNodeMock.__call
                                :should_be_called()
                                :and_will_return(contentNodeMock)
               )
               :and_then(
                 contentNodeMock.setParentNode
                                :should_be_called_with(rootNode)
               )
               :and_also(
                 contentNodeMock.addInnerNode
                                :should_be_called_with(innerNodeMock)
                                :and_will_return(modifiedNodeMock)
               )
               :when(
                 function()
                   modifiedNode = rootNode:addInnerNode(innerNodeMock)
                 end
               )

  self:assertEquals(modifiedNodeMock, modifiedNode)

end

---
-- Checks that the RootNode can return whether it is closed by a specific tag.
--
function TestRootNode:testCanReturnWhetherItIsClosedByTag()

  local RootNode = self.testClass
  local rootNode = RootNode()

  local tag = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMock"
  )
  tag.getName
     :should_be_called()
     :and_will_return("config")
     :and_then(
       self.dependencyMocks.TableUtils.tableHasValue
                                      :should_be_called_with(self.mach.match({}), "config")
                                      :and_will_return(false)
     )
     :when(
       function()
         self:assertFalse(rootNode:isClosedByTag(tag))
       end
     )

end

---
-- Checks that the RootNode can return whether it is opened by a specific tag.
--
function TestRootNode:testCanReturnWhetherItIsOpenedByTag()

  local RootNode = self.testClass
  local rootNode = RootNode()

  local tag = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMock"
  )
  tag.getName
     :should_be_called()
     :and_will_return("row")
     :and_then(
       self.dependencyMocks.TableUtils.tableHasValue
                                      :should_be_called_with(self.mach.match({}), "row")
                                      :and_will_return(false)
     )
     :when(
       function()
         self:assertFalse(rootNode:isOpenedByTag(tag))
       end
     )

end

---
-- Checks that the RootNode can return direct child nodes by their name.
--
function TestRootNode:testCanReturnChildNodesByNodeName()

  local RootNode = self.testClass
  local rootNode = RootNode()

  -- Add some example nodes
  local ConfigNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ConfigNode"
  local ContentNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ContentNode"

  -- "config"
  local innerNodeMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "InnerNodeMockA"
  )
  innerNodeMockA.is = self.mach.mock_method("is")
  innerNodeMockA.getName = self.mach.mock_method("getName")

  innerNodeMockA.is
                :should_be_called_with(ConfigNode)
                :and_will_return(true)
                :and_then(
                  innerNodeMockA.setParentNode
                                :should_be_called_with(rootNode)
                )
                :when(
                  function()
                    rootNode:addInnerNode(innerNodeMockA)
                  end
                )

  -- "content"
  local innerNodeMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "InnerNodeMockB"
  )
  innerNodeMockB.is = self.mach.mock_method("is")
  innerNodeMockB.getName = self.mach.mock_method("getName")

  innerNodeMockB.is
                :should_be_called_with(ConfigNode)
                :and_will_return(false)
                :and_then(
                  innerNodeMockB.is
                                :should_be_called_with(ContentNode)
                                :and_will_return(true)
                )
                :and_then(
                  innerNodeMockB.setParentNode
                                :should_be_called_with(rootNode)
                )
                :when(
                  function()
                    rootNode:addInnerNode(innerNodeMockB)
                  end
                )

  -- "config"
  local innerNodeMockC = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "InnerNodeMockC"
  )
  innerNodeMockC.is = self.mach.mock_method("is")
  innerNodeMockC.getName = self.mach.mock_method("getName")

  innerNodeMockC.is
                :should_be_called_with(ConfigNode)
                :and_will_return(true)
                :and_then(
                  innerNodeMockC.setParentNode
                                :should_be_called_with(rootNode)
                )
                :when(
                  function()
                    rootNode:addInnerNode(innerNodeMockC)
                  end
                )


  -- Search the direct child nodes for "config" nodes
  local foundNodes
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
                    foundNodes = rootNode:find("config")
                  end
                )

  self:assertEquals(2, #foundNodes)
  self:assertEquals({ innerNodeMockA, innerNodeMockC }, foundNodes)

end

---
-- Checks that a RootNode can be converted to a table as expected.
--
function TestRootNode:testCanBeConvertedToTable()

  local RootNode = self.testClass
  local rootNode = RootNode()

  -- Empty root node results in empty table
  self:assertEquals({}, rootNode:toTable())


  -- Add a child node
  local ConfigNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ConfigNode"

  local innerNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "InnerNodeMock"
  )
  innerNodeMock.is = self.mach.mock_method("is")
  innerNodeMock.getName = self.mach.mock_method("getName")

  innerNodeMock.is
               :should_be_called_with(ConfigNode)
               :and_will_return(true)
               :and_then(
                 innerNodeMock.setParentNode
                              :should_be_called_with(rootNode)
               )
               :when(
                 function()
                   rootNode:addInnerNode(innerNodeMock)
                 end
               )

  -- Child nodes are ignored and the result is still an empty table
  self:assertEquals({}, rootNode:toTable())

end

---
-- Checks that a RootNode can be converted to a string as expected.
--
function TestRootNode:testCanBeConvertedToString()

  local RootNode = self.testClass
  local rootNode = RootNode()

  -- Empty root node results in empty string
  self:assertEquals("", rootNode:toString())


  -- Add a child node
  local ConfigNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ConfigNode"
  local ContentNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ContentNode"

  local innerNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "InnerNodeMock"
  )
  innerNodeMock.is = self.mach.mock_method("is")
  innerNodeMock.getName = self.mach.mock_method("getName")

  innerNodeMock.is
               :should_be_called_with(ConfigNode)
               :and_will_return(false)
               :and_then(
                 innerNodeMock.is
                              :should_be_called_with(ContentNode)
                              :and_will_return(true)
               )
               :and_then(
                 innerNodeMock.setParentNode
                              :should_be_called_with(rootNode)
               )
               :when(
                 function()
                   rootNode:addInnerNode(innerNodeMock)
                 end
               )

  -- Child nodes are ignored and the result is still an empty string
  self:assertEquals("", rootNode:toString())

end


return TestRootNode
