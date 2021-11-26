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
local TestBaseCommand = {}


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestBaseCommand.testClassPath = "wesenGemaMod/CommandExecutor/Command/BaseCommand"

---
-- The paths of the classes that the test class depends on
--
-- @tfield string[] dependencyPaths
--
TestBaseCommand.dependencyPaths = {
  ["CommandList"] = { path = "wesenGemaMod/CommandExecutor/CommandList/CommandList" },
  ["StaticString"] = { path = "wesenGemaMod/Output/StaticString" },
  ["Server"] = { path = "wesenGemaMod/Server" },
  ["TemplateException"] = { path = "wesenGemaMod/Util/TemplateException" }
}



function TestBaseCommand:testcanBeConstructed()

  local BaseCommand = self.testClass

  for _, dataSet in pairs(self:canBeConstructedProvider()) do

    -- Build a BaseCommand with the data set's input values
    local input = dataSet["input"]
    local command

    local function createCommand()
      command = BaseCommand(
        input["name"],
        input["requiredLevel"],
        input["group"],
        input["arguments"],
        input["description"],
        input["aliases"]
      )
    end

    if (dataSet["expected"]["calls"]) then
      dataSet["expected"]["calls"]:when(createCommand)
    else
      createCommand()
    end


    -- Check if the getters of the CommandArgument return the expected values
    local expectedValues = dataSet["expected"]["values"]

    self.assertEquals(command:getName(), expectedValues["name"])
    self.assertEquals(command:getRequiredLevel(), expectedValues["requiredLevel"])
    self.assertEquals(command:getGroup(), expectedValues["group"])
    self.assertEquals(command:getArguments(), expectedValues["arguments"])
    self.assertEquals(command:getDescription(), expectedValues["description"])

  end

end

function TestBaseCommand:canBeConstructedProvider()

  local arguments = {
    self:getMock("wesenGemaMod/CommandExecutor/Command/CommandArgument", "CommandArgument#1"),
    self:getMock("wesenGemaMod/CommandExecutor/Command/CommandArgument", "CommandArgument#2"),
    self:getMock("wesenGemaMod/CommandExecutor/Command/CommandArgument", "CommandArgument#3")
  }

  return {

    ["all values set"] = {

      ["input"] = {
        ["name"] = "command1",
        ["requiredLevel"] = 1,
        ["group"] = "Custom",
        ["arguments"] = arguments,
        ["description"] = "This is command #1",
        ["aliases"] = { "cmd1", "command", "hello" }
      },

      ["expected"] = {

        ["values"] = {
          ["name"] = "command1",
          ["requiredLevel"] = 1,
          ["group"] = "Custom",
          ["arguments"] = arguments,
          ["description"] = "This is command #1",
        }
      }
    },

    ["minimum values set"] = {

      ["input"] = {
        ["name"] = "anotherCommand",
        ["requiredLevel"] = nil,
        ["group"] = nil,
        ["arguments"] = nil,
        ["description"] = nil,
        ["aliases"] = nil
      },

      ["expected"] = {

        ["calls"] = self:expectStaticStringUsage("defaultCommandGroup", "Default")
          :and_also(
            self:expectStaticStringUsage("defaultCommandDescription", "No description")
          ),

        ["values"] = {
          ["name"] = "anotherCommand",
          ["requiredLevel"] = 0,
          ["group"] = "Default",
          ["arguments"] = {},
          ["description"] = "No description"
        }
      }
    }
  }

end

function TestBaseCommand:testCanBeAttachedToCommandList()

  local commandListMock = self.dependencyMocks["CommandList"]
  local command = self:createExampleCommand()

  self:expectCommandListAttachment(commandListMock):when(
    function()
      command:attachToCommandList(commandListMock)
    end
  )

  -- Trying to attach the command again to the same command list while it is already attached to
  -- a command list will throw an exception
  self:expectTemplateException(
    "TextTemplate/ExceptionMessages/CommandHandler/CommandAlreadyAttachedToCommandList",
    self.mach.match({ ["command"] = command }),
    function()
      command:attachToCommandList(commandListMock)
    end
  )

  command:detachFromCommandList(commandListMock)

  -- Trying to attach the command to a command list after it was detached from the old command
  -- list should work
  self:expectCommandListAttachment(commandListMock):when(
    function()
      command:attachToCommandList(commandListMock)
    end
  )

  local otherCommandListMock = self:getMock(
    "wesenGemaMod/CommandExecutor/CommandList/CommandList", "CommandListMockB", "object"
  )

  -- Trying to attach the command to a different command list should fail because it is already
  -- attached to a command list
  self:expectTemplateException(
    "TextTemplate/ExceptionMessages/CommandHandler/CommandAlreadyAttachedToCommandList",
    self.mach.match({ ["command"] = command }),
    function()
      command:attachToCommandList(otherCommandListMock)
    end
  )

end

