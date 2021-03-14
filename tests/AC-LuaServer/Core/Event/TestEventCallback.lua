---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the EventCallback works as expected.
--
-- @type TestEventCallback
--
local TestEventCallback = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestEventCallback.testClassPath = "AC-LuaServer.Core.Event.EventCallback"


---
-- Checks that a EventCallback can be created from a function name.
--
function TestEventCallback:testCanBeCreatedFromFunctionName()

  local EventCallback = self.testClass

  _G.testFunction = function(_number)
    return _number + 2
  end


  local callback = EventCallback("testFunction")

  self:assertEquals(5, callback:call(3))
  self:assertEquals(3, callback:call(1))
  self:assertEquals(-4, callback:call(-6))

end

---
-- Checks that a EventCallback can be created from a function.
--
function TestEventCallback:testCanBeCreatedFromFunction()

  local EventCallback = self.testClass

  local callback = EventCallback(function(_text)
    return "123" .. _text .. "321"
  end)

  self:assertEquals("123hello321", callback:call("hello"))
  self:assertEquals("123i pro321", callback:call("i pro"))
  self:assertEquals("123A very long message to test this callback321", callback:call("A very long message to test this callback"))

end

---
-- Checks that a EventCallback can be created from a object's method.
--
function TestEventCallback:testCanBeCreatedFromObjectMethod()

  local EventCallback = self.testClass

  local objectMock = {
    ["someProperty"] = 451,
    ["exampleMethod"] = function(_self, _anotherNumber)
      return _anotherNumber + _self.someProperty
    end
  }

  local callback = EventCallback({["object"] = objectMock, ["methodName"] = "exampleMethod"})

  self:assertEquals(902, callback:call(451))
  self:assertEquals(455, callback:call(4))
  self:assertEquals(430, callback:call(-21))


  local anotherObjectMock = {
    ["otherProperty"] = "hi",
    ["generateString"] = function(_self, _appendString)
      return _self.otherProperty .. _appendString
    end
  }

  local otherCallback = EventCallback({anotherObjectMock, "generateString"})
  self:assertEquals("hi I'm new", otherCallback:call(" I'm new"))
  self:assertEquals("hi!! how to play?", otherCallback:call("!! how to play?"))
  self:assertEquals("hi, i pro", otherCallback:call(", i pro"))

end

---
-- Checks that a EventCallback can be created from a object's method that has no parameters.
--
function TestEventCallback:testCanBeCreatedFromObjectMethodWithNoParameters()

  local EventCallback = self.testClass

  local objectMock = {
    ["myPropertyA"] = "perfect"
  }

  objectMock["methodWithNoParameters"] = function(...)
    local parameters = {...}
    self:assertEquals({ objectMock }, parameters)

    return objectMock.myPropertyA
  end

  local callbackA = EventCallback({["object"] = objectMock, ["methodName"] = "methodWithNoParameters"})
  self:assertEquals("perfect", callbackA:call())

  local callbackB = EventCallback({objectMock, "methodWithNoParameters"})
  self:assertEquals("perfect", callbackB:call())

end

---
-- Checks that a EventCallback can be created from a object's method that has a single parameter.
--
function TestEventCallback:testCanBeCreatedFromObjectMethodWithSingleParameter()

  local EventCallback = self.testClass

  local objectMock = {
    ["myPropertyB"] = "works"
  }

  objectMock["methodWithSingleParameter"] = function(...)
    local parameters = {...}
    self:assertEquals({ objectMock, 8 }, parameters)

    return objectMock.myPropertyB
  end

  local callbackA = EventCallback({["object"] = objectMock, ["methodName"] = "methodWithSingleParameter"})
  self:assertEquals("works", callbackA:call(8))

  local callbackB = EventCallback({objectMock, "methodWithSingleParameter"})
  self:assertEquals("works", callbackB:call(8))

end

---
-- Checks that a EventCallback can be created from a object's method that has multiple parameters.
--
function TestEventCallback:testCanBeCreatedFromObjectMethodWithMultipleParameters()

  local EventCallback = self.testClass

  local objectMock = {
    ["myPropertyC"] = "fine"
  }

  objectMock["methodWithMultipleParameters"] = function(...)
    local parameters = {...}
    self:assertEquals({ objectMock, "bla", "blub" }, parameters)

    return objectMock.myPropertyC
  end

  local callbackA = EventCallback({["object"] = objectMock, ["methodName"] = "methodWithMultipleParameters"})
  self:assertEquals("fine", callbackA:call("bla", "blub"))

  local callbackB = EventCallback({objectMock, "methodWithMultipleParameters"})
  self:assertEquals("fine", callbackB:call("bla", "blub"))

