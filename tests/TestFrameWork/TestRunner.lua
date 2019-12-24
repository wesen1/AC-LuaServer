---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local lfs = require("lfs")
local luaunit = require("luaunit")
local Object = require "classic"

---
-- Allows to configure and run a test suite of luaunit tests.
--
-- @type TestRunner
--
local TestRunner = Object:extend()


---
-- Adds a test directory to load tests from to this TestRunner.
--
-- @tparam string _directoryPath The directory path to add
--
-- @treturn TestRunner The TestRunner instance to allow chaining other method calls
--
function TestRunner:addTestDirectory(_directoryPath)
  self:requireTestsRecursive(_directoryPath)
  return self
end

---
-- Enables code coverage analysis.
--
-- @treturn TestRunner The TestRunner instance to allow chaining other method calls
--
function TestRunner:enableCoverageAnalysis()
  require("luacov")
  return self
end

---
-- Runs the luaunit tests and exits the lua script with luaunit's return status.
--
function TestRunner:run()
  os.exit(luaunit.LuaUnit.run())
end


-- Private Methods

---
-- Requires all unit test lua files from a specified directory recursively.
--
-- @tparam string _testDirectoryPath The path to the directory relative from the entry point file's directory
--
function TestRunner:requireTestsRecursive(_testDirectoryPath)

  for fileName in lfs.dir(_testDirectoryPath) do

    if (fileName ~= "." and fileName ~= "..") then

      local filePath = _testDirectoryPath .. "/" .. fileName
      local attr = lfs.attributes(filePath)

      if (attr.mode == "directory") then
        self:requireTestsRecursive(filePath)
      elseif (fileName:match("^Test.+%.lua$")) then

        local className = fileName:gsub("%.lua$", "")
        local classRequirePath = filePath:gsub("%.lua$", "")

        -- Add the class to the "globals" table because luaunit will only execute test functions that
        -- start with "test" and that it finds inside that table
        _G[className] = require(classRequirePath)

      end

    end

  end

end


return TestRunner
