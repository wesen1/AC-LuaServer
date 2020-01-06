---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the GameHandler works as expected.
--
-- @type TestGameHandler
--
local TestGameHandler = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestGameHandler.testClassPath = "AC-LuaServer.Core.GameHandler.GameHandler"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestGameHandler.dependencyPaths = {
  { id = "ActiveGame", path = "AC-LuaServer.Core.GameHandler.Game.ActiveGame" },
  { id = "EventCallback", path = "AC-LuaServer.Core.Event.EventCallback" },
  { id = "LuaServerApi", path = "AC-LuaServer.Core.LuaServerApi", ["type"] = "table" },
  { id = "MapRotationGame", path = "AC-LuaServer.Core.GameHandler.Game.MapRotationGame" },
  { id = "Server", path = "AC-LuaServer.Core.Server" },
  { id = "VotedGame", path = "AC-LuaServer.Core.GameHandler.Game.VotedGame" }
}

---
-- The event listener for the "onGameChangeVoteCalled" event of the GameHandler test instance
--
-- @tfield table onGameChangeVoteCalledListener
--
TestGameHandler.onGameChangeVoteCalledListener = nil

---
-- The event listener for the "onGameChangeVotePassed" event of the GameHandler test instance
--
-- @tfield table onGameChangeVotePassedListener
--
TestGameHandler.onGameChangeVotePassedListener = nil

---
-- The event listener for the "onGameChangeVoteFailed" event of the GameHandler test instance
--
-- @tfield table onGameChangeVoteFailedListener
--
TestGameHandler.onGameChangeVoteFailedListener = nil

---
-- The event listener for the "onGameWillChange" event of the GameHandler test instance
--
-- @tfield table onGameWillChangeListener
--
TestGameHandler.onGameWillChangeListener = nil

---
-- The event listener for the "onGameChanged" event of the GameHandler test instance
--
-- @tfield table onGameChangedListener
--
TestGameHandler.onGameChangedListener = nil


---
-- Method that is called before a test is executed.
-- Sets up the GameHandler event listeners.
--
function TestGameHandler:setUp()
  self.super.setUp(self)

  self.onGameChangeVoteCalledListener = self.mach.mock_function("onGameChangeVoteCalled")
  self.onGameChangeVotePassedListener = self.mach.mock_function("onGameChangeVotePassed")
  self.onGameChangeVoteFailedListener = self.mach.mock_function("onGameChangeVoteFailed")
  self.onGameWillChangeListener = self.mach.mock_function("onGameWillChange")
  self.onGameChangedListener = self.mach.mock_function("onGameChanged")
end

---
-- Method that is called after a test was executed.
-- Clears the GameHandler event listeners.
--
function TestGameHandler:tearDown()
  self.super.tearDown(self)

  self.onGameChangeVoteCalledListener = nil
  self.onGameChangeVotePassedListener = nil
  self.onGameChangeVoteFailedListener = nil
  self.onGameWillChangeListener = nil
  self.onGameChangedListener = nil
end


---
-- Checks that a successful vote call is handled as expected.
--
function TestGameHandler:testCanHandleCalledVote()

  local MapVote = require "AC-LuaServer.Core.VoteListener.Vote.MapVote"
  local gameHandler = self:createTestGameHandlerInstance()

  -- MapVote called
  local voteMock = self:getMock("AC-LuaServer.Core.VoteListener.Vote.MapVote", "VoteMock")
  voteMock.is = self.mach.mock_method("is")

  local votedGameMock = self:getMock("AC-LuaServer.Core.GameHandler.Game.VotedGame", "VotedGameMock")

  voteMock.is
          :should_be_called_with(MapVote)
          :and_will_return(true)
          :and_then(
            self.dependencyMocks.VotedGame.__call
                                          :should_be_called_with(voteMock)
                                          :and_will_return(votedGameMock)
          )
          :and_then(
            self.onGameChangeVoteCalledListener
                :should_be_called_with(votedGameMock)
          )
          :when(
            function()
              gameHandler:onPlayerCalledVote(voteMock)
            end
          )

  -- Some other vote called
  voteMock = self:getMock("AC-LuaServer.Core.VoteListener.Vote.Vote", "VoteMock")
  voteMock.is = self.mach.mock_method("is")

  voteMock.is
          :should_be_called_with(MapVote)
          :and_will_return(false)
          :when(
            function()
              gameHandler:onPlayerCalledVote(voteMock)
            end
          )

end

