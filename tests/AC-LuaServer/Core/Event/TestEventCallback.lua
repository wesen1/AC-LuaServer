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

end

---
-- Checks that a EventCallback can be created from a object's method that has no parameters.
--
function TestEventCallback:testCanBeCreatedFromObjectMethodWithNoParameters()

  local EventCallback = self.testClass

  local objectMock = {
    ["myPropertyA"] = "perfect",
    ["myPropertyB"] = "works",
    ["myPropertyC"] = "fine"
  }

  objectMock["methodWithNoParameters"] = function(...)
    local parameters = {...}
    self:assertEquals({ objectMock }, parameters)

    return objectMock.myPropertyA
  end

  objectMock["methodWithSingleParameter"] = function(...)
    local parameters = {...}
    self:assertEquals({ objectMock, 8 }, parameters)

    return objectMock.myPropertyB
  end

  objectMock["methodWithMultipleParameters"] = function(...)
    local parameters = {...}
    self:assertEquals({ objectMock, "bla", "blub" }, parameters)

    return objectMock.myPropertyC
  end

  local callbackA = EventCallback({["object"] = objectMock, ["methodName"] = "methodWithNoParameters"})
  local callbackB = EventCallback({["object"] = objectMock, ["methodName"] = "methodWithSingleParameter"})
  local callbackC = EventCallback({["object"] = objectMock, ["methodName"] = "methodWithMultipleParameters"})

  self:assertEquals("perfect", callbackA:call())
  self:assertEquals("works", callbackB:call(8))
  self:assertEquals("fine", callbackC:call("bla", "blub"))

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
