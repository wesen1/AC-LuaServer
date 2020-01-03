---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the TemplateNodeTree works as expected.
--
-- @type TestTemplateNodeTree
--
local TestTemplateNodeTree = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestTemplateNodeTree.testClassPath = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TemplateNodeTree"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestTemplateNodeTree.dependencyPaths = {
  { id = "RootNode", path = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RootNode" },
  { id = "ConfigNode", path = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ConfigNode"},
  { id = "CustomFieldNode", path = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.CustomFieldNode"},
  { id = "RowFieldNode", path = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RowFieldNode"},
  { id = "RowNode", path = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RowNode"},
  { id = "TagFinder", path = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TagFinder" }
}


---
-- The TagFinder mock that will be injected into the TemplateNodeTree test instances
--
-- @tfield table tagFinderMock
--
TestTemplateNodeTree.tagFinderMock = nil

---
-- The RootNode mock that will be injected into the TemplateNodeTree test instances
--
-- @tfield table rootNodeMock
--
TestTemplateNodeTree.rootNodeMock = nil

---
-- The available TemplateNode classes in the same order in which they are looped over during
-- the TemplateNodeTree parsing process.
-- This table is in the format { { name = <shortName>, class = <class> }, ... }
--
-- @tfield table nodeClasses
--
TestTemplateNodeTree.nodeClasses = nil


---
-- Method that is called before a test is executed.
-- Sets up the mocks and the list of TemplateNode classes.
--
function TestTemplateNodeTree:setUp()
  self.super.setUp(self)

  self.tagFinderMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TagFinder", "TagFinderMock"
  )
  self.rootNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RootNode", "RootNodeMock"
  )
  self.rootNodeMock.isClosedByTag = self.mach.mock_method("isClosedByTag")

  self.nodeClasses = {
    {
      name = "ConfigNode",
      class = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.ConfigNode"
    },
    {
      name = "CustomFieldNode",
      class = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.CustomFieldNode"
    },
    {
      name = "RowFieldNode",
      class = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RowFieldNode"
    },
    {
      name = "RowNode",
      class = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.RowNode"
    }
  }

  for _, nodeClass in ipairs(self.nodeClasses) do
    nodeClass["class"].isOpenedByTag = self.mach.mock_method("isOpenedByTag")
  end
end

---
-- Method that is called after a test was executed.
-- Clears the mocks and the list of TemplateNode classes.
--
function TestTemplateNodeTree:tearDown()
  self.super.tearDown(self)

  self.tagFinderMock = nil
  self.rootNodeMock = nil
  self.nodeClasses = nil
end


---
-- Checks that a template string can be parsed as expected into a TemplateNodeTree.
--
function TestTemplateNodeTree:testCanParseString()

  local templateNodeTree = self:createTestInstance()

  local exampleString = "###[ CONFIG ]###lineWidth=50###[ ENDCONFIG ]###some output_______;field A----;fieldB"

  -- Prepare the tag mocks
  local configOpenTagMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "ConfigOpenTagMock"
  )
  local configCloseTagMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "ConfigCloseTagMock"
  )
  local rowTagMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "RowTagMock"
  )
  local rowFieldTagMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "RowFieldTagMock"
  )

  -- Prepare the node mocks
  local configNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "ConfigNodeMock"
  )
  local contentNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "ContentNodeMock"
  )
  local rowNodeMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RowNodeMockA"
  )
  local rowNodeMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RowNodeMockB"
  )
  local rowFieldNodeMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RowFieldNodeMockA"
  )
  local rowFieldNodeMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RowFieldNodeMockB"
  )
  local rowFieldNodeMockC = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RowFieldNodeMockC"
  )

  local ConfigNodeMock = self.dependencyMocks.ConfigNode
  local RowNodeMock = self.dependencyMocks.RowNode
  local RowFieldNodeMock = self.dependencyMocks.RowFieldNode


  -- Should process the config open tag
  self.tagFinderMock.findNextTag
                    :should_be_called_with(exampleString, 1)
                    :and_will_return(configOpenTagMock)
                    :and_then(
                      configOpenTagMock.getStartPosition
                                       :should_be_called()
                                       :and_will_return(1)
                    )
                    :and_then(
                      self.rootNodeMock.isClosedByTag
                                       :should_be_called_with(configOpenTagMock)
                                       :and_will_return(false)
                                       :and_then(
                                         self:expectIsOpenedByTagCallsThatWillReturnFalseUntil(
                                           "ConfigNode", configOpenTagMock
                                         )
                                       )
                                       :and_then(
                                         ConfigNodeMock.__call
                                                       :should_be_called()
                                                       :and_will_return(configNodeMock)
                                       )
                                       :and_then(
                                         self.rootNodeMock.addInnerNode
                                                          :should_be_called_with(configNodeMock)
                                       )
                    )
                    :and_then(
                      configOpenTagMock.getEndPosition
                                       :should_be_called()
                                       :and_will_return(16)
                    )

                    -- Should process the config close tag
                    :and_then(
                      self.tagFinderMock.findNextTag
                                        :should_be_called_with(exampleString, 17)
                                        :and_will_return(configCloseTagMock)
                    )
                    :and_then(
                      configCloseTagMock.getStartPosition
                                        :should_be_called()
                                        :and_will_return(29)
                                        :and_then(
                                          configNodeMock.addInnerText
                                                        :should_be_called_with("lineWidth=50")
                                                        :and_will_return(configNodeMock)
                                        )
                    )
                    :and_then(
                      configNodeMock.isClosedByTag
                                    :should_be_called_with(configCloseTagMock)
                                    :and_will_return(true)
                                    :and_then(
                                      configNodeMock.getParentNode
                                                    :should_be_called()
                                                    :and_will_return(self.rootNodeMock)
                                    )
                                    :and_then(
                                      self.rootNodeMock.isClosedByTag
                                                       :should_be_called_with(configCloseTagMock)
                                                       :and_will_return(false)
                                    )
                                    :and_then(
                                      self:expectIsOpenedByTagCallsThatWillReturnFalseUntil(
                                        nil, configCloseTagMock
                                      )
                                    )
                    )
                    :and_then(
                      configCloseTagMock.getEndPosition
                                        :should_be_called()
                                        :and_will_return(47)
                    )

                    -- Should process the row tag
                    :and_then(
                      self.tagFinderMock.findNextTag
                                        :should_be_called_with(exampleString, 48)
                                        :and_will_return(rowTagMock)
                    )
                    :and_then(
                      rowTagMock.getStartPosition
                                :should_be_called()
                                :and_will_return(59)
                                :and_then(
                                  self.rootNodeMock.addInnerText
                                                   :should_be_called_with("some output")
                                                   :and_will_return(rowFieldNodeMockA)
                                )
                    )
                    :and_then(
                      rowFieldNodeMockA.isClosedByTag
                                       :should_be_called_with(rowTagMock)
                                       :and_will_return(true)
                                       :and_then(
                                         rowFieldNodeMockA.getParentNode
                                                          :should_be_called()
                                                          :and_will_return(rowNodeMockA)
                                       )
                                       :and_then(
                                         rowNodeMockA.isClosedByTag
                                                     :should_be_called_with(rowTagMock)
                                                     :and_will_return(true)
                                       )
                                       :and_then(
                                         rowNodeMockA.getParentNode
                                                     :should_be_called()
                                                     :and_will_return(contentNodeMock)
                                       )
                                       :and_then(
                                         contentNodeMock.isClosedByTag
                                                        :should_be_called_with(rowTagMock)
                                                        :and_will_return(false)
                                       )
                                       :and_then(
                                         self:expectIsOpenedByTagCallsThatWillReturnFalseUntil(
                                           "RowNode", rowTagMock
                                         )
                                       )
                                       :and_then(
                                         RowNodeMock.__call
                                                    :should_be_called()
                                                    :and_will_return(rowNodeMockB)
                                       )
                                       :and_then(
                                         contentNodeMock.addInnerNode
                                                        :should_be_called_with(rowNodeMockB)
                                                        :and_will_return(contentNodeMock)
                                       )
                    )
                    :and_then(
                      rowTagMock.getEndPosition
                                :should_be_called()
                                :and_will_return(66)
                    )

                    -- Should process the row field tag
                    :and_then(
                      self.tagFinderMock.findNextTag
                                        :should_be_called_with(exampleString, 67)
                                        :and_will_return(rowFieldTagMock)
                    )
                    :and_then(
                      rowFieldTagMock.getStartPosition
                                     :should_be_called()
                                     :and_will_return(74)
                                     :and_then(
                                       rowNodeMockB.addInnerText
                                                   :should_be_called_with("field A")
                                                   :and_will_return(rowFieldNodeMockB)
                                     )
                    )
                    :and_then(
                      rowFieldNodeMockB.isClosedByTag
                                       :should_be_called_with(rowFieldTagMock)
                                       :and_will_return(true)
                                       :and_then(
                                         rowFieldNodeMockB.getParentNode
                                                          :should_be_called()
                                                          :and_will_return(rowNodeMockB)
                                       )
                                       :and_then(
                                         rowNodeMockB.isClosedByTag
                                                     :should_be_called_with(rowFieldTagMock)
                                                     :and_will_return(false)
                                       )
                                       :and_then(
                                         self:expectIsOpenedByTagCallsThatWillReturnFalseUntil(
                                           "RowFieldNode", rowFieldTagMock
                                         )
                                       )
                                       :and_then(
                                         RowFieldNodeMock.__call
                                                         :should_be_called()
                                                         :and_will_return(rowFieldNodeMockC)
                                       )
                                       :and_then(
                                         rowNodeMockB.addInnerNode
                                                     :should_be_called_with(rowFieldNodeMockC)
                                       )
                    )
                    :and_then(
                      rowFieldTagMock.getEndPosition
                                     :should_be_called()
                                     :and_will_return(78)
                    )

                    -- Should process the remaining string
                    :and_then(
                      self.tagFinderMock.findNextTag
                                        :should_be_called_with(exampleString, 79)
                                        :and_will_return(nil)
                    )
                    :and_then(
                      rowFieldNodeMockC.addInnerText
                                       :should_be_called_with("fieldB")
                    )

                    :when(
                      function()
                        templateNodeTree:parse(exampleString)
                      end
                    )

