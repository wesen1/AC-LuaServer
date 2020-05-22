---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Base class for tests that test the output of a template.
--
-- @type TemplateTest
--
local TemplateTest = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TemplateTest.testClassPath = "AC-LuaServer.Core.Output.Output"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TemplateTest.dependencyPaths = {
  { id = "LuaServerApi", path = "AC-LuaServer.Core.LuaServerApi", ["type"] = "table" },
}


---
-- The output instance that will be used to render the test template
--
-- @tfield Output output
--
TemplateTest.output = nil

---
-- The output rows that the Output printed for the template
--
-- @tfield string[] outputRows
--
TemplateTest.outputRows = nil


---
-- Method that is called before a test is executed.
-- Initializes the Output instance and the LuaServerApi.clientprint mock.
--
function TemplateTest:setUp()
  TestCase.setUp(self)

  self.output = self:createTestOutput()
  self.outputRows = {}

  self.dependencyMocks.LuaServerApi.clientprint = function(_cn, _outputRow)
    self:assertEquals(-1, _cn)
    table.insert(self.outputRows, _outputRow)
  end
end

---
-- Method that is called after a test was executed.
-- Clears the test Output instance and the printed output rows.
--
function TemplateTest:tearDown()
  TestCase.tearDown(self)

  self.output = nil
  self.outputRows = nil
end


-- Private Methods

---
-- Generates and returns a test Output instance.
--
-- @treturn Output The Output instance
--
function TemplateTest:createTestOutput()
  local Output = self.testClass
  local output = Output()

  return output
end


return TemplateTest
