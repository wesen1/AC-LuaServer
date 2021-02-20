---
-- @author wesen
-- @copyright 2019-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the MapRotationFile works as expected.
--
-- @type TestMapRotationFile
--
local TestMapRotationFile = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestMapRotationFile.testClassPath = "AC-LuaServer.Core.MapRotation.MapRotationFile"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestMapRotationFile.dependencyPaths = {
  { id = "io", path = "io", ["type"] = "globalVariable" },
  { id = "os", path = "os", ["type"] = "globalVariable" }
}


---
-- Checks that a MapRotationEntry can be appended as expected.
--
function TestMapRotationFile:testCanAppendEntry()

  local MapRotationFile = self.testClass

  local mapRotationEntryMock = self:getMock(
    "AC-LuaServer.Core.MapRotation.MapRotationEntry", "MapRotationEntryMock"
  )
  local fileMock = {
    write = self.mach.mock_method("write"),
    close = self.mach.mock_method("close")
  }

  local mapRotationFile = MapRotationFile("config/maprot_tosok.cfg")
  self:assertEquals("config/maprot_tosok.cfg", mapRotationFile:getFilePath())

  self.dependencyMocks.io.open
                         :should_be_called_with("config/maprot_tosok.cfg", "a")
                         :and_will_return(fileMock)
                         :and_also(
                           mapRotationEntryMock.getMapName
                                               :should_be_called()
                                               :and_will_return("ac_desert")
                         )
                         :and_also(
                           mapRotationEntryMock.getGameModeId
                                               :should_be_called()
                                               :and_will_return(11)
                         )
                         :and_also(
                           mapRotationEntryMock.getTimeInMinutes
                                               :should_be_called()
                                               :and_will_return(10)
                         )
                         :and_also(
                           mapRotationEntryMock.getAreGameChangeVotesAllowed
                                              :should_be_called()
                                              :and_will_return(true)
                         )
                         :and_also(
                           mapRotationEntryMock.getMinimumNumberOfPlayers
                                               :should_be_called()
                                               :and_will_return(2)
                         )
                         :and_also(
                           mapRotationEntryMock.getMaximumNumberOfPlayers
                                               :should_be_called()
                                               :and_will_return(11)
                         )
                         :and_also(
                           mapRotationEntryMock.getNumberOfSkipLines
                                               :should_be_called()
                                               :and_will_return(13)
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("ac_desert:11:10:1:2:11:13\n")
                         )
                         :and_then(
                           fileMock.close
                                   :should_be_called()
                         )
                         :when(
                           function()
                             mapRotationFile:appendEntry(mapRotationEntryMock)
                           end
                         )


  mapRotationFile = MapRotationFile("config/maprot_tdm.cfg")
  fileMock = {
    write = self.mach.mock_method("write"),
    close = self.mach.mock_method("close")
  }
  self:assertEquals("config/maprot_tdm.cfg", mapRotationFile:getFilePath())

  self.dependencyMocks.io.open
                         :should_be_called_with("config/maprot_tdm.cfg", "a")
                         :and_will_return(fileMock)
                         :and_also(
                           mapRotationEntryMock.getMapName
                                               :should_be_called()
                                               :and_will_return("ac_edifice")
                         )
                         :and_also(
                           mapRotationEntryMock.getGameModeId
                                               :should_be_called()
                                               :and_will_return(0)
                         )
                         :and_also(
                           mapRotationEntryMock.getTimeInMinutes
                                               :should_be_called()
                                               :and_will_return(12)
                         )
                         :and_also(
                           mapRotationEntryMock.getAreGameChangeVotesAllowed
                                               :should_be_called()
                                               :and_will_return(false)
                         )
                         :and_also(
                           mapRotationEntryMock.getMinimumNumberOfPlayers
                                               :should_be_called()
                                               :and_will_return(4)
                         )
                         :and_also(
                           mapRotationEntryMock.getMaximumNumberOfPlayers
                                               :should_be_called()
                                               :and_will_return(7)
                         )
                         :and_also(
                           mapRotationEntryMock.getNumberOfSkipLines
                                               :should_be_called()
                                               :and_will_return(1)
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("ac_edifice:0:12:0:4:7:1\n")
                         )
                         :and_then(
                           fileMock.close
                                   :should_be_called()
                         )
                         :when(
                           function()
                             mapRotationFile:appendEntry(mapRotationEntryMock)
                           end
                         )

end

