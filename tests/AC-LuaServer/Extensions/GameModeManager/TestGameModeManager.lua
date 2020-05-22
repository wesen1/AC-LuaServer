---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the GameModeManager works as expected.
--
-- @type TestGameModeManager
--
local TestGameModeManager = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestGameModeManager.testClassPath = "AC-LuaServer.Extensions.GameModeManager.GameModeManager"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestGameModeManager.dependencyPaths = {
  { id = "DefaultGameMode", path = "AC-LuaServer.Extensions.GameModeManager.DefaultGameMode" },
  { id = "EventCallback", path = "AC-LuaServer.Core.Event.EventCallback" }
}


---
-- The DefaultGameMode mock that will be injected into the test GameModeManager instance
--
-- @tfield table defaultGameModeMock
--
TestGameModeManager.defaultGameModeMock = nil

---
-- The EventCallback mock for the "disabled" event of the current active GameMode that will be
-- injected into the test GameModeManager instance
--
-- @tfield table onActiveGameModeDisabledEventCallbackMock
--
TestGameModeManager.onActiveGameModeDisabledEventCallbackMock = nil

---
-- The Server mock that will be injected into the test GameModeManager instance
--
-- @tfield table serverMock
--
TestGameModeManager.serverMock = nil

---
-- The listener for the "onGameModeMightChange" event that will be attached to the test
-- GameModeManager instance
--
-- @tfield table onGameModeMightChangeListener
--
TestGameModeManager.onGameModeMightChangeListener = nil

---
-- The listener for the "onGameModeChanged" event that will be attached to the test
-- GameModeManager instance
--
-- @tfield table onGameModeChangedListener
--
TestGameModeManager.onGameModeChangedListener = nil


---
-- Method that is called before a test is executed.
-- Sets up the mocks and the event listeners.
--
function TestGameModeManager:setUp()
  self.super.setUp(self)

  self.defaultGameModeMock = self:createGameModeMock("DefaultGameModeMock")
  self.onActiveGameModeDisabledEventCallbackMock = self:getMock(
    "AC-LuaServer.Core.Event.EventCallback", "onActiveGameModeDisabledEventCallbackMock"
  )
  self.serverMock = self:getMock("AC-LuaServer.Core.Server", "ServerMock")

  self.onGameModeMightChangeListener = self.mach.mock_function("onGameModeMightChange")
  self.onGameModeChangedListener = self.mach.mock_function("onGameModeChanged")
end

---
-- Method that is called after a test was executed.
-- Clears the mocks and the event listeners.
--
function TestGameModeManager:tearDown()
  self.super.tearDown(self)

  self.defaultGameModeMock = nil
  self.onActiveGameModeDisabledEventCallbackMock = nil
  self.serverMock = nil
  self.onGameModeMightChangeListener = nil
  self.onGameModeChangedListener = nil
end


---
-- Checks that a "Game will change or did change" event can be handled when there are no additional
-- game modes configured besides the default game mode.
--
function TestGameModeManager:testCanHandleGameWillOrDidChangeEventsWhenThereAreNoAdditionalGameModes()

  local gameModeManager = self:createEnabledTestInstance()
  local outputMock = self:getMock("AC-LuaServer.Core.Output.Output", "OutputMock")

  -- No game mode enabled yet and only the default game mode is available
  local gameMockA = self:getMock("AC-LuaServer.Core.GameHandler.Game.Game", "GameMockA")
  self.defaultGameModeMock.canBeEnabledForGame
                          :should_be_called_with(gameMockA)
                          :and_will_return(true)
                          :and_then(
                            self:expectGameModeEnabled(gameModeManager, nil, self.defaultGameModeMock)
                          )
                          :and_then(
                            self.serverMock.getOutput
                                           :should_be_called()
                                           :and_will_return(outputMock)
                                           :and_also(
                                             self.defaultGameModeMock.getDisplayName
                                                                     :should_be_called()
                                                                     :and_will_return("Default")
                                           )
                                           :and_then(
                                             outputMock.printTextTemplate
                                                       :should_be_called_with(
                                                         "Extensions/GameModeManager/GameModeChanged",
                                                         self.mach.match({ newGameModeName = "Default" })
                                                       )
                                           )
                          )
                          :and_then(
                            self.onGameModeChangedListener
                                :should_be_called_with(nil, self.defaultGameModeMock)
                          )
                          :when(
                            function()
                              gameModeManager:onGameWillOrDidChange(gameMockA)
                            end
                          )

  -- When the default game mode is the chosen game mode again nothing should be set up
  local gameMockB = self:getMock("AC-LuaServer.Core.GameHandler.Game.Game", "GameMockB")
  self.defaultGameModeMock.canBeEnabledForGame
                          :should_be_called_with(gameMockB)
                          :and_will_return(true)
                          :when(
                            function()
                              gameModeManager:onGameWillOrDidChange(gameMockB)
                            end
                          )

