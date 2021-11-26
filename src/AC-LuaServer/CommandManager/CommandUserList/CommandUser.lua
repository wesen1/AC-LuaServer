---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"
local RequiredLevelFilter = require "AC-LuaServer.CommandManager.CommandSearcher.Filter.RequiredLevelFilter"
local VisibleCommandGroupsFilter = require "AC-LuaServer.CommandManager.CommandSearcher.Filter.VisibleCommandGroupsFilter"

---
-- Represents a connected Player that can use Command's.
--
-- @type CommandUser
--
local CommandUser = Object:extend()


---
-- The Player that this CommandUser was created for
--
-- @tfield Player player
--
CommandUser.player = nil

---
-- The CommandUser's current level (0 = unarmed, 1 = admin)
--
-- @tfield int level
--
CommandUser.level = 0

---
-- The list of CommandGroup names that are explicitly visible to this CommandUser
--
-- @tfield string[] explicitlyVisibleCommandGroupNames
--
CommandUser.explicitlyVisibleCommandGroupNames = nil

CommandUser.commandSearcherFilters = nil

---
-- CommandUser constructor.
--
-- @tparam Player _player The Player to create this CommandUser for
--
function CommandUser:new(_player)
  self.player = _player
  self.level = _player:getHasAdminRole()
  self.explicitlyVisibleCommandGroupNames = {}

  self.commandSearcherFilters = {
    RequiredLevelFilter(self),
    VisibleCommandGroupsFilter(self)
  }
end


-- Getters and Setters

---
-- Returns the CommandUser's level.
--
-- @treturn int The CommandUser's level
--
function CommandUser:getLevel()
  return self.level
end

---
-- Sets the CommandUser's Level.
--
-- @tparam int _level The CommandUser's level
--
function CommandUser:setLevel(_level)
  self.level = _level
end

---
-- Returns the CommandSearcher Filter's for this CommandUser.
--
-- @treturn BaseFilter[] The CommandSearcher Filter's
--
function CommandUser:getCommandSearcherFilters()
  return self.commandSearcherFilters
end

---
-- Returns the list of CommandGroup names that are explicitly visible to this CommandUser.
--
-- @treturn string[] The list of CommandGroup names that are explicitly visible to this CommandUser
--
function CommandUser:getExplicitlyVisibleCommandGroupNames()
  return self.explicitlyVisibleCommandGroupNames
end


-- Public Methods

function CommandUser:addExplictlyVisibleCommandGroupName(_commandGroupName)
  table.insert(self.explicitlyVisibleCommandGroupNames, _commandGroupName)
end

function CommandUser:removeExplicitlyVisibleCommandGroupName(_commandGroupName)
end


return CommandUser