end

---
-- Checks that text at the start of a template is handled as expected.
--
function TestTemplateNodeTree:testCanHandleTextAtStart()

  local templateNodeTree = self:createTestInstance()
  local exampleString = "Field One----;Second Field"

  -- Prepare the tag mocks
  local rowFieldTagMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "RowFieldTagMock"
  )

  -- Prepare the node mocks
  local rowNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RowNodeMock"
  )
  local rowFieldNodeMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RowFieldNodeMockA"
  )
  local rowFieldNodeMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RowFieldNodeMockB"
  )

  local RowFieldNodeMock = self.dependencyMocks.RowFieldNode


  -- Should process the row field tag
  self.tagFinderMock.findNextTag
                    :should_be_called_with(exampleString, 1)
                    :and_will_return(rowFieldTagMock)
                    :and_then(
                      rowFieldTagMock.getStartPosition
                                     :should_be_called()
                                     :and_will_return(10)
                                     :and_then(
                                       self.rootNodeMock.addInnerText
                                                        :should_be_called_with("Field One")
                                                        :and_will_return(rowFieldNodeMockA)
                                     )
                    )
                    :and_then(
                      rowFieldNodeMockA.isClosedByTag
                                       :should_be_called_with(rowFieldTagMock)
                                       :and_will_return(true)
                                       :and_then(
                                         rowFieldNodeMockA.getParentNode
                                                          :should_be_called()
                                                          :and_will_return(rowNodeMock)
                                       )
                                       :and_then(
                                         rowNodeMock.isClosedByTag
                                                    :should_be_called_with(rowFieldTagMock)
                                                    :and_will_return(false)
                                       )
                                       :and_then(
                                         self:expectIsOpenedByTagCallsThatWillReturnFalseUntil(
                                           "RowFieldNode", rowFieldTagMock
                                         )
                                       )
                                       :and_then(
                                         RowFieldNodeMock.__call
                                                         :should_be_called()
                                                         :and_will_return(rowFieldNodeMockB)
                                       )
                                       :and_then(
                                         rowNodeMock.addInnerNode
                                                    :should_be_called_with(rowFieldNodeMockB)
                                       )
                    )
                    :and_then(
                      rowFieldTagMock.getEndPosition
                                     :should_be_called()
                                     :and_will_return(14)
                    )

                    -- Should process the remaining string
                    :and_then(
                      self.tagFinderMock.findNextTag
                                        :should_be_called_with(exampleString, 15)
                                        :and_will_return(nil)
                    )
                    :and_then(
                      rowFieldNodeMockB.addInnerText
                                       :should_be_called_with("Second Field")
                    )

                    :when(
                      function()
                        templateNodeTree:parse(exampleString)
                      end
                    )

