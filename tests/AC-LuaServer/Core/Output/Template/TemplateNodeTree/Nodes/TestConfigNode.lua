---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the ConfigNode works as expected.
--
-- @type TestConfigNode
--
local TestConfigNode = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestConfigNode.testClassPath = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ConfigNode"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestConfigNode.dependencyPaths = {
  { id = "TableUtils", path = "AC-LuaServer.Core.Util.TableUtils", ["type"] = "table" }
}


---
-- Checks that the ConfigNode can return its name as expected.
--
function TestConfigNode:testCanReturnName()
  local ConfigNode = self.testClass
  local configNode = ConfigNode()

  self:assertEquals("config", configNode:getName())
end

---
-- Checks that the ConfigNode can return whether it is closed by a specific tag.
--
function TestConfigNode:testCanReturnWhetherItIsClosedByTag()

  local ConfigNode = self.testClass
  local configNode = ConfigNode()

  local TableUtilsMock = self.dependencyMocks.TableUtils

  local tag = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockA"
  )
  tag.getName
     :should_be_called()
     :and_will_return("end-config")
     :and_then(
       TableUtilsMock.tableHasValue
                     :should_be_called_with(self.mach.match({ "end-config" }), "end-config")
                     :and_will_return(true)
     )
     :when(
       function()
         self:assertTrue(configNode:isClosedByTag(tag))
       end
     )

  local otherTag = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockB"
  )
  otherTag.getName
          :should_be_called()
          :and_will_return("config")
          :and_then(
            TableUtilsMock.tableHasValue
                          :should_be_called_with(self.mach.match({ "end-config" }), "config")
                          :and_will_return(false)
          )
          :when(
            function()
              self:assertFalse(configNode:isClosedByTag(otherTag))
            end
          )

end

---
-- Checks that the ConfigNode can return whether it is opened by a specific tag.
--
function TestConfigNode:testCanReturnWhetherItIsOpenedByTag()

  local ConfigNode = self.testClass
  local configNode = ConfigNode()

  local TableUtilsMock = self.dependencyMocks.TableUtils

  local tag = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockA"
  )
  tag.getName
     :should_be_called()
     :and_will_return("config")
     :and_then(
       TableUtilsMock.tableHasValue
                     :should_be_called_with(self.mach.match({ "config" }), "config")
                     :and_will_return(true)
     )
     :when(
       function()
         self:assertTrue(configNode:isOpenedByTag(tag))
       end
     )

  local otherTag = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockB"
  )
  otherTag.getName
          :should_be_called()
          :and_will_return("row")
          :and_then(
            TableUtilsMock.tableHasValue
                          :should_be_called_with(self.mach.match({ "config" }), "row")
                          :and_will_return(false)
          )
          :when(
            function()
              self:assertFalse(configNode:isOpenedByTag(otherTag))
            end
          )

end

---
-- Checks that a ConfigNode can be converted to a table as expected.
--
function TestConfigNode:testCanBeConvertedToTable()

  local ConfigNode = self.testClass
  local configNode = ConfigNode()

  -- No inner contents
  self:assertEquals({}, configNode:toTable())


  -- Add a inner node
  local innerNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "InnerNodeMock"
  )
  innerNodeMock.setParentNode
               :should_be_called_with(configNode)
               :when(
                 function()
                   configNode:addInnerNode(innerNodeMock)
                 end
               )

  -- Should ignore the inner node(s)
  self:assertEquals({}, configNode:toTable())


  -- With inner text that is no valid config entry
  configNode:addInnerText("value=\"test\"")
  self:assertEquals({}, configNode:toTable())

  -- Make the config entry valid by adding a trailing ";"
  configNode:addInnerText(";")
  self:assertEquals({ value = "test" }, configNode:toTable())

  -- Add another config entry
  configNode:addInnerText("otherValue = false;")
  self:assertEquals({ value = "test", otherValue = false }, configNode:toTable())

  -- Add a third config entry
  configNode:addInnerText("lastEntry = 52.8;")
  self:assertEquals({ value = "test", otherValue = false, lastEntry = 52.8 }, configNode:toTable())

end

---
-- Checks that invalid config entries are handled as expected when converting a ConfigNode to a table.
--
function TestConfigNode:testCanHandleInvalidConfigEntries()

  local ConfigNode = self.testClass
  local configNode = ConfigNode()

  -- Invalid config entry does not match format "<variable name>=<value>"
  configNode:addInnerText("value+36\"bad format\";")
  self:assertEquals({}, configNode:toTable())

  -- Valid config entry
  configNode:addInnerText("goodEntry=true;")
  self:assertEquals({ goodEntry = true }, configNode:toTable())

  -- Invalid config entry matches format "<variable name>=<value>",
  configNode:addInnerText("maliciousEntry=129i092\"break\";")
  self:assertEquals({ goodEntry = true }, configNode:toTable())

  -- Another valid config entry
  configNode:addInnerText("thankyou=\"astring\";")
  self:assertEquals({ goodEntry = true, thankyou = "astring" }, configNode:toTable())

end


return TestConfigNode
