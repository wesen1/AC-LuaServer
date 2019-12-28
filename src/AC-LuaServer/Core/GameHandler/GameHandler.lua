---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ActiveGame = require "AC-LuaServer.Core.GameHandler.Game.ActiveGame"
local EventEmitter = require "AC-LuaServer.Core.Event.EventEmitter"
local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local MapRotationGame = require "AC-LuaServer.Core.GameHandler.Game.MapRotationGame"
local MapVote = require "AC-LuaServer.Core.VoteListener.Vote.MapVote"
local VotedGame = require "AC-LuaServer.Core.GameHandler.Game.VotedGame"
local Object = require "classic"
local ServerEventListener = require "AC-LuaServer.Core.ServerEvent.ServerEventListener"

---
-- Stores the current Game and listens for Game changing events.
--
-- @type GameHandler
--
local GameHandler = Object:extend()
GameHandler:implement(EventEmitter)
GameHandler:implement(ServerEventListener)


---
-- The list of server events for which this class listens
--
-- @tfield table serverEventListeners
--
GameHandler.serverEventListeners = {
  onMapEnd = "onMapEnd",
  onMapChange = "onMapChange"
}

---
-- The current active Game
--
-- @tfield ActiveGame currentGame
--
GameHandler.currentGame = nil

---
-- The next Game that was set via a vote
--
-- @tfield ScheduledGame votedNextGame
--
GameHandler.votedNextGame = nil


---
-- GameHandler constructor.
--
function GameHandler:new()
  self.eventCallbacks = {}
end


-- Getters and Setters

---
-- Returns the current active Game.
--
-- @treturn ActiveGame The current active Game
--
function GameHandler:getCurrentGame()
  return self.currentGame
end


-- Public Methods

---
-- Initializes this GameHandler.
--
function GameHandler:initialize()
  self:registerAllServerEventListeners()
  self:initializeEventListeners()
end


---
-- Event handler that is called when a player successfully called a vote.
--
-- @tparam Vote _vote The vote that was called
--
function GameHandler:onPlayerCalledVote(_vote)
  if (_vote:is(MapVote)) then
    self:emit("onGameChangeVoteCalled", VotedGame(_vote))
  end
end

---
-- Event handler that is called when a vote passes.
--
-- @tparam Vote _vote The vote that passed
--
function GameHandler:onVotePassed(_vote)

  if (_vote:is(MapVote)) then

    local votedNextGame = VotedGame(_vote)
    self:emit("onGameChangeVotePassed", votedNextGame)

    if (_vote:getIsSetNext()) then
      self.votedNextGame = votedNextGame
    else
      self:emit("onGameWillChange", votedNextGame)
    end

  end

end

---
-- Event handler that is called when a vote fails.
--
-- @tparam Vote _vote The vote that failed
--
function GameHandler:onVoteFailed(_vote)
  if (_vote:is(MapVote)) then
    self:emit("onGameChangeVoteFailed", VotedGame(_vote))
  end
end

---
-- Event handler that is called when the current Game ends.
--
function GameHandler:onMapEnd()

  local nextGame
  if (self.votedNextGame) then
    nextGame = self.votedNextGame

  else
    local Server = require "AC-LuaServer.Core.Server"
    local mapRotation = Server.getInstance():getMapRotation()
    nextGame = MapRotationGame(mapRotation:getNextEntry())
  end

  self:emit("onGameWillChange", nextGame)

end

---
-- Event handler that is called when a new Game started.
--
-- @tparam string _mapName The map name of the game
-- @tparam int _gameModeId The game mode if of the game
--
function GameHandler:onMapChange(_mapName, _gameModeId)
  self.votedNextGame = nil
  self.currentGame = ActiveGame(_mapName, _gameModeId)
  self:emit("onGameChanged", self.currentGame)
end


-- Private Methods

---
-- Initializes the event listeners.
--
function GameHandler:initializeEventListeners()

  local Server = require "AC-LuaServer.Core.Server"

  local voteListener = Server.getInstance():getVoteListener()
  voteListener:on("onPlayerCalledVote", EventCallback({object = self, methodName = "onPlayerCalledVote"}))
  voteListener:on("onVotePassed", EventCallback({object = self, methodName = "onVotePassed"}))
  voteListener:on("onVoteFailed", EventCallback({object = self, methodName = "onVoteFailed"}))

end


return GameHandler