---
-- Checks that a failed vote is handled as expected.
--
function TestGameHandler:testCanHandleFailedVote()

  local MapVote = require "AC-LuaServer.Core.VoteListener.Vote.MapVote"
  local gameHandler = self:createTestGameHandlerInstance()

  -- MapVote failed
  local voteMock = self:getMock("AC-LuaServer.Core.VoteListener.Vote.MapVote", "VoteMock")
  voteMock.is = self.mach.mock_method("is")

  local votedGameMock = self:getMock("AC-LuaServer.Core.GameHandler.Game.VotedGame", "VotedGameMock")

  voteMock.is
          :should_be_called_with(MapVote)
          :and_will_return(true)
          :and_then(
            self.dependencyMocks.VotedGame.__call
                                          :should_be_called_with(voteMock)
                                          :and_will_return(votedGameMock)
          )
          :and_then(
            self.onGameChangeVoteFailedListener
                :should_be_called_with(votedGameMock)
          )
          :when(
            function()
              gameHandler:onVoteFailed(voteMock)
            end
          )

  -- Some other vote called
  voteMock = self:getMock("AC-LuaServer.Core.VoteListener.Vote.Vote", "VoteMock")
  voteMock.is = self.mach.mock_method("is")

  voteMock.is
          :should_be_called_with(MapVote)
          :and_will_return(false)
          :when(
            function()
              gameHandler:onVoteFailed(voteMock)
            end
          )

end

---
-- Checks that a map change event is handled as expected.
--
function TestGameHandler:testCanHandleMapChange()

  local gameHandler = self:createTestGameHandlerInstance()
  local activeGameMock = self:getMock("AC-LuaServer.Core.GameHandler.Game.ActiveGame", "ActiveGameMock")

  self:assertNil(gameHandler:getCurrentGame())

  self.dependencyMocks.ActiveGame.__call
                                 :should_be_called_with("ac_casa", 5)
                                 :and_will_return(activeGameMock)
                                 :and_then(
                                   self.onGameChangedListener
                                       :should_be_called_with(activeGameMock)
                                 )
                                 :when(
                                   function()
                                     gameHandler:onMapChange("ac_casa", 5)
                                   end
                                 )

  self:assertEquals(activeGameMock, gameHandler:getCurrentGame())

end

---
-- Checks that a map end event without previously set next game is handled as expected.
--
function TestGameHandler:testCanHandleGameEndWithoutSetNextGame()

  local gameHandler = self:createTestGameHandlerInstance()

  local serverMock = self:getMock("AC-LuaServer.Core.Server", "ServerMock")
  local mapRotationMock = self:getMock("AC-LuaServer.Core.MapRotation.MapRotation", "MapRotationMock")
  local mapRotationEntryMock = self:getMock(
    "AC-LuaServer.Core.MapRotation.MapRotationEntry", "MapRotationEntryMock"
  )
  local mapRotationGameMock = self:getMock(
    "AC-LuaServer.Core.GameHandler.Game.MapRotationGame", "MapRotationGameMock"
  )

  self.dependencyMocks.Server.getInstance
                             :should_be_called()
                             :and_will_return(serverMock)
                             :and_then(
                               serverMock.getMapRotation
                                         :should_be_called()
                                         :and_will_return(mapRotationMock)
                             )
                             :and_then(
                               mapRotationMock.getNextEntry
                                              :should_be_called()
                                              :and_will_return(mapRotationEntryMock)
                             )
                             :and_then(
                               self.dependencyMocks.MapRotationGame.__call
                                                                   :should_be_called_with(mapRotationEntryMock)
                                                                   :and_will_return(mapRotationGameMock)
                             )
                             :and_then(
                               self.onGameWillChangeListener
                                   :should_be_called_with(mapRotationGameMock)
                             )
                             :when(
                               function()
                                 gameHandler:onMapEnd()
                               end
                             )

end

---
-- Checks that a map end event with a previously set next game is handled as expected.
--
function TestGameHandler:testCanHandleGameEndWithSetNextGame()

  local MapVote = require "AC-LuaServer.Core.VoteListener.Vote.MapVote"
  local gameHandler = self:createTestGameHandlerInstance()

  -- MapVote called
  local voteMock = self:getMock("AC-LuaServer.Core.VoteListener.Vote.MapVote", "VoteMock")
  voteMock.is = self.mach.mock_method("is")

  local votedGameMock = self:getMock("AC-LuaServer.Core.GameHandler.Game.VotedGame", "VotedGameMock")

  -- setnext map vote passed
  voteMock.is
          :should_be_called_with(MapVote)
          :and_will_return(true)
          :and_then(
            self.dependencyMocks.VotedGame.__call
                                          :should_be_called_with(voteMock)
                                          :and_will_return(votedGameMock)
                                          :and_then(
                                            self.onGameChangeVotePassedListener
                                                :should_be_called_with(votedGameMock)
                                          )
          )
          :and_also(
            voteMock.getIsSetNext
                    :should_be_called()
                    :and_will_return(true)
          )
          :when(
            function()
              gameHandler:onVotePassed(voteMock)
            end
          )


  -- Current Game ended
  self.onGameWillChangeListener
      :should_be_called_with(votedGameMock)
      :when(
        function()
          gameHandler:onMapEnd()
        end
      )

