---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the TagFinder works as expected.
--
-- @type TestTagFinder
--
local TestTagFinder = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestTagFinder.testClassPath = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TagFinder"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestTagFinder.dependencyPaths = {
  { id = "TemplateTag", path = "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag" }
}


---
-- Checks that config open tags are detected as expected.
--
function TestTagFinder:testCanFindConfigOpenTags()

  local TemplateTagMock = self.dependencyMocks.TemplateTag
  local TagFinder = self.testClass

  local tagFinder = TagFinder()
  local nextTag

  -- Minimum tag text
  local templateTagMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockA"
  )
  TemplateTagMock.__call
                 :should_be_called_with("config", 1, 11)
                 :and_will_return(templateTagMockA)
                 :and_then(
                   templateTagMockA.getName
                                   :should_be_called()
                                   :and_will_return("config")
                 )
                 :when(
                   function()
                     nextTag = tagFinder:findNextTag("##[CONFIG];", 1)
                   end
                 )

  self:assertEquals(templateTagMockA, nextTag)


  -- Customized tag text
  local templateTagMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockB"
  )
  TemplateTagMock.__call
                 :should_be_called_with("config", 3, 27)
                 :and_will_return(templateTagMockB)
                 :and_then(
                   templateTagMockB.getName
                                   :should_be_called()
                                   :and_will_return("config")
                 )
                 :when(
                   function()
                     nextTag = tagFinder:findNextTag("  ######[  CONFIG   ]#####;", 1)
                   end
                 )

  self:assertEquals(templateTagMockB, nextTag)

end

---
-- Checks that config close tags are detected as expected.
--
function TestTagFinder:testCanFindConfigCloseTags()

  local TemplateTagMock = self.dependencyMocks.TemplateTag
  local TagFinder = self.testClass

  local tagFinder = TagFinder()
  local nextTag

  -- Minimum tag text
  local templateTagMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockA"
  )
  TemplateTagMock.__call
                 :should_be_called_with("end-config", 2, 15)
                 :and_will_return(templateTagMockA)
                 :and_then(
                   templateTagMockA.getName
                                   :should_be_called()
                                   :and_will_return("end-config")
                 )
                 :when(
                   function()
                     nextTag = tagFinder:findNextTag(" ##[ENDCONFIG];", 1)
                   end
                 )

  self:assertEquals(templateTagMockA, nextTag)


  -- Customized tag text
  local templateTagMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockB"
  )
  TemplateTagMock.__call
                 :should_be_called_with("end-config", 5, 32)
                 :and_will_return(templateTagMockB)
                 :and_then(
                   templateTagMockB.getName
                                   :should_be_called()
                                   :and_will_return("end-config")
                 )
                 :when(
                   function()
                     nextTag = tagFinder:findNextTag("    ########[  ENDCONFIG   ]###;", 1)
                   end
                 )

  self:assertEquals(templateTagMockB, nextTag)

end

---
-- Checks that custom field open tags are detected as expected.
--
function TestTagFinder:testCanFindCustomFieldOpenTags()

  local TemplateTagMock = self.dependencyMocks.TemplateTag
  local TagFinder = self.testClass

  local tagFinder = TagFinder()
  local nextTag

  -- Minimum tag text
  local templateTagMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockA"
  )
  TemplateTagMock.__call
                 :should_be_called_with("custom-field", 5, 14)
                 :and_will_return(templateTagMockA)
                 :and_then(
                   templateTagMockA.getName
                                   :should_be_called()
                                   :and_will_return("custom-field")
                 )
                 :when(
                   function()
                     nextTag = tagFinder:findNextTag("    --[FIELD];", 1)
                   end
                 )

  self:assertEquals(templateTagMockA, nextTag)


  -- Customized tag text
  local templateTagMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockB"
  )
  TemplateTagMock.__call
                 :should_be_called_with("custom-field", 1, 17)
                 :and_will_return(templateTagMockB)
                 :and_then(
                   templateTagMockB.getName
                                   :should_be_called()
                                   :and_will_return("custom-field")
                 )
                 :when(
                   function()
                     nextTag = tagFinder:findNextTag("------[ FIELD ]-;", 1)
                   end
                 )

  self:assertEquals(templateTagMockB, nextTag)

end

