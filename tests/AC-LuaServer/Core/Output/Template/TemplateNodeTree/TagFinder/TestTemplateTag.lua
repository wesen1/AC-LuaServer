---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the TemplateTag works as expected.
--
-- @type TestTemplateTag
--
local TestTemplateTag = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestTemplateTag.testClassPath = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag"


---
-- Checks that a TemplateTag can be created as expected.
--
function TestTemplateTag:testCanBeCreated()

  local TemplateTag = self.testClass

  local tag = TemplateTag("##+%[ *CONFIG *]#*;", 1, 15)
  self:assertEquals("##+%[ *CONFIG *]#*;", tag:getPattern())
  self:assertEquals(1, tag:getStartPosition())
  self:assertEquals(15, tag:getEndPosition())

  local anotherTag = TemplateTag("##+%[ *ENDCONFIG *]#*;", 130, 147)
  self:assertEquals("##+%[ *ENDCONFIG *]#*;", anotherTag:getPattern())
  self:assertEquals(130, anotherTag:getStartPosition())
  self:assertEquals(147, anotherTag:getEndPosition())

end


return TestTemplateTag
