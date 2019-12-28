---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the ActiveMapRotation works as expected.
--
-- @type TestActiveMapRotation
--
local TestActiveMapRotation = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestActiveMapRotation.testClassPath = "AC-LuaServer.Core.MapRotation.ActiveMapRotation"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestActiveMapRotation.dependencyPaths = {
  { id = "LuaServerApi", path = "AC-LuaServer.Core.LuaServerApi", ["type"] = "table" },
  { id = "MapRotationEntry", path = "AC-LuaServer.Core.MapRotation.MapRotationEntry" }
}


---
-- Checks that the active map rotation can be loaded from a specified MapRotationFile.
--
function TestActiveMapRotation:testCanBeLoadedFromFile()

  local ActiveMapRotation = self.testClass
  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.setmaprot = self.mach.mock_function("setmaprot")

  local activeMapRotation = ActiveMapRotation()

  LuaServerApiMock.setmaprot
                  :should_be_called_with("maprot_gema.cfg")
                  :when(
                    function()
                      activeMapRotation:loadFromFile("maprot_gema.cfg")
                    end
                  )

end

---
-- Checks that the next map rotation entry can be returned as expected.
--
function TestActiveMapRotation:testCanReturnNextEntry()

  local ActiveMapRotation = self.testClass
  local MapRotationEntryMock = self.dependencyMocks.MapRotationEntry
  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.getmaprotnextentry = self.mach.mock_function("getmaprotnextentry")

  local mapRotationEntryMock = self:getMock(
    "AC-LuaServer.Core.MapRotation.MapRotationEntry", "MapRotationEntryMock"
  )

  local activeMapRotation = ActiveMapRotation()
  local nextEntry

  LuaServerApiMock.getmaprotnextentry
                  :should_be_called()
                  :and_will_return({
                    map = "GemaWinter",
                    mode = 5,
                    time = 12,
                    allowVote = 1,
                    minplayer = 3,
                    maxplayer = 16,
                    skiplines = 1
                  })
                  :and_then(
                    MapRotationEntryMock.__call
                                        :should_be_called_with("GemaWinter")
                                        :and_will_return(mapRotationEntryMock)
                  )
                  :and_then(
                    mapRotationEntryMock.setGameModeId
                                        :should_be_called_with(5)
                                        :and_will_return(mapRotationEntryMock)
                  )
                  :and_also(
                    mapRotationEntryMock.setTimeInMinutes
                                        :should_be_called_with(12)
                                        :and_will_return(mapRotationEntryMock)
                  )
                  :and_also(
                    mapRotationEntryMock.setAreGameChangeVotesAllowed
                                        :should_be_called_with(true)
                                        :and_will_return(mapRotationEntryMock)
                  )
                  :and_also(
                    mapRotationEntryMock.setMinimumNumberOfPlayers
                                        :should_be_called_with(3)
                                        :and_will_return(mapRotationEntryMock)
                  )
                  :and_also(
                    mapRotationEntryMock.setMaximumNumberOfPlayers
                                        :should_be_called_with(16)
                                        :and_will_return(mapRotationEntryMock)
                  )
                  :and_also(
                    mapRotationEntryMock.setNumberOfSkipLines
                                        :should_be_called_with(1)
                                        :and_will_return(mapRotationEntryMock)
                  )
                  :when(
                    function()
                      nextEntry = activeMapRotation:getNextEntry()
                    end
                  )

  self:assertEquals(mapRotationEntryMock, nextEntry)


  mapRotationEntryMock = self:getMock(
    "AC-LuaServer.Core.MapRotation.MapRotationEntry", "MapRotationEntryMock"
  )

  LuaServerApiMock.getmaprotnextentry
                  :should_be_called()
                  :and_will_return({
                    map = "GEMA-iCEMAN",
                    mode = 5,
                    time = 8,
                    allowVote = 0,
                    minplayer = 5,
                    maxplayer = 14,
                    skiplines = 0
                  })
                  :and_then(
                    MapRotationEntryMock.__call
                                        :should_be_called_with("GEMA-iCEMAN")
                                        :and_will_return(mapRotationEntryMock)
                  )
                  :and_then(
                    mapRotationEntryMock.setGameModeId
                                        :should_be_called_with(5)
                                        :and_will_return(mapRotationEntryMock)
                  )
                  :and_also(
                    mapRotationEntryMock.setTimeInMinutes
                                        :should_be_called_with(8)
                                        :and_will_return(mapRotationEntryMock)
                  )
                  :and_also(
                    mapRotationEntryMock.setAreGameChangeVotesAllowed
                                        :should_be_called_with(false)
                                        :and_will_return(mapRotationEntryMock)
                  )
                  :and_also(
                    mapRotationEntryMock.setMinimumNumberOfPlayers
                                        :should_be_called_with(5)
                                        :and_will_return(mapRotationEntryMock)
                  )
                  :and_also(
                    mapRotationEntryMock.setMaximumNumberOfPlayers
                                        :should_be_called_with(14)
                                        :and_will_return(mapRotationEntryMock)
                  )
                  :and_also(
                    mapRotationEntryMock.setNumberOfSkipLines
                                        :should_be_called_with(0)
                                        :and_will_return(mapRotationEntryMock)
                  )
                  :when(
                    function()
                      nextEntry = activeMapRotation:getNextEntry()
                    end
                  )

  self:assertEquals(mapRotationEntryMock, nextEntry)

