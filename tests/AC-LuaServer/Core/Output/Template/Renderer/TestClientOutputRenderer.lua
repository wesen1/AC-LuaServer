---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the ClientOutputRenderer works as expected.
--
-- @type TestClientOutputRenderer
--
local TestClientOutputRenderer = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestClientOutputRenderer.testClassPath = "AC-LuaServer.Core.Output.Template.Renderer.ClientOutputRenderer"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestClientOutputRenderer.dependencyPaths = {
  { id = "ClientOutputFactory", path = "AC-ClientOutput.ClientOutputFactory" }
}


---
-- The ClientOutputFactory mock that will be injected into the ClientOutputRenderer test instances
--
-- @tfield table clientOutputFactoryMock
--
TestClientOutputRenderer.clientOutputFactoryMock = nil


---
-- Method that is called before a test is executed.
-- Sets up the mocks.
--
function TestClientOutputRenderer:setUp()
  self.super.setUp(self)

  self.clientOutputFactoryMock = self:getMock("AC-ClientOutput.ClientOutputFactory", "ClientOutputFactoryMock"
  )
end

---
-- Method that is called after a test was executed.
-- Clears the mocks.
--
function TestClientOutputRenderer:tearDown()
  self.super.tearDown(self)

  self.clientOutputFactoryMock = nil
end


---
-- Checks that a ClientOutputRenderer can be configured as expected.
--
function TestClientOutputRenderer:testCanBeConfigured()

  local clientOutputRenderer = self:createTestInstance()

  -- Invalid config
  clientOutputRenderer:configure("abctest123")

  -- Valid config, but no config for the ClientOutputFactory
  clientOutputRenderer:configure({})

  -- Invalid config entry for ClientOutputFactory
  clientOutputRenderer:configure({ ClientOutputFactory = "textinsteadoftable" })

  -- Valid but empty config entry for ClientOutputFactory
  self.clientOutputFactoryMock.configure
                              :should_be_called_with(self.mach.match({}))
                              :when(
                                function()
                                  clientOutputRenderer:configure({ ClientOutputFactory = {} })
                                end
                              )

  -- Valid config entry for ClientOutputFactory with some values
  self.clientOutputFactoryMock.configure
                              :should_be_called_with(
                                self.mach.match({ maximumLineWidth = 4000, newLineIndent = "> " })
                              )
                              :when(
                                function()
                                  clientOutputRenderer:configure({
                                    ClientOutputFactory = { maximumLineWidth = 4000, newLineIndent = "> " }
                                  })
                                end
                              )

end