---
-- Checks that all MapRotationEntry's can be set as expected.
--
function TestMapRotationFile:testCanSetEntries()

  local MapRotationFile = self.testClass

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


  local fileMock = {
    write = self.mach.mock_method("write"),
    close = self.mach.mock_method("close")
  }

  local mapRotationFile = MapRotationFile("config/maprot_random.cfg")
  self:assertEquals("config/maprot_random.cfg", mapRotationFile:getFilePath())

  self.dependencyMocks.io.open
                         :should_be_called_with("config/maprot_random.cfg", "a")
                         :and_will_return(fileMock)
                         :and_also(
                           mapRotationEntryMockA.getMapName
                                                :should_be_called()
                                                :and_will_return("ac_douze")
                                                :and_also(
                                                  mapRotationEntryMockA.getGameModeId
                                                                       :should_be_called()
                                                                       :and_will_return(3)
                                                )
                                                :and_also(
                                                  mapRotationEntryMockA.getTimeInMinutes
                                                                       :should_be_called()
                                                                       :and_will_return(11)
                                                )
                                                :and_also(
                                                  mapRotationEntryMockA.getAreGameChangeVotesAllowed
                                                                       :should_be_called()
                                                                       :and_will_return(true)
                                                )
                                                :and_also(
                                                  mapRotationEntryMockA.getMinimumNumberOfPlayers
                                                                       :should_be_called()
                                                                       :and_will_return(7)
                                                )
                                                :and_also(
                                                  mapRotationEntryMockA.getMaximumNumberOfPlayers
                                                                       :should_be_called()
                                                                       :and_will_return(8)
                                                )
                                                :and_also(
                                                  mapRotationEntryMockA.getNumberOfSkipLines
                                                                       :should_be_called()
                                                                       :and_will_return(2)
                                                )
                         )
                         :and_also(
                           mapRotationEntryMockB.getMapName
                                                :should_be_called()
                                                :and_will_return("camper-minecraft-edition-2")
                                                :and_also(
                                                  mapRotationEntryMockB.getGameModeId
                                                                       :should_be_called()
                                                                       :and_will_return(9)
                                                )
                                                :and_also(
                                                  mapRotationEntryMockB.getTimeInMinutes
                                                                       :should_be_called()
                                                                       :and_will_return(13)
                                                )
                                                :and_also(
                                                  mapRotationEntryMockB.getAreGameChangeVotesAllowed
                                                                       :should_be_called()
                                                                       :and_will_return(false)
                                                )
                                                :and_also(
                                                  mapRotationEntryMockB.getMinimumNumberOfPlayers
                                                                       :should_be_called()
                                                                       :and_will_return(4)
                                                )
                                                :and_also(
                                                  mapRotationEntryMockB.getMaximumNumberOfPlayers
                                                                       :should_be_called()
                                                                       :and_will_return(9)
                                                )
                                                :and_also(
                                                  mapRotationEntryMockB.getNumberOfSkipLines
                                                                       :should_be_called()
                                                                       :and_will_return(0)
                                                )
                         )
                         :and_also(
                           mapRotationEntryMockC.getMapName
                                                :should_be_called()
                                                :and_will_return("ac_sunset")
                                                :and_also(
                                                  mapRotationEntryMockC.getGameModeId
                                                                       :should_be_called()
                                                                       :and_will_return(4)
                                                )
                                                :and_also(
                                                  mapRotationEntryMockC.getTimeInMinutes
                                                                       :should_be_called()
                                                                       :and_will_return(8)
                                                )
                                                :and_also(
                                                  mapRotationEntryMockC.getAreGameChangeVotesAllowed
                                                                       :should_be_called()
                                                                       :and_will_return(true)
                                                )
                                                :and_also(
                                                  mapRotationEntryMockC.getMinimumNumberOfPlayers
                                                                       :should_be_called()
                                                                       :and_will_return(8)
                                                )
                                                :and_also(
                                                  mapRotationEntryMockC.getMaximumNumberOfPlayers
                                                                       :should_be_called()
                                                                       :and_will_return(16)
                                                )
                                                :and_also(
                                                  mapRotationEntryMockC.getNumberOfSkipLines
                                                                       :should_be_called()
                                                                       :and_will_return(7)
                                                )
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with(
                                     "ac_douze:3:11:1:7:8:2\n" ..
                                     "camper-minecraft-edition-2:9:13:0:4:9:0\n" ..
                                     "ac_sunset:4:8:1:8:16:7\n"
                                   )
                         )
                         :and_then(
                           fileMock.close
                                   :should_be_called()
                         )
                         :when(
                           function()
                             mapRotationFile:setEntries(newMapRotationEntries)
                           end
                         )