end

---
-- Checks that a "Game will change or did change" event can be handled when there are additional
-- game modes configured besides the default game mode.
--
function TestGameModeManager:testCanHandleGameWillOrDidChangeEventsWhenThereAreAdditionalGameModes()

  local BaseGameMode = require "AC-LuaServer.Extensions.GameModeManager.BaseGameMode"
  local DefaultGameMode = require "AC-LuaServer.Extensions.GameModeManager.DefaultGameMode"

  local gameModeManager = self:createEnabledTestInstance()
  local gameModeMockA = self:createGameModeMock("GameModeMockA")
  local gameModeMockB = self:createGameModeMock("GameModeMockB")
  local outputMock = self:getMock("AC-LuaServer.Core.Output.Output", "OutputMock")

  -- Add a additional game mode
  gameModeMockA.is
               :should_be_called_with(BaseGameMode)
               :and_will_return(true)
               :and_then(
                 gameModeMockA.is
                              :should_be_called_with(DefaultGameMode)
                              :and_will_return(false)
               )
               :when(
                 function()
                   gameModeManager:addExtension(gameModeMockA)
                 end
               )

  -- Add another additional game mode
  gameModeMockB.is
               :should_be_called_with(BaseGameMode)
               :and_will_return(true)
               :and_then(
                 gameModeMockB.is
                              :should_be_called_with(DefaultGameMode)
                              :and_will_return(false)
               )
               :when(
                 function()
                   gameModeManager:addExtension(gameModeMockB)
                 end
               )

  -- Activate the second additional game mode
  local gameMockA = self:getMock("AC-LuaServer.Core.GameHandler.Game.Game", "GameMockA")
  gameModeMockA.canBeEnabledForGame
               :should_be_called_with(gameMockA)
               :and_will_return(false)
               :and_then(
                 gameModeMockB.canBeEnabledForGame
                              :should_be_called_with(gameMockA)
                              :and_will_return(true)
               )
               :and_then(
                 self:expectGameModeEnabled(gameModeManager, nil, gameModeMockB)
               )
               :and_then(
                 self.serverMock.getOutput
                                :should_be_called()
                                :and_will_return(outputMock)
                                :and_also(
                                  gameModeMockB.getDisplayName
                                               :should_be_called()
                                               :and_will_return("Zombie")
                                )
                                :and_then(
                                  outputMock.printTextTemplate
                                            :should_be_called_with(
                                              "Extensions/GameModeManager/GameModeChanged",
                                              self.mach.match({ newGameModeName = "Zombie" })
                                            )
                                )
               )
               :and_then(
                 self.onGameModeChangedListener
                     :should_be_called_with(nil, gameModeMockB)
               )
               :when(
                 function()
                   gameModeManager:onGameWillOrDidChange(gameMockA)
                 end
               )

  -- Keep the second additional game mode activated for the next Game
  local gameMockB = self:getMock("AC-LuaServer.Core.GameHandler.Game.Game", "GameMockB")
  gameModeMockA.canBeEnabledForGame
               :should_be_called_with(gameMockB)
               :and_will_return(false)
               :and_also(
                 gameModeMockB.canBeEnabledForGame
                              :should_be_called_with(gameMockB)
                              :and_will_return(true)
               )
               :when(
                 function()
                   gameModeManager:onGameWillOrDidChange(gameMockB)
                 end
               )

  -- Activate the default game mode for the next Game
  local gameMockC = self:getMock("AC-LuaServer.Core.GameHandler.Game.Game", "GameMockC")
  gameModeMockA.canBeEnabledForGame
               :should_be_called_with(gameMockC)
               :and_will_return(false)
               :and_then(
                 gameModeMockB.canBeEnabledForGame
                              :should_be_called_with(gameMockC)
                              :and_will_return(false)
               )
               :and_then(
                 self.defaultGameModeMock.canBeEnabledForGame
                                         :should_be_called_with(gameMockC)
                                         :and_will_return(true)
               )
               :and_then(
                 self:expectGameModeEnabled(gameModeManager, gameModeMockB, self.defaultGameModeMock)
               )
               :and_then(
                 self.serverMock.getOutput
                                :should_be_called()
                                :and_will_return(outputMock)
                                :and_also(
                                  self.defaultGameModeMock.getDisplayName
                                                          :should_be_called()
                                                          :and_will_return("Default")
                                )
                                :and_then(
                                  outputMock.printTextTemplate
                                            :should_be_called_with(
                                              "Extensions/GameModeManager/GameModeChanged",
                                              self.mach.match({ newGameModeName = "Default" })
                                            )
                                )
               )
               :and_then(
                 self.onGameModeChangedListener
                     :should_be_called_with(gameModeMockB, self.defaultGameModeMock)
               )
               :when(
                 function()
                   gameModeManager:onGameWillOrDidChange(gameMockC)
                 end
               )

  -- Keep the default game mode activated for the next Game
  local gameMockD = self:getMock("AC-LuaServer.Core.GameHandler.Game.Game", "GameMockD")
  gameModeMockA.canBeEnabledForGame
               :should_be_called_with(gameMockD)
               :and_will_return(false)
               :and_then(
                 gameModeMockB.canBeEnabledForGame
                              :should_be_called_with(gameMockD)
                              :and_will_return(false)
               )
               :and_then(
                 self.defaultGameModeMock.canBeEnabledForGame
                                         :should_be_called_with(gameMockD)
                                         :and_will_return(true)
               )
               :when(
                 function()
                   gameModeManager:onGameWillOrDidChange(gameMockD)
                 end
               )