end

---
-- Checks that a MapRotationEntry can be appended as expected.
--
function TestActiveMapRotation:testCanAppendEntry()

  local ActiveMapRotation = self.testClass
  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.getwholemaprot = self.mach.mock_function("getmaprotnextentry")
  LuaServerApiMock.setwholemaprot = self.mach.mock_function("setwholemaprot")

  local mapRotationEntryMock = self:getMock(
    "AC-LuaServer.Core.MapRotation.MapRotationEntry", "MapRotationEntryMock"
  )

  local activeMapRotation = ActiveMapRotation()


  LuaServerApiMock.getwholemaprot
                  :should_be_called()
                  :and_will_return({
                    {
                      map = "GEMA-iCEMAN",
                      mode = 5,
                      time = 8,
                      allowVote = 0,
                      minplayer = 5,
                      maxplayer = 14,
                      skiplines = 0
                    },
                    {
                      map = "GemaWinter",
                      mode = 5,
                      time = 12,
                      allowVote = 1,
                      minplayer = 3,
                      maxplayer = 16,
                      skiplines = 1
                    }
                  })
                  :and_also(
                    mapRotationEntryMock.getMapName
                                        :should_be_called()
                                        :and_will_return("gladi-gema1")
                  )
                  :and_also(
                    mapRotationEntryMock.getGameModeId
                                        :should_be_called()
                                        :and_will_return(5)
                  )
                  :and_also(
                    mapRotationEntryMock.getTimeInMinutes
                                        :should_be_called()
                                        :and_will_return(18)
                  )
                  :and_also(
                    mapRotationEntryMock.getAreGameChangeVotesAllowed
                                        :should_be_called()
                                        :and_will_return(true)
                  )
                  :and_also(
                    mapRotationEntryMock.getMinimumNumberOfPlayers
                                        :should_be_called()
                                        :and_will_return(8)
                  )
                  :and_also(
                    mapRotationEntryMock.getMaximumNumberOfPlayers
                                        :should_be_called()
                                        :and_will_return(10)
                  )
                  :and_also(
                    mapRotationEntryMock.getNumberOfSkipLines
                                        :should_be_called()
                                        :and_will_return(4)
                  )
                  :and_then(
                    LuaServerApiMock.setwholemaprot
                                    :should_be_called_with(
                                      self.mach.match({
                                        {
                                          map = "GEMA-iCEMAN",
                                          mode = 5,
                                          time = 8,
                                          allowVote = 0,
                                          minplayer = 5,
                                          maxplayer = 14,
                                          skiplines = 0
                                        },
                                        {
                                          map = "GemaWinter",
                                          mode = 5,
                                          time = 12,
                                          allowVote = 1,
                                          minplayer = 3,
                                          maxplayer = 16,
                                          skiplines = 1
                                        },
                                        {
                                          map = "gladi-gema1",
                                          mode = 5,
                                          time = 18,
                                          allowVote = 1,
                                          minplayer = 8,
                                          maxplayer = 10,
                                          skiplines = 4
                                        }
                                      })
                                    )
                  ):when(
                    function()
                      activeMapRotation:appendEntry(mapRotationEntryMock)
                    end
                  )


    LuaServerApiMock.getwholemaprot
                    :should_be_called()
                    :and_will_return({})
                    :and_also(
                      mapRotationEntryMock.getMapName
                                          :should_be_called()
                                          :and_will_return("gema_warm_up")
                    )
                    :and_also(
                      mapRotationEntryMock.getGameModeId
                                          :should_be_called()
                                          :and_will_return(0)
                    )
                    :and_also(
                      mapRotationEntryMock.getTimeInMinutes
                                          :should_be_called()
                                          :and_will_return(7)
                    )
                    :and_also(
                      mapRotationEntryMock.getAreGameChangeVotesAllowed
                                          :should_be_called()
                                          :and_will_return(false)
                    )
                    :and_also(
                      mapRotationEntryMock.getMinimumNumberOfPlayers
                                          :should_be_called()
                                          :and_will_return(2)
                    )
                    :and_also(
                      mapRotationEntryMock.getMaximumNumberOfPlayers
                                          :should_be_called()
                                          :and_will_return(12)
                    )
                    :and_also(
                      mapRotationEntryMock.getNumberOfSkipLines
                                          :should_be_called()
                                          :and_will_return(3)
                    )
                    :and_then(
                      LuaServerApiMock.setwholemaprot
                                      :should_be_called_with(
                                        self.mach.match({
                                          {
                                            map = "gema_warm_up",
                                            mode = 0,
                                            time = 7,
                                            allowVote = 0,
                                            minplayer = 2,
                                            maxplayer = 12,
                                            skiplines = 3
                                          }
                                        })
                                      )
                    ):when(
                      function()
                        activeMapRotation:appendEntry(mapRotationEntryMock)
                      end
                    )

