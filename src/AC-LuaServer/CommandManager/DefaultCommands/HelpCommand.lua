---
-- @author wesen
-- @copyright 2017-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require("wesenGemaMod/CommandExecutor/Command/BaseCommand")
local CommandArgument = require("wesenGemaMod/CommandExecutor/Command/CommandArgument")
local StaticString = require("wesenGemaMod/Output/StaticString")
local TemplateException = require("wesenGemaMod/Util/TemplateException")

---
-- Command !help.
-- Prints help texts for each command.
--
-- @type HelpCommand
--
local HelpCommand = BaseCommand:extend()


---
-- HelpCommand constructor.
--
function HelpCommand:new()

  BaseCommand.new(self, "help")

  local commandNameArgument = CommandArgument("commandName")
  commandNameArgument:setShortName("cmd")
  commandNameArgument:setDescription("The command name")

  self:addArgument(commandNameArgument)
  self:setRequiredLevel(0)

  self:setDescription("Shows a command's description and its arguments.")
  self:addAlias("man")

end


-- Public Methods

---
-- Adjusts the input arguments.
--
-- @tparam mixed[] _arguments The list of arguments
--
-- @treturn mixed[] The updated list of arguments
--
function HelpCommand:adjustInputArguments(_arguments)

  local arguments = _arguments

  -- The command name may be specified with or without leading "!", however the command
  -- name that will be processed is the one without leading "!"
  if (arguments.commandName:sub(1,1) == "!") then
    arguments.commandName = arguments.commandName:sub(2)
  end

  return arguments

end

---
-- Displays the help text for a command to a player.
--
-- @tparam Player _player The player who executed the command
-- @tparam string[] _arguments The list of arguments which were passed by the player
--
-- @raise Error if the specified command name is unknown
--
function HelpCommand:execute(_player, _arguments)

  local command = self.parentCommandList:getCommandByNameOrAlias(_arguments["commandName"])
  if (command) then
    self.output:printTableTemplate(
      "TableTemplate/CommandHelpText/CommandHelpText",
      { ["command"] = command },
      _player
    )

  else
    error(TemplateException(
      "TextTemplate/ExceptionMessages/CommandHandler/UnknownCommand",
      { ["commandName"] = _arguments["commandName"] }
    ))
  end

end


return HelpCommand