end

---
-- Checks that the default game mode can be activated as the initial game mode when there are
-- additional game modes.
--
function TestGameModeManager:testCanActivateDefaultGameModeAsInitialGameModeWhenThereAreAdditionalGameModes()

  local BaseGameMode = require "AC-LuaServer.Extensions.GameModeManager.BaseGameMode"
  local DefaultGameMode = require "AC-LuaServer.Extensions.GameModeManager.DefaultGameMode"

  local gameModeManager = self:createEnabledTestInstance()
  local gameModeMockA = self:createGameModeMock("GameModeMockA")
  local gameModeMockB = self:createGameModeMock("GameModeMockB")
  local outputMock = self:getMock("AC-LuaServer.Core.Output.Output", "OutputMock")

  -- Add a additional game mode
  gameModeMockA.is
               :should_be_called_with(BaseGameMode)
               :and_will_return(true)
               :and_then(
                 gameModeMockA.is
                              :should_be_called_with(DefaultGameMode)
                              :and_will_return(false)
               )
               :when(
                 function()
                   gameModeManager:addExtension(gameModeMockA)
                 end
               )

  -- Add another additional game mode
  gameModeMockB.is
               :should_be_called_with(BaseGameMode)
               :and_will_return(true)
               :and_then(
                 gameModeMockB.is
                              :should_be_called_with(DefaultGameMode)
                              :and_will_return(false)
               )
               :when(
                 function()
                   gameModeManager:addExtension(gameModeMockB)
                 end
               )

  -- Activate the default game mode
  local gameMockA = self:getMock("AC-LuaServer.Core.GameHandler.Game.Game", "GameMockA")
  gameModeMockA.canBeEnabledForGame
               :should_be_called_with(gameMockA)
               :and_will_return(false)
               :and_then(
                 gameModeMockB.canBeEnabledForGame
                              :should_be_called_with(gameMockA)
                              :and_will_return(false)
               )
               :and_then(
                 self.defaultGameModeMock.canBeEnabledForGame
                                         :should_be_called_with(gameMockA)
                                         :and_will_return(true)
               )
               :and_then(
                 self:expectGameModeEnabled(gameModeManager, nil, self.defaultGameModeMock)
               )
               :and_then(
                 self.serverMock.getOutput
                                :should_be_called()
                                :and_will_return(outputMock)
                                :and_also(
                                  self.defaultGameModeMock.getDisplayName
                                                          :should_be_called()
                                                          :and_will_return("Default")
                                )
                                :and_then(
                                  outputMock.printTextTemplate
                                            :should_be_called_with(
                                              "Extensions/GameModeManager/GameModeChanged",
                                              self.mach.match({ newGameModeName = "Default" })
                                            )
                                )
               )
               :and_then(
                 self.onGameModeChangedListener
                     :should_be_called_with(nil, self.defaultGameModeMock)
               )
               :when(
                 function()
                   gameModeManager:onGameWillOrDidChange(gameMockA)
                 end
               )

end