end

---
-- Checks that MapRotationEntry's can be removed by their map name from the start of the map rotation.
--
function TestActiveMapRotation:testCanRemoveEntriesForMapAtStart()

  local mapRotation = {
    {
      map = "Gema-BR",
      mode = 5,
      time = 15,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "MountainGema",
      mode = 5,
      time = 16,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "Gema_Simple",
      mode = 5,
      time = 17,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "gema_la_momie",
      mode = 5,
      time = 18,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    }
  }

  local expectedUpdatedMapRotation = {
    {
      map = "MountainGema",
      mode = 5,
      time = 16,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "Gema_Simple",
      mode = 5,
      time = 17,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "gema_la_momie",
      mode = 5,
      time = 18,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    }
  }


  local ActiveMapRotation = self.testClass
  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.getwholemaprot = self.mach.mock_function("getmaprotnextentry")
  LuaServerApiMock.setwholemaprot = self.mach.mock_function("setwholemaprot")

  local activeMapRotation = ActiveMapRotation()

  LuaServerApiMock.getwholemaprot
                  :should_be_called()
                  :and_will_return(mapRotation)
                  :and_then(
                    LuaServerApiMock.setwholemaprot
                                    :should_be_called_with(self.mach.match(expectedUpdatedMapRotation))
                  )
                  :when(
                    function()
                      activeMapRotation:removeEntriesForMap("Gema-BR")
                    end
                  )

end

---
-- Checks that MapRotationEntry's can be removed by their map name from between the start and end of the map rotation.
--
function TestActiveMapRotation:testCanRemoveEntriesForMapBetweenStartAndEnd()

  local mapRotation = {
    {
      map = "SuperBrightGema",
      mode = 5,
      time = 15,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "MountainGema",
      mode = 5,
      time = 14,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "Gema_Simple",
      mode = 5,
      time = 13,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "gema_la_momie",
      mode = 5,
      time = 12,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    }
  }

  local expectedUpdatedMapRotation = {
    {
      map = "SuperBrightGema",
      mode = 5,
      time = 15,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "Gema_Simple",
      mode = 5,
      time = 13,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "gema_la_momie",
      mode = 5,
      time = 12,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    }
  }


  local ActiveMapRotation = self.testClass
  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.getwholemaprot = self.mach.mock_function("getmaprotnextentry")
  LuaServerApiMock.setwholemaprot = self.mach.mock_function("setwholemaprot")

  local activeMapRotation = ActiveMapRotation()

  LuaServerApiMock.getwholemaprot
                  :should_be_called()
                  :and_will_return(mapRotation)
                  :and_then(
                    LuaServerApiMock.setwholemaprot
                                    :should_be_called_with(self.mach.match(expectedUpdatedMapRotation))
                  )
                  :when(
                    function()
                      activeMapRotation:removeEntriesForMap("MountainGema")
                    end
                  )