---
-- Checks that custom field close tags are detected as expected.
--
function TestTagFinder:testCanFindCustomFieldCloseTags()

  local TemplateTagMock = self.dependencyMocks.TemplateTag
  local TagFinder = self.testClass

  local tagFinder = TagFinder()
  local nextTag

  -- Minimum tag text
  local templateTagMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockA"
  )
  TemplateTagMock.__call
                 :should_be_called_with("end-custom-field", 3, 15)
                 :and_will_return(templateTagMockA)
                 :and_then(
                   templateTagMockA.getName
                                   :should_be_called()
                                   :and_will_return("end-custom-field")
                 )
                 :when(
                   function()
                     nextTag = tagFinder:findNextTag("  --[ENDFIELD];", 1)
                   end
                 )

  self:assertEquals(templateTagMockA, nextTag)


  -- Customized tag text
  local templateTagMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockB"
  )
  TemplateTagMock.__call
                 :should_be_called_with("end-custom-field", 1, 25)
                 :and_will_return(templateTagMockB)
                 :and_then(
                   templateTagMockB.getName
                                   :should_be_called()
                                   :and_will_return("end-custom-field")
                 )
                 :when(
                   function()
                     nextTag = tagFinder:findNextTag("---------[   ENDFIELD ]-;", 1)
                   end
                 )

  self:assertEquals(templateTagMockB, nextTag)

end

---
-- Checks that row tags are detected as expected.
--
function TestTagFinder:testCanFindRowTags()

  local TemplateTagMock = self.dependencyMocks.TemplateTag
  local TagFinder = self.testClass

  local tagFinder = TagFinder()
  local nextTag

  -- Minimum tag text
  local templateTagMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockA"
  )
  TemplateTagMock.__call
                 :should_be_called_with("row", 2, 4)
                 :and_will_return(templateTagMockA)
                 :and_then(
                   templateTagMockA.getName
                                   :should_be_called()
                                   :and_will_return("row")
                 )
                 :when(
                   function()
                     nextTag = tagFinder:findNextTag(" __;", 1)
                   end
                 )

  self:assertEquals(templateTagMockA, nextTag)


  -- Customized tag text
  local templateTagMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockB"
  )
  TemplateTagMock.__call
                 :should_be_called_with("row", 1, 20)
                 :and_will_return(templateTagMockB)
                 :and_then(
                   templateTagMockB.getName
                                   :should_be_called()
                                   :and_will_return("row")
                 )
                 :when(
                   function()
                     nextTag = tagFinder:findNextTag("___________________;", 1)
                   end
                 )

  self:assertEquals(templateTagMockB, nextTag)

end

---
-- Checks that row field tags are detected as expected.
--
function TestTagFinder:testCanFindRowFieldTags()

  local TemplateTagMock = self.dependencyMocks.TemplateTag
  local TagFinder = self.testClass

  local tagFinder = TagFinder()
  local nextTag

  -- Minimum tag text
  local templateTagMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockA"
  )
  TemplateTagMock.__call
                 :should_be_called_with("row-field", 6, 8)
                 :and_will_return(templateTagMockA)
                 :and_then(
                   templateTagMockA.getName
                                   :should_be_called()
                                   :and_will_return("row-field")
                 )
                 :when(
                   function()
                     nextTag = tagFinder:findNextTag("abc  --;", 1)
                   end
                 )

  self:assertEquals(templateTagMockA, nextTag)


  -- Customized tag text
  local templateTagMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockB"
  )
  TemplateTagMock.__call
                 :should_be_called_with("row-field", 10, 20)
                 :and_will_return(templateTagMockB)
                 :and_then(
                   templateTagMockB.getName
                                   :should_be_called()
                                   :and_will_return("row-field")
                 )
                 :when(
                   function()
                     nextTag = tagFinder:findNextTag("sometext ----------;othertext", 1)
                   end
                 )

  self:assertEquals(templateTagMockB, nextTag)

end

---
-- Checks that the case that a string has no remaining tags is handled as expected.
--
function TestTagFinder:testsCanHandleNoTagsFound()

  local TagFinder = self.testClass

  local tagFinder = TagFinder()

  -- Tags with missing trailing ";"
  self:assertNil(tagFinder:findNextTag("###[ CONFIG ]###", 1))
  self:assertNil(tagFinder:findNextTag("####[ ENDCONFIG ]###no"))
  self:assertNil(tagFinder:findNextTag("------[ FIELD ]------moretext", 1))
  self:assertNil(tagFinder:findNextTag("------[ ENDFIELD ]------moretext", 1))
  self:assertNil(tagFinder:findNextTag("_____"))
  self:assertNil(tagFinder:findNextTag("----"))

  -- Random text
  self:assertNil(tagFinder:findNextTag("asldjiowjdiowjio", 1))
  self:assertNil(tagFinder:findNextTag("oiejfowiejfoiwmf", 1))
  self:assertNil(tagFinder:findNextTag("paijfcpmaiwemf aiwej", 1))

