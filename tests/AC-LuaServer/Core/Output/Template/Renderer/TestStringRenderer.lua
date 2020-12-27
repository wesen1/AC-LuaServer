---
-- @author wesen
-- @copyright 2019-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"
local tablex = require "pl.tablex"

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
  { id = "Path", path = "AC-LuaServer.Core.Path", ["type"] = "table" },
  { id = "path", path = "pl.path", ["type"] = "table" }
}


---
-- Method that is called before a test is executed.
-- Sets up the pl.path method mocks.
--
function TestStringRenderer:setUp()
  TestCase.setUp(self)
  self.dependencyMocks.path.exists = self.mach.mock_function("pathmock.exists")
end


---
-- Checks that a template can be rendered without default and without custom template values.
--
function TestStringRenderer:testCanRenderStringWithoutTemplateValues()

  local pathMock = self.dependencyMocks.path
  local renderer = self:createTestInstance("/tmp/src")
  local renderedString

  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  templateMock.getTemplatePath
              :should_be_called()
              :and_will_return("TimeExtended")
              :and_then(
                pathMock.exists
                        :should_be_called_with("/tmp/src/AC-LuaServer/Templates/TimeExtended.template")
                        :and_will_return(true)
              )
              :and_also(
                templateMock.getTemplateValues
                            :should_be_called()
                            :and_will_return({})
              )
              :and_then(
                self:expectLuaRestyTemplateEngineRendering(
                  "/tmp/src/AC-LuaServer/Templates/TimeExtended.template",
                  { getAbsoluteTemplatePath = function(_value)
                      return (type(_value) == "function")
                    end
                  },
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

  local pathMock = self.dependencyMocks.path
  local renderer = self:createTestInstance("/home/wesen/server")
  local renderedString

  renderer:configure({
      defaultTemplateValues = { serverOwner = "unarmed" }
  })

  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  templateMock.getTemplatePath
              :should_be_called()
              :and_will_return("ServerInfo")
              :and_then(
                pathMock.exists
                        :should_be_called_with("/home/wesen/server/AC-LuaServer/Templates/ServerInfo.template")
                        :and_will_return(true)
              )
              :and_also(
                templateMock.getTemplateValues
                            :should_be_called()
                            :and_will_return({})
              )
              :and_then(
                self:expectLuaRestyTemplateEngineRendering(
                  "/home/wesen/server/AC-LuaServer/Templates/ServerInfo.template",
                  { getAbsoluteTemplatePath = function(_value)
                      return (type(_value) == "function")
                    end,
                    serverOwner = "unarmed"
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

  local pathMock = self.dependencyMocks.path
  local renderer = self:createTestInstance("/src")
  local renderedString

  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  templateMock.getTemplatePath
              :should_be_called()
              :and_will_return("PlayerDisconnected")
              :and_then(
                pathMock.exists
                        :should_be_called_with("/src/AC-LuaServer/Templates/PlayerDisconnected.template")
                        :and_will_return(true)
              )
              :and_also(
                templateMock.getTemplateValues
                            :should_be_called()
                            :and_will_return({ reason = "banned" })
              )
              :and_then(
                self:expectLuaRestyTemplateEngineRendering(
                  "/src/AC-LuaServer/Templates/PlayerDisconnected.template",
                  { getAbsoluteTemplatePath = function(_value)
                      return (type(_value) == "function")
                    end,
                    reason = "banned"
                  },
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

  local pathMock = self.dependencyMocks.path
  local renderer = self:createTestInstance("/etc/lua")
  local renderedString

  renderer:configure({
      defaultTemplateValues = { serverName = "best-server" }
  })

  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  templateMock.getTemplatePath
              :should_be_called()
              :and_will_return("Greeting")
              :and_then(
                pathMock.exists
                        :should_be_called_with("/etc/lua/AC-LuaServer/Templates/Greeting.template")
                        :and_will_return(true)
              )
              :and_also(
                templateMock.getTemplateValues
                            :should_be_called()
                            :and_will_return({ playerName = "random" })
              )
              :and_then(
                self:expectLuaRestyTemplateEngineRendering(
                  "/etc/lua/AC-LuaServer/Templates/Greeting.template",
                  { getAbsoluteTemplatePath = function(_value)
                      return (type(_value) == "function")
                    end,
                    serverName = "best-server",
                    playerName = "random"
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

  local pathMock = self.dependencyMocks.path
  local renderer = self:createTestInstance("/othertmp/src")
  local renderedString

  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  templateMock.getTemplatePath
              :should_be_called()
              :and_will_return("WithEmptyLines")
              :and_then(
                pathMock.exists
                        :should_be_called_with("/othertmp/src/AC-LuaServer/Templates/WithEmptyLines.template")
                        :and_will_return(true)
              )
              :and_also(
                templateMock.getTemplateValues
                            :should_be_called()
                            :and_will_return({})
              )
              :and_then(
                self:expectLuaRestyTemplateEngineRendering(
                  "/othertmp/src/AC-LuaServer/Templates/WithEmptyLines.template",
                  { getAbsoluteTemplatePath = function(_value)
                      return (type(_value) == "function")
                    end
                  },
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
  local pathMock = self.dependencyMocks.path
  local renderer = self:createTestInstance("/final")
  local renderedString

  local templateMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMockA"
  )
  templateMockA.getTemplatePath
               :should_be_called()
               :and_will_return("WhitespaceUsageA")
               :and_then(
                 pathMock.exists
                         :should_be_called_with("/final/AC-LuaServer/Templates/WhitespaceUsageA.template")
                         :and_will_return(true)
               )
               :and_also(
                 templateMockA.getTemplateValues
                              :should_be_called()
                              :and_will_return({})
               )
               :and_then(
                 self:expectLuaRestyTemplateEngineRendering(
                   "/final/AC-LuaServer/Templates/WhitespaceUsageA.template",
                   { getAbsoluteTemplatePath = function(_value)
                       return (type(_value) == "function")
                     end
                   },
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
                 pathMock.exists
                         :should_be_called_with("/final/AC-LuaServer/Templates/WhitespaceUsageB.template")
                         :and_will_return(true)
               )
               :and_also(
                 templateMockB.getTemplateValues
                              :should_be_called()
                              :and_will_return({})
               )
               :and_then(
                 self:expectLuaRestyTemplateEngineRendering(
                   "/final/AC-LuaServer/Templates/WhitespaceUsageB.template",
                   { getAbsoluteTemplatePath = function(_value)
                       return (type(_value) == "function")
                     end
                   },
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
-- Checks that the StringRenderer handles non existing templates as expected.
--
function TestStringRenderer:testCanHandleTemplateNotExisting()

  local pathMock = self.dependencyMocks.path
  local renderer = self:createTestInstance("/custom/stuff")
  local renderedString

  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  templateMock.getTemplatePath
              :should_be_called()
              :and_will_return("NotFound404")
              :and_then(
                pathMock.exists
                        :should_be_called_with("/custom/stuff/AC-LuaServer/Templates/NotFound404.template")
                        :and_will_return(false)
              )
              :and_also(
                templateMock.getTemplateValues
                            :should_be_called()
                            :and_will_return({})
              )
              :and_then(
                self:expectLuaRestyTemplateEngineRendering(
                  "NotFound404",
                  { getAbsoluteTemplatePath = function(_value)
                      return (type(_value) == "function")
                    end
                  },
                  "You gave me a wrong path"
                )
              )
              :when(
                function()
                  renderedString = renderer:render(templateMock)
                end
              )

  self:assertEquals("You gave me a wrong path", renderedString)

end

---
-- Checks that custom template base paths can be configured as expected.
--
function TestStringRenderer:testCanConfigureCustomTemplateBasePaths()

  local pathMock = self.dependencyMocks.path
  local renderer = self:createTestInstance("/custom/stuff")

  -- Configure some custom template base paths
  renderer:configure({
    templateBaseDirectoryPaths = {
      "/more/templates/",
      "my-templates-relative/path/"
    }
  })

  local renderedString

  -- Case A: Template does not exist
  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  templateMock.getTemplatePath
              :should_be_called()
              :and_will_return("CommandList")
              :and_then(
                pathMock.exists
                        :should_be_called_with("/more/templates/CommandList.template")
                        :and_will_return(false)
              )
              :and_then(
                pathMock.exists
                        :should_be_called_with("my-templates-relative/path/CommandList.template")
                        :and_will_return(false)
              )
              :and_then(
                pathMock.exists
                        :should_be_called_with("/custom/stuff/AC-LuaServer/Templates/CommandList.template")
                        :and_will_return(false)
              )
              :and_also(
                templateMock.getTemplateValues
                            :should_be_called()
                            :and_will_return({})
              )
              :and_then(
                self:expectLuaRestyTemplateEngineRendering(
                  "CommandList",
                  { getAbsoluteTemplatePath = function(_value)
                      return (type(_value) == "function")
                    end
                  },
                  "Template not found"
                )
              )
              :when(
                function()
                  renderedString = renderer:render(templateMock)
                end
              )

  self:assertEquals("Template not found", renderedString)


    -- Case B: Template exists in one of the custom directories
  templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  templateMock.getTemplatePath
              :should_be_called()
              :and_will_return("MapScoreManager/MapTop")
              :and_then(
                pathMock.exists
                        :should_be_called_with("/more/templates/MapScoreManager/MapTop.template")
                        :and_will_return(false)
              )
              :and_then(
                pathMock.exists
                        :should_be_called_with("my-templates-relative/path/MapScoreManager/MapTop.template")
                        :and_will_return(true)
              )
              :and_also(
                templateMock.getTemplateValues
                            :should_be_called()
                            :and_will_return({})
              )
              :and_then(
                self:expectLuaRestyTemplateEngineRendering(
                  "my-templates-relative/path/MapScoreManager/MapTop.template",
                  { getAbsoluteTemplatePath = function(_value)
                      return (type(_value) == "function")
                    end
                  },
                  "No map scores found for this map"
                )
              )
              :when(
                function()
                  renderedString = renderer:render(templateMock)
                end
              )

  self:assertEquals("No map scores found for this map", renderedString)

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
                                       self.mach.match(
                                         _templateValues,
                                         function(_expectedTemplateValues, _actualTemplateValues)
                                           self:assertEquals(
                                             tablex.keys(_templateValues),
                                             tablex.keys(_actualTemplateValues)
                                           )

                                           for key, expectedTemplateValue in pairs(_expectedTemplateValues) do
                                             local actualTemplateValue = _actualTemplateValues[key]
                                             if (type(expectedTemplateValue) == "function") then
                                               if (expectedTemplateValue(actualTemplateValue) == false) then
                                                 -- Custom matcher did not match
                                                 return false
                                               end
                                             else
                                               if (expectedTemplateValue ~= actualTemplateValue) then
                                                 return false
                                               end
                                             end
                                           end

                                           return true
                                         end
                                       )
                                     )
                                     :and_will_return(_returnValue)
                                   )

end

---
-- Creates and returns a StringRenderer instance.
--
-- @tparam string _sourceDirectoryPath The source directory path to inject into the StringRenderer instance
--
-- @treturn StringRenderer The created StringRenderer instance
--
function TestStringRenderer:createTestInstance(_sourceDirectoryPath)

  local StringRenderer = self.testClass
  local PathMock = self.dependencyMocks.Path

  local stringRenderer
  PathMock.getSourceDirectoryPath
          :should_be_called()
          :and_will_return(_sourceDirectoryPath)
          :when(
            function()
              stringRenderer = StringRenderer()
            end
          )

  return stringRenderer

end


return TestStringRenderer
