---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the CustomFieldNode works as expected.
--
-- @type TestCustomFieldNode
--
local TestCustomFieldNode = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestCustomFieldNode.testClassPath = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.CustomFieldNode"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestCustomFieldNode.dependencyPaths = {
  { id = "TableUtils", path = "AC-LuaServer.Core.Util.TableUtils", ["type"] = "table" }
}


---
-- Checks that the CustomFieldNode can return its name as expected.
--
function TestCustomFieldNode:testCanReturnName()
  local CustomFieldNode = self.testClass
  local customFieldNode = CustomFieldNode()

  self:assertEquals("custom-field", customFieldNode:getName())
end

---
-- Checks that the CustomFieldNode can return whether it is closed by a specific tag.
--
function TestCustomFieldNode:testCanReturnWhetherItIsClosedByTag()

  local CustomFieldNode = self.testClass
  local customFieldNode = CustomFieldNode()

  local TableUtilsMock = self.dependencyMocks.TableUtils

  local tag = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockA"
  )
  tag.getName
     :should_be_called()
     :and_will_return("end-custom-field")
     :and_then(
       TableUtilsMock.tableHasValue
                     :should_be_called_with(self.mach.match({ "end-custom-field" }), "end-custom-field")
                     :and_will_return(true)
     )
     :when(
       function()
         self:assertTrue(customFieldNode:isClosedByTag(tag))
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
                          :should_be_called_with(self.mach.match({ "end-custom-field" }), "custom-field")
                          :and_will_return(false)
          )
          :when(
            function()
              self:assertFalse(customFieldNode:isClosedByTag(otherTag))
            end
          )

end

---
-- Checks that the CustomFieldNode can return whether it is opened by a specific tag.
--
function TestCustomFieldNode:testCanReturnWhetherItIsOpenedByTag()

  local CustomFieldNode = self.testClass
  local customFieldNode = CustomFieldNode()

  local TableUtilsMock = self.dependencyMocks.TableUtils

  local tag = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockA"
  )
  tag.getName
     :should_be_called()
     :and_will_return("custom-field")
     :and_then(
       TableUtilsMock.tableHasValue
                     :should_be_called_with(self.mach.match({ "custom-field" }), "custom-field")
                     :and_will_return(true)
     )
     :when(
       function()
         self:assertTrue(customFieldNode:isOpenedByTag(tag))
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
                          :should_be_called_with(self.mach.match({ "custom-field" }), "row-field")
                          :and_will_return(false)
          )
          :when(
            function()
              self:assertFalse(customFieldNode:isOpenedByTag(otherTag))
            end
          )

end


return TestCustomFieldNode
