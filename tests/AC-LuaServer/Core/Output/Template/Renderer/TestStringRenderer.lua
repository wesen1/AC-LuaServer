---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the StringRenderer works as expected.
--
-- @type TestStringRenderer
--
local TestStringRenderer = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestStringRenderer.testClassPath = "AC-LuaServer.Core.Output.Template.Renderer.StringRenderer"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestStringRenderer.dependencyPaths = {
  { id = "LuaRestyTemplateEngine", path = "resty.template", ["type"] = "table" }
}


---
-- Checks that a custom template path prefix can be configured as expected.
--
function TestStringRenderer:testCanConfigureCustomTemplatePathPrefix()

  local StringRenderer = self.testClass
  local renderer = StringRenderer()
  local renderedString

  -- Default prefix
  local templateMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMockA"
  )
  templateMockA.getTemplatePath
               :should_be_called()
               :and_will_return("TextTemplates/myexample")
               :and_also(
                 templateMockA.getTemplateValues
                              :should_be_called()
                              :and_will_return({})
               )
               :and_then(
                 self:expectLuaRestyTemplateEngineRendering(
                   "./TextTemplates/myexample.template", {}, "astring"
                 )
               )
               :when(
                 function()
                   renderedString = renderer:render(templateMockA)
                 end
               )

  self:assertEquals("astring", renderedString)


  -- Custom prefix
  renderer:configure({
      basePath = "/tmp/templates"
  })

  local templateMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMockB"
  )
  templateMockB.getTemplatePath
               :should_be_called()
               :and_will_return("TableTemplates/otherexample")
               :and_also(
                 templateMockB.getTemplateValues
                              :should_be_called()
                              :and_will_return({})
               )
               :and_then(
                 self:expectLuaRestyTemplateEngineRendering(
                   "/tmp/templates/TableTemplates/otherexample.template", {}, "atable"
                 )
               )
               :when(
                 function()
                   renderedString = renderer:render(templateMockB)
                 end
               )

  self:assertEquals("atable", renderedString)

end

---
-- Checks that a custom template path suffix can be configured as expected.
--
function TestStringRenderer:testCanConfigureCustomTemplatePathSuffix()

  local StringRenderer = self.testClass
  local renderer = StringRenderer()
  local renderedString

  -- Default suffix
  local templateMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  templateMockA.getTemplatePath
               :should_be_called()
               :and_will_return("TextTemplates/averyshorttext")
               :and_also(
                 templateMockA.getTemplateValues
                              :should_be_called()
                              :and_will_return({})
               )
               :and_then(
                 self:expectLuaRestyTemplateEngineRendering(
                   "./TextTemplates/averyshorttext.template", {}, "really?"
                 )
               )
               :when(
                 function()
                   renderedString = renderer:render(templateMockA)
                 end
               )

  self:assertEquals("really?", renderedString)

  -- Custom prefix
  renderer:configure({
      suffix = ".txt"
  })

  local templateMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMockB"
  )
  templateMockB.getTemplatePath
               :should_be_called()
               :and_will_return("TableTemplates/PlayerScore")
               :and_also(
                 templateMockB.getTemplateValues
                              :should_be_called()
                              :and_will_return({})
               )
               :and_then(
                 self:expectLuaRestyTemplateEngineRendering(
                   "./TableTemplates/PlayerScore.txt", {}, "unarmed scored after 0 seconds"
                 )
               )
               :when(
                 function()
                   renderedString = renderer:render(templateMockB)
                 end
               )

  self:assertEquals("unarmed scored after 0 seconds", renderedString)

end

---
-- Checks that a template can be rendered without default and without custom template values.
--
function TestStringRenderer:testCanRenderStringWithoutTemplateValues()

  local StringRenderer = self.testClass
  local renderer = StringRenderer()
  local renderedString

  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  templateMock.getTemplatePath
              :should_be_called()
              :and_will_return("TextTemplates/TimeExtended")
              :and_also(
                templateMock.getTemplateValues
                            :should_be_called()
                            :and_will_return({})
              )
              :and_then(
                self:expectLuaRestyTemplateEngineRendering(
                  "./TextTemplates/TimeExtended.template", {}, "Time extended by 10 minutes"
                )
              )
              :when(
                function()
                  renderedString = renderer:render(templateMock)
                end
              )

  self:assertEquals("Time extended by 10 minutes", renderedString)

end

---
-- Checks that a template can be rendered with default and without custom template values.
--
function TestStringRenderer:testCanRenderStringWithOnlyDefaultTemplateValues()

  local StringRenderer = self.testClass
  local renderer = StringRenderer()
  local renderedString

  renderer:configure({
      defaultTemplateValues = { serverOwner = "unarmed" }
  })

  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  templateMock.getTemplatePath
              :should_be_called()
              :and_will_return("TextTemplates/ServerInfo")
              :and_also(
                templateMock.getTemplateValues
                            :should_be_called()
                            :and_will_return({})
              )
              :and_then(
                self:expectLuaRestyTemplateEngineRendering(
                  "./TextTemplates/ServerInfo.template",
                  { serverOwner = "unarmed" },
                  "AC-LuaServer hosted by unarmed"
                )
              )
              :when(
                function()
                  renderedString = renderer:render(templateMock)
                end
              )

  self:assertEquals("AC-LuaServer hosted by unarmed", renderedString)

end

