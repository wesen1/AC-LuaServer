---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TemplateException = require "AC-LuaServer.Core.Util.Exception.TemplateException"

local TooManyArgumentsException = TemplateException:extend()


TooManyArgumentsException.commandName = nil


function TooManyArgumentsException:new(_commandName, _expectedNumberOfArguments, _actualNumberOfArguments)

  TemplateException.new(
    self,
    "TextTemplate/ExceptionMessages/CommandHandler/UnknownCommand", -- TODO: Fix path
    {
      commandName = _commandName,
      expectedNumberOfArguments = _expectedNumberOfArguments,
      actualNumberOfArguments = _actualNumberOfArguments
    }
  )

end


return TooManyArgumentsException
