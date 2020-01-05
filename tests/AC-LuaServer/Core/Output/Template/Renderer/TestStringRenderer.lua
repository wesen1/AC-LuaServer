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
  { id = "LuaRestyTemplateEngine", path = "resty.template", ["type"] = "table" },
  { id = "Path", path = "AC-LuaServer.Core.Path", ["type"] = "table" }
}


---
-- Checks that a template can be rendered without default and without custom template values.
--
function TestStringRenderer:testCanRenderStringWithoutTemplateValues()

  local StringRenderer = self.testClass
  local renderer = StringRenderer()
  local renderedString

  local PathMock = self.dependencyMocks.Path
  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  templateMock.getTemplatePath
              :should_be_called()
              :and_will_return("TimeExtended")
              :and_then(
                PathMock.getSourceDirectoryPath
                        :should_be_called()
                        :and_will_return("/tmp/src")
              )
              :and_also(
                templateMock.getTemplateValues
                            :should_be_called()
                            :and_will_return({})
              )
              :and_then(
                self:expectLuaRestyTemplateEngineRendering(
                  "/tmp/src/AC-LuaServer/Templates/TimeExtended.template",
                  { getAbsoluteTemplatePath = StringRenderer.getAbsoluteTemplatePath },
                  "Time extended by 10 minutes"
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

  local PathMock = self.dependencyMocks.Path
  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  templateMock.getTemplatePath
              :should_be_called()
              :and_will_return("ServerInfo")
              :and_then(
                PathMock.getSourceDirectoryPath
                        :should_be_called()
                        :and_will_return("/home/wesen/server")
              )
              :and_also(
                templateMock.getTemplateValues
                            :should_be_called()
                            :and_will_return({})
              )
              :and_then(
                self:expectLuaRestyTemplateEngineRendering(
                  "/home/wesen/server/AC-LuaServer/Templates/ServerInfo.template",
                  {
                    serverOwner = "unarmed",
                    getAbsoluteTemplatePath = StringRenderer.getAbsoluteTemplatePath
                  },
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

  local PathMock = self.dependencyMocks.Path
  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  templateMock.getTemplatePath
              :should_be_called()
              :and_will_return("PlayerDisconnected")
              :and_then(
                PathMock.getSourceDirectoryPath
                        :should_be_called()
                        :and_will_return("/src")
              )
              :and_also(
                templateMock.getTemplateValues
                            :should_be_called()
                            :and_will_return({ reason = "banned" })
              )
              :and_then(
                self:expectLuaRestyTemplateEngineRendering(
                  "/src/AC-LuaServer/Templates/PlayerDisconnected.template",
                  { reason = "banned", getAbsoluteTemplatePath = StringRenderer.getAbsoluteTemplatePath },
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

  local PathMock = self.dependencyMocks.Path
  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  templateMock.getTemplatePath
              :should_be_called()
              :and_will_return("Greeting")
              :and_then(
                PathMock.getSourceDirectoryPath
                        :should_be_called()
                        :and_will_return("/etc/lua")
              )
              :and_also(
                templateMock.getTemplateValues
                            :should_be_called()
                            :and_will_return({ playerName = "random" })
              )
              :and_then(
                self:expectLuaRestyTemplateEngineRendering(
                  "/etc/lua/AC-LuaServer/Templates/Greeting.template",
                  {
                    serverName = "best-server",
                    playerName = "random",
                    getAbsoluteTemplatePath = StringRenderer.getAbsoluteTemplatePath
                  },
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

  local PathMock = self.dependencyMocks.Path
  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  templateMock.getTemplatePath
              :should_be_called()
              :and_will_return("WithEmptyLines")
              :and_then(
                PathMock.getSourceDirectoryPath
                        :should_be_called()
                        :and_will_return("/othertmp/src")
              )
              :and_also(
                templateMock.getTemplateValues
                            :should_be_called()
                            :and_will_return({})
              )
              :and_then(
                self:expectLuaRestyTemplateEngineRendering(
                  "/othertmp/src/AC-LuaServer/Templates/WithEmptyLines.template",
                  { getAbsoluteTemplatePath = StringRenderer.getAbsoluteTemplatePath },
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

  local PathMock = self.dependencyMocks.Path
  local templateMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMockA"
  )
  templateMockA.getTemplatePath
               :should_be_called()
               :and_will_return("WhitespaceUsageA")
               :and_then(
                 PathMock.getSourceDirectoryPath
                         :should_be_called()
                         :and_will_return("/final")
               )
               :and_also(
                 templateMockA.getTemplateValues
                              :should_be_called()
                              :and_will_return({})
               )
               :and_then(
                 self:expectLuaRestyTemplateEngineRendering(
                   "/final/AC-LuaServer/Templates/WhitespaceUsageA.template",
                   { getAbsoluteTemplatePath = StringRenderer.getAbsoluteTemplatePath },
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
               :and_will_return("WhitespaceUsageB")
               :and_then(
                 PathMock.getSourceDirectoryPath
                         :should_be_called()
                         :and_will_return("/lib/luarocks")
               )
               :and_also(
                 templateMockB.getTemplateValues
                              :should_be_called()
                              :and_will_return({})
               )
               :and_then(
                 self:expectLuaRestyTemplateEngineRendering(
                   "/lib/luarocks/AC-LuaServer/Templates/WhitespaceUsageB.template",
                   { getAbsoluteTemplatePath = StringRenderer.getAbsoluteTemplatePath },
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