end

---
-- Checks that MapRotationEntry's can be removed by their map name from the end of the map rotation.
--
function TestActiveMapRotation:testCanRemoveEntriesForMapAtEnd()

    local mapRotation = {
    {
      map = "SuperBrightGema",
      mode = 5,
      time = 15,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "MountainGema",
      mode = 5,
      time = 14,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "Gema_Simple",
      mode = 5,
      time = 13,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "gema_la_momie",
      mode = 5,
      time = 12,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    }
  }

  local expectedUpdatedMapRotation = {
    {
      map = "SuperBrightGema",
      mode = 5,
      time = 15,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "MountainGema",
      mode = 5,
      time = 14,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "Gema_Simple",
      mode = 5,
      time = 13,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    }
  }


  local ActiveMapRotation = self.testClass
  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.getwholemaprot = self.mach.mock_function("getmaprotnextentry")
  LuaServerApiMock.setwholemaprot = self.mach.mock_function("setwholemaprot")

  local activeMapRotation = ActiveMapRotation()

  LuaServerApiMock.getwholemaprot
                  :should_be_called()
                  :and_will_return(mapRotation)
                  :and_then(
                    LuaServerApiMock.setwholemaprot
                                    :should_be_called_with(self.mach.match(expectedUpdatedMapRotation))
                  )
                  :when(
                    function()
                      activeMapRotation:removeEntriesForMap("gema_la_momie")
                    end
                  )

end

---
-- Checks that multiple MapRotationEntry's can be removed at once by their map name from the map rotation.
--
function TestActiveMapRotation:testCanRemoveMultipleEntriesForMap()

    local mapRotation = {
    {
      map = "SuperBrightGema",
      mode = 5,
      time = 15,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "MountainGema",
      mode = 0,
      time = 14,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "SuperBrightGema",
      mode = 0,
      time = 12,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 3
    },
    {
      map = "gema_la_momie",
      mode = 5,
      time = 12,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    }
  }

  local expectedUpdatedMapRotation = {
    {
      map = "MountainGema",
      mode = 0,
      time = 14,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "gema_la_momie",
      mode = 5,
      time = 12,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    }
  }


  local ActiveMapRotation = self.testClass
  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.getwholemaprot = self.mach.mock_function("getmaprotnextentry")
  LuaServerApiMock.setwholemaprot = self.mach.mock_function("setwholemaprot")

  local activeMapRotation = ActiveMapRotation()

  LuaServerApiMock.getwholemaprot
                  :should_be_called()
                  :and_will_return(mapRotation)
                  :and_then(
                    LuaServerApiMock.setwholemaprot
                                    :should_be_called_with(self.mach.match(expectedUpdatedMapRotation))
                  )
                  :when(
                    function()
                      activeMapRotation:removeEntriesForMap("SuperBrightGema")
                    end
                  )

end