---
-- Checks that the ClientOutputRenderer can render RootNode's as ClientOutputString's as expected.
--
function TestClientOutputRenderer:testCanRenderAsClientOutputString()

  local clientOutputRenderer = self:createTestInstance()
  local generatedClientOutputString

  -- With config and with content
  local rootNodeMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RootNodeMockA"
  )
  local configNodeMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "ConfigNodeMockA"
  )
  local contentNodeMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "ContentNodeMockA"
  )
  local clientOutputStringMockA = self:getMock(
    "AC-ClientOutput.ClientOutput.ClientOutputString.ClientOutputString", "ClientOutputStringMockA"
  )

  rootNodeMockA.find
               :should_be_called_with("config")
               :and_will_return({ configNodeMockA })
               :and_also(
                 rootNodeMockA.find
                              :should_be_called_with("content")
                              :and_will_return({ contentNodeMockA })
               )
               :and_then(
                 configNodeMockA.toTable
                                :should_be_called()
                                :and_will_return({ configA = "value", configB = "test" })
               )
               :and_also(
                 contentNodeMockA.toString
                                 :should_be_called()
                                 :and_will_return("some example template content")
               )
               :and_then(
                 self.clientOutputFactoryMock.getClientOutputString
                                             :should_be_called_with(
                                               "some example template content",
                                               self.mach.match({ configA = "value", configB = "test" })
                                             )
                                             :and_will_return(clientOutputStringMockA)
               )
               :when(
                 function()
                   generatedClientOutputString = clientOutputRenderer:renderAsClientOutputString(rootNodeMockA)
                 end
               )

  self:assertEquals(clientOutputStringMockA, generatedClientOutputString)


  -- Without config and with content
  local rootNodeMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RootNodeMockB"
  )
  local contentNodeMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "ContentNodeMockB"
  )
  local clientOutputStringMockB = self:getMock(
    "AC-ClientOutput.ClientOutput.ClientOutputString.ClientOutputString", "ClientOutputStringMockB"
  )

  rootNodeMockB.find
               :should_be_called_with("config")
               :and_will_return({})
               :and_also(
                 rootNodeMockB.find
                              :should_be_called_with("content")
                              :and_will_return({ contentNodeMockB })
               )
               :and_also(
                 contentNodeMockB.toString
                                 :should_be_called()
                                 :and_will_return("only text, no config")
               )
               :and_then(
                 self.clientOutputFactoryMock.getClientOutputString
                                             :should_be_called_with("only text, no config")
                                             :and_will_return(clientOutputStringMockB)
               )
               :when(
                 function()
                   generatedClientOutputString = clientOutputRenderer:renderAsClientOutputString(rootNodeMockB)
                 end
               )

  self:assertEquals(clientOutputStringMockB, generatedClientOutputString)


    -- With config and without content
  local rootNodeMockC = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RootNodeMockC"
  )
  local configNodeMockC = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "ConfigNodeMockC"
  )
  local clientOutputStringMockC = self:getMock(
    "AC-ClientOutput.ClientOutput.ClientOutputString.ClientOutputString", "ClientOutputStringMockC"
  )

  rootNodeMockC.find
               :should_be_called_with("config")
               :and_will_return({ configNodeMockC })
               :and_also(
                 rootNodeMockC.find
                              :should_be_called_with("content")
                              :and_will_return({})
               )
               :and_then(
                 configNodeMockC.toTable
                                :should_be_called()
                                :and_will_return({ entry1 = 500, entry6 = "number" })
               )
               :and_then(
                 self.clientOutputFactoryMock.getClientOutputString
                                             :should_be_called_with(
                                               "",
                                               self.mach.match({ entry1 = 500, entry6 = "number" })
                                             )
                                             :and_will_return(clientOutputStringMockC)
               )
               :when(
                 function()
                   generatedClientOutputString = clientOutputRenderer:renderAsClientOutputString(rootNodeMockC)
                 end
               )

  self:assertEquals(clientOutputStringMockC, generatedClientOutputString)


  -- Without config and without content
  local rootNodeMockD = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RootNodeMockD"
  )
  local clientOutputStringMockD = self:getMock(
    "AC-ClientOutput.ClientOutput.ClientOutputString.ClientOutputString", "ClientOutputStringMockD"
  )

  rootNodeMockD.find
               :should_be_called_with("config")
               :and_will_return({})
               :and_also(
                 rootNodeMockD.find
                              :should_be_called_with("content")
                              :and_will_return({})
               )
               :and_then(
                 self.clientOutputFactoryMock.getClientOutputString
                                             :should_be_called_with("")
                                             :and_will_return(clientOutputStringMockD)
               )
               :when(
                 function()
                   generatedClientOutputString = clientOutputRenderer:renderAsClientOutputString(rootNodeMockD)
                 end
               )

  self:assertEquals(clientOutputStringMockD, generatedClientOutputString)

end

