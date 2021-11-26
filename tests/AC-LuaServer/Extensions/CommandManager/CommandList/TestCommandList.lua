---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require("TestFrameWork/TestCase")

local TestCommandList = {}

TestCommandList.testClassPath = "wesenGemaMod/CommandExecutor/CommandList/CommandList"

TestCommandList.dependencyPaths = {
  CmdsCommand = { path = "wesenGemaMod/CommandExecutor/DefaultCommands/CmdsCommand" },
  HelpCommand = { path = "wesenGemaMod/CommandExecutor/DefaultCommands/HelpCommand" },
  SortedCommandList = { path = "wesenGemaMod/CommandExecutor/CommandList/SortedCommandList" }
}

--[[
  function TestCommandList:testCan
  end
--]]


setmetatable(TestCommandList, {__index = TestCase})


return TestCommandList