---
-- Checks that a Game changing vote call is handled as expected when there is no
-- active GameMode at the moment.
--
function TestGameModeManager:testCanHandleGameChangeVoteCall()

  local BaseGameMode = require "AC-LuaServer.Extensions.GameModeManager.BaseGameMode"
  local DefaultGameMode = require "AC-LuaServer.Extensions.GameModeManager.DefaultGameMode"

  local gameModeManager = self:createEnabledTestInstance()
  local gameModeMockA = self:createGameModeMock("GameModeMockA")
  local gameModeMockB = self:createGameModeMock("GameModeMockB")
  local outputMock = self:getMock("AC-LuaServer.Core.Output.Output", "OutputMock")

  -- Add a additional game mode
  gameModeMockA.is
               :should_be_called_with(BaseGameMode)
               :and_will_return(true)
               :and_then(
                 gameModeMockA.is
                              :should_be_called_with(DefaultGameMode)
                              :and_will_return(false)
               )
               :when(
                 function()
                   gameModeManager:addExtension(gameModeMockA)
                 end
               )

  gameModeMockB.is
               :should_be_called_with(BaseGameMode)
               :and_will_return(true)
               :and_then(
                 gameModeMockB.is
                              :should_be_called_with(DefaultGameMode)
                              :and_will_return(false)
               )
               :when(
                 function()
                   gameModeManager:addExtension(gameModeMockB)
                 end
               )


  -- Game changing vote called
  local votedGameMock = self:getMock("AC-LuaServer.Core.GameHandler.Game.Game", "VotedGameMock")

  gameModeMockA.canBeEnabledForGame
               :should_be_called_with(votedGameMock)
               :and_will_return(false)
               :and_also(
                 gameModeMockB.canBeEnabledForGame
                              :should_be_called_with(votedGameMock)
                              :and_will_return(true)
               )
               :and_then(
                 self.serverMock.getOutput
                                :should_be_called()
                                :and_will_return(outputMock)
                                :and_also(
                                  gameModeMockB.getDisplayName
                                               :should_be_called()
                                               :and_will_return("Zombie")
                                )
                                :and_then(
                                  outputMock.printTextTemplate
                                            :should_be_called_with(
                                              "Extensions/GameModeManager/GameModeWillChangeIfVotePasses",
                                              self.mach.match({ nextGameModeName = "Zombie" })
                                            )
                                )
               )
               :and_then(
                 self.onGameModeMightChangeListener
                     :should_be_called_with(nil, gameModeMockB)
               )
               :when(
                 function()
                   gameModeManager:onGameChangeVoteCalled(votedGameMock)
                 end
               )

end

---
-- Checks that a Game changing vote call is handled as expected when there is a
-- active GameMode at the moment.
--
function TestGameModeManager:testCanHandleGameChangeVoteCallWhenThereIsACurrentActiveGame()

  local BaseGameMode = require "AC-LuaServer.Extensions.GameModeManager.BaseGameMode"
  local DefaultGameMode = require "AC-LuaServer.Extensions.GameModeManager.DefaultGameMode"

  local gameModeManager = self:createEnabledTestInstance()
  local gameModeMockA = self:createGameModeMock("GameModeMockA")
  local gameModeMockB = self:createGameModeMock("GameModeMockB")
  local outputMock = self:getMock("AC-LuaServer.Core.Output.Output", "OutputMock")

  -- Add a additional game mode
  gameModeMockA.is
               :should_be_called_with(BaseGameMode)
               :and_will_return(true)
               :and_then(
                 gameModeMockA.is
                              :should_be_called_with(DefaultGameMode)
                              :and_will_return(false)
               )
               :when(
                 function()
                   gameModeManager:addExtension(gameModeMockA)
                 end
               )

  gameModeMockB.is
               :should_be_called_with(BaseGameMode)
               :and_will_return(true)
               :and_then(
                 gameModeMockB.is
                              :should_be_called_with(DefaultGameMode)
                              :and_will_return(false)
               )
               :when(
                 function()
                   gameModeManager:addExtension(gameModeMockB)
                 end
               )


  -- Activate the default game mode
  local gameMockA = self:getMock("AC-LuaServer.Core.GameHandler.Game.Game", "GameMockA")
  gameModeMockA.canBeEnabledForGame
               :should_be_called_with(gameMockA)
               :and_will_return(false)
               :and_then(
                 gameModeMockB.canBeEnabledForGame
                              :should_be_called_with(gameMockA)
                              :and_will_return(false)
               )
               :and_then(
                 self.defaultGameModeMock.canBeEnabledForGame
                                         :should_be_called_with(gameMockA)
                                         :and_will_return(true)
               )
               :and_then(
                 self:expectGameModeEnabled(gameModeManager, nil, self.defaultGameModeMock)
               )
               :and_then(
                 self.serverMock.getOutput
                                :should_be_called()
                                :and_will_return(outputMock)
                                :and_also(
                                  self.defaultGameModeMock.getDisplayName
                                                          :should_be_called()
                                                          :and_will_return("Default")
                                )
                                :and_then(
                                  outputMock.printTextTemplate
                                            :should_be_called_with(
                                              "Extensions/GameModeManager/GameModeChanged",
                                              self.mach.match({ newGameModeName = "Default" })
                                            )
                                )
               )
               :and_then(
                 self.onGameModeChangedListener
                     :should_be_called_with(nil, self.defaultGameModeMock)
               )
               :when(
                 function()
                   gameModeManager:onGameWillOrDidChange(gameMockA)
                 end
               )


  -- Case A: The game mode for the voted Game is different than the currently active game mode
  local votedGameMockA = self:getMock("AC-LuaServer.Core.GameHandler.Game.Game", "VotedGameMockA")
  gameModeMockA.canBeEnabledForGame
               :should_be_called_with(votedGameMockA)
               :and_will_return(true)
               :and_then(
                 self.serverMock.getOutput
                                :should_be_called()
                                :and_will_return(outputMock)
                                :and_also(
                                  gameModeMockA.getDisplayName
                                               :should_be_called()
                                               :and_will_return("Gema")
                                )
                                :and_then(
                                  outputMock.printTextTemplate
                                            :should_be_called_with(
                                              "Extensions/GameModeManager/GameModeWillChangeIfVotePasses",
                                              self.mach.match({ nextGameModeName = "Gema" })
                                            )
                                )
               )
               :and_then(
                 self.onGameModeMightChangeListener
                     :should_be_called_with(self.defaultGameModeMock, gameModeMockA)
               )
               :when(
                 function()
                   gameModeManager:onGameChangeVoteCalled(votedGameMockA)
                 end
               )

  -- Case B: The game mode for the voted Game is the same as the currently active game mode
  local votedGameMockB = self:getMock("AC-LuaServer.Core.GameHandler.Game.Game", "VotedGameMockB")
  gameModeMockA.canBeEnabledForGame
               :should_be_called_with(votedGameMockB)
               :and_will_return(false)
               :and_then(
                 gameModeMockB.canBeEnabledForGame
                              :should_be_called_with(votedGameMockB)
                              :and_will_return(false)
               )
               :and_then(
                 self.defaultGameModeMock.canBeEnabledForGame
                                         :should_be_called_with(votedGameMockB)
                                         :and_will_return(true)
               )
               :when(
                 function()
                   gameModeManager:onGameChangeVoteCalled(votedGameMockB)
                 end
               )

