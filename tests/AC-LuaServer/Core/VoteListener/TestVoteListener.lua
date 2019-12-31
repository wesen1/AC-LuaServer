---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the VoteListener works as expected.
--
-- @type TestVoteListener
--
local TestVoteListener = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestVoteListener.testClassPath = "AC-LuaServer.Core.VoteListener.VoteListener"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestVoteListener.dependencyPaths = {
  { id = "EventCallback", path = "AC-LuaServer.Core.Event.EventCallback" },
  { id = "LuaServerApi", path = "AC-LuaServer.Core.LuaServerApi", ["type"] = "table" },
  { id = "MapVote", path = "AC-LuaServer.Core.VoteListener.Vote.MapVote" },
  { id = "Vote", path = "AC-LuaServer.Core.VoteListener.Vote.Vote" },
  { id = "Server", path = "AC-LuaServer.Core.Server" }
}

---
-- The event listener for the "onPlayerCalledVote" event of the VoteListener test instance
--
-- @tfield table onPlayerCalledVoteListener
--
TestVoteListener.onPlayerCalledVoteListener = nil

---
-- The event listener for the "onPlayerFailedToCallVote" event of the VoteListener test instance
--
-- @tfield table onPlayerFailedToCallVoteListener
--
TestVoteListener.onPlayerFailedToCallVoteListener = nil

---
-- The event listener for the "onVotePassed" event of the VoteListener test instance
--
-- @tfield table onVotePassedListener
--
TestVoteListener.onVotePassedListener = nil

---
-- The event listener for the "onVoteFailed" event of the VoteListener test instance
--
-- @tfield table onVoteFailedListener
--
TestVoteListener.onVoteFailedListener = nil


---
-- Method that is called before a test is executed.
-- Sets up the VoteListener event listeners.
--
function TestVoteListener:setUp()
  self.super.setUp(self)

  self.onPlayerCalledVoteListener = self.mach.mock_function("onPlayerCalledVote")
  self.onPlayerFailedToCallVoteListener = self.mach.mock_function("onPlayerFailedToCallVote")
  self.onVotePassedListener = self.mach.mock_function("onVotePassed")
  self.onVoteFailedListener = self.mach.mock_function("onVoteFailed")
end

---
-- Method that is called after a test was executed.
-- Clears the VoteListener event listeners.
--
function TestVoteListener:tearDown()
  self.super.tearDown(self)

  self.onPlayerCalledVoteListener = nil
  self.onPlayerFailedToCallVoteListener = nil
  self.onVotePassedListener = nil
  self.onVoteFailedListener = nil
end


---
-- Checks that a successful vote call is handled as expected.
--
function TestVoteListener:testCanHandleSuccessfulVoteCall()
  local voteListener = self:createTestVoteListenerInstance()

  self.dependencyMocks.LuaServerApi.SA_MAP = 7
  self.dependencyMocks.LuaServerApi.VOTEE_NOERROR = -1

  local VoteMock = self.dependencyMocks.Vote
  local voteMock = self:getMock("AC-LuaServer.Core.VoteListener.Vote.Vote", "VoteMock")

  VoteMock.__call
          :should_be_called_with(3, 0, "gemakiller", 6, 0)
          :and_will_return(voteMock)
          :and_then(
            self.onPlayerCalledVoteListener
                :should_be_called_with(voteMock)
          )
          :when(
            function()
              voteListener:onPlayerCallVote(3, 0, "gemakiller", 6, 0, -1)
            end
          )

end

---
-- Checks that a failed vote call is handled as expected.
--
function TestVoteListener:testCanHandleFailedVoteCall()
  local voteListener = self:createTestVoteListenerInstance()

  self.dependencyMocks.LuaServerApi.SA_MAP = 7
  self.dependencyMocks.LuaServerApi.VOTEE_NOERROR = -1

  local VoteMock = self.dependencyMocks.Vote
  VoteMock.STATUS_FAILED = "FAILED"

  local voteMock = self:getMock("AC-LuaServer.Core.VoteListener.Vote.Vote", "VoteMock")

  VoteMock.__call
          :should_be_called_with(6, 0, "bb", 3, 0)
          :and_will_return(voteMock)
          :and_then(
            voteMock.setStatus
                    :should_be_called_with("FAILED")
          )
          :and_then(
            self.onPlayerFailedToCallVoteListener
                :should_be_called_with(voteMock, 7)
          )
          :when(
            function()
              voteListener:onPlayerCallVote(6, 0, "bb", 3, 0, 7)
            end
          )

end

---
-- Checks that a passed vote is handled as expected.
--
function TestVoteListener:testCanHandlePassedVote()

  local voteListener = self:createTestVoteListenerInstance()

  self.dependencyMocks.LuaServerApi.SA_MAP = 7
  self.dependencyMocks.LuaServerApi.VOTE_YES = 1

  local VoteMock = self.dependencyMocks.Vote
  VoteMock.STATUS_PASSED = "PASSED"

  local voteMock = self:getMock("AC-LuaServer.Core.VoteListener.Vote.Vote", "VoteMock")

  VoteMock.__call
          :should_be_called_with(7, 5, "0", 7, 4)
          :and_will_return(voteMock)
          :and_then(
            voteMock.setStatus
                    :should_be_called_with("PASSED")
          )
          :and_then(
            self.onVotePassedListener
                :should_be_called_with(voteMock)
          )
          :when(
            function()
              voteListener:onVoteEnd(1, 7, 5, "0", 7, 4)
            end
          )

end