---
-- Checks that a template can be rendered without default and with custom template values.
--
function TestStringRenderer:testCanRenderStringWithOnlyCustomTemplateValues()

  local StringRenderer = self.testClass
  local renderer = StringRenderer()
  local renderedString

  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  templateMock.getTemplatePath
              :should_be_called()
              :and_will_return("TextTemplates/PlayerDisconnected")
              :and_also(
                templateMock.getTemplateValues
                            :should_be_called()
                            :and_will_return({ reason = "banned" })
              )
              :and_then(
                self:expectLuaRestyTemplateEngineRendering(
                  "./TextTemplates/PlayerDisconnected.template",
                  { reason = "banned" },
                  "Player could not connect (banned)"
                )
              )
              :when(
                function()
                  renderedString = renderer:render(templateMock)
                end
              )

  self:assertEquals("Player could not connect (banned)", renderedString)

end

---
-- Checks that a template can be rendered with default and with custom template values.
--
function TestStringRenderer:testCanRenderStringWithDefaultAndCustomTemplateValues()

  local StringRenderer = self.testClass
  local renderer = StringRenderer()
  local renderedString

  renderer:configure({
      defaultTemplateValues = { serverName = "best-server" }
  })

  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  templateMock.getTemplatePath
              :should_be_called()
              :and_will_return("TextTemplates/Greeting")
              :and_also(
                templateMock.getTemplateValues
                            :should_be_called()
                            :and_will_return({ playerName = "random" })
              )
              :and_then(
                self:expectLuaRestyTemplateEngineRendering(
                  "./TextTemplates/Greeting.template",
                  { serverName = "best-server", playerName = "random" },
                  "[best-server] Welcome to our server random!"
                )
              )
              :when(
                function()
                  renderedString = renderer:render(templateMock)
                end
              )

  self:assertEquals("[best-server] Welcome to our server random!", renderedString)

end

---
-- Checks that line endings and leading and trailing whitespace are while rendering the template.
--
function TestStringRenderer:testCanRemoveLineEndingsAndBorderingWhitespace()

  local StringRenderer = self.testClass
  local renderer = StringRenderer()
  local renderedString

  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  templateMock.getTemplatePath
              :should_be_called()
              :and_will_return("TextTemplates/WithEmptyLines")
              :and_also(
                templateMock.getTemplateValues
                            :should_be_called()
                            :and_will_return({})
              )
              :and_then(
                self:expectLuaRestyTemplateEngineRendering(
                  "./TextTemplates/WithEmptyLines.template",
                  {},
                  "    Next line is empty   \n\n\n\n   Next line is empty with whitespace\n  \n  \n\nSee?   "
                )
              )
              :when(
                function()
                  renderedString = renderer:render(templateMock)
                end
              )

  self:assertEquals("Next line is emptyNext line is empty with whitespaceSee?", renderedString)

end

---
-- Checks that "<whitespace>" tags are replaced as expected.
--
function TestStringRenderer:testCanReplaceWhitespaceTags()

  -- Test A: <whitespace> (Should result in " ")
  local StringRenderer = self.testClass
  local renderer = StringRenderer()
  local renderedString

  local templateMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMockA"
  )
  templateMockA.getTemplatePath
               :should_be_called()
               :and_will_return("TextTemplates/WhitespaceUsageA")
               :and_also(
                 templateMockA.getTemplateValues
                              :should_be_called()
                              :and_will_return({})
               )
               :and_then(
                 self:expectLuaRestyTemplateEngineRendering(
                   "./TextTemplates/WhitespaceUsageA.template",
                   {},
                   "Whitespace in separate line upcoming:\n<whitespace>\nDone"
                 )
               )
               :when(
                 function()
                   renderedString = renderer:render(templateMockA)
                 end
               )

  self:assertEquals("Whitespace in separate line upcoming: Done", renderedString)


  -- Test B: <whitespace:4> (Should result in "    ")
  local templateMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMockB"
  )
  templateMockB.getTemplatePath
               :should_be_called()
               :and_will_return("TextTemplates/WhitespaceUsageB")
               :and_also(
                 templateMockB.getTemplateValues
                              :should_be_called()
                              :and_will_return({})
               )
               :and_then(
                 self:expectLuaRestyTemplateEngineRendering(
                   "./TextTemplates/WhitespaceUsageB.template",
                   {},
                   "Multiple whitespaces in a row:\n<whitespace:5>\nCool!"
                 )
               )
               :when(
                 function()
                   renderedString = renderer:render(templateMockB)
                 end
               )

  self:assertEquals("Multiple whitespaces in a row:     Cool!", renderedString)

end


---
-- Returns the expectations for when a template is rendered using the lua-resty-template dependency.
--
-- @tparam string _templatePath The expected template path
-- @tparam mixed[] _templateValues The expected template values
-- @tparam string _returnValue The value that will be returned as rendered template string
--
-- @treturn table The expectations
--
function TestStringRenderer:expectLuaRestyTemplateEngineRendering(_templatePath, _templateValues, _returnValue)

  local LuaRestyTemplateEngineMock = self.dependencyMocks.LuaRestyTemplateEngine
  local compiledTemplateFunctionMock = self.mach.mock_function("compiledTemplate")

  return LuaRestyTemplateEngineMock.compile
                                   :should_be_called_with(_templatePath)
                                   :and_will_return(compiledTemplateFunctionMock)
                                   :and_then(
                                     compiledTemplateFunctionMock.should_be_called_with(
                                                                   self.mach.match(_templateValues)
                                                                 )
                                                                 :and_will_return(_returnValue)
                                   )

end


return TestStringRenderer