end

---
-- Checks that the cached results of previous findNextTag() calls are reused as expected.
--
function TestTagFinder:testCanUseCachedResults()

  local targetString = "Row 1              \n"
                    .. "__________________;\n"
                    .. "Row 2 - Field 1    \n"
                    .. "------------------;\n"
                    .. "Row 2 - Field 2    \n"
                    .. "__________________;\n"
                    .. "Row 3 - Field 1    \n"
                    .. "------------------;\n"
                    .. "Row 3 - Field 2    \n"

  local rowTagMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "RowTagMockA"
  )
  local rowTagMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "RowTagMockB"
  )
  local rowFieldTagMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "RowFieldTagMockA"
  )
  local rowFieldTagMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "RowFieldTagMockB"
  )


  local TemplateTagMock = self.dependencyMocks.TemplateTag
  local TagFinder = self.testClass

  local tagFinder = TagFinder()
  local nextTag

  -- Should find new row tag
  TemplateTagMock.__call
                 :should_be_called_with("row", 21, 39)
                 :and_will_return(rowTagMockA)
                 :and_then(

                   -- Should find new row-field tag
                   TemplateTagMock.__call
                                  :should_be_called_with("row-field", 61, 79)
                                  :and_will_return(rowFieldTagMockA)
                 )
                 :and_then(

                   -- And compare its start position to the already found row tag
                   rowTagMockA.getStartPosition
                              :should_be_called()
                              :and_will_return(21)
                              :and_also(
                                rowFieldTagMockA.getStartPosition
                                                :should_be_called()
                                                :and_will_return(61)
                              )
                 )
                 :and_then(

                   -- Should clear the cached tag for the closest next tag
                   rowTagMockA.getName
                              :should_be_called()
                              :and_will_return("row")
                 )
                 :when(
                   function()
                     nextTag = tagFinder:findNextTag(targetString, 1)
                   end
                 )

  self:assertEquals(rowTagMockA, nextTag)


  -- Should find new row tag
  TemplateTagMock.__call
                 :should_be_called_with("row", 101, 119)
                 :and_will_return(rowTagMockB)
                 :and_then(

                   -- Should check if the already found row-field tag is still in the search range
                   rowFieldTagMockA.getStartPosition
                                   :should_be_called()
                                   :and_will_return(61)
                 )
                 :and_then(

                   -- And compare its start position to the already found row tag
                   rowTagMockB.getStartPosition
                              :should_be_called()
                              :and_will_return(101)
                              :and_also(
                                rowFieldTagMockA.getStartPosition
                                                :should_be_called()
                                                :and_will_return(61)
                              )
                 )
                 :and_then(

                   -- Should clear the cached tag for the closest next tag
                   rowFieldTagMockA.getName
                                   :should_be_called()
                                   :and_will_return("row-field")
                 )
                 :when(
                   function()
                     nextTag = tagFinder:findNextTag(targetString, 40)
                   end
                 )

  self:assertEquals(rowFieldTagMockA, nextTag)


  -- Should check if the already found row tag is still in the search range
  rowTagMockB.getStartPosition
             :should_be_called()
             :and_will_return(101)
             :and_then(

               -- Should find a new row-field tag
               TemplateTagMock.__call
                              :should_be_called_with("row-field", 141, 159)
                              :and_will_return(rowFieldTagMockB)
             )
             :and_then(

               -- And compare its start position to the already found row tag
               rowTagMockB.getStartPosition
                          :should_be_called()
                          :and_will_return(101)
                          :and_also(
                            rowFieldTagMockB.getStartPosition
                                            :should_be_called()
                                            :and_will_return(141)
                          )
             )
             :and_then(

               -- Should clear the cached tag for the closest next tag
               rowTagMockB.getName
                          :should_be_called()
                          :and_will_return("row")
             )
             :when(
               function()
                 nextTag = tagFinder:findNextTag(targetString, 80)
               end
             )

  self:assertEquals(rowTagMockB, nextTag)


    -- Should check if the already found row-field tag is still in the search range
  rowFieldTagMockB.getStartPosition
                  :should_be_called()
                  :and_will_return(141)
                  :and_then(

                    -- Should clear the cached tag for the closest next tag
                    rowFieldTagMockB.getName
                                    :should_be_called()
                                    :and_will_return("row-field")
                  )
                  :when(
                    function()
                      nextTag = tagFinder:findNextTag(targetString, 120)
                    end
                  )

  self:assertEquals(rowFieldTagMockB, nextTag)


  -- Should find no more tags
  self:assertNil(tagFinder:findNextTag(targetString, 160))

