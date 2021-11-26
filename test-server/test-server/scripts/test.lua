---
-- @author wesen
-- @copyright 2019-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

-- Configure AC-ClientOutput
local ClientOutputFactory = require "AC-ClientOutput.ClientOutputFactory"
ClientOutputFactory.getInstance():configure({})

-- Configure AC-LuaServer
local Server = require "AC-LuaServer.Core.Server"
local server = Server.getInstance()
server:configure({})


local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"

LuaServerApi:on("before_clientprint", EventCallback(function(_cn, _text)
  if (_text == "special") then
    return "prevent special text print"
  end
end))

function onPlayerSayText(_cn, _text)
  LuaServerApi:clientprint(-1, _text)
end
