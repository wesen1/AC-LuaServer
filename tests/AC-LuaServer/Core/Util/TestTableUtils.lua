---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the table utils work as expected.
--
-- @type TestTableUtils
--
local TestTableUtils = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestTableUtils.testClassPath = "AC-LuaServer.Core.Util.TableUtils"


---
-- Checks that the tableHasValue method works as expected.
--
function TestTableUtils:testCanReturnWhetherTableHasValue()

  local TableUtils = self.testClass

  -- Search table does not contain the searched item
  self:assertFalse(
    TableUtils.tableHasValue({ "a", "b", "c", "d", "e" }, "f")
  )

  -- Search table is empty
  self:assertFalse(TableUtils.tableHasValue({}, "a"))

  -- Search table contains item at start
  self:assertTrue(
    TableUtils.tableHasValue({ "a", "b", "c", "d" }, "a")
  )

  -- Search table contains item between start and end
  self:assertTrue(
    TableUtils.tableHasValue({ "a", "b", "c", "d" }, "b")
  )

  -- Search table contains item at end
  self:assertTrue(
    TableUtils.tableHasValue({ "a", "b", "c", "d" }, "d")
  )

  -- Search table contains search item multiple times
  self:assertTrue(
    TableUtils.tableHasValue({ 1, 2, 1, 3, 4, 5, 1 }, 1)
  )

  -- Search table contains items that start with search item text
  self:assertFalse(
    TableUtils.tableHasValue({ "abcde", "fghij", "klmno" }, "abc")
  )

  -- Search table is an associative array
  self:assertTrue(
    TableUtils.tableHasValue({ ItemA = "a", ItemB = "b", ItemC = "c"}, "b")
  )

end


return TestTableUtils
