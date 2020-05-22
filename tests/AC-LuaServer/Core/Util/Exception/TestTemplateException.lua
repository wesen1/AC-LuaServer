---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the TemplateException works as expected.
--
-- @type TestTemplateException
--
local TestTemplateException = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestTemplateException.testClassPath = "AC-LuaServer.Core.Util.Exception.TemplateException"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestTemplateException.dependencyPaths = {
  { id = "Template", path = "AC-LuaServer.Core.Output.Template.Template" },
  { id = "Server", path = "AC-LuaServer.Core.Server" }
}


---
-- Checks that a TemplateException can be created as expected.
--
function TestTemplateException:testCanBeCreated()

  local TemplateException = self.testClass

  local TemplateMock = self.dependencyMocks.Template
  local templateMock = self:getMock("AC-LuaServer.Core.Output.Template.Template", "TemplateMock")

  local templateException
  TemplateMock.__call
              :should_be_called_with(
                "TextTemplate/TestNotFoundException",
                self.mach.match({ testName = "testsCanBeCreated" })
              )
              :and_will_return(templateMock)
              :when(
                function()
                  templateException = TemplateException(
                    "TextTemplate/TestNotFoundException", { testName = "testsCanBeCreated" }
                  )
                end
              )


  local ServerMock = self.dependencyMocks.Server
  local serverMock = self:getMock("AC-LuaServer.Core.Server", "ServerMock")
  local outputMock = self:getMock("AC-LuaServer.Core.Output.Output", "OutputMock")
  local templateRendererMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateRenderer", "TemplateRendererMock"
  )

  local exceptionMessage
  ServerMock.getInstance
            :should_be_called()
            :and_will_return(serverMock)
            :and_then(
              serverMock.getOutput
                        :should_be_called()
                        :and_will_return(outputMock)
            )
            :and_then(
              outputMock.getTemplateRenderer
                        :should_be_called()
                        :and_will_return(templateRendererMock)
            )
            :and_then(
              templateRendererMock.renderAsRawText
                                  :should_be_called_with(templateMock)
                                  :and_will_return("Test \"testCanBeCreated\" could not be found")
            )
            :when(
              function()
                exceptionMessage = templateException:getMessage()
              end
            )

  self:assertEquals("Test \"testCanBeCreated\" could not be found", exceptionMessage)

end


return TestTemplateException