end

---
-- Checks that the GameModeManager can handle when the currently active game mode disables itself.
--
function TestGameModeManager:testCanHandleActiveGameModeDisablingItself()

  local BaseGameMode = require "AC-LuaServer.Extensions.GameModeManager.BaseGameMode"
  local DefaultGameMode = require "AC-LuaServer.Extensions.GameModeManager.DefaultGameMode"

  local gameModeManager = self:createEnabledTestInstance()
  local gameModeMockA = self:createGameModeMock("GameModeMockA")
  local gameModeMockB = self:createGameModeMock("GameModeMockB")
  local outputMock = self:getMock("AC-LuaServer.Core.Output.Output", "OutputMock")

  -- Add a additional game mode
  gameModeMockA.is
               :should_be_called_with(BaseGameMode)
               :and_will_return(true)
               :and_then(
                 gameModeMockA.is
                              :should_be_called_with(DefaultGameMode)
                              :and_will_return(false)
               )
               :when(
                 function()
                   gameModeManager:addExtension(gameModeMockA)
                 end
               )

  gameModeMockB.is
               :should_be_called_with(BaseGameMode)
               :and_will_return(true)
               :and_then(
                 gameModeMockB.is
                              :should_be_called_with(DefaultGameMode)
                              :and_will_return(false)
               )
               :when(
                 function()
                   gameModeManager:addExtension(gameModeMockB)
                 end
               )


  -- Activate the first additional game mode
  local gameMockA = self:getMock("AC-LuaServer.Core.GameHandler.Game.Game", "GameMockA")
  gameModeMockA.canBeEnabledForGame
               :should_be_called_with(gameMockA)
               :and_will_return(true)
               :and_then(
                 self:expectGameModeEnabled(gameModeManager, nil, gameModeMockA)
               )
               :and_then(
                 self.serverMock.getOutput
                                :should_be_called()
                                :and_will_return(outputMock)
                                :and_also(
                                  gameModeMockA.getDisplayName
                                               :should_be_called()
                                               :and_will_return("Gema")
                                )
                                :and_then(
                                  outputMock.printTextTemplate
                                            :should_be_called_with(
                                              "Extensions/GameModeManager/GameModeChanged",
                                              self.mach.match({ newGameModeName = "Gema" })
                                            )
                                )
               )
               :and_then(
                 self.onGameModeChangedListener
                     :should_be_called_with(nil, gameModeMockA)
               )
               :when(
                 function()
                   gameModeManager:onGameWillOrDidChange(gameMockA)
                 end
               )


  -- Make the acitve game mode disable itself
  local gameHandlerMock = self:getMock(
    "AC-LuaServer.Core.GameHandler.GameHandler", "GameHandlerMock"
  )
  local gameMockB = self:createGameModeMock("GameMockB")

  self.serverMock.getGameHandler
                 :should_be_called()
                 :and_will_return(gameHandlerMock)
                 :and_then(
                   gameHandlerMock.getCurrentGame
                                  :should_be_called()
                                  :and_will_return(gameMockB)
                 )
                 :and_then(
                   gameModeMockA.canBeEnabledForGame
                                :should_be_called_with(gameMockB)
                                :and_will_return(false)
                                :and_then(
                                  gameModeMockB.canBeEnabledForGame
                                               :should_be_called_with(gameMockB)
                                               :and_will_return(false)
                                )
                                :and_then(
                                  self.defaultGameModeMock.canBeEnabledForGame
                                                          :should_be_called_with(gameMockB)
                                                          :and_will_return(true)
                                )
                 )
                 :and_then(
                   self:expectGameModeEnabled(gameModeManager, gameModeMockA, self.defaultGameModeMock)
                 )
                 :and_then(
                   self.onGameModeChangedListener
                       :should_be_called_with(gameModeMockA, self.defaultGameModeMock)
                 )
                 :when(
                   function()
                     gameModeManager:onActiveGameModeDisabled()
                   end
                 )