---
-- Checks that a MapRotationEntry removal by map name call for a map that has no entry in the map rotation
-- is handled as expected.
--
function TestActiveMapRotation:testCanHandleRemoveEntriesForNonExistingMap()

    local mapRotation = {
    {
      map = "MountainGema",
      mode = 0,
      time = 14,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "gema_la_momie",
      mode = 5,
      time = 12,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    }
  }

  local expectedUpdatedMapRotation = {
    {
      map = "MountainGema",
      mode = 0,
      time = 14,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "gema_la_momie",
      mode = 5,
      time = 12,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    }
  }


  local ActiveMapRotation = self.testClass
  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.getwholemaprot = self.mach.mock_function("getmaprotnextentry")
  LuaServerApiMock.setwholemaprot = self.mach.mock_function("setwholemaprot")

  local activeMapRotation = ActiveMapRotation()

  LuaServerApiMock.getwholemaprot
                  :should_be_called()
                  :and_will_return(mapRotation)
                  :and_then(
                    LuaServerApiMock.setwholemaprot
                                    :should_be_called_with(self.mach.match(expectedUpdatedMapRotation))
                  )
                  :when(
                    function()
                      activeMapRotation:removeEntriesForMap("gibbed-gema11")
                    end
                  )

end

---
-- Checks that map rotation entries are only removed when the map name and case match.
--
function TestActiveMapRotation:testRemovesEntriesForMapCaseSensitive()

  local mapRotation = {
    {
      map = "mountaingema",
      mode = 0,
      time = 14,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "MountainGema",
      mode = 5,
      time = 12,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "mountainGema",
      mode = 5,
      time = 12,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "Mountaingema",
      mode = 5,
      time = 12,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    }
  }

  local expectedUpdatedMapRotation = {
    {
      map = "mountaingema",
      mode = 0,
      time = 14,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "mountainGema",
      mode = 5,
      time = 12,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "Mountaingema",
      mode = 5,
      time = 12,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    }
  }


  local ActiveMapRotation = self.testClass
  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.getwholemaprot = self.mach.mock_function("getmaprotnextentry")
  LuaServerApiMock.setwholemaprot = self.mach.mock_function("setwholemaprot")

  local activeMapRotation = ActiveMapRotation()

  LuaServerApiMock.getwholemaprot
                  :should_be_called()
                  :and_will_return(mapRotation)
                  :and_then(
                    LuaServerApiMock.setwholemaprot
                                    :should_be_called_with(self.mach.match(expectedUpdatedMapRotation))
                  )
                  :when(
                    function()
                      activeMapRotation:removeEntriesForMap("MountainGema")
                    end
                  )

end

---
-- Checks that map rotation entries are not removed if they contain the target map name somewhere in their map name.
--
function TestActiveMapRotation:testDoesNotRemoveEntriesThatContainMapName()

  local mapRotation = {
    {
      map = "gema_la_momiee",
      mode = 0,
      time = 14,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "gema_la_momie",
      mode = 5,
      time = 12,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "newgema_la_momie",
      mode = 5,
      time = 12,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "finalgema_la_momiefinal",
      mode = 5,
      time = 12,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    }
  }

  local expectedUpdatedMapRotation = {
    {
      map = "gema_la_momiee",
      mode = 0,
      time = 14,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "newgema_la_momie",
      mode = 5,
      time = 12,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    },
    {
      map = "finalgema_la_momiefinal",
      mode = 5,
      time = 12,
      allowVote = 1,
      minplayer = 0,
      maxplayer = 16,
      skiplines = 0
    }
  }


  local ActiveMapRotation = self.testClass
  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.getwholemaprot = self.mach.mock_function("getmaprotnextentry")
  LuaServerApiMock.setwholemaprot = self.mach.mock_function("setwholemaprot")

  local activeMapRotation = ActiveMapRotation()

  LuaServerApiMock.getwholemaprot
                  :should_be_called()
                  :and_will_return(mapRotation)
                  :and_then(
                    LuaServerApiMock.setwholemaprot
                                    :should_be_called_with(self.mach.match(expectedUpdatedMapRotation))
                  )
                  :when(
                    function()
                      activeMapRotation:removeEntriesForMap("gema_la_momie")
                    end
                  )

end

---
-- Checks that the ActiveMapRotation can be cleared as expected.
--
function TestActiveMapRotation:testCanBeCleared()

  local ActiveMapRotation = self.testClass
  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.setwholemaprot = self.mach.mock_function("setwholemaprot")

  local activeMapRotation = ActiveMapRotation()

  LuaServerApiMock.setwholemaprot
                  :should_be_called_with(self.mach.match({}))
                  :when(
                    function()
                      activeMapRotation:clear()
                    end
                  )

end


return TestActiveMapRotation
