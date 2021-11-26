---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TemplateException = require "AC-LuaServer.Core.Util.Exception.TemplateException"

local UnknownCommandException = TemplateException:extend()


UnknownCommandException.commandName = nil


function UnknownCommandException:new(_commandName)

  TemplateException.new(
    self,
    "TextTemplate/ExceptionMessages/CommandHandler/UnknownCommand", -- TODO: Fix path
    {
      commandName = _commandName
    }
  )

end


return UnknownCommandException
