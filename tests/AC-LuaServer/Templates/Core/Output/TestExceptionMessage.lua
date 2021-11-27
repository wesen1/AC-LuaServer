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


-- TODO: AC-ClientOutput is broken for this, check if other branches contain fixes
function TestExceptionMessage:tesstCanBeRenderedWithMultiLineErrorMessage()

  -- The width of "[ERROR] " for the default font config is 312
  -- The width for the new line indent of the ExceptionMessage template is 310
  --
  self.output:configure({
      TemplateRenderer = {
        ClientOutputRenderer = {
          ClientOutputFactory = {
            maximumLineWidth = 312
          }
        }
      }
  })

  self.output:printTextTemplate(
    "Core/Output/ExceptionMessage",
    {
      exceptionMessage = "Alongword",
      colors = {
        ["error"] = "\f1"
      }
    }
  )

  self:assertEquals("[ERROR]", self.outputRows[1])
  self:assertEquals("          ", self.outputRows[2])

end


return TestExceptionMessage
