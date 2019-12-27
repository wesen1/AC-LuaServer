---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "TestFrameWork.TestCase"

---
-- Checks that the ExtensionManager works as expected.
--
-- @type TestExtensionManager
--
local TestExtensionManager = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestExtensionManager.testClassPath = "AC-LuaServer.Core.Extension.ExtensionManager"

---
-- The Server mock that will be passed to the ExtensionManager's constructor
--
-- @tfield table serverMock
--
TestExtensionManager.serverMock = nil


---
-- Method that is called before a test is executed.
-- Sets up the Server mock.
--
function TestExtensionManager:setUp()
  TestCase.setUp(self)

  local Server = require "AC-LuaServer.Core.Server"
  self.serverMock = self.mach.mock_object(Server, "ServerMock")
end

---
-- Method that is called after a test was executed.
-- Clears the Server mock.
--
function TestExtensionManager:tearDown()
  TestCase.tearDown(self)
  self.serverMock = nil
end


---
-- Checks that extensions can be added as expected.
--
function TestExtensionManager:testCanAddExtensions()

  local ExtensionManager = self.testClass
  local extensionManager = ExtensionManager(self.serverMock)

  -- Add a extension for the server
  local extensionMockA = self:getExtensionMock()

  extensionMockA.getTargetName
                :should_be_called()
                :and_will_return("server")
                :and_then(
                  self.serverMock.addExtension
                                 :should_be_called_with(extensionMockA)
                )
                :when(
                  function()
                    extensionManager:addExtension(extensionMockA)
                  end
                )

  -- Add a extension for the other already existing extension
  local extensionMockB = self:getExtensionMock()

  extensionMockB.getTargetName
                :should_be_called()
                :and_will_return("the_first_extension")
                :and_then(
                  extensionMockA.getName
                                :should_be_called()
                                :and_will_return("the_first_extension")
                )
                :and_then(
                  extensionMockA.addExtension
                                :should_be_called_with(extensionMockB)
                )
                :when(
                  function()
                    extensionManager:addExtension(extensionMockB)
                  end
                )

  -- Add a extension for the just added extension
  local extensionMockC = self:getExtensionMock()

  extensionMockC.getTargetName
                :should_be_called()
                :and_will_return("the_second_extension")
                :and_then(
                  extensionMockA.getName
                                :should_be_called()
                                :and_will_return("the_first_extension")
                )
                :and_then(
                  extensionMockB.getName
                                :should_be_called()
                                :and_will_return("the_second_extension")
                )
                :and_then(
                  extensionMockB.addExtension
                                :should_be_called_with(extensionMockC)
                )
                :when(
                  function()
                    extensionManager:addExtension(extensionMockC)
                  end
                )

end

---
-- Checks that an extension with an invalid target is handled as expected.
--
function TestExtensionManager:testCanHandleInvalidExtensionTarget()

  local ExtensionManager = self.testClass
  local ExtensionTargetNotFoundException = require "AC-LuaServer.Core.Extension.Exception.ExtensionTargetNotFoundException"
  local extensionManager = ExtensionManager(self.serverMock)

  -- Try to add an invalid extension
  local extensionMock = self:getExtensionMock()

  extensionMock.getTargetName
               :should_be_called()
               :and_will_return("unknownTarget")
               :and_then(
                 extensionMock.getName
                              :should_be_called()
                              :and_will_return("exampleExtension")
               )
               :and_then(
                 extensionMock.getTargetName
                              :should_be_called()
                              :and_will_return("unknownTarget")
               )
               :when(
                 function()

                   local exception = self:expectException(
                     function()
                       extensionManager:addExtension(extensionMock)
                     end
                   )

                   self:assertTrue(exception:is(ExtensionTargetNotFoundException))

                   self:assertEquals("exampleExtension", exception:getExtensionName())
                   self:assertEquals("unknownTarget", exception:getExtensionTargetName())
                 end
               )

end


---
-- Generates and returns a BaseExtension mock.
--
-- @treturn table The BaseExtension mock
--
function TestExtensionManager:getExtensionMock()
  local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
  return self.mach.mock_object(BaseExtension, "ExtensionMock")
end


return TestExtensionManager
