---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require("TestFrameWork/TestCase")

local TestCommandStringParser = {}


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestCommandStringParser.testClassPath = "wesenGemaMod/CommandExecutor/CommandStringParser"


function TestCommandStringParser:testCanDetectCommandStrings()

  local CommandStringParser = self.testClass

  local parser = CommandStringParser()

  -- Command without arguments
  self.assertTrue(parser:isCommand("!cmds"))

  -- Command with arguments
  self.assertTrue(parser:isCommand("!help maptop"))


  -- Exclamation mark at first position but not followed by a letter
  self.assertFalse(parser:isCommand("!!!"))
  self.assertFalse(parser:isCommand("! cmds"))
  self.assertFalse(parser:isCommand("!-extend 500"))

  -- No exclamation mark at first position
  self.assertFalse(parser:isCommand(" !cmds"))
  self.assertFalse(parser:isCommand(" !help maptop"))

end

function TestCommandStringParser:testCanParseCommandString()

  local CommandStringParser = self.testClass

  local parser = CommandStringParser()


  self.assertNil(parser:getCommandName())
  self.assertNil(parser:getArguments())

  -- Command without arguments
  parser:parseCommandString("!rules")
  self.assertEquals(parser:getCommandName(), "rules")
  self.assertEquals(parser:getArguments(), {})

  -- Command with arguments
  parser:parseCommandString("!maptop 5 hello")
  self.assertEquals(parser:getCommandName(), "maptop")
  self.assertEquals(parser:getArguments(), {"5", "hello"})


  -- Command with options

end


setmetatable(TestCommandStringParser, {__index = TestCase})


return TestCommandStringParser
