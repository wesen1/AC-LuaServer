---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the ContentNode works as expected.
--
-- @type TestContentNode
--
local TestContentNode = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestContentNode.testClassPath = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ContentNode"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestContentNode.dependencyPaths = {
  { id = "TableUtils", path = "AC-LuaServer.Core.Util.TableUtils", ["type"] = "table" },
  { id = "RowNode", path = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RowNode" }
}


---
-- Checks that the ContentNode can return its name as expected.
--
function TestContentNode:testCanReturnName()
  local ContentNode = self.testClass
  local contentNode = ContentNode()

  self:assertEquals("content", contentNode:getName())
end

---
-- Checks that inner text can be added as expected.
--
function TestContentNode:testCanAddInnerText()

  local ContentNode = self.testClass
  local contentNode = ContentNode()

  local RowNodeMock = self.dependencyMocks.RowNode
  local rowNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RowNode", "RowNodeMock"
  )
  rowNodeMock.setParentNode = self.mach.mock_method("setParentNode")

  local modifiedNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "ModifiedNodeMock"
  )

  local modifiedNode
  RowNodeMock.__call
             :should_be_called()
             :and_will_return(rowNodeMock)
             :and_then(
               rowNodeMock.setParentNode
                          :should_be_called_with(contentNode)
             )
             :and_also(
               rowNodeMock.addInnerText
                          :should_be_called_with("some-inner-string")
                          :and_will_return(modifiedNodeMock)
             )
             :when(
               function()
                 modifiedNode = contentNode:addInnerText("some-inner-string")
               end
             )

  self:assertEquals(modifiedNodeMock, modifiedNode)

end

---
-- Checks that a inner row node can be added as expected.
--
function TestContentNode:testCanAddInnerRowNode()

  local ContentNode = self.testClass
  local contentNode = ContentNode()

  local rowNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RowNode", "RowNodeMock"
  )
  rowNodeMock.is = self.mach.mock_method("is")
  rowNodeMock.setParentNode = self.mach.mock_method("setParentNode")

  local RowNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RowNode"

  local modifiedNode
  rowNodeMock.is
             :should_be_called_with(RowNode)
             :and_will_return(true)
             :and_then(
               rowNodeMock.setParentNode
                          :should_be_called_with(contentNode)
             )
             :when(
               function()
                 modifiedNode = contentNode:addInnerNode(rowNodeMock)
               end
             )

  self:assertEquals(contentNode, modifiedNode)

end

---
-- Checks that a inner node that is no row node can be added as expected.
--
function TestContentNode:testCanAddOtherInnerNodes()

  local ContentNode = self.testClass
  local contentNode = ContentNode()

  local RowNodeMock = self.dependencyMocks.RowNode
  local rowNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RowNode", "RowNodeMock"
  )
  rowNodeMock.setParentNode = self.mach.mock_method("setParentNode")
  rowNodeMock.addInnerNode = self.mach.mock_method("addInnerNode")

  local modifiedNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "ModifiedNodeMock"
  )
  local innerNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "InnerNodeMock"
  )
  innerNodeMock.is = self.mach.mock_method("is")

  local RowNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RowNode"

  local modifiedNode
  innerNodeMock.is
               :should_be_called_with(RowNode)
               :and_will_return(false)
               :and_then(
                 RowNodeMock.__call
                            :should_be_called()
                            :and_will_return(rowNodeMock)
               )
               :and_then(
                 rowNodeMock.setParentNode
                            :should_be_called_with(contentNode)
               )
               :and_also(
                 rowNodeMock.addInnerNode
                            :should_be_called_with(innerNodeMock)
                            :and_will_return(modifiedNodeMock)
               )
               :when(
                 function()
                   modifiedNode = contentNode:addInnerNode(innerNodeMock)
                 end
               )

  self:assertEquals(modifiedNodeMock, modifiedNode)

end

---
-- Checks that the ContentNode can return whether it is closed by a specific tag.
--
function TestContentNode:testCanReturnWhetherItIsClosedByTag()

  local ContentNode = self.testClass
  local contentNode = ContentNode()

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
         self:assertFalse(contentNode:isClosedByTag(tag))
       end
     )

end

---
-- Checks that the ContentNode can return whether it is opened by a specific tag.
--
function TestContentNode:testCanReturnWhetherItIsOpenedByTag()

  local ContentNode = self.testClass
  local contentNode = ContentNode()

  local tag = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMock"
  )
  tag.getName
     :should_be_called()
     :and_will_return("custom-field")
     :and_then(
       self.dependencyMocks.TableUtils.tableHasValue
                                      :should_be_called_with(self.mach.match({}), "custom-field")
                                      :and_will_return(false)
     )
     :when(
       function()
         self:assertFalse(contentNode:isOpenedByTag(tag))
       end
     )

end


return TestContentNode
