---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require("TestFrameWork/TestCase")

---
-- Checks that the TableParser works as expected.
--
-- @type TestTableParser
--
local TestCommandArgument = {}


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestCommandArgument.testClassPath = "wesenGemaMod/CommandExecutor/Command/CommandArgument"

---
-- The paths of the classes that the test class depends on
--
-- @tfield string[] dependencyPaths
--
TestCommandArgument.dependencyPaths = {
  ["Exception"] = { path = "wesenGemaMod/Util/Exception" },
  ["StaticString"] = { path = "wesenGemaMod/Output/StaticString" },
  ["TemplateException"] = { path = "wesenGemaMod/Util/TemplateException" }
}



function TestCommandArgument:testcanBeConstructed()

  local CommandArgument = self.testClass

  for _, dataSet in pairs(self:canBeConstructedProvider()) do

    -- Build a CommandArgument with the data set's input values
    local input = dataSet["input"]
    local argument

    function createArgument()
      argument = CommandArgument(
        input["name"], input["isOptional"], input["type"], input["shortName"], input["description"]
      )
    end

    if (dataSet["expected"]["calls"]) then
      dataSet["expected"]["calls"]:when(createArgument)
    else
      createArgument()
    end


    -- Check if the getters of the CommandArgument return the expected values
    local expectedValues = dataSet["expected"]["values"]

    self.assertEquals(argument:getName(), expectedValues["name"])
    self.assertEquals(argument:getShortName(), expectedValues["shortName"])
    self.assertEquals(argument:getIsOptional(), expectedValues["isOptional"])
    self.assertEquals(argument:getDescription(), expectedValues["description"])

  end

end

function TestCommandArgument:canBeConstructedProvider()

  return {

    ["all values set"] = {

      ["input"] = {
        ["name"] = "argument1",
        ["isOptional"] = true,
        ["type"] = "integer",
        ["shortName"] = "arg1",
        ["description"] = "This is argument #1"
      },

      ["expected"] = {

        ["values"] = {
          ["name"] = "argument1",
          ["isOptional"] = true,
          ["shortName"] = "arg1",
          ["description"] = "This is argument #1"
        }
      }
    },

    ["minimum values set"] = {

      ["input"] = {
        ["name"] = "anotherArgument",
        ["isOptional"] = nil,
        ["type"] = nil,
        ["shortName"] = nil,
        ["description"] = nil
      },

      ["expected"] = {

        ["calls"] = self:expectStaticStringUsage("defaultArgumentDescription", "No description"),

        ["values"] = {
          ["name"] = "anotherArgument",
          ["isOptional"] = false,
          ["shortName"] = "anotherArgument",
          ["description"] = "No description"
        }
      }
    }
  }

end

function TestCommandArgument:testCanNotBeConstructedWithInvalidType()

  local CommandArgument = self.testClass

  for _, dataSet in ipairs(self:canNotBeConstructedWithInvalidTypeProvider()) do

    -- Build a CommandArgument with the data set's input values
    local input = dataSet["input"]
    local argument

    function createArgument()
      argument = CommandArgument(
        input["name"], input["isOptional"], input["type"], input["shortName"], input["description"]
      )
    end

    if (dataSet["expected"]["isValidType"]) then
      createArgument()
    else

      self:expectTemplateException(
        "TextTemplate/ExceptionMessages/CommandHandler/InvalidArgumentType",
        self.mach.match({ ["argumentName"] = input["name"], ["type"] = input["type"] }),
        createArgument
      )

    end

  end


end

function TestCommandArgument:canNotBeConstructedWithInvalidTypeProvider()

  local dataSets = {}

  local testTypes = {
    { ["typeName"] = "random", ["isExpectedValidType"] = false },
    { ["typeName"] = "integer", ["isExpectedValidType"] = true },
    { ["typeName"] = "float", ["isExpectedValidType"] = true },
    { ["typeName"] = "notAType", ["isExpectedValidType"] = false },
    { ["typeName"] = "valid", ["isExpectedValidType"] = false },
    { ["typeName"] = "bool", ["isExpectedValidType"] = true },
    { ["typeName"] = "string", ["isExpectedValidType"] = true }
  }

  for _, testType in ipairs(testTypes) do

    local dataSet = {
      ["input"] = {
        ["name"] = "testArgument",
        ["isOptional"] = true,
        ["type"] = testType["typeName"],
        ["shortName"] = "short",
        ["description"] = "It's a test"
      },
      ["expected"] = {
        ["isValidType"] = testType["isExpectedValidType"]
      }
    }

    table.insert(dataSets, dataSet)

  end

  return dataSets

end

