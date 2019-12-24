---
-- @author wesen
-- @copyright 2017-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local Object = require "classic"
local PlayerNotFoundException = require "AC-LuaServer.Core.PlayerList.Exception.PlayerNotFoundException"

---
-- Stores information about a connected player.
--
-- @type Player
--
local Player = Object:extend()


---
-- The client number of the player
--
-- @tfield int cn
--
Player.cn = nil

---
-- The player name
--
-- @tfield string name
--
Player.name = nil

---
-- The player ip
--
-- @tfield string ip
--
Player.ip = nil


---
-- Player constructor.
--
-- @tparam int _cn The client number of the player
-- @tparam string _ip The player ip
-- @tparam string _name The player name
--
function Player:new(_cn, _ip, _name)
  self.cn = _cn
  self.ip = _ip
  self.name = _name
end

---
-- Creates and returns a Player instance from a connected player.
--
-- @tparam int _cn The client number of the connected player
--
-- @treturn Player The Player instance for the connected player
--
-- @raise Error when no player is connected with the target cn
--
function Player.createFromConnectedPlayer(_cn)

  if (LuaServerApi.isconnected(_cn)) then

    local playerIp = LuaServerApi.getip(_cn)
    local playerName = LuaServerApi.getname(_cn)

    return Player(_cn, playerIp, playerName)

  else
    error(PlayerNotFoundException(_cn))
  end

end


-- Getters and Setters

---
-- Returns the client number of the player.
--
-- @treturn int The client number of the player
--
function Player:getCn()
  return self.cn
end

---
-- Returns the player ip.
--
-- @treturn string The player ip
--
function Player:getIp()
  return self.ip
end

---
-- Returns the player name.
--
-- @treturn string The player name
--
function Player:getName()
  return self.name
end

---
-- Sets the player name.
--
-- @tparam string _name The player name
--
function Player:setName(_name)
  self.name = _name
end


return Player
