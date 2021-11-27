---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local apr = require "apr"

local argString = "!maptop --limit 5 --weapon AR \"a long text\" -- --test 'hallo welt' hallo welt"
argString = "!maptop --limit 6 --weapon \"Assault Rifle\""
local arguments = apr.tokenize_to_argv(argString)

table.remove(arguments, 1)


for k, v in pairs(arguments) do
  print(k, v)
end



-- script.lua
local argparse = require "argparse"

local parser = argparse("!maptop", "An example.")

parser:option("-n --limit")
  :description("Limit")
  :default(5)
parser:option("-w --weapon", "Weapon filter", "all")
parser:add_help(false)

print(parser:get_help())


--[[
local done = false
parser:add_help {
  action = function()
    print(parser:get_usage())
    done = true
  end
}
--]]


local args, errorMessage = parser:pparse(arguments)

if (not done) then

  if (args == false) then

    if (errorMessage) then
      print("Error: " .. errorMessage)
    end

  else

    for k, v in pairs(errorMessage) do
      print(k, v)
    end

  end

end
