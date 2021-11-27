---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TemplateException = require "AC-LuaServer.Core.Util.Exception.TemplateException"

---
-- Exception for the case that the argparse library returned encountered an error during parsing.
--
-- @type ArgparseException
--
local ArgparseException = TemplateException:extend()


---
-- ArgparseException constructor.
--
-- @tparam string _commandName The name of the command that raised this Exception
-- @tparam string _argparseErrorMessage The error message that was returned by the argparse library
--
function ArgparseException:new(_commandName, _argparseErrorMessage)

  TemplateException.new(
    self,
    "TextTemplate/ExceptionMessages/CommandHandler/NotEnoughCommandArguments", -- TODO: Fix path
    {
      commandName = _commandName,
      argparseErrorMessage = _argparseErrorMessage
    }
  )

end


return ArgparseException