end

---
-- Checks that a string with no trailing text after the last tag is handled as expected.
--
function TestTemplateNodeTree:testCanHandleNoTrailingTextAfterLastTag()

  local templateNodeTree = self:createTestInstance()

  local exampleString = "----;"

  -- Prepare the tag mocks
  local rowFieldTagMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "RowFieldTagMock"
  )

  -- Prepare the node mocks
  local rowFieldNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RowFieldNodeMock"
  )

  local RowFieldNodeMock = self.dependencyMocks.RowFieldNode


  -- Should process the row field tag
  self.tagFinderMock.findNextTag
                    :should_be_called_with(exampleString, 1)
                    :and_will_return(rowFieldTagMock)
                    :and_then(
                      rowFieldTagMock.getStartPosition
                                     :should_be_called()
                                     :and_will_return(1)
                    )
                    :and_then(
                      self.rootNodeMock.isClosedByTag
                                       :should_be_called_with(rowFieldTagMock)
                                       :and_will_return(false)
                                       :and_then(
                                         self:expectIsOpenedByTagCallsThatWillReturnFalseUntil(
                                           "RowFieldNode", rowFieldTagMock
                                         )
                                       )
                                       :and_then(
                                         RowFieldNodeMock.__call
                                                         :should_be_called()
                                                         :and_will_return(rowFieldNodeMock)
                                       )
                                       :and_then(
                                         self.rootNodeMock.addInnerNode
                                                          :should_be_called_with(rowFieldNodeMock)
                                       )
                    )
                    :and_then(
                      rowFieldTagMock.getEndPosition
                                     :should_be_called()
                                     :and_will_return(5)
                    )

                    :when(
                      function()
                        templateNodeTree:parse(exampleString)
                      end
                    )