end

---
-- Checks that MapRotationEntry's can be removed by their map name from the start of the map rotation.
--
function TestMapRotationFile:testCanRemoveEntriesForMapAtStart()

  local MapRotationFile = self.testClass

  local fileMock = {
    write = self.mach.mock_method("write"),
    close = self.mach.mock_method("close")
  }

  local lines = {
    "Gema-BR:5:15:1:0:16:0",
    "MountainGema:5:15:1:0:16:0",
    "Gema_Simple:5:15:1:0:16:0",
    "gema_la_momie:5:15:1:0:16:0"
  }

  local mapRotationFile = MapRotationFile("config/gema_maprot.cfg")
  self:assertEquals("config/gema_maprot.cfg", mapRotationFile:getFilePath())

  self.dependencyMocks.io.open
                         :should_be_called_with("config/gema_maprot.cfg.tmp", "w")
                         :and_will_return(fileMock)
                         :and_also(
                           self.dependencyMocks.io.lines
                                               :should_be_called_with("config/gema_maprot.cfg")
                                               :and_will_return(self:generateLineIteratorMock(lines))
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("MountainGema:5:15:1:0:16:0\n")
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("Gema_Simple:5:15:1:0:16:0\n")
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("gema_la_momie:5:15:1:0:16:0\n")
                         )
                         :and_then(
                           fileMock.close
                                   :should_be_called()
                         )
                         :and_then(
                           self.dependencyMocks.os.rename
                                                  :should_be_called_with(
                                                    "config/gema_maprot.cfg.tmp", "config/gema_maprot.cfg"
                                                  )
                         )
                         :when(
                           function()
                             mapRotationFile:removeEntriesForMap("Gema-BR")
                           end
                         )

end

---
-- Checks that MapRotationEntry's can be removed by their map name from between the start and end of the map rotation.
--
function TestMapRotationFile:testCanRemoveEntriesForMapBetweenStartAndEnd()

  local MapRotationFile = self.testClass

  local fileMock = {
    write = self.mach.mock_method("write"),
    close = self.mach.mock_method("close")
  }

  local lines = {
    "SuperBrightGema:5:15:1:0:16:0",
    "MountainGema:5:15:1:0:16:0",
    "Gema_Simple:5:15:1:0:16:0",
    "gema_la_momie:5:15:1:0:16:0"
  }


  local mapRotationFile = MapRotationFile("config/ctf_maprot.cfg")
  self:assertEquals("config/ctf_maprot.cfg", mapRotationFile:getFilePath())

  self.dependencyMocks.io.open
                         :should_be_called_with("config/ctf_maprot.cfg.tmp", "w")
                         :and_will_return(fileMock)
                         :and_also(
                           self.dependencyMocks.io.lines
                                                  :should_be_called_with("config/ctf_maprot.cfg")
                                                  :and_will_return(self:generateLineIteratorMock(lines))
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("SuperBrightGema:5:15:1:0:16:0\n")
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("Gema_Simple:5:15:1:0:16:0\n")
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("gema_la_momie:5:15:1:0:16:0\n")
                         )
                         :and_then(
                           fileMock.close
                                   :should_be_called()
                         )
                         :and_then(
                           self.dependencyMocks.os.rename
                                                  :should_be_called_with(
                                                    "config/ctf_maprot.cfg.tmp", "config/ctf_maprot.cfg"
                                                  )
                         )
                         :when(
                           function()
                             mapRotationFile:removeEntriesForMap("MountainGema")
                           end
                         )

end

