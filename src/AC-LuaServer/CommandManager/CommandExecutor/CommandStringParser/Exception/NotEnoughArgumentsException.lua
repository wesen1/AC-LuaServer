---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TemplateException = require "AC-LuaServer.Core.Util.Exception.TemplateException"

---
-- Exception for the case that a player did not pass the required number of arguments to a command.
--
-- @type NotEnoughArgumentsException
--
local NotEnoughArgumentsException = TemplateException:extend()


---
-- NotEnoughArgumentsException constructor.
--
-- @tparam string _commandName The name of the command that raised this Exception
-- @tparam int _expectedNumberOfArguments The minimum number of arguments that the command expects
-- @tparam int _actualNumberOfArguments The actual number of arguments that were passed to the command
--
function NotEnoughArgumentsException:new(_commandName, _expectedNumberOfArguments, _actualNumberOfArguments)

  TemplateException.new(
    self,
    "TextTemplate/ExceptionMessages/CommandHandler/NotEnoughCommandArguments", -- TODO: Fix path
    {
      commandName = _commandName,
      expectedNumberOfArguments = _expectedNumberOfArguments,
      actualNumberOfArguments = _actualNumberOfArguments
    }
  )

end


return NotEnoughArgumentsException
