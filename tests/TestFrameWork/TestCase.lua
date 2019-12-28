---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local luaunit = require "luaunit"
local mach = require "mach"
local Object = require "classic"

---
-- Base class for all unit tests.
-- Internally uses luaunit as unit test framework and mach as mocking framework.
--
local TestCase = Object:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestCase.testClassPath = nil

---
-- The test class
-- This is loaded from the corresponding lua file during each test's setup
--
-- @tfield table testClass
--
TestCase.testClass = nil

---
-- The paths of the classes that the test class depends on
-- The list must be in the format { { id = <string>, path = <string>, [type = "object"|"table"] }, ... }
-- Every dependency will be mocked during each test's setup
--
-- @tfield table[] dependencyPaths
--
TestCase.dependencyPaths = {}

---
-- The list of mocked dependencies
-- This list is in the format { "dependencyPackageId" = mockObject }
--
-- @tfield table mockedDependencies
--
TestCase.dependencyMocks = nil

---
-- The backup of the originally loaded packages in the package.loaded table
-- This is created before the test is started and before any of the dependencies or the test class are loaded
--
-- @tfield table originalLoadedPackages
--
TestCase.originalLoadedPackages = nil

---
-- The backup of the original global variables
-- The list is in the format { "variableName" = originalDependency }
--
-- @tfield table[] originalGlobalVariables
--
TestCase.originalGlobalVariables = nil

---
-- The backup of the original dependencies that are replaced by mocks as configured in dependencyPaths
-- The list is in the format { "dependencyPath" = originalDependency }
--
-- @tfield table[] originalDependencies
--
TestCase.originalDependencies = nil

---
-- The mocking framework
--
-- @tfield mach mach
--
TestCase.mach = mach


---
-- Method that will be called when a table field is attempted to be accessed that was not found in self.
-- Checks if the parent class or luaunit have a field with the name and returns these values if one of
-- these have fields with the target field name.
--
-- @tparam string _fieldName The name of the table field
--
-- @treturn mixed|nil The value for the field
--
function TestCase:__index(_fieldName)

  -- Check parent class
  if (self.super[_fieldName] ~= nil) then
    return self.super[_fieldName]

  -- Check luaunit
  elseif (luaunit[_fieldName] ~= nil) then
    if (type(luaunit[_fieldName]) == "function") then
      return function (self, ...)
        luaunit[_fieldName](...)
      end

    else
      return luaunit[_fieldName]
    end
  end

end


-- Public Methods

---
-- Method that is called before a test is executed.
-- Initializes the dependency mocks and loads the test class.
--
function TestCase:setUp()

  self:backupOriginalDependencies()
  self:initializeDependencyMocks()

  -- Unload the test class for the case that it was loaded while requiring one of its dependencies
  package.loaded[self.testClassPath] = nil

  -- Load the test class
  self.testClass = require(self.testClassPath)

end

---
-- Method that is called after a test was executed.
-- Clears the mocks and restores the packages that were loaded before the test was executed.
--
function TestCase:tearDown()

  self:restoreOriginalDependencies()

  self.originalLoadedPackages = nil
  self.originalGlobalVariables = nil
  self.dependencyMocks = nil
  self.testClass = nil

end


-- Protected Methods

---
-- Expects a function to raise an exception.
--
-- @tparam function _exceptionRaisingFunction The function that is expected to raise an exception
--
-- @treturn Exception The Exception that the function raised
--
function TestCase:expectException(_exceptionRaisingFunction)

  local success, exception = pcall(_exceptionRaisingFunction)

  self:assertFalse(success)
  self:assertNotNil(exception)

  return exception

end

---
-- Returns the mock for a object or class.
--
-- @tparam table _mockTarget The mock target (May be an object, class or table)
-- @tparam string _mockName The name of the mock
-- @tparam string _mockType The mock type (Can be either "object" or "table")
--
-- @treturn table The mock of the object or class
--
function TestCase:getMock(_mockTarget, _mockName, _mockType)

  local mockTarget
  if (type(_mockTarget) == "string") then

    if (self.originalDependencies[_mockTarget]) then
      mockTarget = self.originalDependencies[_mockTarget]
    else
      mockTarget = require(_mockTarget)
    end

  else
    mockTarget = _mockTarget
  end

  if (_mockType == nil or _mockType == "object") then
    return mach.mock_object(mockTarget, _mockName)
  elseif (_mockType == "table") then
    return mach.mock_table(mockTarget, _mockName)
  end

end


-- Private Methods

---
-- Backs up the original dependencies to be able to restore them after a test was executed.
--
function TestCase:backupOriginalDependencies()

  -- Backup the original loaded packages
  self.originalLoadedPackages = {}
  for packagePath, loadedPackage in pairs(package.loaded) do
    self.originalLoadedPackages[packagePath] = loadedPackage
  end

  -- Backup the original fields of the global table
  self.originalGlobalVariables = {}
  for key, value in pairs(_G) do
    self.originalGlobalVariables[key] = value
  end

end

---
-- Restores the original dependencies and global variables.
--
function TestCase:restoreOriginalDependencies()

  -- Restore  all packages that were loaded before the test started
  for packagePath, _ in pairs(package.loaded) do
    package.loaded[packagePath] = self.originalLoadedPackages[packagePath]
  end

  -- Overwrite all global variables with the ones that were set before the test started
  for key, _ in pairs(_G) do
    _G[key] = self.originalGlobalVariables[key]
  end

end

---
-- Initializes the mocks for the test class dependencies.
--
function TestCase:initializeDependencyMocks()

  -- Create mocks and load them into the package.loaded or the _G variable
  self.dependencyMocks = {}
  self.originalDependencies = {}
  for _, dependencyInfo in pairs(self.dependencyPaths) do

    local dependencyId = dependencyInfo["id"]
    local dependencyPath = dependencyInfo["path"]
    local dependencyType = dependencyInfo["type"] or "object"

    -- Load the dependency
    local dependency
    if (dependencyType == "globalVariable") then
      dependency = _G[dependencyPath]
    else
      dependency = require(dependencyPath)
    end

    local dependencyMock, injectValue = self:getDependencyMock(dependency, dependencyId, dependencyType)

    -- Replace the dependency by the mock
    if (dependencyType == "globalVariable") then
      _G[dependencyPath] = injectValue
    else
      package.loaded[dependencyPath] = injectValue
    end

    -- Save the mock to be able to use it in the tests
    self.dependencyMocks[dependencyId] = dependencyMock

    -- Backup the original dependency to be able to manually create more mocks from the dependency
    self.originalDependencies[dependencyPath] = dependency
  end

end

---
-- Generates and returns a mock for a dependency.
--
-- @tparam mixed _dependency The dependency to mock
-- @tparam string _dependencyId The id of the dependency (Will be used to generate the mock name)
-- @tparam string _dependencyType The dependency type
--
-- @treturn table The mock for the depedency
-- @treturn table The mock to insert into the loaded packages list or the global table
--
function TestCase:getDependencyMock(_dependency, _dependencyId, _dependencyType)

  local dependencyType = _dependencyType
  if (dependencyType == "globalVariable") then
    dependencyType = "table"
  end

  local dependencyMock = self:getMock(_dependency, _dependencyId .. "Mock", dependencyType)

  local injectValue
  if (dependencyType == "object") then
    injectValue = setmetatable({}, {
        __call = function(...)
          return dependencyMock.__call(...)
        end,
        __index = dependencyMock
    })
  else
    injectValue = dependencyMock
  end


  return dependencyMock, injectValue

end


return TestCase
