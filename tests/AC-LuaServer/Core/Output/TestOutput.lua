---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the Output works as expected.
--
-- @type TestOutput
--
local TestOutput = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestOutput.testClassPath = "AC-LuaServer.Core.Output.Output"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestOutput.dependencyPaths = {
  { id = "LuaServerApi", path = "AC-LuaServer.Core.LuaServerApi", ["type"] = "table" },
  { id = "Template", path = "AC-LuaServer.Core.Output.Template.Template" },
  { id = "TemplateRenderer", path = "AC-LuaServer.Core.Output.Template.TemplateRenderer" }
}


---
-- The TemplateRenderer mock that will be injected into the Output test instances
--
-- @tfield table templateRendererMock
--
TestOutput.templateRendererMock = nil


---
-- Method that is called before a test is executed.
-- Sets up the mocks.
--
function TestOutput:setUp()
  self.super.setUp(self)

  self.templateRendererMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateRenderer", "TemplateRendererMock"
  )
end

---
-- Method that is called after a test was executed.
-- Clears the mocks.
--
function TestOutput:tearDown()
  self.super.tearDown(self)

  self.templateRendererMock = nil
end


---
-- Checks that the internally used TemplateRenderer can be configured as expected.
--
function TestOutput:testCanConfigureTemplateRenderer()

  local output = self:createTestInstance()

  self.templateRendererMock.configure
                           :should_be_called_with(
                             self.mach.match({ StringRenderer = { prefix = "/tpl/AC-LuaServer" } })
                           )
                           :when(
                             function()
                               output:configure({
                                   TemplateRenderer = {
                                     StringRenderer = { prefix = "/tpl/AC-LuaServer" }
                                   }
                               })
                             end
                           )

end

---
-- Checks that text templates can be printed.
--
function TestOutput:testCanPrintTextTemplate()

  local TemplateMock = self.dependencyMocks.Template
  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template"
  )
  local targetPlayerMock = self:getMock(
    "AC-LuaServer.Core.PlayerList.Player", "TargetPlayerMock"
  )

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.clientprint = self.mach.mock_function("clientprint")

  local output = self:createTestInstance()

  TemplateMock.__call
              :should_be_called_with("TextTemplate/MapBest", self.mach.match({ milliseconds = 1234 }))
              :and_will_return(templateMock)
              :and_then(
                self.templateRendererMock.renderAsText
                                         :should_be_called_with(templateMock)
                                         :and_will_return({ "The best map record is 1234 ms" })
              )
              :and_then(
                targetPlayerMock.getCn
                                :should_be_called()
                                :and_will_return(4)
                                :and_then(
                                  LuaServerApiMock.clientprint
                                                  :should_be_called_with(
                                                    4, "The best map record is 1234 ms"
                                                  )
                                )
              )
              :when(
                function()
                  output:printTextTemplate(
                    "TextTemplate/MapBest", { milliseconds = 1234 }, targetPlayerMock
                  )
                end
              )

end

---
-- Checks that table templates can be printed.
--
function TestOutput:testCanPrintTableTemplate()

  local TemplateMock = self.dependencyMocks.Template
  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template"
  )
  local targetPlayerMock = self:getMock(
    "AC-LuaServer.Core.PlayerList.Player", "TargetPlayerMock"
  )

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.clientprint = self.mach.mock_function("clientprint")

  local output = self:createTestInstance()

  TemplateMock.__call
              :should_be_called_with("TableTemplate/MapTop", self.mach.match({ limit = 5 }))
              :and_will_return(templateMock)
              :and_then(
                self.templateRendererMock.renderAsTable
                                         :should_be_called_with(templateMock)
                                         :and_will_return({
                                           "The two best players of this map are:",
                                           "1) unarmed\t2m03s,500ms",
                                           "2) pro\t60m27s,001ms"
                                         })
              )

              -- Should print all the lines separately
              :and_then(
                targetPlayerMock.getCn
                                :should_be_called()
                                :and_will_return(7)
                                :and_then(
                                  LuaServerApiMock.clientprint
                                                  :should_be_called_with(
                                                    7, "The two best players of this map are:"
                                                  )
                                )
              )
              :and_then(
                targetPlayerMock.getCn
                                :should_be_called()
                                :and_will_return(7)
                                :and_then(
                                  LuaServerApiMock.clientprint
                                                  :should_be_called_with(
                                                    7, "1) unarmed\t2m03s,500ms"
                                                  )
                                )
              )
              :and_then(
                targetPlayerMock.getCn
                                :should_be_called()
                                :and_will_return(7)
                                :and_then(
                                  LuaServerApiMock.clientprint
                                                  :should_be_called_with(
                                                    7, "2) pro\t60m27s,001ms"
                                                  )
                                )
              )

              :when(
                function()
                  output:printTableTemplate("TableTemplate/MapTop", { limit = 5 }, targetPlayerMock)
                end
              )

