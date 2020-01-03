---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the string utils work as expected.
--
-- @type TestStringUtils
--
local TestStringUtils = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestStringUtils.testClassPath = "AC-LuaServer.Core.Util.StringUtils"


---
-- Checks that strings can be split by a delimiter as expected.
--
function TestStringUtils:testCanSplitStringByDelimiter()

  local StringUtils = self.testClass

  -- Empty string
  self:assertEquals({}, StringUtils.split("", "a"))

  -- Empty delimiter
  self:assertEquals({ "a", "b", "c" }, StringUtils.split("abc", ""))

  -- Single letter delimiter
  self:assertEquals({ "b", "cd", "e", "fg" }, StringUtils.split("abacdaeafg", "a"))
  self:assertEquals({ "hello", "world" }, StringUtils.split("hello world", " "))
  self:assertEquals({ "Hel", "lo", "Univ", "erse" }, StringUtils.split("Hel;lo;Univ;erse", ";"))

  -- Multi letter delimiter
  self:assertEquals({ "a", "de", "fgbhbicjk" }, StringUtils.split("abcdebcfgbhbicjkbc", "bc"))

  -- Text ending with multiple delimiters in a row
  self:assertEquals({ "a", "b", "c" }, StringUtils.split("a b c   ", " "))

  -- Text starting with multiple delimiters in a row
  self:assertEquals({"hello", "test" }, StringUtils.split("cccchelloctest", "c"))

  -- Text containing multiple delimiters in a row
  self:assertEquals({ "good", "hello", "mytest" }, StringUtils.split("good~~~~hello~~~mytest~", "~"))

end


return TestStringUtils