end

---
-- Checks that the Game that was voted via setnext is reset when the map changes before the current Game ends.
--
function TestGameHandler:testSetNextVotedGameIsResetOnMapChange()

  local MapVote = require "AC-LuaServer.Core.VoteListener.Vote.MapVote"
  local gameHandler = self:createTestGameHandlerInstance()

  -- MapVote called
  local voteMock = self:getMock("AC-LuaServer.Core.VoteListener.Vote.MapVote", "VoteMock")
  voteMock.is = self.mach.mock_method("is")

  local votedGameMock = self:getMock("AC-LuaServer.Core.GameHandler.Game.VotedGame", "VotedGameMock")

  -- setnext map vote passed
  voteMock.is
          :should_be_called_with(MapVote)
          :and_will_return(true)
          :and_then(
            self.dependencyMocks.VotedGame.__call
                                          :should_be_called_with(voteMock)
                                          :and_will_return(votedGameMock)
                                          :and_then(
                                            self.onGameChangeVotePassedListener
                                                :should_be_called_with(votedGameMock)
                                          )
          )
          :and_also(
            voteMock.getIsSetNext
                    :should_be_called()
                    :and_will_return(true)
          )
          :when(
            function()
              gameHandler:onVotePassed(voteMock)
            end
          )


  -- Map changed
  local activeGameMock = self:getMock("AC-LuaServer.Core.GameHandler.Game.ActiveGame", "ActiveGameMock")

  self.dependencyMocks.ActiveGame.__call
                                 :should_be_called_with("ac_douze", 10)
                                 :and_will_return(activeGameMock)
                                 :and_then(
                                   self.onGameChangedListener
                                       :should_be_called_with(activeGameMock)
                                 )
                                 :when(
                                   function()
                                     gameHandler:onMapChange("ac_douze", 10)
                                   end
                                 )


  -- Next Game ended
  local serverMock = self:getMock("AC-LuaServer.Core.Server", "ServerMock")
  local mapRotationMock = self:getMock("AC-LuaServer.Core.MapRotation.MapRotation", "MapRotationMock")
  local mapRotationEntryMock = self:getMock(
    "AC-LuaServer.Core.MapRotation.MapRotationEntry", "MapRotationEntryMock"
  )
  local mapRotationGameMock = self:getMock(
    "AC-LuaServer.Core.GameHandler.Game.MapRotationGame", "MapRotationGameMock"
  )

  self.dependencyMocks.Server.getInstance
                             :should_be_called()
                             :and_will_return(serverMock)
                             :and_then(
                               serverMock.getMapRotation
                                         :should_be_called()
                                         :and_will_return(mapRotationMock)
                             )
                             :and_then(
                               mapRotationMock.getNextEntry
                                              :should_be_called()
                                              :and_will_return(mapRotationEntryMock)
                             )
                             :and_then(
                               self.dependencyMocks.MapRotationGame.__call
                                                                   :should_be_called_with(mapRotationEntryMock)
                                                                   :and_will_return(mapRotationGameMock)
                             )
                             :and_then(
                               self.onGameWillChangeListener
                                   :should_be_called_with(mapRotationGameMock)
                             )
                             :when(
                               function()
                                 gameHandler:onMapEnd()
                               end
                             )

end

