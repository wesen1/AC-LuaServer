---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require("CommandHandler/BaseCommand");
local CommandArgument = require("CommandHandler/CommandArgument");
local StaticString = require("Output/StaticString");
local TemplateException = require("Util/TemplateException");

---
-- Command !help.
-- Prints help texts for each command.
-- ColorsCommand inherits from BaseCommand
--
-- @type HelpCommand
--
local HelpCommand = setmetatable({}, {__index = BaseCommand});


---
-- The command help text printer
--
-- @tfield CommandHelpTextPrinter The command help text printer
--
HelpCommand.commandHelpTextPrinter = nil;


---
-- HelpCommand constructor.
--
-- @treturn HelpCommand The HelpCommand instance
--
function HelpCommand:__construct()

  local commandNameArgument = CommandArgument(
    StaticString("helpCommandCommandNameArgumentName"):getString(),
    false,
    "string",
    StaticString("helpCommandCommandNameArgumentShortName"):getString(),
    StaticString("helpCommandCommandNameArgumentDescription"):getString()
  );

  local instance = BaseCommand(
    StaticString("helpCommandName"):getString(),
    0,
    nil,
    { commandNameArgument },
    StaticString("helpCommandDescription"):getString(),
    { StaticString("helpCommandAlias1"):getString() }
  );
  setmetatable(instance, {__index = HelpCommand});

  return instance;

end

getmetatable(HelpCommand).__call = HelpCommand.__construct;


-- Public Methods

---
-- Displays the help text for a command to the player.
--
-- @tparam Player _player The player who executed the command
-- @tparam string[] _arguments The list of arguments which were passed by the player
--
-- @raise Error in case of unknown command
--
function HelpCommand:execute(_player, _arguments)

  local command = self.parentCommandList:getCommand(_arguments.commandName);
  if (command) then
    self.output:printTableTemplate(
      "TableTemplate/CommandHelpText/CommandHelpText",
      { ["command"] = command },
      _player
    )

  else
    error(TemplateException(
      "TextTemplate/ExceptionMessages/CommandHandler/UnknownCommand",
      { ["commandName"] = _arguments.commandName }
    ));
  end

end

---
-- Adjusts the input arguments.
--
-- @tparam String[] The list of arguments
--
-- @treturn String[] The updated list of arguments
--
function HelpCommand:adjustInputArguments(_arguments)

  local arguments = _arguments;

  if (arguments.commandName:sub(1,1) ~= "!") then
    arguments.commandName = "!" .. arguments.commandName;
  end

  return arguments;

end


return HelpCommand;