function TestBaseCommand:testCanBeDetachedFromCommandList()

  local commandListMock = self.dependencyMocks["CommandList"]
  local command = self:createExampleCommand()

  -- The command is not attached to any command list, it should throw an exception when trying to
  -- detach it from a command list
  self:expectTemplateException(
    "TextTemplate/ExceptionMessages/CommandHandler/CommandNotAttachedToCommandList",
    self.mach.match({ ["command"] = command }),
    function()
      command:detachFromCommandList(commandListMock)
    end
  )

  self:expectCommandListAttachment(commandListMock):when(
    function()
      command:attachToCommandList(commandListMock)
    end
  )

  -- It should be detachable when connected to that command list
  command:detachFromCommandList(commandListMock)


  self:expectCommandListAttachment(commandListMock):when(
    function()
      command:attachToCommandList(commandListMock)
    end
  )

  local otherCommandListMock = self:getMock(
    "wesenGemaMod/CommandExecutor/CommandList/CommandList", "CommandListMockB", "object"
  )

  -- This should fail because the command is attached to a different command list
  self:expectTemplateException(
    "TextTemplate/ExceptionMessages/CommandHandler/CommandNotAttachedToCommandList",
    self.mach.match({ ["command"] = command }),
    function()
      command:detachFromCommandList(otherCommandListMock)
    end
  )

end

function TestBaseCommand:expectCommandListAttachment(_commandListMock)

  local serverMock = self.dependencyMocks["Server"]

  return _commandListMock.getParentServer:should_be_called()
    :and_will_return(serverMock)
    :and_then(
      serverMock.getOutput:should_be_called()
             )

end

function TestBaseCommand:createExampleCommand(_aliases, _arguments)
  local BaseCommand = self.testClass
  return BaseCommand("exampleCommand", 0, "example group", _arguments, "example description", _aliases)
end


function TestBaseCommand:testCanFindAlias()

  for _, dataSet in pairs(self:canFindAliasProvider()) do

    local command = self:createExampleCommand(dataSet["input"]["aliases"])

    for _, test in ipairs(dataSet["tests"]) do

      local commandHasAlias = command:hasAlias(test["input"])
      if (test["expected"]["hasAlias"]) then
        self.assertTrue(commandHasAlias)
      else
        self.assertFalse(commandHasAlias)
      end
    end

  end

end

function TestBaseCommand:canFindAliasProvider()

  return {

    ["no aliases"] = {
      ["input"] = {
        ["aliases"] = {}
      },

      ["tests"] = {
        { ["input"] = "exampleCommand", ["expected"] = { ["hasAlias"] = false } },
        { ["input"] = "hallo", ["expected"] = { ["hasAlias"] = false } },
        { ["input"] = "exmpl", ["expected"] = { ["hasAlias"] = false } },
      }
    },

    {
      ["input"] = {
        ["aliases"] = { "exmpl", "newexmpl" }
      },

      ["tests"] = {
        { ["input"] = "exampleCommand", ["expected"] = { ["hasAlias"] = false } },
        { ["input"] = "hallo", ["expected"] = { ["hasAlias"] = false } },
        { ["input"] = "exmpl", ["expected"] = { ["hasAlias"] = true } },
        { ["input"] = "newexmpl", ["expected"] = { ["hasAlias"] = true } },
        { ["input"] = "newestexmpl", ["expected"] = { ["hasAlias"] = false } },
      }
    }

  }

end


