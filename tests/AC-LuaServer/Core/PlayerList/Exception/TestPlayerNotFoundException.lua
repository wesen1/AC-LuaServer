---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the PlayerNotFoundException works as expected.
--
-- @type TestPlayerNotFoundException
--
local TestPlayerNotFoundException = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestPlayerNotFoundException.testClassPath = "AC-LuaServer.Core.PlayerList.Exception.PlayerNotFoundException"


---
-- Checks that the PlayerNotFoundException can be instantiated as expected.
--
function TestPlayerNotFoundException:testCanBeCreated()

  local PlayerNotFoundException = self.testClass
  local exception = PlayerNotFoundException(5)

  self:assertEquals(5, exception:getCn())
  self:assertEquals(
    "Could not create Player object from connected player: No player connected with client number 5",
    exception:getMessage()
  )

end


return TestPlayerNotFoundException