end

---
-- Checks that the TagFinder does not return cached tags when their start position is lower
-- than the search start position.
--
function TestTagFinder:testDoesNotReturnCachedTagWhenCachedTagStartPositionIsLowerThanSearchStartPosition()

  local TemplateTagMock = self.dependencyMocks.TemplateTag
  local TagFinder = self.testClass

  local tagFinder = TagFinder()
  local nextTag


  -- Start position of cached tag equals search start position
  local rowTagMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "RowTagMockA"
  )
  local rowFieldTagMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "RowFieldTagMockA"
  )

  TemplateTagMock.__call
                 :should_be_called_with("row", 6, 8)
                 :and_will_return(rowTagMockA)
                 :and_then(
                   TemplateTagMock.__call
                                  :should_be_called_with("row-field", 1, 3)
                                  :and_will_return(rowFieldTagMockA)
                 )
                 :and_then(
                   rowTagMockA.getStartPosition
                              :should_be_called()
                              :and_will_return(6)
                              :and_also(
                                rowFieldTagMockA.getStartPosition
                                                :should_be_called()
                                                :and_will_return(1)
                              )
                 )
                 :and_then(
                   rowFieldTagMockA.getName
                                   :should_be_called()
                                   :and_will_return("row-field")
                 )
                 :when(
                   function()
                     nextTag = tagFinder:findNextTag("--;  __; ", 1)
                   end
                 )

  self:assertEquals(rowFieldTagMockA, nextTag)

  rowTagMockA.getStartPosition
             :should_be_called()
             :and_will_return(6)
             :and_then(
               rowTagMockA.getName
                          :should_be_called()
                          :and_will_return("__;")
             )
             :when(
               function()
                 nextTag = tagFinder:findNextTag("--;  __; ", 6)
               end
             )
  self:assertEquals(rowTagMockA, nextTag)


  -- Start position of cached tag is one below search start position
  tagFinder = TagFinder()

  local rowTagMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "RowTagMockB"
  )
  local rowFieldTagMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "RowFieldTagMockB"
  )

  TemplateTagMock.__call
                 :should_be_called_with("row", 6, 8)
                 :and_will_return(rowTagMockB)
                 :and_then(
                   TemplateTagMock.__call
                                  :should_be_called_with("row-field", 1, 3)
                                  :and_will_return(rowFieldTagMockB)
                 )
                 :and_then(
                   rowTagMockB.getStartPosition
                              :should_be_called()
                              :and_will_return(6)
                              :and_also(
                                rowFieldTagMockB.getStartPosition
                                                :should_be_called()
                                                :and_will_return(1)
                              )
                 )
                 :and_then(
                   rowFieldTagMockB.getName
                                   :should_be_called()
                                   :and_will_return("row-field")
                 )
                 :when(
                   function()
                     nextTag = tagFinder:findNextTag("--;  __; ", 1)
                   end
                 )

  self:assertEquals(rowFieldTagMockB, nextTag)

  rowTagMockB.getStartPosition
             :should_be_called()
             :and_will_return(6)
             :when(
               function()
                 nextTag = tagFinder:findNextTag("--;  __; ", 7)
               end
             )
  self:assertNil(nextTag)

end