---
-- Checks that passed votes are handled as expected.
--
function TestGameHandler:testCanHandlePassedVote()

  local MapVote = require "AC-LuaServer.Core.VoteListener.Vote.MapVote"
  local gameHandler = self:createTestGameHandlerInstance()

  -- MapVote called via /gonext or /<gamemode> <map> vote
  local voteMock = self:getMock("AC-LuaServer.Core.VoteListener.Vote.MapVote", "VoteMock")
  voteMock.is = self.mach.mock_method("is")

  local votedGameMock = self:getMock("AC-LuaServer.Core.GameHandler.Game.VotedGame", "VotedGameMock")
  voteMock.is
          :should_be_called_with(MapVote)
          :and_will_return(true)
          :and_then(
            self.dependencyMocks.VotedGame.__call
                                          :should_be_called_with(voteMock)
                                          :and_will_return(votedGameMock)
          )
          :and_then(
            self.onGameChangeVotePassedListener
                :should_be_called_with(votedGameMock)
          )
          :and_also(
            voteMock.getIsSetNext
                    :should_be_called()
                    :and_will_return(false)
                    :and_then(
                      self.onGameWillChangeListener
                          :should_be_called_with(votedGameMock)
                    )
          )
          :when(
            function()
              gameHandler:onVotePassed(voteMock)
            end
          )


  -- Some other vote called
  voteMock = self:getMock("AC-LuaServer.Core.VoteListener.Vote.Vote", "VoteMock")
  voteMock.is = self.mach.mock_method("is")

  voteMock.is
          :should_be_called_with(MapVote)
          :and_will_return(false)
          :when(
            function()
              gameHandler:onVotePassed(voteMock)
            end
          )

end

---
-- Checks that player connects are handled as expected.
--
function TestGameHandler:testCanHandlePlayerConnection()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.getmapname = self.mach.mock_function("getmapname")
  LuaServerApiMock.getgamemode = self.mach.mock_function("getgamemode")

  local gameHandler = self:createTestGameHandlerInstance()
  local playerMockA = self:getMock("AC-LuaServer.Core.PlayerList.Player", "PlayerMockA")
  local activeGameMock = self:getMock("AC-LuaServer.Core.GameHandler.Game.ActiveGame", "ActiveGameMock")

  -- Server had 0 connected players before this player connected, so this connection triggers a Game start
  LuaServerApiMock.getmapname
                  :should_be_called()
                  :and_will_return("ac_desert3")
                  :and_also(
                    LuaServerApiMock.getgamemode
                                    :should_be_called()
                                    :and_will_return(4)
                  )
                  :and_then(
                    self.dependencyMocks.ActiveGame.__call
                                                   :should_be_called_with("ac_desert3", 4)
                                                   :and_will_return(activeGameMock)
                  )
                  :and_then(
                    self.onGameChangedListener
                        :should_be_called_with(activeGameMock)
                  )
                  :when(
                    function()
                      gameHandler:onPlayerConnected(playerMockA, 1)
                    end
                  )

  -- Should do nothing when the number of connected players is not 1
  local playerMockB = self:getMock("AC-LuaServer.Core.PlayerList.Player", "PlayerMockB")
  gameHandler:onPlayerConnected(playerMockB, 2)

  local playerMockC = self:getMock("AC-LuaServer.Core.PlayerList.Player", "PlayerMockC")
  gameHandler:onPlayerConnected(playerMockC, 10)

end


