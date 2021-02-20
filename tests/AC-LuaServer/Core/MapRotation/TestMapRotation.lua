---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the MapRotation works as expected.
--
-- @type TestMapRotation
--
local TestMapRotation = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestMapRotation.testClassPath = "AC-LuaServer.Core.MapRotation.MapRotation"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestMapRotation.dependencyPaths = {
  { id = "ActiveMapRotation", path = "AC-LuaServer.Core.MapRotation.ActiveMapRotation" },
  { id = "MapRotationFile", path = "AC-LuaServer.Core.MapRotation.MapRotationFile" }
}


---
-- The ActiveMapRotation mock that will be injected into the test MapRotation instance
--
-- @tfield table activeMapRotationMock
--
TestMapRotation.activeMapRotationMock = nil

---
-- The MapRotationFile mock that will be injected into the test MapRotation instance
--
-- @tfield table mapRotationFileMock
--
TestMapRotation.mapRotationFileMock = nil


---
-- Method that is called before a test is executed.
-- Sets up the mocks.
--
function TestMapRotation:setUp()
  self.super.setUp(self)

  self.activeMapRotationMock = self:getMock(
    "AC-LuaServer.Core.MapRotation.ActiveMapRotation", "ActiveMapRotationMock"
  )
  self.mapRotationFileMock = self:getMock(
    "AC-LuaServer.Core.MapRotation.MapRotationFile", "MapRotationFileMock"
  )
end

---
-- Method that is called after a test was executed.
-- Clears the mocks.
--
function TestMapRotation:tearDown()
  self.super.tearDown(self)

  self.activeMapRotationMock = nil
  self.mapRotationFileMock = nil
end


---
-- Checks that a MapRotation can be created with a custom map rotation file path.
--
function TestMapRotation:testCanBeCreatedWithCustomMapRotationFilePath()

  local MapRotation = self.testClass

  local ActiveMapRotationMock = self.dependencyMocks.ActiveMapRotation
  local MapRotationFileMock = self.dependencyMocks.MapRotationFile

  ActiveMapRotationMock.__call
                       :should_be_called()
                       :and_will_return(self.activeMapRotationMock)
                       :and_also(
                         MapRotationFileMock.__call
                                            :should_be_called_with("config/gema_maprot.cfg")
                                            :and_will_return(self.mapRotationFileMock)
                       )
                       :when(
                         function()
                           MapRotation("config/gema_maprot.cfg")
                         end
                       )

end

---
-- Checks that the MapRotation can return the next map rotation entry.
--
function TestMapRotation:testCanReturnNextEntry()

  local mapRotation = self:createTestMapRotationInstance()

  local mapRotationEntryMock = self:getMock(
    "AC-LuaServer.Core.MapRotation.MapRotationEntry", "MapRotationEntryMock"
  )

  local nextEntry
  self.activeMapRotationMock.getNextEntry
                            :should_be_called()
                            :and_will_return(mapRotationEntryMock)
                            :when(
                              function()
                                nextEntry = mapRotation:getNextEntry()
                              end
                            )

  self:assertEquals(mapRotationEntryMock, nextEntry)

end

---
-- Checks that a MapRotationEntry can be appended to a MapRotation.
--
function TestMapRotation:testCanAppendEntry()

  local mapRotation = self:createTestMapRotationInstance()

  local mapRotationEntryMock = self:getMock(
    "AC-LuaServer.Core.MapRotation.MapRotationEntry", "MapRotationEntryMock"
  )

  self.activeMapRotationMock.appendEntry
                            :should_be_called_with(mapRotationEntryMock)
                            :and_also(
                              self.mapRotationFileMock.appendEntry
                                                      :should_be_called_with(mapRotationEntryMock)
                            )
                            :when(
                              function()
                                mapRotation:appendEntry(mapRotationEntryMock)
                              end
                            )

end

---
-- Checks that all entries for a specified map can be removed from a MapRotation.
--
function TestMapRotation:testCanRemoveEntriesForMap()

  local mapRotation = self:createTestMapRotationInstance()

  self.activeMapRotationMock.removeEntriesForMap
                            :should_be_called_with("ac_unarmed_gema")
                            :and_also(
                              self.mapRotationFileMock.removeEntriesForMap
                                                      :should_be_called_with("ac_unarmed_gema")
                            )
                            :when(
                              function()
                                mapRotation:removeEntriesForMap("ac_unarmed_gema")
                              end
                            )

end

