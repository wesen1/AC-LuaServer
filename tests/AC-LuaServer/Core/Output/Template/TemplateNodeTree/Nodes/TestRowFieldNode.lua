---
-- @author wesen
-- @copyright 2019-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the RowFieldNode works as expected.
--
-- @type TestRowFieldNode
--
local TestRowFieldNode = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestRowFieldNode.testClassPath = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RowFieldNode"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestRowFieldNode.dependencyPaths = {
  { id = "TableUtils", path = "AC-LuaServer.Core.Util.TableUtils", ["type"] = "table" }
}


---
-- Checks that the RowFieldNode can return its name as expected.
--
function TestRowFieldNode:testCanReturnName()
  local RowFieldNode = self.testClass
  local rowFieldNode = RowFieldNode()

  self:assertEquals("row-field", rowFieldNode:getName())
end

---
-- Checks that the RowFieldNode can return whether it is closed by a specific tag.
--
function TestRowFieldNode:testCanReturnWhetherItIsClosedByTag()

  local RowFieldNode = self.testClass
  local rowFieldNode = RowFieldNode()

  local TableUtilsMock = self.dependencyMocks.TableUtils

  local tag = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockA"
  )
  tag.getName
     :should_be_called()
     :and_will_return("row")
     :and_then(
       TableUtilsMock.tableHasValue
                     :should_be_called_with(
                       self.mach.match({ "row", "custom-field", "end-custom-field", "row-field"}),
                       "row"
                     )
                     :and_will_return(true)
     )
     :when(
       function()
         self:assertTrue(rowFieldNode:isClosedByTag(tag))
       end
     )

  local otherTag = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockB"
  )
  otherTag.getName
          :should_be_called()
          :and_will_return("root")
          :and_then(
            TableUtilsMock.tableHasValue
                          :should_be_called_with(
                            self.mach.match({ "row", "custom-field", "end-custom-field", "row-field"}),
                            "root"
                          )
                          :and_will_return(false)
          )
          :when(
            function()
              self:assertFalse(rowFieldNode:isClosedByTag(otherTag))
            end
          )

end

---
-- Checks that the RowFieldNode can return whether it is opened by a specific tag.
--
function TestRowFieldNode:testCanReturnWhetherItIsOpenedByTag()

  local RowFieldNode = self.testClass
  local rowFieldNode = RowFieldNode()

  local TableUtilsMock = self.dependencyMocks.TableUtils

  local tag = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMock"
  )
  tag.getName
     :should_be_called()
     :and_will_return("row-field")
     :and_then(
       TableUtilsMock.tableHasValue
         :should_be_called_with(self.mach.match({}), "row-field")
         :and_will_return(false)
     )
     :when(
       function()
         self:assertFalse(rowFieldNode:isOpenedByTag(tag))
       end
     )

  local otherTag = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockB"
  )
  otherTag.getName
          :should_be_called()
          :and_will_return("content")
          :and_then(
            TableUtilsMock.tableHasValue
                          :should_be_called_with(self.mach.match({}), "content")
                          :and_will_return(false)
          )
          :when(
            function()
              self:assertFalse(rowFieldNode:isOpenedByTag(otherTag))
            end
          )

end

---
-- Checks that a RowFieldNode can be converted to its table representation as expected.
--
function TestRowFieldNode:testCanBeConvertedToTable()

  local RowFieldNode = self.testClass

  local emptyRowFieldNode = RowFieldNode()
  self:assertEquals("", emptyRowFieldNode:toTable())

  local rowFieldNodeWithSingleInnerText = RowFieldNode()
  rowFieldNodeWithSingleInnerText:addInnerText("Welcome player")
  self:assertEquals("Welcome player", rowFieldNodeWithSingleInnerText:toTable())

  local rowFieldNodeWithMultipleInnerTexts = RowFieldNode()
  rowFieldNodeWithMultipleInnerTexts:addInnerText("some")
  rowFieldNodeWithMultipleInnerTexts:addInnerText("text")
  rowFieldNodeWithMultipleInnerTexts:addInnerText("that will be glued together")

  self:assertEquals("sometextthat will be glued together", rowFieldNodeWithMultipleInnerTexts:toTable())

end


return TestRowFieldNode