end

---
-- Checks that two tags in a row that have no text in between are handled as expected.
--
function TestTemplateNodeTree:testCanHandleNoTextBetweenTags()

  local templateNodeTree = self:createTestInstance()

  local exampleString = "empty row incoming_______;______;row 3"

  -- Prepare the tag mocks
  local rowTagMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "RowTagMockA"
  )
  local rowTagMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "RowTagMockB"
  )

  -- Prepare the node mocks
  local contentNodeMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "ContentNodeMock"
  )
  local rowNodeMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RowNodeMockA"
  )
  local rowNodeMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RowNodeMockB"
  )
  local rowNodeMockC = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RowNodeMockB"
  )
  local rowFieldNodeMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode", "RowFieldNodeMockA"
  )

  local RowNodeMock = self.dependencyMocks.RowNode


  -- Should process the row tag
  self.tagFinderMock.findNextTag
                    :should_be_called_with(exampleString, 1)
                    :and_will_return(rowTagMockA)
                    :and_then(
                      rowTagMockA.getStartPosition
                                 :should_be_called()
                                 :and_will_return(19)
                    )
                    :and_then(
                      self.rootNodeMock.addInnerText
                                       :should_be_called_with("empty row incoming")
                                       :and_will_return(rowFieldNodeMockA)
                    )
                    :and_then(
                      rowFieldNodeMockA.isClosedByTag
                                       :should_be_called_with(rowTagMockA)
                                       :and_will_return(true)
                                       :and_then(
                                         rowFieldNodeMockA.getParentNode
                                                          :should_be_called()
                                                          :and_will_return(rowNodeMockA)
                                       )
                                       :and_then(
                                         rowNodeMockA.isClosedByTag
                                                     :should_be_called_with(rowTagMockA)
                                                     :and_will_return(true)
                                       )
                                       :and_then(
                                         rowNodeMockA.getParentNode
                                                     :should_be_called()
                                                     :and_will_return(contentNodeMock)
                                       )
                                       :and_then(
                                         contentNodeMock.isClosedByTag
                                                        :should_be_called_with(rowTagMockA)
                                                        :and_will_return(false)
                                       )
                                       :and_then(
                                         self:expectIsOpenedByTagCallsThatWillReturnFalseUntil(
                                           "RowNode", rowTagMockA
                                         )
                                       )
                                       :and_then(
                                         RowNodeMock.__call
                                                    :should_be_called()
                                                    :and_will_return(rowNodeMockB)
                                       )
                                       :and_then(
                                         contentNodeMock.addInnerNode
                                                        :should_be_called_with(rowNodeMockB)
                                       )
                    )
                    :and_then(
                      rowTagMockA.getEndPosition
                                 :should_be_called()
                                 :and_will_return(26)
                    )

                    -- Should process the other row tag
                    :and_then(
                      self.tagFinderMock.findNextTag
                                        :should_be_called_with(exampleString, 27)
                                        :and_will_return(rowTagMockB)
                    )
                    :and_then(
                      rowTagMockB.getStartPosition
                                 :should_be_called()
                                 :and_will_return(27)
                    )
                    :and_then(
                      rowNodeMockB.isClosedByTag
                                  :should_be_called_with(rowTagMockB)
                                  :and_will_return(true)
                                  :and_then(
                                    rowNodeMockB.getParentNode
                                                :should_be_called()
                                                :and_will_return(contentNodeMock)
                                  )
                                  :and_then(
                                    contentNodeMock.isClosedByTag
                                                   :should_be_called_with(rowTagMockB)
                                                   :and_will_return(false)
                                  )
                                  :and_then(
                                    self:expectIsOpenedByTagCallsThatWillReturnFalseUntil(
                                      "RowNode", rowTagMockB
                                    )
                                  )
                                  :and_then(
                                    RowNodeMock.__call
                                               :should_be_called()
                                               :and_will_return(rowNodeMockC)
                                  )
                                  :and_then(
                                    contentNodeMock.addInnerNode
                                                   :should_be_called_with(rowNodeMockC)
                                  )
                    )
                    :and_then(
                      rowTagMockB.getEndPosition
                                 :should_be_called()
                                 :and_will_return(33)
                    )

                    -- Should process the remaining string
                    :and_then(
                      self.tagFinderMock.findNextTag
                                        :should_be_called_with(exampleString, 34)
                                        :and_will_return(nil)
                    )
                    :and_then(
                      rowNodeMockC.addInnerText
                                  :should_be_called_with("row 3")
                    )

                    :when(
                      function()
                        templateNodeTree:parse(exampleString)
                      end
                    )