---
-- Checks that the whole map rotation can be set as expected.
--
function TestMapRotation:testCanSetAllEntries()

  local mapRotation = self:createTestMapRotationInstance()

  local mapRotationEntryMockA = self:getMock(
    "AC-LuaServer.Core.MapRotation.MapRotationEntry", "MapRotationEntryMock"
  )
  local mapRotationEntryMockB = self:getMock(
    "AC-LuaServer.Core.MapRotation.MapRotationEntry", "MapRotationEntryMock"
  )
  local mapRotationEntryMockC = self:getMock(
    "AC-LuaServer.Core.MapRotation.MapRotationEntry", "MapRotationEntryMock"
  )

  local newMapRotationEntries = {
    mapRotationEntryMockA,
    mapRotationEntryMockB,
    mapRotationEntryMockC
  }

  self.activeMapRotationMock.clear
                            :should_be_called()
                            :and_also(
                              self.mapRotationFileMock.remove
                                                      :should_be_called()
                            )
                            :and_then(
                              self.activeMapRotationMock.setEntries
                                                        :should_be_called_with(
                                                          self.mach.match(newMapRotationEntries)
                                                        )
                                                        :and_also(
                                                          self.mapRotationFileMock.setEntries
                                                                                  :should_be_called_with(
                                                                                    self.mach.match(
                                                                                      newMapRotationEntries
                                                                                    )
                                                                                  )
                                                        )
                            )
                            :when(
                              function()
                                mapRotation:setAllEntries(newMapRotationEntries)
                              end
                            )

end

---
-- Checks that the MapRotationFile of the MapRotation can be changed after creating the instance.
--
function TestMapRotation:testCanChangeMapRotationFile()

  local mapRotation = self:createTestMapRotationInstance()

  local MapRotationFileMock = self.dependencyMocks.MapRotationFile
  local mapRotationFileMock = self:getMock(
    "AC-LuaServer.Core.MapRotation.MapRotationFile", "MapRotationFileMockB"
  )

  MapRotationFileMock.__call
                     :should_be_called_with("config/tosok_maprot.cfg")
                     :and_will_return(mapRotationFileMock)
                     :and_also(
                       self.activeMapRotationMock.loadFromFile
                                                 :should_be_called_with("config/tosok_maprot.cfg")
                     )
                     :when(
                       function()
                         mapRotation:changeMapRotationConfigFile("config/tosok_maprot.cfg")
                       end
                     )

  -- Append a entry
  local mapRotationEntryMock = self:getMock(
    "AC-LuaServer.Core.MapRotation.MapRotationEntry", "MapRotationEntryMock"
  )

  self.activeMapRotationMock.appendEntry
                            :should_be_called_with(mapRotationEntryMock)
                            :and_also(
                              mapRotationFileMock.appendEntry
                                                 :should_be_called_with(mapRotationEntryMock)
                            )
                            :when(
                              function()
                                mapRotation:appendEntry(mapRotationEntryMock)
                              end
                            )

  -- Remove entries for a map
  self.activeMapRotationMock.removeEntriesForMap
                            :should_be_called_with("ac_unarmed_gema")
                            :and_also(
                              mapRotationFileMock.removeEntriesForMap
                                                 :should_be_called_with("ac_unarmed_gema")
                            )
                            :when(
                              function()
                                mapRotation:removeEntriesForMap("ac_unarmed_gema")
                              end
                            )

  -- Clear the map rotation file
  self.activeMapRotationMock.clear
                            :should_be_called()
                            :and_also(
                              mapRotationFileMock.remove
                                                 :should_be_called()
                            )
                            :when(
                              function()
                                mapRotation:clear()
                              end
                            )

end


---
-- Creates and returns a test MapRotation instance.
--
-- @treturn MapRotation The test MapRotation instance
--
function TestMapRotation:createTestMapRotationInstance()

  local MapRotation = self.testClass

  local ActiveMapRotationMock = self.dependencyMocks.ActiveMapRotation
  local MapRotationFileMock = self.dependencyMocks.MapRotationFile

  local mapRotation

  ActiveMapRotationMock.__call
                       :should_be_called()
                       :and_will_return(self.activeMapRotationMock)
                       :and_also(
                         MapRotationFileMock.__call
                                            :should_be_called_with("config/maprot.cfg")
                                            :and_will_return(self.mapRotationFileMock)
                       )
                       :when(
                         function()
                           mapRotation = MapRotation()
                         end
                       )

  return mapRotation

end


return TestMapRotation