end


---
-- Checks that non GameMode extensions can be added to the GameModeManager when it's not enabled.
--
function TestGameModeManager:testCanAddNonGameModeExtensionsWhenNotEnabled()

  local BaseGameMode = require "AC-LuaServer.Extensions.GameModeManager.BaseGameMode"
  local DefaultGameMode = require "AC-LuaServer.Extensions.GameModeManager.DefaultGameMode"

  local gameModeManager = self:createTestInstance()

  local nonGameModeExtensionA = self:getMock(
    "AC-LuaServer.Core.Extension.BaseExtension", "NonGameModeExtensionA"
  )
  nonGameModeExtensionA.is = self.mach.mock_method("is")

  local nonGameModeExtensionB = self:getMock(
    "AC-LuaServer.Core.Extension.BaseExtension", "NonGameModeExtensionB"
  )
  nonGameModeExtensionB.is = self.mach.mock_method("is")

  local gameModeExtensionMock = self:getMock(
    "AC-LuaServer.Extensions.GameModeManager.BaseGameMode"
  )
  gameModeExtensionMock.is = self.mach.mock_method("is")


  -- Add the first non GameMode extension
  nonGameModeExtensionA.is
                       :should_be_called_with(BaseGameMode)
                       :and_will_return(false)
                       :when(
                         function()
                           gameModeManager:addExtension(nonGameModeExtensionA)
                         end
                       )

  -- Add a GameMode extension
  gameModeExtensionMock.is
                       :should_be_called_with(BaseGameMode)
                       :and_will_return(true)
                       :and_then(
                         gameModeExtensionMock.is
                                              :should_be_called_with(DefaultGameMode)
                                              :and_will_return(false)
                       )
                       :when(
                         function()
                           gameModeManager:addExtension(gameModeExtensionMock)
                         end
                       )

  -- Add the second non GameMode extension
  nonGameModeExtensionB.is
                       :should_be_called_with(BaseGameMode)
                       :and_will_return(false)
                       :when(
                         function()
                           gameModeManager:addExtension(nonGameModeExtensionB)
                         end
                       )

  -- Enable the GameModeManage
  self:expectEventListenersSetup()
      :and_then(
        nonGameModeExtensionA.is
                             :should_be_called_with(BaseGameMode)
                             :and_will_return(false)
                             :and_then(
                               nonGameModeExtensionA.enable
                                                    :should_be_called_with(gameModeManager)
                             )
      )
      :and_then(
        gameModeExtensionMock.is
                             :should_be_called_with(BaseGameMode)
                             :and_will_return(true)
      )
      :and_then(
        nonGameModeExtensionB.is
                             :should_be_called_with(BaseGameMode)
                             :and_will_return(false)
                             :and_then(
                               nonGameModeExtensionB.enable
                                                    :should_be_called_with(gameModeManager)
                             )
      )
      :when(
        function()
          gameModeManager:enable(self.serverMock)
        end
      )

end