---
-- Checks that MapRotationEntry's can be removed by their map name from the end of the map rotation.
--
function TestMapRotationFile:testCanRemoveEntriesForMapAtEnd()

  local MapRotationFile = self.testClass

  local fileMock = {
    write = self.mach.mock_method("write"),
    close = self.mach.mock_method("close")
  }

  local lines = {
    "SuperBrightGema:5:15:1:0:16:0",
    "MountainGema:5:15:1:0:16:0",
    "Gema_Simple:5:15:1:0:16:0",
    "gema_la_momie:5:15:1:0:16:0"
  }


  local mapRotationFile = MapRotationFile("config/ctf_maprot.cfg")
  self:assertEquals("config/ctf_maprot.cfg", mapRotationFile:getFilePath())

  self.dependencyMocks.io.open
                         :should_be_called_with("config/ctf_maprot.cfg.tmp", "w")
                         :and_will_return(fileMock)
                         :and_also(
                           self.dependencyMocks.io.lines
                                                  :should_be_called_with("config/ctf_maprot.cfg")
                                                  :and_will_return(self:generateLineIteratorMock(lines))
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("SuperBrightGema:5:15:1:0:16:0\n")
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("MountainGema:5:15:1:0:16:0\n")
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("Gema_Simple:5:15:1:0:16:0\n")
                         )
                         :and_then(
                           fileMock.close
                                   :should_be_called()
                         )
                         :and_then(
                           self.dependencyMocks.os.rename
                                                  :should_be_called_with(
                                                    "config/ctf_maprot.cfg.tmp", "config/ctf_maprot.cfg"
                                                  )
                         )
                         :when(
                           function()
                             mapRotationFile:removeEntriesForMap("gema_la_momie")
                           end
                         )

end

---
-- Checks that multiple MapRotationEntry's can be removed at once by their map name from the map rotation.
--
function TestMapRotationFile:testCanRemoveMultipleEntriesForMap()

  local MapRotationFile = self.testClass

  local fileMock = {
    write = self.mach.mock_method("write"),
    close = self.mach.mock_method("close")
  }

  local lines = {
    "SuperBrightGema:5:15:1:0:16:0",
    "MountainGema:5:15:1:0:16:0",
    "SuperBrightGema:5:15:1:0:16:0",
    "gema_la_momie:5:15:1:0:16:0"
  }


  local mapRotationFile = MapRotationFile("config/ctf_maprot.cfg")
  self:assertEquals("config/ctf_maprot.cfg", mapRotationFile:getFilePath())

  self.dependencyMocks.io.open
                         :should_be_called_with("config/ctf_maprot.cfg.tmp", "w")
                         :and_will_return(fileMock)
                         :and_also(
                           self.dependencyMocks.io.lines
                                                  :should_be_called_with("config/ctf_maprot.cfg")
                                                  :and_will_return(self:generateLineIteratorMock(lines))
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("MountainGema:5:15:1:0:16:0\n")
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("gema_la_momie:5:15:1:0:16:0\n")
                         )
                         :and_then(
                           fileMock.close
                                   :should_be_called()
                         )
                         :and_then(
                           self.dependencyMocks.os.rename
                                                  :should_be_called_with(
                                                    "config/ctf_maprot.cfg.tmp", "config/ctf_maprot.cfg"
                                                  )
                         )
                         :when(
                           function()
                             mapRotationFile:removeEntriesForMap("SuperBrightGema")
                           end
                         )

end

---
-- Checks that a MapRotationEntry removal by map name call for a map that has no entry in the map rotation
-- is handled as expected.
--
function TestMapRotationFile:testCanHandleRemoveEntriesForNonExistingMap()

  local MapRotationFile = self.testClass

  local fileMock = {
    write = self.mach.mock_method("write"),
    close = self.mach.mock_method("close")
  }

  local lines = {
    "MountainGema:5:15:1:0:16:0",
    "gema_la_momie:5:15:1:0:16:0"
  }


  local mapRotationFile = MapRotationFile("config/ctf_maprot.cfg")
  self:assertEquals("config/ctf_maprot.cfg", mapRotationFile:getFilePath())

  self.dependencyMocks.io.open
                         :should_be_called_with("config/ctf_maprot.cfg.tmp", "w")
                         :and_will_return(fileMock)
                         :and_also(
                           self.dependencyMocks.io.lines
                                                  :should_be_called_with("config/ctf_maprot.cfg")
                                                  :and_will_return(self:generateLineIteratorMock(lines))
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("MountainGema:5:15:1:0:16:0\n")
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("gema_la_momie:5:15:1:0:16:0\n")
                         )
                         :and_then(
                           fileMock.close
                                   :should_be_called()
                         )
                         :and_then(
                           self.dependencyMocks.os.rename
                                                  :should_be_called_with(
                                                    "config/ctf_maprot.cfg.tmp", "config/ctf_maprot.cfg"
                                                  )
                         )
                         :when(
                           function()
                             mapRotationFile:removeEntriesForMap("gibbed-gema11")
                           end
                         )

end

