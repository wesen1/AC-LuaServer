---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require "AC-LuaServer.Core.Util.Exception.Exception"
local Template = require "AC-LuaServer.Core.Output.Template.Template"

---
-- Exception that uses a template to render its message.
--
-- @type TemplateException
--
local TemplateException = Exception:extend()


---
-- The template that will be used to render this Exception's message
--
-- @tfield Template template
--
TemplateException.template = nil


---
-- TemplateException constructor.
--
-- @tparam string _templatePath The path to the template file
-- @tparam mixed[] _templateValues The template values
--
function TemplateException:new(_templatePath, _templateValues)
  self.template = Template(_templatePath, _templateValues)
end


---
-- Returns the message.
--
-- @treturn string The message
--
function TemplateException:getMessage()
  local Server = require "AC-LuaServer.Core.Server"
  local server = Server.getInstance()
  local templateRenderer = server:getOutput():getTemplateRenderer()

  return templateRenderer:renderAsRawText(self.template)
end


return TemplateException
