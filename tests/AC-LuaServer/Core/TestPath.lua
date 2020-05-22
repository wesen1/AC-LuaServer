---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the Path works as expected.
--
-- @type TestPath
--
local TestPath = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestPath.testClassPath = "AC-LuaServer.Core.Path"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestPath.dependencyPaths = {
  { id = "path", path = "pl.path", ["type"] = "table" }
}


---
-- The mock for the "package.searchpath" function
--
-- @tfield function packageSearchpathMock
--
TestPath.packageSearchpathMock = nil

---
-- The backup of the original "package.searchpath" function
--
-- @tfield function originalPackageSearchpathFunction
--
TestPath.originalPackageSearchpathFunction = nil

---
-- The backup of the original "package.path" string
--
-- @tfield string originalPackagePathString
--
TestPath.originalPackagePathString = nil


---
-- Method that is called before a test is executed.
-- Sets up the mocks.
--
function TestPath:setUp()
  TestCase.setUp(self)

  -- Generate the mocks
  self.packageSearchpathMock = self.mach.mock_function("packageMock.searchpath")

  -- Backup the original values
  self.originalPackagePathString = package.path
  self.originalPackageSearchpathFunction = package.searchpath

  -- Replace the package fields with the mocks
  package.path = "test/?.lua"
  package.searchpath = self.packageSearchpathMock
end

---
-- Method that is called after a test was executed.
-- Clears the mocks.
--
function TestPath:tearDown()
  TestCase.tearDown(self)

  -- Restore the original package fields
  package.path = self.originalPackagePathString
  package.searchpath = self.originalPackageSearchpathFunction

  -- Clear the mocks
  self.originalPackageSearchpathFunction = nil
end


---
-- Checks that the Path can return the source directory path as expected.
--
function TestPath:testCanReturnSourceDirectoryPath()

  local Path = self.testClass
  local pathMock = self.dependencyMocks.path

  local sourceDirectoryPath
  self.packageSearchpathMock
      :should_be_called_with("AC-LuaServer.Core.Path", "test/?.lua")
      :and_will_return("/home/wesen/lua/src/AC-LuaServer/Core/Path.lua")
      :and_then(
        pathMock.dirname
                :should_be_called_with("/home/wesen/lua/src/AC-LuaServer/Core/Path.lua")
                :and_will_return("/home/wesen/lua/src/AC-LuaServer/Core")
      )
      :and_then(
        pathMock.abspath
                :should_be_called_with("/home/wesen/lua/src/AC-LuaServer/Core/../..")
                :and_will_return("/home/wesen/lua/src")
      )
      :when(
        function()
          sourceDirectoryPath = Path.getSourceDirectoryPath()
        end
      )

  self:assertEquals("/home/wesen/lua/src", sourceDirectoryPath)

  -- Should not fetch the source directory path again on subsequent calls
  self:assertEquals("/home/wesen/lua/src", Path.getSourceDirectoryPath())

end


return TestPath
