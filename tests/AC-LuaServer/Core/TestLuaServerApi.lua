---
-- @author wesen
-- @copyright 2020-2021 wesen <wesen-ac@web.de>
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
-- Checks that LuaServer Api functions with no arguments can be called with emitting of the
-- "before_<function name>" and "after_<function name>" events.
--
function TestLuaServerApi:testCanCallLuaServerApiFunctionsWithNoArgumentsWithEmittingEvents()

  local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
  local LuaServerApi = self.testClass

  local removebansMock = self.mach.mock_function("removebansMock")
  _G.removebans = function(...)
    removebansMock(...)
  end

  local onBeforeBansRemoveListener = self.mach.mock_function("onBeforeBansRemoveListener")
  local onBansRemovedListener = self.mach.mock_function("onBansRemovedListener")

  LuaServerApi:on(
    "before_removebans",
    EventCallback(function(...) return onBeforeBansRemoveListener(...) end)
  )
  LuaServerApi:on(
    "after_removebans",
    EventCallback(function(...) onBansRemovedListener(...) end)
  )


  -- removebans is cancelled by the "before_removebans" event listeners
  onBeforeBansRemoveListener.should_be_called()
                            :and_will_return("won't let you do this")
                            :when(
                              function()
                                LuaServerApi:removebans()
                              end
                            )

  -- removebans is not cancelled by the "before_removebans" event listeners
  onBeforeBansRemoveListener.should_be_called()
                            :and_then(
                              removebansMock.should_be_called()
                            )
                            :and_then(
                              onBansRemovedListener.should_be_called()
                            )
                            :when(
                              function()
                                LuaServerApi:removebans()
                              end
                            )

end

---
-- Checks that LuaServer Api functions with a single argument can be called with emitting of the
-- "before_<function name>" and "after_<function name>" events.
--
function TestLuaServerApi:testCanCallLuaServerApiFunctionsWithSingleArgumentWithEmittingEvents()

  local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
  local LuaServerApi = self.testClass

  local removemapMock = self.mach.mock_function("removemapMock")
  _G.removemap = function(...)
    removemapMock(...)
  end

  local onBeforeMapRemoveListener = self.mach.mock_function("onBeforeMapRemoveListener")
  local onMapRemovedListener = self.mach.mock_function("onMapRemovedListener")

  LuaServerApi:on(
    "before_removemap",
    EventCallback(function(...) return onBeforeMapRemoveListener(...) end)
  )
  LuaServerApi:on(
    "after_removemap",
    EventCallback(function(...) onMapRemovedListener(...) end)
  )


  -- removemap is cancelled by the "before_removemap" event listeners
  onBeforeMapRemoveListener.should_be_called_with("unplayable-gema-map")
                           :and_will_return("dont do that!")
                           :when(
                             function()
                               LuaServerApi:removemap("unplayable-gema-map")
                             end
                           )

  -- removemap is not cancelled by the "before_removemap" event listeners
  onBeforeMapRemoveListener.should_be_called_with("RoofTopGemaEasy")
                           :and_then(
                             removemapMock.should_be_called_with("RoofTopGemaEasy")
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
-- Checks that LuaServer Api functions with mulitple arguments can be called with emitting of the
-- "before_<function name>" and "after_<function name>" events.
--
function TestLuaServerApi:testCanCallLuaServerApiFunctionsWithMultipleArgumentsWithEmittingEvents()

  local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
  local LuaServerApi = self.testClass

  local disconnectMock = self.mach.mock_function("disconnectMock")
  _G.disconnect = function(...)
    disconnectMock(...)
  end

  local onBeforeDisconnectListener = self.mach.mock_function("onBeforeDisconnectListener")
  local onDisconnectedListener = self.mach.mock_function("onDisconnectedListener")

  LuaServerApi:on(
    "before_disconnect",
    EventCallback(function(...) return onBeforeDisconnectListener(...) end)
  )
  LuaServerApi:on(
    "after_disconnect",
    EventCallback(function(...) onDisconnectedListener(...) end)
  )


  -- disconnect is cancelled by the "before_disconnect" event listeners
  onBeforeDisconnectListener.should_be_called_with(5, 19)
                            :and_will_return("100% not a cheater")
                            :when(
                              function()
                                LuaServerApi:disconnect(5, 19)
                              end
                            )

  -- disconnect is not cancelled by the "before_disconnect" event listeners
  onBeforeDisconnectListener.should_be_called_with(15, 17)
                            :and_then(
                              disconnectMock.should_be_called_with(15, 17)
                            )
                            :and_then(
                              onDisconnectedListener.should_be_called_with(15, 17)
                            )
                            :when(
                              function()
                                LuaServerApi:disconnect(15, 17)
                              end
                            )

end

---
-- Checks that LuaServer Api functions can be called without emitting of the "before_<function name>"
-- and "after_<function name>" events.
--
function TestLuaServerApi:testCanCallLuaServerApiFunctionsWithoutEmittingEvents()

  local LuaServerApi = self.testClass

  -- No arguments
  local shuffleteamsMock = self.mach.mock_function("shuffleteamsMock")
  _G.shuffleteams = function(...)
    shuffleteamsMock(...)
  end

  shuffleteamsMock:should_be_called()
                  :when(
                    function()
                      LuaServerApi.shuffleteams()
                    end
                  )


  -- Single argument
  local spawnitemMock = self.mach.mock_function("spawnitemMock")
  _G.spawnitem = function(...)
    spawnitemMock(...)
  end

  spawnitemMock:should_be_called_with(37)
               :when(
                 function()
                   LuaServerApi.spawnitem(37)
                 end
               )


  -- Multiple arguments
  local pickupasMock = self.mach.mock_function("pickupasMock")
  _G.pickupas = function(...)
    pickupasMock(...)
  end

  pickupasMock:should_be_called_with(4, 23)
              :when(
                function()
                  LuaServerApi.pickupas(4, 23)
                end
              )

end

---
-- Checks that the return values of LuaServer Api functions are returned as expected.
--
function TestLuaServerApi:testCanReturnReturnValuesOfApiFunctions()

  local LuaServerApi = self.testClass

  -- No return values
  local setscoreMock = self.mach.mock_function("setscoreMock")
  _G.setscore = function(...)
    return setscoreMock(...)
  end

  setscoreMock:should_be_called_with(7, 311)
              :when(
                function()
                  self:assertNil(LuaServerApi.setscore(7, 311))
                end
              )


  -- Single return value
  local getnameMock = self.mach.mock_function("getnameMock")
  _G.getname = function(...)
    return getnameMock(...)
  end

  getnameMock:should_be_called_with(5)
             :and_will_return("unarmed")
             :when(
               function()
                 self:assertEquals("unarmed", LuaServerApi.getname(5))
               end
             )


  -- Multiple return values
  local getposMock = self.mach.mock_function("getposMock")
  _G.getpos = function(...)
    return getposMock(...)
  end

  getposMock:should_be_called_with(8)
            :and_will_return(1, 4, 2)
            :when(
              function()
                self:assertEquals({1, 4, 2}, { LuaServerApi.getpos(8) })
              end
            )

end

---
-- Checks that global API constants can be returned by the LuaServerApi as expected.
--
function TestLuaServerApi:testCanReturnGlobalApiConstants()

  local LuaServerApi = self.testClass

  _G.SA_MAP = 7
  _G.GM_CTF = 5
  _G.VOTEE_INVALID = 6

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
  self:assertIs(eventListenerMock, _G.onPlayerCallVote)

end


return TestLuaServerApi