end

---
-- Checks that Exception's can be printed.
--
function TestOutput:testCanPrintException()

  local TemplateMock = self.dependencyMocks.Template
  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template"
  )

  local exceptionMock = self:getMock(
    "AC-LuaServer.Core.Util.Exception.Exception", "ExceptionMock"
  )
  local targetPlayerMock = self:getMock(
    "AC-LuaServer.Core.PlayerList.Player", "TargetPlayerMock"
  )

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.clientprint = self.mach.mock_function("clientprint")

  local output = self:createTestInstance()

  exceptionMock.getMessage
               :should_be_called()
               :and_will_return("Could not extend time: No extend minutes remaining")
               :and_then(
                 TemplateMock.__call
                             :should_be_called_with(
                               "Core/Output/ExceptionMessage",
                               self.mach.match(
                                 { errorMessage = "Could not extend time: No extend minutes remaining" }
                               )
                             )
                             :and_will_return(templateMock)
               )
               :and_then(
                 self.templateRendererMock.renderAsText
                                          :should_be_called_with(templateMock)
                                          :and_will_return(
                                            { "[ERROR] Could not extend time: No extend minutes remaining" }
                                          )
               )
               :and_then(
                 targetPlayerMock.getCn
                                 :should_be_called()
                                 :and_will_return(12)
                                 :and_then(
                                   LuaServerApiMock.clientprint
                                                   :should_be_called_with(
                                                     12,
                                                     "[ERROR] Could not extend time: No extend minutes remaining"
                                                   )
                                 )
               )
               :when(
                 function()
                   output:printException(exceptionMock, targetPlayerMock)
                 end
               )

end

---
-- Checks that templates can be printed when no target Player is specified.
-- In that case -1 should be used as target cn to target all connected players.
--
function TestOutput:testCanPrintTemplateWhenNoTargetPlayerIsSpecified()

  local TemplateMock = self.dependencyMocks.Template
  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template"
  )

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.clientprint = self.mach.mock_function("clientprint")

  local output = self:createTestInstance()

  TemplateMock.__call
              :should_be_called_with("TextTemplate/GreetAll", self.mach.match({}))
              :and_will_return(templateMock)
              :and_then(
                self.templateRendererMock.renderAsText
                                         :should_be_called_with(templateMock)
                                         :and_will_return({ "Hello Everyone" })
              )
              :and_then(
                LuaServerApiMock.clientprint
                                :should_be_called_with(-1, "Hello Everyone")
              )
              :when(
                function()
                  output:printTextTemplate("TextTemplate/GreetAll", {})
                end
              )

end


---
-- Generates and returns a Output instance into which the TemplateRendererMock was injected.
--
-- @treturn Output The Output
--
function TestOutput:createTestInstance()

  local Output = self.testClass
  local TemplateRendererMock = self.dependencyMocks.TemplateRenderer

  local output
  TemplateRendererMock.__call
                      :should_be_called()
                      :and_will_return(self.templateRendererMock)
                      :when(
                        function()
                          output = Output()
                        end
                      )

  self:assertEquals(self.templateRendererMock, output:getTemplateRenderer())

  return output

end


return TestOutput
