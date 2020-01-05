---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TemplateTest = require "TestFrameWork.TemplateTest"

---
-- Checks that the ExceptionMessage.template works as expected.
--
-- @type TestExceptionMessage
--
local TestExceptionMessage = TemplateTest:extend()


---
-- Checks that the ExceptionMessage.template is rendered as expected.
--
function TestExceptionMessage:testCanBeRendered()

  self.output:printTextTemplate(
    "Core/Output/ExceptionMessage",
    {
      exceptionMessage = "Tried to compare nil with number",
      colors = {
        ["error"] = "\f3"
      }
    }
  )

  self:assertEquals("\f3[ERROR] Tried to compare nil with number", self.outputRows[1])

end


return TestExceptionMessage
