---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the LuaServerApi works as expected.
--
-- @type TestLuaServerApi
--
local TestLuaServerApi = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestLuaServerApi.testClassPath = "AC-LuaServer.Core.LuaServerApi"


---
-- Checks that the removemap() method works as expected.
--
function TestLuaServerApi:testCanRemoveMap()

  local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
  local LuaServerApi = self.testClass

  _G.removemap = self.mach.mock_function("removemapMock")

  local onBeforeMapRemoveListener = self.mach.mock_function("onBeforeMapRemoveListener")
  local onMapRemovedListener = self.mach.mock_function("onMapRemovedListener")

  LuaServerApi:on(
    "beforeMapRemove",
    EventCallback(function(...) return onBeforeMapRemoveListener(...) end)
  )
  LuaServerApi:on(
    "mapRemoved",
    EventCallback(function(...) onMapRemovedListener(...) end)
  )


  -- removemap is cancelled by the "beforeMapRemove" event listeners
  onBeforeMapRemoveListener.should_be_called_with("unplayable-gema-map")
                           :and_will_return("dont do that!")
                           :when(
                             function()
                               LuaServerApi:removemap("unplayable-gema-map")
                             end
                           )

  -- removemap is not cancelled by the "beforeMapRemove" event listeners
  onBeforeMapRemoveListener.should_be_called_with("RoofTopGemaEasy")
                           :and_then(
                             _G.removemap.should_be_called_with("RoofTopGemaEasy")
                           )
                           :and_then(
                             onMapRemovedListener.should_be_called_with("RoofTopGemaEasy")
                           )
                           :when(
                             function()
                               LuaServerApi:removemap("RoofTopGemaEasy")
                             end
                           )

end

---
-- Checks that global API functions and constants can be returned by the LuaServerApi as expected.
--
function TestLuaServerApi:testCanReturnGlobalApiFunctionsAndConstants()

  local LuaServerApi = self.testClass

  _G.clientprint = self.mach.mock_function("clientprintMock")
  _G.getip = self.mach.mock_function("getipMock")
  _G.flagaction = self.mach.mock_function("flagactionMock")

  _G.SA_MAP = 7
  _G.GM_CTF = 5
  _G.VOTEE_INVALID = 6

  self:assertEquals(_G.clientprint, LuaServerApi.clientprint)
  self:assertEquals(_G.getip, LuaServerApi.getip)
  self:assertEquals(_G.flagaction, LuaServerApi.flagaction)

  self:assertEquals(7, LuaServerApi.SA_MAP)
  self:assertEquals(5, LuaServerApi.GM_CTF)
  self:assertEquals(6, LuaServerApi.VOTEE_INVALID)

end

---
-- Checks that the methods of the base Object from which LuaServerApi extends are accessible.
--
function TestLuaServerApi:testCanAccessBaseObjectMethods()

  local Object = require "classic"
  local LuaServerApi = self.testClass

  self:assertTrue(LuaServerApi:is(Object))

  local DifferentObject = Object:extend()
  self:assertFalse(LuaServerApi:is(DifferentObject))

end

---
-- Checks that API event listeners can be set up via the LuaServerApi as expected.
--
function TestLuaServerApi:testCanSetApiEventListeners()

  local LuaServerApi = self.testClass

  local eventListenerMock = self.mach.mock_function("onPlayerCallVoteMock")

  self:assertNil(_G.onPlayerCallVote)
  LuaServerApi.onPlayerCallVote = eventListenerMock
  self:assertIs(eventListenerMock, LuaServerApi.onPlayerCallVote)

end


return TestLuaServerApi