---
-- Creates and returns a GameHandler instance to which the event listeners are attached.
--
-- @treturn GameHandler The test GameHandler instance
--
function TestGameHandler:createTestGameHandlerInstance()

  local GameHandler = self.testClass
  local gameHandler = GameHandler()

  local EventCallbackMock = self.dependencyMocks.EventCallback
  local ServerMock = self.dependencyMocks.Server

  local playerListMock = self:getMock("AC-LuaServer.Core.PlayerList.PlayerList", "PlayerListMock")
  local serverMock = self:getMock("AC-LuaServer.Core.Server", "ServerMock")
  local serverEventManagerMock = self:getMock(
    "AC-LuaServer.Core.ServerEvent.ServerEventManager", "ServerEventManagerMock"
  )

  local voteListenerMock = self:getMock("AC-LuaServer.Core.VoteListener.VoteListener", "VoteListenerMock")

  local eventCallbackPath = "AC-LuaServer.Core.Event.EventCallback"
  local eventCallbackMockA = self:getMock(eventCallbackPath, "EventCallbackMockA")
  local eventCallbackMockB = self:getMock(eventCallbackPath, "EventCallbackMockB")
  local eventCallbackMockC = self:getMock(eventCallbackPath, "EventCallbackMockC")
  local eventCallbackMockD = self:getMock(eventCallbackPath, "EventCallbackMockD")
  local eventCallbackMockE = self:getMock(eventCallbackPath, "EventCallbackMockE")
  local eventCallbackMockF = self:getMock(eventCallbackPath, "EventCallbackMockF")

  -- Initialize event callbacks and register the event handlers
  EventCallbackMock.__call
                   :should_be_called_with(
                     self.mach.match(
                       { object = GameHandler, methodName = "onMapEnd"},
                       TestGameHandler.matchEventCallback
                     ),
                     nil
                   )
                   :and_will_return(eventCallbackMockA)
                   :and_also(
                     EventCallbackMock.__call
                                      :should_be_called_with(
                                        self.mach.match(
                                          { object = GameHandler, methodName = "onMapChange" },
                                          TestGameHandler.matchEventCallback
                                        ),
                                        nil
                                      )
                                      :and_will_return(eventCallbackMockB)
                   )
                   :and_then(
                     ServerMock.getInstance
                               :should_be_called()
                               :and_will_return(serverMock)
                   )
                   :and_then(
                     serverMock.getEventManager
                               :should_be_called()
                               :and_will_return(serverEventManagerMock)
                               :and_then(
                                 serverEventManagerMock.on
                                                       :should_be_called_with("onMapEnd", eventCallbackMockA)
                               )
                               :and_also(
                                 serverEventManagerMock.on
                                                       :should_be_called_with("onMapChange", eventCallbackMockB)
                               )
                   )
                   :and_also(
                     ServerMock.getInstance
                               :should_be_called()
                               :and_will_return(serverMock)
                   )

                   -- Should fetch the vote listener and player list
                   :and_then(
                     serverMock.getVoteListener
                               :should_be_called()
                               :and_will_return(voteListenerMock)
                   )
                   :and_also(
                     serverMock.getPlayerList
                               :should_be_called()
                               :and_will_return(playerListMock)
                   )

                   -- Should set up the event callbacks
                   :and_also(
                     EventCallbackMock.__call
                                      :should_be_called_with(
                                        self.mach.match(
                                          { object = GameHandler, methodName = "onPlayerCalledVote" },
                                          TestGameHandler.matchEventCallback
                                        ),
                                        nil
                                      )
                                      :and_will_return(eventCallbackMockC)
                   )
                   :and_also(
                     EventCallbackMock.__call
                                      :should_be_called_with(
                                        self.mach.match(
                                          { object = GameHandler, methodName = "onVotePassed" },
                                          TestGameHandler.matchEventCallback
                                        ),
                                        nil
                                      )
                                      :and_will_return(eventCallbackMockD)
                   )
                   :and_also(
                     EventCallbackMock.__call
                                      :should_be_called_with(
                                        self.mach.match(
                                          { object = GameHandler, methodName = "onVoteFailed" },
                                          TestGameHandler.matchEventCallback
                                        ),
                                        nil
                                      )
                                      :and_will_return(eventCallbackMockE)
                   )
                   :and_also(
                     EventCallbackMock.__call
                                      :should_be_called_with(
                                        self.mach.match(
                                          { object = GameHandler, methodName = "onPlayerConnected" },
                                          TestGameHandler.matchEventCallback
                                        ),
                                        nil
                                      )
                                      :and_will_return(eventCallbackMockF)
                   )

                   -- Should set up the event listeners for the vote listener and the player list
                   :and_also(
                     voteListenerMock.on
                                     :should_be_called_with("onPlayerCalledVote", eventCallbackMockC)
                   )
                   :and_also(
                     voteListenerMock.on
                                     :should_be_called_with("onVotePassed", eventCallbackMockD)
                   )
                   :and_also(
                     voteListenerMock.on
                                     :should_be_called_with("onVoteFailed",eventCallbackMockE)
                   )
                   :and_also(
                     playerListMock.on
                                   :should_be_called_with("onPlayerAdded", eventCallbackMockF)
                   )
                   :when(
                     function()
                       gameHandler:initialize()
                     end
                   )


  -- Attach the event listeners to the GameHandler instance
  local EventCallback = self.originalDependencies["AC-LuaServer.Core.Event.EventCallback"]
  gameHandler:on("onGameChangeVoteCalled", EventCallback(function(...) self.onGameChangeVoteCalledListener(...) end))
  gameHandler:on("onGameChangeVotePassed", EventCallback(function(...) self.onGameChangeVotePassedListener(...) end))
  gameHandler:on("onGameChangeVoteFailed", EventCallback(function(...) self.onGameChangeVoteFailedListener(...) end))
  gameHandler:on("onGameWillChange", EventCallback(function(...) self.onGameWillChangeListener(...) end))
  gameHandler:on("onGameChanged", EventCallback(function(...) self.onGameChangedListener(...) end))

  return gameHandler

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
function TestGameHandler.matchEventCallback(_expected, _actual)
  return (_actual.object:is(_expected.object) and _actual.methodName == _expected.methodName)
end


return TestGameHandler
