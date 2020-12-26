---
-- @author wesen
-- @copyright 2017-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local Object = require "classic"
local Template = require "AC-LuaServer.Core.Output.Template.Template"
local TemplateRenderer = require "AC-LuaServer.Core.Output.Template.TemplateRenderer"

---
-- Handles outputs of texts to clients.
--
-- @type Output
--
local Output = Object:extend()


---
-- The template renderer that will be used to render Template's
--
-- @tfield TemplateRenderer templateRenderer
--
Output.templateRenderer = nil


---
-- Output constructor.
--
function Output:new()
  self.templateRenderer = TemplateRenderer()
end


-- Getters and Setters

---
-- Returns the TemplateRenderer.
--
-- @treturn TemplateRenderer The TemplateRenderer
--
function Output:getTemplateRenderer()
  return self.templateRenderer
end


-- Public Methods

---
-- Configures this Output.
--
-- @tparam table _configuration The configuration to apply
--
function Output:configure(_configuration)

  if (_configuration["TemplateRenderer"] ~= nil) then
    self.templateRenderer:configure(_configuration["TemplateRenderer"])
  end

end

---
-- Prints a text template to a player.
-- If no player is specified the template will be printed to every connected player.
--
-- @tparam string _templatePath The path to the template
-- @tparam table _templateValues The template values
-- @tparam Player _player The player to print the template to
--
function Output:printTextTemplate(_templatePath, _templateValues, _player)
  local template = Template(_templatePath, _templateValues)
  local outputRows = self.templateRenderer:renderAsText(template)

  self:printMultiple(outputRows, _player)
end

---
-- Prints a table template to a player.
-- If no player is specified the template will be printed to every connected player.
--
-- @tparam string _templatePath The path to the template
-- @tparam table _templateValues The template values
-- @tparam Player _player The player to print the template to
--
function Output:printTableTemplate(_templatePath, _templateValues, _player)
  local template = Template(_templatePath, _templateValues)
  local outputRows = self.templateRenderer:renderAsTable(template)

  self:printMultiple(outputRows, _player)
end

---
-- Prints a error message to a player.
-- If no player is specified the message will be printed to every connected player.
--
-- @tparam Exception _exception The exception to print
-- @tparam Player _player The player to print the exception to
--
function Output:printException(_exception, _player)
  self:printTextTemplate(
    "Core/Output/ExceptionMessage", { exceptionMessage = _exception:getMessage() }, _player
  )
end


-- Private Methods

---
-- Prints multiple rows at once to a player.
-- If no player is specified the rows will be printed to every connected player.
--
-- @tparam string[] _rows The rows to print
-- @tparam Player _player The player to print the rows to
--
function Output:printMultiple(_rows, _player)
  for _, row in ipairs(_rows) do
    self:print(row, _player)
  end
end

---
-- Displays text in the console of a player.
-- If no player is specified the text will be printed to every connected player.
--
-- @tparam string _text The text to print
-- @tparam Player _player The player to print the text to
--
function Output:print(_text, _player)

  -- If the player is set use its cn as target cn, else use -1 which targets all connected players
  local targetCn = _player and _player:getCn() or -1
  LuaServerApi.clientprint(targetCn, _text)

end


return Output
