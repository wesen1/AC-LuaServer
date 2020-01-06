---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TemplateTest = require "TestFrameWork.TemplateTest"

---
-- Checks that the GameModeWillChangeIfVotePasses.template works as expected.
--
-- @type TestGameModeWillChangeIfVotePasses
--
local TestGameModeWillChangeIfVotePasses = TemplateTest:extend()


---
-- Checks that the GameModeWillChangeIfVotePasses.template is rendered as expected.
--
function TestGameModeWillChangeIfVotePasses:testCanBeRendered()

  self.output:printTextTemplate(
    "Extensions/GameModeManager/GameModeWillChangeIfVotePasses",
    {
      nextGameModeName = "Default",
      colors = {
        ["info"] = "\f2",
        ["gameModeName"] = "\f4"
      }
    }
  )

  self:assertEquals(
    "\f2[INFO] The \f4Default\f2 game mode will be automatically activated if this vote passes.",
    self.outputRows[1]
  )

end


return TestGameModeWillChangeIfVotePasses