function TestCommandArgument:testCanParseArgument()

  for _, dataSet in ipairs(self:canParseArgumentProvider()) do
    for _, test in ipairs(dataSet["tests"]) do

      local function parseValue()
        return dataSet["argument"]:parse(test["input"])
      end

      if (test["expected"]["exception"]) then

        self:expectTemplateException(
          "TextTemplate/ExceptionMessages/CommandHandler/InvalidValueType",
          self.mach.match({ ["argument"] = dataSet["argument"] }),
          parseValue
        )

      else
        self.assertEquals(parseValue(), test["expected"]["parsedInput"])
      end

    end
  end


end


function TestCommandArgument:canParseArgumentProvider()

  return {

    -- string
    {
      ["argument"] = self:createExampleArgumentWithType("string"),
      ["tests"] = {

        -- Strings need no convesion
        { ["input"] = "hallo", ["expected"] = { ["parsedInput"] = "hallo" }}
      }
    },

    -- float
    {
      ["argument"] = self:createExampleArgumentWithType("float"),
      ["tests"] = {

        -- Numeric strings will be converted to floats
        { ["input"] = "10.8", ["expected"] = { ["parsedInput"] = 10.8 }},
        { ["input"] = "13", ["expected"] = { ["parsedInput"] = 13 }},
        { ["input"] = "21.", ["expected"] = { ["parsedInput"] = 21 }},

        -- Partial or non numeric strings will throw exceptions
        { ["input"] = "NaN", ["expected"] = { ["exception"] = true }},
        { ["input"] = "notanumber", ["expected"] = { ["exception"] = true }},
        { ["input"] = "1partial2number3", ["expected"] = { ["exception"] = true }},
        { ["input"] = "12a", ["expected"] = { ["exception"] = true }},
        { ["input"] = "b41", ["expected"] = { ["exception"] = true }},
        { ["input"] = "34a45", ["expected"] = { ["exception"] = true }},
        { ["input"] = "good56bad", ["expected"] = { ["exception"] = true }}
      }
    },

    -- integer
    {
      ["argument"] = self:createExampleArgumentWithType("integer"),
      ["tests"] = {

        -- Numeric strings with integer numbers will be converted to integers
        { ["input"] = "15", ["expected"] = { ["parsedInput"] = 15 }},
        { ["input"] = "26", ["expected"] = { ["parsedInput"] = 26 }},

        -- Numeric but not integers will throw exceptions
        { ["input"] = "15.7", ["expected"] = { ["exception"] = true }},
        { ["input"] = "12.", ["expected"] = { ["exception"] = true }},

        -- Partial or non numeric strings will throw exceptions
        { ["input"] = "INF", ["expected"] = { ["exception"] = true }},
        { ["input"] = "1numberone", ["expected"] = { ["exception"] = true }},
        { ["input"] = "numbertwo2", ["expected"] = { ["exception"] = true }},
        { ["input"] = "3numberthree3", ["expected"] = { ["exception"] = true }},
        { ["input"] = "hello444text", ["expected"] = { ["exception"] = true }}
      }
    },

    -- bool
    {
      ["argument"] = self:createExampleArgumentWithType("bool"),
      ["tests"] = {

        -- "true" and "false" will be converted to the corresponding boolean value
        { ["input"] = "true", ["expected"] = { ["parsedInput"] = true }},
        { ["input"] = "false", ["expected"] = { ["parsedInput"] = false }},

        -- Everything else will throw an exception
        { ["input"] = "42", ["expected"] = { ["exception"] = true }},
        { ["input"] = "126", ["expected"] = { ["exception"] = true }},
        { ["input"] = "12.3", ["expected"] = { ["exception"] = true }},
        { ["input"] = "46.7", ["expected"] = { ["exception"] = true }},
        { ["input"] = "19.", ["expected"] = { ["exception"] = true }},
        { ["input"] = "72.", ["expected"] = { ["exception"] = true }},
        { ["input"] = "1hallo3", ["expected"] = { ["exception"] = true }},
        { ["input"] = "1textA", ["expected"] = { ["exception"] = true }},
        { ["input"] = "textB4", ["expected"] = { ["exception"] = true }},
        { ["input"] = "nottext45thisistext", ["expected"] = { ["exception"] = true }},
        { ["input"] = "only_non_digits", ["expected"] = { ["exception"] = true }},
        { ["input"] = "hello-universe", ["expected"] = { ["exception"] = true }}
      }
    }

  }


end

function TestCommandArgument:createExampleArgumentWithType(_type)
  local CommandArgument = self.testClass

  return CommandArgument(
    "exampleArg", false, _type, "exmpl", "This is a reused example argument"
  )
end


-- TODO: testDefaultsTostringType


setmetatable(TestCommandArgument, {__index = TestCase})


return TestCommandArgument