---
-- Checks that a failed vote is handled as expected.
--
function TestVoteListener:testCanHandleFailedVote()

  local voteListener = self:createTestVoteListenerInstance()

  self.dependencyMocks.LuaServerApi.SA_MAP = 7
  self.dependencyMocks.LuaServerApi.VOTE_YES = 1

  local VoteMock = self.dependencyMocks.Vote
  VoteMock.STATUS_FAILED = "FAILED"

  local voteMock = self:getMock("AC-LuaServer.Core.VoteListener.Vote.Vote", "VoteMock")

  VoteMock.__call
          :should_be_called_with(3, 0, "gemakiller", 6, 0)
          :and_will_return(voteMock)
          :and_then(
            voteMock.setStatus
                    :should_be_called_with("FAILED")
          )
          :and_then(
            self.onVoteFailedListener
                :should_be_called_with(voteMock)
          )
          :when(
            function()
              voteListener:onVoteEnd(2, 3, 0, "gemakiller", 6, 0)
            end
          )

end

---
-- Checks that MapVote instances are created for map votes and Vote instances are created for other votes.
--
function TestVoteListener:testCanDifferentiateBetweenMapVotesAndOtherVotes()

  local voteListener = self:createTestVoteListenerInstance()

  self.dependencyMocks.LuaServerApi.SA_MAP = 7
  self.dependencyMocks.LuaServerApi.VOTEE_NOERROR = -1

  local VoteMock = self.dependencyMocks.Vote
  VoteMock.STATUS_FAILED = "FAILED"

  local voteMock = self:getMock("AC-LuaServer.Core.VoteListener.Vote.Vote", "VoteMock")

  -- Non map vote
  VoteMock.__call
          :should_be_called_with(6, 1, "teamkiller", 0, 0)
          :and_will_return(voteMock)
          :and_then(
            self.onPlayerCalledVoteListener
                :should_be_called_with(voteMock)
          )
          :when(
            function()
              voteListener:onPlayerCallVote(6, 1, "teamkiller", 0, 0, -1)
            end
          )

  -- Map vote
  local MapVoteMock = self.dependencyMocks.MapVote
  local mapVoteMock = self:getMock("AC-LuaServer.Core.VoteListener.Vote.MapVote", "MapVoteMock")

  MapVoteMock.__call
             :should_be_called_with(13, 7, "SE-GEMA-22", 5, 60)
             :and_will_return(mapVoteMock)
             :and_then(
               self.onPlayerCalledVoteListener
                   :should_be_called_with(mapVoteMock)
             )
             :when(
               function()
                 voteListener:onPlayerCallVote(13, 7, "SE-GEMA-22", 5, 60, -1)
               end
             )

end


---
-- Creates and returns a VoteListener instance to which the event listeners are attached.
--
-- @treturn VoteListener The test VoteListener instance
--
function TestVoteListener:createTestVoteListenerInstance()

  local VoteListener = self.testClass
  local voteListener = VoteListener()

  local EventCallbackMock = self.dependencyMocks.EventCallback

  local serverMock = self:getMock("AC-LuaServer.Core.Server", "ServerMock")
  local serverEventManagerMock = self:getMock(
    "AC-LuaServer.Core.ServerEvent.ServerEventManager", "ServerEventManagerMock"
  )

  local eventCallbackPath = "AC-LuaServer.Core.Event.EventCallback"
  local eventCallbackMockA = self:getMock(eventCallbackPath, "EventCallbackMock")
  local eventCallbackMockB = self:getMock(eventCallbackPath, "EventCallbackMock")

  -- Initialize event callbacks and register the event handlers
  EventCallbackMock.__call
                   :should_be_called_with(
                     self.mach.match(
                       { object = VoteListener, methodName = "onPlayerCallVote"},
                       TestVoteListener.matchEventCallback
                     ),
                     nil
                   )
                   :and_will_return(eventCallbackMockA)
                   :and_also(
                     EventCallbackMock.__call
                                      :should_be_called_with(
                                        self.mach.match(
                                          { object = VoteListener, methodName = "onVoteEnd" },
                                          TestVoteListener.matchEventCallback
                                        ),
                                        nil
                                      )
                                      :and_will_return(eventCallbackMockB)
                   )
                   :and_then(
                     self.dependencyMocks.Server.getInstance
                                                :should_be_called()
                                                :and_will_return(serverMock)
                   )
                   :and_then(
                     serverMock.getEventManager
                               :should_be_called()
                               :and_will_return(serverEventManagerMock)
                   )
                   :and_then(
                     serverEventManagerMock.on
                                           :should_be_called_with("onPlayerCallVote", eventCallbackMockA)
                   )
                   :and_also(
                     serverEventManagerMock.on
                                           :should_be_called_with("onVoteEnd", eventCallbackMockB)
                   )
                   :when(
                     function()
                       voteListener:initialize()
                     end
                   )


  -- Attach the event listeners to the VoteListener instance
  local EventCallback = self.originalDependencies["AC-LuaServer.Core.Event.EventCallback"]
  voteListener:on("onPlayerCalledVote", EventCallback(function(...) self.onPlayerCalledVoteListener(...) end))
  voteListener:on("onPlayerFailedToCallVote", EventCallback(function(...) self.onPlayerFailedToCallVoteListener(...) end))
  voteListener:on("onVotePassed", EventCallback(function(...) self.onVotePassedListener(...) end))
  voteListener:on("onVoteFailed", EventCallback(function(...) self.onVoteFailedListener(...) end))

  return voteListener

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
function TestVoteListener.matchEventCallback(_expected, _actual)
  return (_actual.object:is(_expected.object) and _actual.methodName == _expected.methodName)
end


return TestVoteListener
