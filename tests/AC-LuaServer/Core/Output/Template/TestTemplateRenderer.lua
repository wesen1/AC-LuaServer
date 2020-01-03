---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the TemplateRenderer works as expected.
--
-- @type TestTemplateRenderer
--
local TestTemplateRenderer = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestTemplateRenderer.testClassPath = "AC-LuaServer.Core.Output.Template.TemplateRenderer"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestTemplateRenderer.dependencyPaths = {
  { id = "ClientOutputRenderer", path = "AC-LuaServer.Core.Output.Template.Renderer.ClientOutputRenderer" },
  { id = "StringRenderer", path = "AC-LuaServer.Core.Output.Template.Renderer.StringRenderer" },
  { id = "TemplateNodeTree", path = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TemplateNodeTree" }
}


---
-- The ClientOutputRenderer mock that will be injected into the TemplateRenderer test instances
--
-- @tfield table clientOutputRendererMock
--
TestTemplateRenderer.clientOutputRendererMock = nil

---
-- The StringRenderer mock that will be injected into the TemplateRenderer test instances
--
-- @tfield table stringRendererMock
--
TestTemplateRenderer.stringRendererMock = nil


---
-- Method that is called before a test is executed.
-- Sets up the mocks.
--
function TestTemplateRenderer:setUp()
  self.super.setUp(self)

  self.clientOutputRendererMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Renderer.ClientOutputRenderer", "ClientOutputRendererMock"
  )
  self.stringRendererMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Renderer.StringRenderer", "StringRendererMock"
  )
end

---
-- Method that is called after a test was executed.
-- Clears the mocks.
--
function TestTemplateRenderer:tearDown()
  self.super.tearDown(self)

  self.clientOutputRendererMock = nil
  self.stringRendererMock = nil
end


---
-- Checks that the internally used ClientOutputRenderer can be configured as expected.
--
function TestTemplateRenderer:testCanConfigureClientOutputRenderer()

  local templateRenderer = self:createTestInstance()

  self.clientOutputRendererMock.configure
                               :should_be_called_with(
                                 self.mach.match(
                                   { ClientOutputFactory = { fontConfigFileName = "FontDefault" } }
                                 )
                               )
                               :when(
                                 function()
                                   templateRenderer:configure({
                                       ClientOutputRenderer = {
                                         ClientOutputFactory = { fontConfigFileName = "FontDefault" }
                                       }
                                   })
                                 end
                               )

end

---
-- Checks that the internally used StringRenderer can be configured as expected.
--
function TestTemplateRenderer:testCanConfigureStringRenderer()

  local templateRenderer = self:createTestInstance()

  self.stringRendererMock.configure
                         :should_be_called_with(self.mach.match({ suffix = ".tpl" }))
                         :when(
                           function()
                             templateRenderer:configure({
                                 StringRenderer = { suffix = ".tpl"}
                             })
                           end
                         )

end


---
-- Checks that a Template can be rendered as a table as expected.
--
function TestTemplateRenderer:testCanRenderTemplateAsTable()

  local templateRenderer = self:createTestInstance()

  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  local rootNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RootNodeMock"
  )
  local clientOutputTableMock = self:getMock(
    "AC-ClientOutput.ClientOutput.ClientOutputTable.ClientOutputTable", "ClientOutputTableMock"
  )

  local generatedOutputRows
  self:expectTemplateParsing(templateMock, rootNodeMock)
      :and_then(
        self.clientOutputRendererMock.renderAsClientOutputTable
                                     :should_be_called_with(rootNodeMock)
                                     :and_will_return(clientOutputTableMock)
      )
      :and_then(
        clientOutputTableMock.getOutputRows
                             :should_be_called()
                             :and_will_return({"This\tis", "a\ttable", "with\ttwo columns"})
      )
      :when(
        function()
          generatedOutputRows = templateRenderer:renderAsTable(templateMock)
        end
      )

  self:assertEquals({"This\tis", "a\ttable", "with\ttwo columns"}, generatedOutputRows)

end