end

---
-- Checks that additional parameters can be added to a callback object method with no parameters.
--
function TestEventCallback:testCanAddAdditionalParametersToObjectMethodWithNoParameters()

  local EventCallback = self.testClass

  local objectMock = {}

  -- Case A: Add single parameter at end position
  objectMock["myPropertyA"] = "done"
  objectMock["methodWithNoParameters"] = function(...)
    local parameters = {...}
    self:assertEquals({ objectMock, "somevalue" }, parameters)

    return objectMock.myPropertyA
  end

  local callbackA = EventCallback({
      ["object"] = objectMock,
      ["methodName"] = "methodWithNoParameters",
      ["additionalParameters"] = { [1] = { "somevalue" } }
  })
  self:assertEquals("done", callbackA:call())

  local callbackB = EventCallback({ objectMock, "methodWithNoParameters", { [1] = { "somevalue" } } })
  self:assertEquals("done", callbackB:call())


  -- Case B: Add multiple parameters at end position
  objectMock["myPropertyB"] = "yes"
  objectMock["methodWithNoParametersTwo"] = function(...)
    local parameters = {...}
    self:assertEquals({ objectMock, "one", 2 }, parameters)

    return objectMock.myPropertyB
  end

  local callbackC = EventCallback({
      ["object"] = objectMock,
      ["methodName"] = "methodWithNoParametersTwo",
      ["additionalParameters"] = { [1] = { "one", 2 } }
  })
  self:assertEquals("yes", callbackC:call())

  local callbackD = EventCallback({ objectMock, "methodWithNoParametersTwo", { [1] = { "one", 2 } } })
  self:assertEquals("yes", callbackD:call())

end

---
-- Checks that additional parameters can be added to a callback object method with parameters.
--
function TestEventCallback:testCanAddAdditionalParametersToObjectMethodWithParameters()

  local EventCallback = self.testClass

  local objectMock = {}

  -- Case A: Single parameter at start
  objectMock["myPropertyA"] = 1
  objectMock["methodWithParametersOne"] = function(...)
    local parameters = {...}
    self:assertEquals({ objectMock, 1, "realfirst" }, parameters)

    return objectMock.myPropertyA
  end

  local callbackA = EventCallback({
      ["object"] = objectMock,
      ["methodName"] = "methodWithParametersOne",
      ["additionalParameters"] = { [1] = { 1 } }
  })
  self:assertEquals(1, callbackA:call("realfirst"))

  local callbackB = EventCallback({objectMock, "methodWithParametersOne", { [1] = { 1 } }})
  self:assertEquals(1, callbackB:call("realfirst"))


  -- Case B: Multiple parameter at start
  objectMock["myPropertyB"] = 2
  objectMock["methodWithParametersTwo"] = function(...)
    local parameters = {...}
    self:assertEquals({ objectMock, 2, 3, "iamarealargument" }, parameters)

    return objectMock.myPropertyB
  end

  local callbackC = EventCallback({
      ["object"] = objectMock,
      ["methodName"] = "methodWithParametersTwo",
      ["additionalParameters"] = { [1] = { 2, 3 } }
  })
  self:assertEquals(2, callbackC:call("iamarealargument"))

  local callbackD = EventCallback({objectMock, "methodWithParametersTwo", { [1] = { 2, 3 } }})
  self:assertEquals(2, callbackD:call("iamarealargument"))


  -- Case C: Single parameter in middle
  objectMock["myPropertyC"] = 3
  objectMock["methodWithParametersThree"] = function(...)
    local parameters = {...}
    self:assertEquals({ objectMock, "yes", 99, "bla" }, parameters)

    return objectMock.myPropertyC
  end

  local callbackE = EventCallback({
      ["object"] = objectMock,
      ["methodName"] = "methodWithParametersThree",
      ["additionalParameters"] = { [2] = { 99 } }
  })
  self:assertEquals(3, callbackE:call("yes", "bla"))

  local callbackF = EventCallback({objectMock, "methodWithParametersThree", { [2] = { 99 } }})
  self:assertEquals(3, callbackF:call("yes", "bla"))


  -- Case D: Multiple parameter in middle
  objectMock["myPropertyD"] = 4
  objectMock["methodWithParametersFour"] = function(...)
    local parameters = {...}
    self:assertEquals({ objectMock, "firstword", 1000, 9999, "secondword" }, parameters)

    return objectMock.myPropertyD
  end

  local callbackG = EventCallback({
      ["object"] = objectMock,
      ["methodName"] = "methodWithParametersFour",
      ["additionalParameters"] = { [2] = { 1000, 9999 } }
  })
  self:assertEquals(4, callbackG:call("firstword", "secondword"))

  local callbackH = EventCallback({objectMock, "methodWithParametersFour", { [2] = { 1000, 9999 } }})
  self:assertEquals(4, callbackH:call("firstword", "secondword"))


  -- Case E: Single parameter at end
  objectMock["myPropertyE"] = 5
  objectMock["methodWithParametersFive"] = function(...)
    local parameters = {...}
    self:assertEquals({ objectMock, "a", "b", true }, parameters)

    return objectMock.myPropertyE
  end

  local callbackI = EventCallback({
      ["object"] = objectMock,
      ["methodName"] = "methodWithParametersFive",
      ["additionalParameters"] = { [3] = { true } }
  })
  self:assertEquals(5, callbackI:call("a", "b"))

  local callbackJ = EventCallback({objectMock, "methodWithParametersFive", { [3] = { true } }})
  self:assertEquals(5, callbackJ:call("a", "b"))


  -- Case F: Multiple parameters at end
  objectMock["myPropertyF"] = 6
  objectMock["methodWithParametersSix"] = function(...)
    local parameters = {...}
    self:assertEquals({ objectMock, "almostdone", "now", false, "notfalse" }, parameters)

    return objectMock.myPropertyF
  end

  local callbackK = EventCallback({
      ["object"] = objectMock,
      ["methodName"] = "methodWithParametersSix",
      ["additionalParameters"] = { [3] = { false, "notfalse" } }
  })
  self:assertEquals(6, callbackK:call("almostdone", "now"))

  local callbackL = EventCallback({objectMock, "methodWithParametersSix", { [3] = { false, "notfalse" } }})
  self:assertEquals(6, callbackL:call("almostdone", "now"))


  -- Case G: Parameters at multiple positions at once
  objectMock["myPropertyG"] = 7
  objectMock["methodWithParametersSeven"] = function(...)
    local parameters = {...}
    self:assertEquals(
      { objectMock, "some", "before", "#1", "then", "more", "after", "#2", "and", "some", "at", "end" },
      parameters
    )

    return objectMock.myPropertyG
  end

  local callbackM = EventCallback({
      ["object"] = objectMock,
      ["methodName"] = "methodWithParametersSeven",
      ["additionalParameters"] = {
        [1] = { "some", "before" },
        [2] = { "then", "more", "after" },
        [3] = { "and", "some", "at", "end" }
      }
  })
  self:assertEquals(7, callbackM:call("#1", "#2"))

  local callbackN = EventCallback({
    objectMock,
    "methodWithParametersSeven",
    {
      [1] = { "some", "before" },
      [2] = { "then", "more", "after" },
      [3] = { "and", "some", "at", "end" }
    }
  })
  self:assertEquals(7, callbackN:call("#1", "#2"))

