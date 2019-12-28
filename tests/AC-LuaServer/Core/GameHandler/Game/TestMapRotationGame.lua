---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the MapRotationGame works as expected.
--
-- @type TestMapRotationGame
--
local TestMapRotationGame = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestMapRotationGame.testClassPath = "AC-LuaServer.Core.GameHandler.Game.MapRotationGame"


---
-- Checks that a MapRotationGame can be created as expected.
--
function TestMapRotationGame:testCanBeCreated()

  local MapRotationGame = self.testClass

  local mapRotationEntryMock = self:getMock(
    "AC-LuaServer.Core.MapRotation.MapRotationEntry", "MapRotationEntryMock"
  )
  local mapRotationGame = MapRotationGame(mapRotationEntryMock)

  -- Fetch the map name
  local mapName
  mapRotationEntryMock.getMapName
                      :should_be_called()
                      :and_will_return("Nice_Insane_Gema")
                      :when(
                        function()
                          mapName = mapRotationGame:getMapName()
                        end
                      )
  self:assertEquals("Nice_Insane_Gema", mapName)

  -- Fetch the game mode id
  local gameModeId
  mapRotationEntryMock.getGameModeId
                      :should_be_called()
                      :and_will_return(1)
                      :when(
                        function()
                          gameModeId = mapRotationGame:getGameModeId()
                        end
                      )
  self:assertEquals(1, gameModeId)

  -- Fetch the time in minutes
  local timeInMinutes
  mapRotationEntryMock.getTimeInMinutes
                      :should_be_called()
                      :and_will_return(60)
                      :when(
                        function()
                          timeInMinutes = mapRotationGame:getTimeInMinutes()
                        end
                      )
  self:assertEquals(60, timeInMinutes)

end


return TestMapRotationGame
