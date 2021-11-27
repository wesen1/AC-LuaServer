---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local argparse = require "argparse"
local parser = argparse()

parser:argument("hello")
parser:option("--special")

--[[
parser:command("!commands !cmds !listcommands"):action(function(_args)
    for k, v in pairs(_args) do
      print(k, v)
    end
                                                      end)
parser:command("!help !man")
parser:command("!extendtime !ext")
parser:command("!rules")
parser:command("!maptop !mtop")
parser:command("!gtop !gematop")

--]]

local args = parser:parse({"cmds"})

for k, v in pairs(parser._commands) do
  print(k, v)
end


print(parser:get_help())
