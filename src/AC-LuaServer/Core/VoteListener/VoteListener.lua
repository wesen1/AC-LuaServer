---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventEmitter = require "AC-LuaServer.Core.Event.EventEmitter"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local MapVote = require "AC-LuaServer.Core.VoteListener.Vote.MapVote"
local Object = require "classic"
local ServerEventListener = require  "AC-LuaServer.Core.ServerEvent.ServerEventListener"
local Vote = require "AC-LuaServer.Core.VoteListener.Vote.Vote"

---
-- Listens for votes and their results and fires custom events.
--
-- @type VoteListener
--
local VoteListener = Object:extend()
VoteListener:implement(EventEmitter)
VoteListener:implement(ServerEventListener)

---
-- The list of server events for which this class listens
--
-- @tfield table serverEventListeners
--
VoteListener.serverEventListeners = {
  onPlayerCallVote = "onPlayerCallVote",
  onVoteEnd = "onVoteEnd"
}


---
-- VoteListener constructor.
--
function VoteListener:new()
  self.eventCallbacks = {}
end


-- Public Methods

---
-- Initializes this VoteListener.
--
function VoteListener:initialize()
  self:registerAllServerEventListeners()
end

---
-- Event handler that is called when a player calls a vote.
--
-- @tparam int _cn The client number of the player who called the vote
-- @tparam int _type The vote type
-- @tparam string _text The map name, kick reason, etc.
-- @tparam int _numberA The game mode, target cn, etc.
-- @tparam int _numberB The time of the map vote, target team of teamchange vote, etc.
-- @tparam int _voteError The vote error
--
function VoteListener:onPlayerCallVote(_cn, _type, _text, _numberA, _numberB, _voteError)

  local vote = self:createVoteInstance(_cn, _type, _text, _numberA, _numberB)

  if (_voteError == LuaServerApi.VOTEE_NOERROR) then
    -- Vote was successfully called
    self:emit("onPlayerCalledVote", vote)
  else
    vote:setStatus(Vote.STATUS_FAILED)
    self:emit("onPlayerFailedToCallVote", vote)
  end

end

---
-- Event handler that is called when a vote ends.
--
-- @tparam int _result The result of the vote
-- @tparam int _cn The client number of the player who called the vote
-- @tparam int _type The vote type
-- @tparam string _text The map name, kick reason, etc.
-- @tparam int _number1 The game mode, target cn, etc.
-- @tparam int _number2 The time of the map vote, target team of teamchange vote, etc.
--
function VoteListener:onVoteEnd(_result, _cn, _type, _text, _numberA, _numberB)

  local vote = self:createVoteInstance(_cn, _type, _text, _numberA, _numberB)

  if (_result == LuaServerApi.VOTE_YES) then
    vote:setStatus(Vote.STATUS_PASSED)
    self:emit("onVotePassed", vote)
  else
    vote:setStatus(Vote.STATUS_FAILED)
    self:emit("onVoteFailed", vote)
  end

end


-- Private Methods

---
-- Creates and returns a Vote instance from raw vote data.
--
-- @tparam int _cn The client number of the player who called the vote
-- @tparam int _type The vote type
-- @tparam string _text The map name, kick reason, etc.
-- @tparam int _number1 The game mode, target cn, etc.
-- @tparam int _number2 The time of the map vote, target team of teamchange vote, etc.
--
-- @treturn Vote The Vote instance
--
function VoteListener:createVoteInstance(_cn, _type, _text, _numberA, _numberB)

  if (_type == LuaServerApi.SA_MAP) then
    return MapVote(_cn, _type, _text, _numberA, _numberB)
  else
    return Vote(_cn, _type, _text, _numberA, _numberB)
  end

end


return VoteListener
