---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the Template works as expected.
--
-- @type TestTemplate
--
local TestTemplate = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestTemplate.testClassPath = "AC-LuaServer.Core.Output.Template.Template"


---
-- Checks that a Template can be created as expected.
--
function TestTemplate:testCanBeCreated()

  local Template = self.testClass

  -- Without values
  local template = Template("TextTemplate/ExampleOne")
  self:assertEquals("TextTemplate/ExampleOne", template:getTemplatePath())
  self:assertEquals({}, template:getTemplateValues())

  -- With values
  local otherTemplate = Template("TextTemplate/SecondExample", { val1 = 1, val2 = 3 })
  self:assertEquals("TextTemplate/SecondExample", otherTemplate:getTemplatePath())
  self:assertEquals({ val1 = 1, val2 = 3 }, otherTemplate:getTemplateValues())

end


return TestTemplate
