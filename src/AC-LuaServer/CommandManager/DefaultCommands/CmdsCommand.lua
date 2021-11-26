---
-- @author wesen
-- @copyright 2017-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require("wesenGemaMod/CommandExecutor/Command/BaseCommand")
local StaticString = require("wesenGemaMod/Output/StaticString")
local TemplateFactory = require("wesenGemaMod/Output/Template/TemplateFactory")

---
-- Command !cmds.
-- Displays all available commands to a player
--
-- @type CmdsCommand
--
local CmdsCommand = BaseCommand:extend()


---
-- The cached "CmdsCommandList" Template
--
-- @tfield Template cmdsCommandListTemplate
--
CmdsCommand.cmdsCommandListTemplate = nil

---
-- The cached SortedCommandList of the parent CommandList
--
-- @tfield SortedCommandList sortedCommandList
--
CmdsCommand.sortedCommandList = nil


---
-- CmdsCommand constructor.
--
function CmdsCommand:new()

  BaseCommand.new(
    self,
    StaticString("cmdsCommandName"):getString(),
    0,
    nil,
    nil,
    StaticString("cmdsCommandDescription"):getString(),
    { StaticString("cmdsCommandAlias1"):getString() }
  )

end


-- Public Methods

---
-- Displays an auto generated list of all commands.
--
-- @tparam Player _player The player who executed the command
--
function CmdsCommand:execute(_player)
  self.output:printTemplate(self:getCmdsCommandListTemplate(_player), _player)
end


-- Protected Methods

---
-- Event handler that is called after this BaseCommand was attached to a CommandList.
--
function CmdsCommand:onCommandListAttached()
  self.sortedCommandList = self.parentCommandList:generateSortedCommandList()
end

---
-- Event handler that is called after this BaseCommand was detached from its current CommandList.
--
function CmdsCommand:onCommandListDetached()
  self.sortedCommandList = nil
end


-- Private Methods

---
-- Returns the "CmdsCommandList" Template.
-- The template will be rendered only when there is no cached template yet or when the template values
-- of the cached template are outdated.
--
-- @tparam Player _player The player who executed the command
--
-- @treturn Template The "CmdsCommandList" Template
--
function CmdsCommand:getCmdsCommandListTemplate(_player)

  if (self.cmdsCommandListTemplate == nil or
      self.cmdsCommandListTemplate:getTemplateValues()["sortedCommandList"] ~= self.sortedCommandList or
      self.cmdsCommandListTemplate:getTemplateValues()["maximumLevel"] ~= _player:getLevel()) then

    self.cmdsCommandListTemplate = TemplateFactory.getInstance():getTemplate(
      "TableTemplate/Commands/CmdsCommandList",
      { sortedCommandList = self.sortedCommandList, maximumLevel = _player:getLevel() }
    )
    self.cmdsCommandListTemplate:renderAsTable()

  end

  return self.cmdsCommandListTemplate

end


return CmdsCommand