---
-- Checks that the ClientOutputRenderer can render RootNode's as ClientOutputTable's as expected.
--
function TestClientOutputRenderer:testCanRenderAsClientOutputTable()

  local clientOutputRenderer = self:createTestInstance()
  local generatedClientOutputTable

  -- With config and with content
  local rootNodeMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RootNodeMockA"
  )
  local configNodeMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "ConfigNodeMockA"
  )
  local contentNodeMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "ContentNodeMockA"
  )
  local clientOutputTableMockA = self:getMock(
    "AC-ClientOutput.ClientOutput.ClientOutputTable.ClientOutputTable", "ClientOutputTableMockA"
  )

  rootNodeMockA.find
               :should_be_called_with("config")
               :and_will_return({ configNodeMockA })
               :and_also(
                 rootNodeMockA.find
                              :should_be_called_with("content")
                              :and_will_return({ contentNodeMockA })
               )
               :and_then(
                 configNodeMockA.toTable
                                :should_be_called()
                                :and_will_return({ AConfig = "string", BConfig = 56.2 })
               )
               :and_also(
                 contentNodeMockA.toTable
                                 :should_be_called()
                                 :and_will_return({ "some", "example", "template", "content" })
               )
               :and_then(
                 self.clientOutputFactoryMock.getClientOutputTable
                                             :should_be_called_with(
                                               self.mach.match({ "some", "example", "template", "content" }),
                                               self.mach.match({ AConfig = "string", BConfig = 56.2 })
                                             )
                                             :and_will_return(clientOutputTableMockA)
               )
               :when(
                 function()
                   generatedClientOutputTable = clientOutputRenderer:renderAsClientOutputTable(rootNodeMockA)
                 end
               )

  self:assertEquals(clientOutputTableMockA, generatedClientOutputTable)


  -- Without config and with content
  local rootNodeMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RootNodeMockB"
  )
  local contentNodeMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "ContentNodeMockB"
  )
  local clientOutputTableMockB = self:getMock(
    "AC-ClientOutput.ClientOutput.ClientOutputTable.ClientOutputTable", "ClientOutputTableMockB"
  )

  rootNodeMockB.find
               :should_be_called_with("config")
               :and_will_return({})
               :and_also(
                 rootNodeMockB.find
                              :should_be_called_with("content")
                              :and_will_return({ contentNodeMockB })
               )
               :and_also(
                 contentNodeMockB.toTable
                                 :should_be_called()
                                 :and_will_return({ "only", "text,", "no", "config" })
               )
               :and_then(
                 self.clientOutputFactoryMock.getClientOutputTable
                                             :should_be_called_with(
                                               self.mach.match({ "only", "text,", "no", "config" })
                                             )
                                             :and_will_return(clientOutputTableMockB)
               )
               :when(
                 function()
                   generatedClientOutputTable = clientOutputRenderer:renderAsClientOutputTable(rootNodeMockB)
                 end
               )

  self:assertEquals(clientOutputTableMockB, generatedClientOutputTable)


    -- With config and without content
  local rootNodeMockC = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RootNodeMockC"
  )
  local configNodeMockC = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "ConfigNodeMockC"
  )
  local clientOutputTableMockC = self:getMock(
    "AC-ClientOutput.ClientOutput.ClientOutputTable.ClientOutputTable", "ClientOutputTableMockC"
  )

  rootNodeMockC.find
               :should_be_called_with("config")
               :and_will_return({ configNodeMockC })
               :and_also(
                 rootNodeMockC.find
                              :should_be_called_with("content")
                              :and_will_return({})
               )
               :and_then(
                 configNodeMockC.toTable
                                :should_be_called()
                                :and_will_return({ anotherConfig = 1293987 })
               )
               :and_then(
                 self.clientOutputFactoryMock.getClientOutputTable
                                             :should_be_called_with(
                                               self.mach.match({}),
                                               self.mach.match({ anotherConfig = 1293987 })
                                             )
                                             :and_will_return(clientOutputTableMockC)
               )
               :when(
                 function()
                   generatedClientOutputTable = clientOutputRenderer:renderAsClientOutputTable(rootNodeMockC)
                 end
               )

  self:assertEquals(clientOutputTableMockC, generatedClientOutputTable)


  -- Without config and without content
  local rootNodeMockD = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RootNodeMockD"
  )
  local clientOutputTableMockD = self:getMock(
    "AC-ClientOutput.ClientOutput.ClientOutputTable.ClientOutputTable", "ClientOutputTableMockD"
  )

  rootNodeMockD.find
               :should_be_called_with("config")
               :and_will_return({})
               :and_also(
                 rootNodeMockD.find
                              :should_be_called_with("content")
                              :and_will_return({})
               )
               :and_then(
                 self.clientOutputFactoryMock.getClientOutputTable
                                             :should_be_called_with(self.mach.match({}))
                                             :and_will_return(clientOutputTableMockD)
               )
               :when(
                 function()
                   generatedClientOutputTable = clientOutputRenderer:renderAsClientOutputTable(rootNodeMockD)
                 end
               )

  self:assertEquals(clientOutputTableMockD, generatedClientOutputTable)

end


---
-- Generates and returns a ClientOutputRenderer instance into which the ClientOutputFactory
-- mock was injected.
--
-- @treturn ClientOutputRenderer The ClientOutputRenderer
--
function TestClientOutputRenderer:createTestInstance()

  local ClientOutputRenderer = self.testClass

  local ClientOutputFactoryMock = self.dependencyMocks.ClientOutputFactory
  ClientOutputFactoryMock.__call = self.mach.mock_method("__call")

  local clientOutputRenderer
  ClientOutputFactoryMock.__call
                         :should_be_called()
                         :and_will_return(self.clientOutputFactoryMock)
                         :when(
                           function()
                             clientOutputRenderer = ClientOutputRenderer()
                           end
                         )

  return clientOutputRenderer

end


return TestClientOutputRenderer
