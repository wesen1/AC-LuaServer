---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"
local tablex = require "pl.tablex"

---
-- Checks that the CommandStringInformationExtractor works as expected.
--
-- @type TestCommandStringInformationExtractor
--
local TestCommandStringInformationExtractor = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestCommandStringInformationExtractor.testClassPath = "AC-LuaServer.CommandManager.CommandExecutor.CommandStringParser.CommandStringInformationExtractor"


---
-- Checks that the DefaultGameMode can be created as expected.
--
function TestCommandStringInformationExtractor:testCanTellWhetherStringIsCommandString()

  local CommandStringInformationExtractor = self.testClass
  local informationExtractor = CommandStringInformationExtractor()

  self:assertFalse(informationExtractor:isCommandString("random text"))
  self:assertFalse(informationExtractor:isCommandString(" !cmds")) -- String does not start with "!"
  self:assertFalse(informationExtractor:isCommandString("! cmds")) -- String contains a " " after the "!"
  self:assertFalse(informationExtractor:isCommandString("!!cmds")) -- String contains multiple "!" in sequence
  self:assertFalse(informationExtractor:isCommandString("!")) -- String contains nothing after the "!"
  self:assertTrue(informationExtractor:isCommandString("!maptop")) -- Command without parameters
  self:assertTrue(informationExtractor:isCommandString("!help maptop cmds")) -- Command with parameters

end

function TestCommandStringInformationExtractor:testCanExtractCommandName()

  local CommandStringInformationExtractor = self.testClass
  local informationExtractor = CommandStringInformationExtractor()

  self:assertEquals("maptop", informationExtractor:extractCommandName("!maptop")) -- Command without parameters
  self:assertEquals("help", informationExtractor:extractCommandName("!help maptop cmds")) -- Command with parameters

end

function TestCommandStringInformationExtractor:testCanExtractSingleOneWordParameter()

  local CommandStringInformationExtractor = self.testClass
  local informationExtractor = CommandStringInformationExtractor()

  local parameters, explicitOptions = informationExtractor:extractParameters("!help maptop")

  self:assertEquals(1, #parameters)
  self:assertEquals(0, #tablex.keys(explicitOptions))

  self:assertEquals("maptop", parameters[1])

end

function TestCommandStringInformationExtractor:testCanExtractMultipleOneWordParameters()

  local CommandStringInformationExtractor = self.testClass
  local informationExtractor = CommandStringInformationExtractor()

  local parameters, explicitOptions = informationExtractor:extractParameters("!maptop 5 7 AR")

  self:assertEquals(3, #parameters)
  self:assertEquals(0, #tablex.keys(explicitOptions))

  self:assertEquals("5", parameters[1])
  self:assertEquals("7", parameters[2])
  self:assertEquals("AR", parameters[3])

end

function TestCommandStringInformationExtractor:testCanExtractExplicitOptions()

  local CommandStringInformationExtractor = self.testClass
  local informationExtractor = CommandStringInformationExtractor()

  local parameters, explicitOptions = informationExtractor:extractParameters("!maptop --weapon AR --startRank 5")

  self:assertEquals(0, #parameters)
  self:assertEquals(2, #tablex.keys(explicitOptions))

  self:assertEquals("AR", explicitOptions["weapon"])
  self:assertEquals("5", explicitOptions["startRank"])

end

function TestCommandStringInformationExtractor:testCanExtractSingleMultiWordParameter()

  local CommandStringInformationExtractor = self.testClass
  local informationExtractor = CommandStringInformationExtractor()

  local parametersA, explicitOptionsA = informationExtractor:extractParameters("!info \"this is a test message\"")

  self:assertEquals(1, #parametersA)
  self:assertEquals(0, #tablex.keys(explicitOptionsA))

  self:assertEquals("this is a test message", parametersA[1])


  local parametersB, explicitOptionsB = informationExtractor:extractParameters("!shutdown 'Server will go down'")

  self:assertEquals(1, #parametersB)
  self:assertEquals(0, #tablex.keys(explicitOptionsB))

  self:assertEquals("Server will go down", parametersB[1])


  local parametersC, explicitOptionsC = informationExtractor:extractParameters("!restart [Add new feature]")

  self:assertEquals(1, #parametersC)
  self:assertEquals(0, #tablex.keys(explicitOptionsC))

  self:assertEquals("Add new feature", parametersC[1])

end


return TestCommandStringInformationExtractor
