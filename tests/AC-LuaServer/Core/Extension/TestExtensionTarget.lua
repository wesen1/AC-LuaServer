---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the ExtensionTarget works as expected.
--
-- @type TestExtensionTarget
--
local TestExtensionTarget = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestExtensionTarget.testClassPath = "tests.AC-LuaServer.Core.Extension.ExampleExtensionTarget"


---
-- Checks that a ExtensionTarget can be enabled and disabled when it has no extensions.
--
function TestExtensionTarget:testCanBeEnabledAndDisabledWithoutExtensions()

  local ExampleExtensionTarget = self.testClass
  local extensionTarget = ExampleExtensionTarget()

  extensionTarget:disable()

  extensionTarget:enable()
  extensionTarget:disable()

end

---
-- Checks that a ExtensionTarget can be enabled when it has extensions.
--
function TestExtensionTarget:testCanBeEnabledWithExtensions()

  local ExampleExtensionTarget = self.testClass
  local extensionTarget = ExampleExtensionTarget()

  extensionTarget:disable()

  -- Add some extensions
  local extensionMockA = self:getExtensionMock()
  local extensionMockB = self:getExtensionMock()
  extensionTarget:addExtension(extensionMockA)
  extensionTarget:addExtension(extensionMockB)

  extensionMockA.enable
                :should_be_called_with(extensionTarget)
                :and_then(
                  extensionMockB.enable
                                :should_be_called_with(extensionTarget)
                )
                :when(
                  function()
                    extensionTarget:enable()
                  end
                )

  -- Nothing should happen when the extension target is enabled again
  extensionTarget:enable()

end

---
-- Checks that a ExtensionTarget can be disabled when it has extensions.
--
function TestExtensionTarget:testeCanBeDisabledWithExtensions()

  local ExampleExtensionTarget = self.testClass
  local extensionTarget = ExampleExtensionTarget()

  extensionTarget:enable()

  -- Add some extensions
  local extensionMockA = self:getExtensionMock()
  local extensionMockB = self:getExtensionMock()

  extensionMockA.enable
                :should_be_called_with(extensionTarget)
                :when(
                  function()
                    extensionTarget:addExtension(extensionMockA)
                  end
                )

  extensionMockB.enable
                :should_be_called_with(extensionTarget)
                :when(
                  function()
                    extensionTarget:addExtension(extensionMockB)
                  end
                )

  extensionMockA.disable
                :should_be_called()
                :and_then(
                  extensionMockB.disable
                                :should_be_called()
                )
                :when(
                  function()
                    extensionTarget:disable()
                  end
                )

  -- Nothing should happen when the extension target is disabled again
  extensionTarget:disable()

end

---
-- Checks that a ExtensionTarget can return its name.
--
function TestExtensionTarget:testCanReturnName()

  local ExampleExtensionTarget = self.testClass
  local extensionTarget

  extensionTarget = ExampleExtensionTarget("someTarget")
  self:assertEquals("someTarget", extensionTarget:getName())

  extensionTarget = ExampleExtensionTarget("server")
  self:assertEquals("server", extensionTarget:getName())

  extensionTarget = ExampleExtensionTarget("GameModeManager")
  self:assertEquals("GameModeManager", extensionTarget:getName())

end


---
-- Generates and returns a BaseExtension mock.
--
-- @treturn table The BaseExtension mock
--
function TestExtensionTarget:getExtensionMock()
  local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
  return self.mach.mock_object(BaseExtension, "ExtensionMock")
end


return TestExtensionTarget