---
-- Checks that map rotation entries are only removed when the map name and case match.
--
function TestMapRotationFile:testRemovesEntriesForMapCaseSensitive()

  local MapRotationFile = self.testClass

  local fileMock = {
    write = self.mach.mock_method("write"),
    close = self.mach.mock_method("close")
  }

  local lines = {
    "mountaingema:5:15:1:0:16:0",
    "MountainGema:5:15:1:0:16:0",
    "mountainGema:5:15:1:0:16:0",
    "Mountaingema:5:15:1:0:16:0"
  }


  local mapRotationFile = MapRotationFile("config/ctf_maprot.cfg")
  self:assertEquals("config/ctf_maprot.cfg", mapRotationFile:getFilePath())

  self.dependencyMocks.io.open
                         :should_be_called_with("config/ctf_maprot.cfg.tmp", "w")
                         :and_will_return(fileMock)
                         :and_also(
                           self.dependencyMocks.io.lines
                                                  :should_be_called_with("config/ctf_maprot.cfg")
                                                  :and_will_return(self:generateLineIteratorMock(lines))
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("mountaingema:5:15:1:0:16:0\n")
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("mountainGema:5:15:1:0:16:0\n")
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("Mountaingema:5:15:1:0:16:0\n")
                         )
                         :and_then(
                           fileMock.close
                                   :should_be_called()
                         )
                         :and_then(
                           self.dependencyMocks.os.rename
                                                  :should_be_called_with(
                                                    "config/ctf_maprot.cfg.tmp", "config/ctf_maprot.cfg"
                                                  )
                         )
                         :when(
                           function()
                             mapRotationFile:removeEntriesForMap("MountainGema")
                           end
                         )

end

---
-- Checks that map rotation entries are not removed if they contain the target map name somewhere in their map name.
--
function TestMapRotationFile:testDoesNotRemoveEntriesThatContainMapName()

  local MapRotationFile = self.testClass

  local fileMock = {
    write = self.mach.mock_method("write"),
    close = self.mach.mock_method("close")
  }

  local lines = {
    "gema_la_momiee:5:15:1:0:16:0",
    "gema_la_momie:5:15:1:0:16:0",
    "newgema_la_momie:5:15:1:0:16:0",
    "finalgema_la_momiefinal:5:15:1:0:16:0"
  }


  local mapRotationFile = MapRotationFile("config/ctf_maprot.cfg")
  self:assertEquals("config/ctf_maprot.cfg", mapRotationFile:getFilePath())

  self.dependencyMocks.io.open
                         :should_be_called_with("config/ctf_maprot.cfg.tmp", "w")
                         :and_will_return(fileMock)
                         :and_also(
                           self.dependencyMocks.io.lines
                                                  :should_be_called_with("config/ctf_maprot.cfg")
                                                  :and_will_return(self:generateLineIteratorMock(lines))
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("gema_la_momiee:5:15:1:0:16:0\n")
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("newgema_la_momie:5:15:1:0:16:0\n")
                         )
                         :and_then(
                           fileMock.write
                                   :should_be_called_with("finalgema_la_momiefinal:5:15:1:0:16:0\n")
                         )
                         :and_then(
                           fileMock.close
                                   :should_be_called()
                         )
                         :and_then(
                           self.dependencyMocks.os.rename
                                                  :should_be_called_with(
                                                    "config/ctf_maprot.cfg.tmp", "config/ctf_maprot.cfg"
                                                  )
                         )
                         :when(
                           function()
                             mapRotationFile:removeEntriesForMap("gema_la_momie")
                           end
                         )

end

---
-- Generates and returns a function that iterates over a set of lines and can be used in a
-- "for line in <function>" expression.
--
-- @tparam string[] _lines The lines to generate the iterator function for
--
-- @treturn function The iterator function
--
function TestMapRotationFile:generateLineIteratorMock(_lines)

  local lineNumber = 0
  local numberOfLines = #_lines

  return function()
    lineNumber = lineNumber + 1
    if (lineNumber <= numberOfLines) then
      return _lines[lineNumber]
    end
  end

end


---
-- Checks that the MapRotationFile can be removed as expected.
--
function TestMapRotationFile:testCanBeRemoved()

  local MapRotationFile = self.testClass

  local mapRotationFile = MapRotationFile("config/maprot_lss.cfg")
  self:assertEquals("config/maprot_lss.cfg", mapRotationFile:getFilePath())

  self.dependencyMocks.os.remove
                         :should_be_called_with("config/maprot_lss.cfg")
                         :when(
                           function()
                             mapRotationFile:remove()
                           end
                         )

end


return TestMapRotationFile