---
-- Checks that non GameMode extensions can be added to the GameModeManager when it's enabled.
--
function TestGameModeManager:testCanAddNonGameModeExtensionsWhenEnabled()

  local BaseGameMode = require "AC-LuaServer.Extensions.GameModeManager.BaseGameMode"
  local DefaultGameMode = require "AC-LuaServer.Extensions.GameModeManager.DefaultGameMode"

  local gameModeManager = self:createEnabledTestInstance()

  local nonGameModeExtensionA = self:getMock(
    "AC-LuaServer.Core.Extension.BaseExtension", "NonGameModeExtensionA"
  )
  nonGameModeExtensionA.is = self.mach.mock_method("is")

  local nonGameModeExtensionB = self:getMock(
    "AC-LuaServer.Core.Extension.BaseExtension", "NonGameModeExtensionB"
  )
  nonGameModeExtensionB.is = self.mach.mock_method("is")

  local gameModeExtensionMock = self:getMock(
    "AC-LuaServer.Extensions.GameModeManager.BaseGameMode"
  )
  gameModeExtensionMock.is = self.mach.mock_method("is")


  -- Add the first non GameMode extension
  nonGameModeExtensionA.is
                       :should_be_called_with(BaseGameMode)
                       :and_will_return(false)
                       :and_then(
                         nonGameModeExtensionA.enable
                                              :should_be_called_with(gameModeManager)
                       )
                       :when(
                         function()
                           gameModeManager:addExtension(nonGameModeExtensionA)
                         end
                       )

  -- Add a GameMode extension
  gameModeExtensionMock.is
                       :should_be_called_with(BaseGameMode)
                       :and_will_return(true)
                       :and_then(
                         gameModeExtensionMock.is
                                              :should_be_called_with(DefaultGameMode)
                                              :and_will_return(false)
                       )
                       :when(
                         function()
                           gameModeManager:addExtension(gameModeExtensionMock)
                         end
                       )

  -- Add the second non GameMode extension
  nonGameModeExtensionB.is
                       :should_be_called_with(BaseGameMode)
                       :and_will_return(false)
                       :and_then(
                         nonGameModeExtensionB.enable
                                              :should_be_called_with(gameModeManager)
                       )
                       :when(
                         function()
                           gameModeManager:addExtension(nonGameModeExtensionB)
                         end
                       )

end


---
-- Creates and returns a GameModeManager test instance.
--
-- @treturn GameModeManager The GameModeManager test instance
--
function TestGameModeManager:createTestInstance()

  local GameModeManager = self.testClass
  local EventCallbackMock = self.dependencyMocks.EventCallback

  local gameModeManager

  EventCallbackMock.__call
                   :should_be_called_with(
                     self.mach.match(
                       { object = GameModeManager, methodName = "onActiveGameModeDisabled" },
                       TestGameModeManager.matchEventCallback
                     )
                   )
                   :and_will_return(self.onActiveGameModeDisabledEventCallbackMock)
                   :when(
                     function()
                       gameModeManager = GameModeManager()
                     end
                   )

  self:assertEquals("GameModeManager", gameModeManager:getName())
  self:assertEquals("Server", gameModeManager:getTargetName())


  -- Attach the event listeners
  local EventCallback = self.originalDependencies["AC-LuaServer.Core.Event.EventCallback"]
  gameModeManager:on(
    "onGameModeMightChange",
    EventCallback(function(...) self.onGameModeMightChangeListener(...) end)
  )
  gameModeManager:on(
    "onGameModeChanged",
    EventCallback(function(...) self.onGameModeChangedListener(...) end)
  )


  return gameModeManager

end

---
-- Creates and returns a enabled GameModeManager test instance.
--
-- @treturn GameModeManager The enabled GameModeManager test instance
--
function TestGameModeManager:createEnabledTestInstance()

  local BaseGameMode = require "AC-LuaServer.Extensions.GameModeManager.BaseGameMode"
  local DefaultGameMode = require "AC-LuaServer.Extensions.GameModeManager.DefaultGameMode"

  local gameModeManager = self:createTestInstance()

  self:expectEventListenersSetup()
      :when(
        function()
          gameModeManager:enable(self.serverMock)
        end
      )


  -- Must manually do what the extension manager would do when addExtension is called
  self.defaultGameModeMock.is
                          :should_be_called_with(BaseGameMode)
                          :and_will_return(true)
                          :and_then(
                            self.defaultGameModeMock.is
                                                    :should_be_called_with(DefaultGameMode)
                                                    :and_will_return(true)
                          )
                          :when(
                            function()
                              gameModeManager:addExtension(self.defaultGameModeMock)
                            end
                          )

  return gameModeManager

end