end


---
-- Generates and returns a TemplateNodeTree instance into which the RootNode
-- and TagFinder mocks were injected.
--
-- @treturn TemplateNodeTree The TemplateNodeTree
--
function TestTemplateNodeTree:createTestInstance()

  local TemplateNodeTree = self.testClass

  local RootNodeMock = self.dependencyMocks.RootNode
  local TagFinderMock = self.dependencyMocks.TagFinder

  local templateNodeTree
  TagFinderMock.__call
               :should_be_called()
               :and_will_return(self.tagFinderMock)
               :and_also(
                 RootNodeMock.__call
                             :should_be_called()
                             :and_will_return(self.rootNodeMock)
               )
               :when(
                 function()
                   templateNodeTree = TemplateNodeTree()
                 end
               )

  self:assertEquals(self.rootNodeMock, templateNodeTree:getRootNode())

  return templateNodeTree

end

---
-- Generates and returns the expectations for when the TemplateNodeTree loops over all available
-- TemplateNode classes and checks if one of them is opened by the current found tag.
--
-- @tparam string _targetClassName The name of the class that should return true (optional)
-- @tparam table _tag The tag that the isOpenedByTag method is expected to be called with
--
-- @ŧreturn table The expectations
--
function TestTemplateNodeTree:expectIsOpenedByTagCallsThatWillReturnFalseUntil(_targetClassName, _tag)

  local expectations
  for _, nodeClass in ipairs(self.nodeClasses) do

    local isTargetNodeClass = (_targetClassName and nodeClass["name"] == _targetClassName)
    local isOpenedByTagCallExpectation = nodeClass["class"].isOpenedByTag
                                                           :should_be_called_with(_tag)

    if (isTargetNodeClass) then
      isOpenedByTagCallExpectation:and_will_return(true)
    else
      isOpenedByTagCallExpectation:and_will_return(false)
    end

    if (expectations) then
      expectations:and_then(isOpenedByTagCallExpectation)
    else
      expectations = isOpenedByTagCallExpectation
    end

    if (isTargetNodeClass) then
      break
    end

  end


  return expectations

end


return TestTemplateNodeTree
