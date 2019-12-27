---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestRunner = require "TestFrameWork.TestRunner"

---
-- Add the path to the AC-LuaServer classes to the package path list, so the require paths can match
-- the ones that are used in the "src" folder
-- This is required to mock dependencies in each TestCase
--
package.path = package.path .. ";../src/?.lua"

---
-- Add the main directory to the package path list so that classes inside the tests directory can be
-- required with the prefix "tests."
--
package.path = package.path .. ";../?.lua"


---
-- The lua unit test suite
-- Runs all tests from the "AC-LuaServer" directory
--
local runner = TestRunner()

local coverageAnalysisConfigFile = _G.arg[1]
_G.arg[1] = nil

runner:addTestDirectory("AC-LuaServer")
      :enableCoverageAnalysis(coverageAnalysisConfigFile)
      :run()
