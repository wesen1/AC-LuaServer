---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the RowNode works as expected.
--
-- @type TestRowNode
--
local TestRowNode = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestRowNode.testClassPath = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RowNode"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestRowNode.dependencyPaths = {
  { id = "TableUtils", path = "AC-LuaServer.Core.Util.TableUtils", ["type"] = "table" },
  { id = "RowFieldNode", path = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RowFieldNode" }
}


---
-- Checks that the RowNode can return its name as expected.
--
function TestRowNode:testCanReturnName()
  local RowNode = self.testClass
  local rowNode = RowNode()

  self:assertEquals("row", rowNode:getName())
end

---
-- Checks that the RowNode can return whether it is closed by a specific tag.
--
function TestRowNode:testCanReturnWhetherItIsClosedByTag()

  local RowNode = self.testClass
  local rowNode = RowNode()

  local TableUtilsMock = self.dependencyMocks.TableUtils

  local tag = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockA"
  )
  tag.getName
     :should_be_called()
     :and_will_return("row")
     :and_then(
       TableUtilsMock.tableHasValue
                     :should_be_called_with(self.mach.match({ "row", "end-custom-field" }), "row")
                     :and_will_return(true)
     )
     :when(
       function()
         self:assertTrue(rowNode:isClosedByTag(tag))
       end
     )

  local otherTag = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockB"
  )
  otherTag.getName
          :should_be_called()
          :and_will_return("row-field")
          :and_then(
            TableUtilsMock.tableHasValue
                          :should_be_called_with(self.mach.match({ "row", "end-custom-field" }), "row-field")
                          :and_will_return(false)
          )
          :when(
            function()
              self:assertFalse(rowNode:isClosedByTag(otherTag))
            end
          )

end

---
-- Checks that the RowNode can return whether it is opened by a specific tag.
--
function TestRowNode:testCanReturnWhetherItIsOpenedByTag()

  local RowNode = self.testClass
  local rowNode = RowNode()

  local TableUtilsMock = self.dependencyMocks.TableUtils

  local tag = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockA"
  )
  tag.getName
     :should_be_called()
     :and_will_return("row")
     :and_then(
       TableUtilsMock.tableHasValue
                     :should_be_called_with(self.mach.match({ "row" }), "row")
                     :and_will_return(true)
     )
     :when(
       function()
         self:assertTrue(rowNode:isOpenedByTag(tag))
       end
     )

  local otherTag = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockB"
  )
  otherTag.getName
          :should_be_called()
          :and_will_return("custom-field")
          :and_then(
            TableUtilsMock.tableHasValue
                          :should_be_called_with(self.mach.match({ "row" }), "custom-field")
                          :and_will_return(false)
          )
          :when(
            function()
              self:assertFalse(rowNode:isOpenedByTag(otherTag))
            end
          )

end

---
-- Checks that inner text can be added as expected.
--
function TestRowNode:testCanAddInnerText()

  local RowNode = self.testClass
  local rowNode = RowNode()

  local RowFieldNodeMock = self.dependencyMocks.RowFieldNode
  local rowFieldNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RowFieldNode", "RowFieldNodeMock"
  )
  rowFieldNodeMock.setParentNode = self.mach.mock_method("setParentNode")
  rowFieldNodeMock.addInnerText = self.mach.mock_method("addInnerText")

  local modifiedNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "ModifiedNodeMock"
  )

  local modifiedNode
  RowFieldNodeMock.__call
             :should_be_called()
             :and_will_return(rowFieldNodeMock)
             :and_then(
               rowFieldNodeMock.setParentNode
                              :should_be_called_with(rowNode)
             )
             :and_also(
               rowFieldNodeMock.addInnerText
                          :should_be_called_with("new-inner-string")
                          :and_will_return(modifiedNodeMock)
             )
             :when(
               function()
                 modifiedNode = rowNode:addInnerText("new-inner-string")
               end
             )

  self:assertEquals(modifiedNodeMock, modifiedNode)

end


return TestRowNode