---
-- Checks that the TagFinder does not use its cached next tags when the target string changes.
--
function TestTagFinder:testDoesNotUseCacheWhenTargetStringChanges()

  local TemplateTagMock = self.dependencyMocks.TemplateTag
  local TagFinder = self.testClass

  local tagFinder = TagFinder()
  local nextTag


  local rowTagMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "RowTagMockA"
  )
  local rowTagMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "RowTagMockB"
  )
  local rowFieldTagMock = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "RowFieldTagMock"
  )

  TemplateTagMock.__call
                 :should_be_called_with("row", 6, 8)
                 :and_will_return(rowTagMockA)
                 :and_then(
                   TemplateTagMock.__call
                                  :should_be_called_with("row-field", 1, 3)
                                  :and_will_return(rowFieldTagMock)
                 )
                 :and_then(
                   rowTagMockA.getStartPosition
                              :should_be_called()
                              :and_will_return(6)
                              :and_also(
                                rowFieldTagMock.getStartPosition
                                               :should_be_called()
                                               :and_will_return(1)
                              )
                 )
                 :and_then(
                   rowFieldTagMock.getName
                                  :should_be_called()
                                  :and_will_return("row-field")
                 )
                 :when(
                   function()
                     nextTag = tagFinder:findNextTag("--;  __; ", 1)
                   end
                 )

  self:assertEquals(rowFieldTagMock, nextTag)

  TemplateTagMock.__call
                 :should_be_called_with("row", 6, 8)
                 :and_will_return(rowTagMockB)
                 :and_then(
                   rowTagMockB.getName
                              :should_be_called()
                              :and_will_return("row")
                 )
                 :when(
                   function()
                     nextTag = tagFinder:findNextTag("--;  __; #", 4)
                   end
                 )

  self:assertEquals(rowTagMockB, nextTag)

end

---
-- Checks that custom field open and close tags with multiple trailing dashes before the ";"
-- are handled as expected.
--
function TestTagFinder:testCanHandleCustomFieldTagsWithTrailingDashes()

  local TemplateTagMock = self.dependencyMocks.TemplateTag
  local TagFinder = self.testClass

  local tagFinder = TagFinder()
  local nextTag


  -- Should find a custom-field tag and a row-field tag (the "------;" part at the end)
  local templateTagMockA = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockA"
  )
  local templateTagMockB = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockB"
  )
  TemplateTagMock.__call
                 :should_be_called_with("custom-field", 1, 22)
                 :and_will_return(templateTagMockA)
                 :and_also(
                   TemplateTagMock.__call
                                  :should_be_called_with("row-field", 16, 22)
                                  :and_will_return(templateTagMockB)
                 )
                 :and_then(
                   templateTagMockA.getStartPosition
                                   :should_be_called()
                                   :and_will_return(1)
                                   :and_also(
                                     templateTagMockB.getStartPosition
                                                     :should_be_called()
                                                     :and_will_return(16)
                                   )
                 )
                 :and_then(
                   templateTagMockA.getName
                                   :should_be_called()
                                   :and_will_return("custom-field")
                 )
                 :when(
                   function()
                     nextTag = tagFinder:findNextTag("------[ FIELD ]------;moretext", 1)
                   end
                 )

  self:assertEquals(templateTagMockA, nextTag)

  templateTagMockB.getStartPosition
                  :should_be_called()
                  :and_will_return(16)
                  :when(
                    function()
                      nextTag = tagFinder:findNextTag("------[ FIELD ]------;moretext", 23)
                    end
                  )

  self:assertNil(nextTag)


  -- Should find a end-custom-field tag and a row-field tag (the "------;" part at the end)
  local templateTagMockC = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockC"
  )
  local templateTagMockD = self:getMock(
    "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag", "TemplateTagMockD"
  )
  TemplateTagMock.__call
                 :should_be_called_with("end-custom-field", 3, 21)
                 :and_will_return(templateTagMockC)
                 :and_also(
                   TemplateTagMock.__call
                                  :should_be_called_with("row-field", 18, 21)
                                  :and_will_return(templateTagMockD)
                 )
                 :and_then(
                   templateTagMockC.getStartPosition
                                   :should_be_called()
                                   :and_will_return(3)
                                   :and_also(
                                     templateTagMockD.getStartPosition
                                                     :should_be_called()
                                                     :and_will_return(18)
                                   )
                 )
                 :and_then(
                   templateTagMockC.getName
                                   :should_be_called()
                                   :and_will_return("end-custom-field")
                 )
                 :when(
                   function()
                     nextTag = tagFinder:findNextTag("  ---[ ENDFIELD ]---;somemoretext", 1)
                   end
                 )

  self:assertEquals(templateTagMockC, nextTag)

  templateTagMockD.getStartPosition
                  :should_be_called()
                  :and_will_return(18)
                  :when(
                    function()
                      nextTag = tagFinder:findNextTag("  ---[ ENDFIELD ]---;somemoretext", 22)
                    end
                  )

  self:assertNil(nextTag)

end


return TestTagFinder