end


---
-- Checks that a invalid callback function config is handled as expected.
--
function TestEventCallback:testCanHandleInvalidCallbackFunctionConfig()

  local EventCallback = self.testClass
  local GlobalCallbackFunctionNotFoundException = require "AC-LuaServer.Core.Event.Exception.GlobalCallbackFunctionNotFoundException"
  local InvalidCallbackFunctionException = require "AC-LuaServer.Core.Event.Exception.InvalidCallbackFunctionException"

  local exception

  -- Invalid callback config
  exception = self:expectException(function() EventCallback(false) end)
  self:assertTrue(exception:is(InvalidCallbackFunctionException))

  exception = self:expectException(function() EventCallback(nil) end)
  self:assertTrue(exception:is(InvalidCallbackFunctionException))

  exception = self:expectException(function() EventCallback({ ["object"] = {}}) end)
  self:assertTrue(exception:is(InvalidCallbackFunctionException))


  -- Global callback function not found
  exception = self:expectException(function() EventCallback("helloworld") end)
  self:assertTrue(exception:is(GlobalCallbackFunctionNotFoundException))

  self:assertEquals("helloworld", exception:getFunctionName())

end

---
-- Checks that the priority is configured as expected.
--
function TestEventCallback:testCanConfigurePriority()

  local EventCallback = self.testClass

  local callbackFunction = function() end
  local callback

  -- No explicit priority
  callback = EventCallback(callbackFunction)
  self:assertEquals(128, callback:getPriority())

  -- Explicit priority
  callback = EventCallback(callbackFunction, 0)
  self:assertEquals(0, callback:getPriority())

  callback = EventCallback(callbackFunction, 256)
  self:assertEquals(256, callback:getPriority())

end


return TestEventCallback
