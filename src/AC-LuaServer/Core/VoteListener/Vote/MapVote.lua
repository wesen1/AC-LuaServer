---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local Vote = require "AC-LuaServer.Core.VoteListener.Vote.Vote"

---
-- Represents a map vote.
--
-- @type MapVote
--
local MapVote = Vote:extend()


---
-- Stores whether this MapVote was created using the "setnext" command
--
-- @tfield bool isSetNext
--
MapVote.isSetNext = nil

---
-- Stores the game mode id of this MapVote
--
-- @tfield int gameModeId
--
MapVote.gameModeId = nil


---
-- MapVote constructor.
--
function MapVote:new(...)

  self.super.new(self, ...)

  if (self:getNumberA() >= LuaServerApi.GM_NUM) then
    self.isSetNext = true
    self.gameModeId = self:getNumberA() - LuaServerApi.GM_NUM
  else
    self.isSetNext = false
    self.gameModeId = self:getNumberA()
  end

end


-- Getters and Setters

---
-- Returns whether this MapVote was created using the "setnext" command.
--
-- @treturn bool True if this MapVote was created using the "setnext" command, false otherwise
--
function MapVote:getIsSetNext()
  return self.isSetNext
end

---
-- Returns the map name of this MapVote.
--
-- @treturn string The map name
--
function MapVote:getMapName()
  return self:getText()
end

---
-- Returns the game mode id of this MapVote.
--
-- @treturn int The game mode id
--
function MapVote:getGameModeId()
  return self.gameModeId
end

---
-- Returns the time of this MapVote.
--
-- @treturn int The time
--
function MapVote:getTime()
  return self:getNumberB()
end


return MapVote