---
-- Generates and returns the expectations for the event listener setup of a GameModeManager's
-- initialization process.
--
-- @treturn function The generated expectations
--
function TestGameModeManager:expectEventListenersSetup()

  local DefaultGameModeMock = self.dependencyMocks.DefaultGameMode
  local EventCallbackMock = self.dependencyMocks.EventCallback
  local GameModeManager = self.testClass

  local extensionManagerMock = self:getMock(
    "AC-LuaServer.Core.Extension.ExtensionManager", "ExtensionManagerMock"
  )
  local gameHandlerMock = self:getMock(
    "AC-LuaServer.Core.GameHandler.GameHandler", "GameHandlerMock"
  )

  local eventCallbackPath = "AC-LuaServer.Core.Event.EventCallback"
  local eventCallbackMockA = self:getMock(eventCallbackPath, "EventCallbackMockA")
  local eventCallbackMockB = self:getMock(eventCallbackPath, "EventCallbackMockB")
  local eventCallbackMockC = self:getMock(eventCallbackPath, "EventCallbackMockC")

  return self.serverMock.getExtensionManager
                        :should_be_called()
                        :and_will_return(extensionManagerMock)
                        :and_then(
                          DefaultGameModeMock.__call
                                             :should_be_called()
                                             :and_will_return(self.defaultGameModeMock)
                                             :and_then(
                                               extensionManagerMock.addExtension
                                                                   :should_be_called_with(
                                                                     self.defaultGameModeMock
                                                                   )
                                             )
                        )
                        :and_also(
                          self.serverMock.getGameHandler
                                         :should_be_called()
                                         :and_will_return(gameHandlerMock)
                                         :and_then(
                                           EventCallbackMock.__call
                                                            :should_be_called_with(
                                                              self.mach.match(
                                                                {
                                                                  object = GameModeManager,
                                                                  methodName = "onGameChangeVoteCalled"
                                                                },
                                                                TestGameModeManager.matchEventCallback
                                                              ),
                                                              nil
                                                            )
                                                            :and_will_return(eventCallbackMockA)
                                         )
                                         :and_then(
                                           gameHandlerMock.on
                                                          :should_be_called_with(
                                                            "onGameChangeVoteCalled", eventCallbackMockA
                                                          )
                                         )
                                         :and_also(
                                           EventCallbackMock.__call
                                                            :should_be_called_with(
                                                              self.mach.match(
                                                                {
                                                                  object = GameModeManager,
                                                                  methodName = "onGameWillOrDidChange"
                                                                },
                                                                TestGameModeManager.matchEventCallback
                                                              ),
                                                              nil
                                                            )
                                                            :and_will_return(eventCallbackMockB)
                                         )
                                         :and_then(
                                           gameHandlerMock.on
                                                          :should_be_called_with(
                                                            "onGameWillChange", eventCallbackMockB
                                                          )
                                         )
                                         :and_also(
                                           EventCallbackMock.__call
                                                            :should_be_called_with(
                                                              self.mach.match(
                                                                {
                                                                  object = GameModeManager,
                                                                  methodName = "onGameWillOrDidChange"
                                                                },
                                                                TestGameModeManager.matchEventCallback
                                                              ),
                                                              nil
                                                            )
                                                            :and_will_return(eventCallbackMockC)
                                         )
                                         :and_then(
                                           gameHandlerMock.on
                                                          :should_be_called_with(
                                                            "onGameChangedPlayerConnected",
                                                            eventCallbackMockC
                                                          )
                                         )
                        )

end

---
-- Creates and returns a named GameMode mock.
--
-- @tparam string _mockName The name for the Gamemode mock
--
-- @treturn table The GameMode mock
--
function TestGameModeManager:createGameModeMock(_mockName)

  local gameModeMock = self:getMock("AC-LuaServer.Extensions.GameModeManager.BaseGameMode", _mockName)

  gameModeMock.is = self.mach.mock_method("is")
  gameModeMock.on = self.mach.mock_method("on")
  gameModeMock.off = self.mach.mock_method("off")
  gameModeMock.enable = self.mach.mock_method("enable")
  gameModeMock.disable = self.mach.mock_method("disable")

  return gameModeMock

end

---
-- Generates and returns the expectations for a game mode activation.
--
-- @tparam GameModeManager The test GameModeManager instance
-- @tparam GameMode|nil The GameMode that is currently active
-- @tparam GameMode The GameMode that will be activated
--
-- @treturn function The expectations for the game mode activation
--
function TestGameModeManager:expectGameModeEnabled(_gameModeManager, _previousGameMode, _nextGameMode)

  local previousGameModeDisabledExpectation
  if (_previousGameMode) then

    previousGameModeDisabledExpectation = _previousGameMode.off
                                                           :should_be_called_with(
                                                             "disabled",
                                                             self.onActiveGameModeDisabledEventCallbackMock
                                                           )
                                                           :and_then(
                                                             _previousGameMode.disable
                                                                              :should_be_called()
                                                           )

  end

  local nextGameModeEnabledExpectation = _nextGameMode.on
                                                      :should_be_called_with(
                                                        "disabled",
                                                        self.onActiveGameModeDisabledEventCallbackMock
                                                      )
                                                      :and_then(
                                                        _nextGameMode.enable
                                                                     :should_be_called_with(_gameModeManager)
                                                      )

  if (previousGameModeDisabledExpectation) then
    return previousGameModeDisabledExpectation:and_then(
      nextGameModeEnabledExpectation
    )
  else
    return nextGameModeEnabledExpectation
  end

end


---
-- Matches a specific event callback constructor call.
--
-- The expected object must be a class, the expected methodName a string.
-- This matcher function then checks that he object is an instance of the specified class and that the
-- method names match.
--
-- @treturn bool True if the actual value met the expectations, false otherwise
--
function TestGameModeManager.matchEventCallback(_expected, _actual)
  return (_actual.object:is(_expected.object) and _actual.methodName == _expected.methodName)
end


return TestGameModeManager
