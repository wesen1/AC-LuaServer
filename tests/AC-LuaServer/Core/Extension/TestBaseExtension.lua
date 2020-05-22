---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the BaseExtension works as expected.
--
-- @type TestBaseExtension
--
local TestBaseExtension = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestBaseExtension.testClassPath = "tests.AC-LuaServer.Core.Extension.ExampleExtension"

---
-- The event listener mock for the "intialized" event of the ExampleExtension
--
-- @tfield table onInitializedEventListener
--
TestBaseExtension.onInitializedEventListener = nil

---
-- The event listener mock for the "enabled" event of the ExampleExtension
--
-- @tfield table onEnabledEventListener
--
TestBaseExtension.onEnabledEventListener = nil

---
-- The event listener mock for the "terminated" event of the ExampleExtension
--
-- @tfield table onTerminatedEventListener
--
TestBaseExtension.onTerminatedEventListener = nil

---
-- The event listener mock for the "disabled" event of the ExampleExtension
--
-- @tfield table onDisabledEventListener
--
TestBaseExtension.onDisabledEventListener = nil


---
-- Method that is called before a test is executed.
-- Sets up the event listener mocks.
--
function TestBaseExtension:setUp()
  TestCase.setUp(self)

  self.onInitializedEventListener = self.mach.mock_function("onInitialized")
  self.onEnabledEventListener = self.mach.mock_function("onEnabled")

  self.onTerminatedEventListener = self.mach.mock_function("onTerminated")
  self.onDisabledEventListener = self.mach.mock_function("onDisabled")
end

---
-- Method that is called after a test was executed.
-- Clears the event listener mocks.
--
function TestBaseExtension:tearDown()
  TestCase.tearDown(self)

  self.onInitializedEventListener = nil
  self.onEnabledEventListener = nil

  self.onTerminatedEventListener = nil
  self.onDisabledEventListener = nil
end


---
-- Checks that a BaseExtension can return its target name.
--
function TestBaseExtension:testCanReturnTargetName()

  local ExampleExtension = self.testClass
  local extension

  extension = ExampleExtension("myTarget")
  self:assertEquals("myTarget", extension:getTargetName())

  extension = ExampleExtension("another_example")
  self:assertEquals("another_example", extension:getTargetName())

  extension = ExampleExtension("different_example")
  self:assertEquals("different_example", extension:getTargetName())

end

---
-- Checks that a BaseExtension can be enabled as expected.
--
function TestBaseExtension:testCanBeEnabled()

  local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
  local ExampleExtension = self.testClass
  local extension = ExampleExtension()

  extension:on("initialized", EventCallback(function() self.onInitializedEventListener() end))
  extension:on("enabled", EventCallback(function() self.onEnabledEventListener() end))
  extension:on("terminated", EventCallback(function() self.onTerminatedEventListener() end))
  extension:on("disabled", EventCallback(function() self.onDisabledEventListener() end))

  self:assertNil(extension:getTarget())

  local extensionTargetMock = self:getExtensionTargetMock()
  self.onInitializedEventListener:should_be_called()
                                 :and_then(
                                   self.onEnabledEventListener:should_be_called()
                                 )
                                 :when(
                                   function()
                                     extension:enable(extensionTargetMock)
                                   end
                                 )
  self:assertEquals(extensionTargetMock, extension:getTarget())

  -- Nothing should happen when the extension target is enabled again
  extension:enable(extensionTargetMock)

end

---
-- Checks that a BaseExtension can be disabled as expected.
--
function TestBaseExtension:testCanBeDisabled()

  local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
  local ExampleExtension = self.testClass
  local extension = ExampleExtension()

  self:assertNil(extension:getTarget())

  local extensionTargetMock = self:getExtensionTargetMock()
  extension:enable(extensionTargetMock)
  self:assertEquals(extensionTargetMock, extension:getTarget())

  extension:on("initialized", EventCallback(function() self.onInitializedEventListener() end))
  extension:on("enabled", EventCallback(function() self.onEnabledEventListener() end))
  extension:on("terminated", EventCallback(function() self.onTerminatedEventListener() end))
  extension:on("disabled", EventCallback(function() self.onDisabledEventListener() end))

  self.onTerminatedEventListener:should_be_called()
                                :and_then(
                                  self.onDisabledEventListener:should_be_called()
                                )
                                :when(
                                  function()
                                    extension:disable()
                                  end
                                )

  self:assertNil(extension:getTarget())

  -- Nothing should happen when the extension is disabled again
  extension:disable()

end


---
-- Generates and returns a ExtensionTarget mock.
--
-- @treturn table The ExtensionTarget mock
--
function TestBaseExtension:getExtensionTargetMock()
  local ExtensionTarget = require "AC-LuaServer.Core.Extension.ExtensionTarget"
  return self.mach.mock_object(ExtensionTarget, "ExtensionTargetMock")
end


return TestBaseExtension