function TestBaseCommand:testCanReturnRequiredArguments()

  for _, dataSet in pairs(self:canReturnRequiredArgumentsProvider()) do

    -- Prepare the mocks
    local argumentMocks = self:createNumberedArgumentMocks(#dataSet["input"]["arguments"])

    -- Build the list of expected required arguments
    local expectedRequiredArguments = {}
    for _, argumentId in ipairs(dataSet["expected"]["arguments"]) do
      table.insert(expectedRequiredArguments, argumentMocks[argumentId])
    end


    local command = self:createExampleCommand(nil, argumentMocks)

    local requiredArguments
    local function fetchRequiredArguments()
      requiredArguments = command:getRequiredArguments()
    end

    local numberOfRequiredArguments
    local function fetchNumberOfRequiredArguments()
      numberOfRequiredArguments = command:getNumberOfRequiredArguments()
    end

    if (#argumentMocks == 0) then
      fetchRequiredArguments()
      fetchNumberOfRequiredArguments()
    else
      self:expectArgumentMockIsOptionalCalls(argumentMocks, dataSet["input"]["arguments"])
        :when(fetchRequiredArguments)
      self:expectArgumentMockIsOptionalCalls(argumentMocks, dataSet["input"]["arguments"])
        :when(fetchNumberOfRequiredArguments)
    end

    self.assertEquals(requiredArguments, expectedRequiredArguments)
    self.assertEquals(numberOfRequiredArguments, dataSet["expected"]["numberOfRequiredArguments"])

  end

end

function TestBaseCommand:expectArgumentMockIsOptionalCalls(_argumentMocks, _argumentConfigurations)

  local expectedCalls

  for i, argument in ipairs(_argumentConfigurations) do

    local expectedCall = _argumentMocks[i].getIsOptional:should_be_called()
      :and_will_return(argument["isOptional"])

    if (expectedCalls) then
      expectedCalls:and_also(expectedCall)
    else
      expectedCalls = expectedCall
    end

  end

  return expectedCalls

end

function TestBaseCommand:canReturnRequiredArgumentsProvider()

  return {

    {
      ["input"] = {
        ["arguments"] = {}
      },
      ["expected"] = {
        ["arguments"] = {},
        ["numberOfRequiredArguments"] = 0
      }
    },

    {
      ["input"] = {
        ["arguments"] = {
          [1] ={ ["isOptional"] = false },
          [2] ={ ["isOptional"] = true },
          [3] = { ["isOptional"] = true },
          [4] = { ["isOptional"] = false },
          [5] = { ["isOptional"] = false }
        }
      },
      ["expected"] = {
        ["arguments"] = { 1, 4, 5 },
        ["numberOfRequiredArguments"] = 3
      }
    }

  }

end


function TestBaseCommand:testCanReturnNumberOfArguments()

  for _, dataSet in ipairs(self:canReturnNumberOfArgumentsProvider()) do

    local argumentMocks = self:createNumberedArgumentMocks(dataSet["input"]["numberOfGenerateArguments"])
    local command = self:createExampleCommand(nil, argumentMocks)

    -- Check that the expected number of arguments is returned
    self.assertEquals(command:getNumberOfArguments(), dataSet["expected"]["numberOfArguments"])

  end

end

function TestBaseCommand:canReturnNumberOfArgumentsProvider()

  return {

    {
      ["input"] = {
        ["numberOfGenerateArguments"] = 0
      },
      ["expected"] = {
        ["numberOfArguments"] = 0
      }
    },

    {
      ["input"] = {
        ["numberOfGenerateArguments"] = 6
      },
      ["expected"] = {
        ["numberOfArguments"] = 6
      }
    },

    {
      ["input"] = {
        ["numberOfGenerateArguments"] = 3
      },
      ["expected"] = {
        ["numberOfArguments"] = 3
      }
    },

    {
      ["input"] = {
        ["numberOfGenerateArguments"] = 12
      },
      ["expected"] = {
        ["numberOfArguments"] = 12
      }
    },

    {
      ["input"] = {
        ["numberOfGenerateArguments"] = 5
      },
      ["expected"] = {
        ["numberOfArguments"] = 5
      }
    }

  }

end


---
-- This test tests the base implementation of adjustInputArguments.
-- If there is a custom adjustInputArguments implementation in the command this method must be
-- overridden in the command test.
--
function TestBaseCommand:testCanAdjustInputArguments()

  for _, dataSet in ipairs(self:canAdjustInputArgumentsProvider()) do

    local argumentMocks = self:createNumberedArgumentMocks(dataSet["input"]["numberOfArguments"])
    local command = self:createExampleCommand(nil, argumentMocks)

    for _, test in ipairs(dataSet["tests"]) do
      local adjustedInputArguments = command:adjustInputArguments(test["input"]["inputArguments"])
      self.assertEquals(test["expected"]["adjustedInputArguments"], adjustedInputArguments)
    end

  end

end

function TestBaseCommand:canAdjustInputArgumentsProvider()

  return {
    {
      ["input"] = { ["numberOfArguments"] = 3 },
      ["tests"] = {
        {
          ["input"] = { ["inputArguments"] = { "a", "b", 5 } },
          ["expected"] = { ["adjustedInputArguments"] = {"a", "b", 5 } }
        },
        {
          ["input"] = { ["inputArguments"] = {} },
          ["expected"] = { ["adjustedInputArguments"] = {} }
        }
      }
    },
    {
      ["input"] = { ["numberOfArguments"] = 0 },
      ["tests"] = {
        {
          ["input"] = { ["inputArguments"] = { "cmd", false } },
          ["expected"] = { ["adjustedInputArguments"] = { "cmd", false } }
        },
        {
          ["input"] = { ["inputArguments"] = { true } },
          ["expected"] = { ["adjustedInputArguments"] = { true } }
        }
      }
    },
    {
      ["input"] = { ["numberOfArguments"] = 1 },
      ["tests"] = {
        {
          ["input"] = { ["inputArguments"] = { 4.5, true, "hello" } },
          ["expected"] = { ["adjustedInputArguments"] = { 4.5, true, "hello" } }
        },
        {
          ["input"] = { ["inputArguments"] = { 12, 17, "other", "random" } },
          ["expected"] = { ["adjustedInputArguments"] = { 12, 17, "other", "random" } }
        },
      }
    }
  }

end

function TestBaseCommand:createNumberedArgumentMocks(_numberOfMocks)

  local argumentMocks = {}
  for i = 1, _numberOfMocks, 1 do

    local argumentMock = self:getMock(
      "wesenGemaMod/CommandExecutor/Command/CommandArgument", "CommandArgument#" .. i
    )
    table.insert(argumentMocks, argumentMock)

  end

  return argumentMocks

end


setmetatable(TestBaseCommand, {__index = TestCase})


return TestBaseCommand
