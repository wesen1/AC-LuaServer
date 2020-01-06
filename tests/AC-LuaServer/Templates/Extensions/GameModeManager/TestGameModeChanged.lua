---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TemplateTest = require "TestFrameWork.TemplateTest"

---
-- Checks that the GameModeChanged.template works as expected.
--
-- @type TestGameModeChanged
--
local TestGameModeChanged = TemplateTest:extend()


---
-- Checks that the GameModeChanged.template is rendered as expected.
--
function TestGameModeChanged:testCanBeRendered()

  self.output:printTextTemplate(
    "Extensions/GameModeManager/GameModeChanged",
    {
      newGameModeName = "Gema",
      colors = {
        ["info"] = "\f9",
        ["gameModeName"] = "\f1"
      }
    }
  )

  self:assertEquals("\f9[INFO] The \f1Gema\f9 game mode was automatically activated.", self.outputRows[1])

end


return TestGameModeChanged