---
-- Checks that a Template can be rendered as a text as expected.
--
function TestTemplateRenderer:testCanRenderTemplateAsText()

  local templateRenderer = self:createTestInstance()

  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  local rootNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RootNodeMock"
  )
  local clientOutputStringMock = self:getMock(
    "AC-ClientOutput.ClientOutput.ClientOutputString.ClientOutputString", "ClientOutputStringMock"
  )

  local generatedOutputRows
  self:expectTemplateParsing(templateMock, rootNodeMock)
      :and_then(
        self.clientOutputRendererMock.renderAsClientOutputString
                                     :should_be_called_with(rootNodeMock)
                                     :and_will_return(clientOutputStringMock)
      )
      :and_then(
        clientOutputStringMock.getOutputRows
                              :should_be_called()
                              :and_will_return({
                                "This is just a string that is split into two rows",
                                "because it's too long"
                              })
      )
      :when(
        function()
          generatedOutputRows = templateRenderer:renderAsText(templateMock)
        end
      )

  self:assertEquals(
    {"This is just a string that is split into two rows", "because it's too long"},
    generatedOutputRows
  )

end

---
-- Checks that a Template can be rendered as a raw text as expected.
--
function TestTemplateRenderer:testCanRenderTemplateAsRawText()

  local templateRenderer = self:createTestInstance()

  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  local rootNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RootNodeMock"
  )
  local contentNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "ContentNodeMock"
  )

  local generatedString
  self:expectTemplateParsing(templateMock, rootNodeMock)
      :and_then(
        rootNodeMock.find
                    :should_be_called_with("content")
                    :and_will_return({ contentNodeMock })
      )
      :and_then(
        contentNodeMock.toString
                       :should_be_called()
                       :and_will_return("This is the raw one line template string")
      )
      :when(
        function()
          generatedString = templateRenderer:renderAsRawText(templateMock)
        end
      )

  self:assertEquals("This is the raw one line template string", generatedString)

end

---
-- Checks that a Template can be rendered as a raw text when there is no content node in the template.
--
function TestTemplateRenderer:testCanRenderTemplateAsRawTextWhenItHasNoContent()

  local templateRenderer = self:createTestInstance()

  local templateMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.Template", "TemplateMock"
  )
  local rootNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RootNodeMock"
  )

  local generatedOutputRows
  self:expectTemplateParsing(templateMock, rootNodeMock)
      :and_then(
        rootNodeMock.find
                    :should_be_called_with("content")
                    :and_will_return({})
      )
      :when(
        function()
          generatedOutputRows = templateRenderer:renderAsRawText(templateMock)
        end
      )

  self:assertEquals("", generatedOutputRows)

end

---
-- Returns the expectations for when a Template is parsed into a tree of TemplateNode's.
--
-- @tparam Template _template The Template that is expected to be parsed
-- @tparam RootNode _rootNodeMock The RootNode mock that will be returned as parsed template
--
function TestTemplateRenderer:expectTemplateParsing(_template, _rootNodeMock)

  local TemplateNodeTreeMock = self.dependencyMocks.TemplateNodeTree
  local templateNodetreeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TemplateNodeTree", "TemplateNodeTreeMock"
  )

  return self.stringRendererMock.render
                                :should_be_called_with(_template)
                                :and_will_return("A____;rendered<whitespace>template")
                                :and_then(
                                  TemplateNodeTreeMock.__call
                                                      :should_be_called()
                                                      :and_will_return(templateNodetreeMock)
                                )
                                :and_then(
                                  templateNodetreeMock.parse
                                                      :should_be_called_with(
                                                        "A____;rendered<whitespace>template"
                                                      )
                                )
                                :and_then(
                                  templateNodetreeMock.getRootNode
                                                      :should_be_called()
                                                      :and_will_return(_rootNodeMock)
                                )

end


---
-- Generates and returns a TemplateRenderer instance into which the ClientOutputRenderer
-- and StringRenderer mocks were injected.
--
-- @treturn TemplateRenderer The TemplateRenderer
--
function TestTemplateRenderer:createTestInstance()

  local TemplateRenderer = self.testClass

  local ClientOutputRendererMock = self.dependencyMocks.ClientOutputRenderer
  local StringRendererMock = self.dependencyMocks.StringRenderer

  local templateRenderer
  ClientOutputRendererMock.__call
                          :should_be_called()
                          :and_will_return(self.clientOutputRendererMock)
                          :and_also(
                            StringRendererMock.__call
                                              :should_be_called()
                                              :and_will_return(self.stringRendererMock)
                          )
                          :when(
                            function()
                              templateRenderer = TemplateRenderer()
                            end
                          )

  return templateRenderer

end


return TestTemplateRenderer
