---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ClientOutputFactory = require "AC-ClientOutput.ClientOutputFactory"
local Object = require "classic"

---
-- Provides methods to render RootNode's to ClientOutputString's and ClientOutputTable's.
--
-- @type ClientOutputRenderer
--
local ClientOutputRenderer = Object:extend()


---
-- The ClientOutputFactory that will be used to create ClientOutputString's and ClientOutputTable's
--
-- @tfield ClientOutputFactory clientOutputFactory
--
ClientOutputRenderer.clientOutputFactory = nil


---
-- ClientOutputRenderer constructor.
--
function ClientOutputRenderer:new()
  self.clientOutputFactory = ClientOutputFactory()
end


-- Public Methods

---
-- Configures this ClientOutputRenderer.
--
-- @tparam table _configuration The configuration to apply
--
function ClientOutputRenderer:configure(_configuration)

  if (type(_configuration) == "table") then

    if (type(_configuration["ClientOutputFactory"]) == "table") then
      self.clientOutputFactory:configure(_configuration["ClientOutputFactory"])
    end

  end

end

---
-- Generates and returns a ClientOutputString from a parsed template's root node.
--
-- @tparam RootNode _parsedTemplate The parsed template's root node
--
-- @treturn ClientOutputString The ClientOutputString
--
function ClientOutputRenderer:renderAsClientOutputString(_parsedTemplate)
  return self.clientOutputFactory:getClientOutputString(
    _parsedTemplate:find("content")[1]:toString(),
    self:getClientOutputConfigurationFromParsedTemplate(_parsedTemplate)
  )
end

---
-- Generates and returns a ClientOutputTable from a parsed template's root node.
--
-- @tparam RootNode _parsedTemplate The parsed template's root node
--
-- @treturn ClientOutputTable The ClientOutputTable
--
function ClientOutputRenderer:renderAsClientOutputTable(_parsedTemplate)
  return self.clientOutputFactory:getClientOutputTable(
    _parsedTemplate:find("content")[1]:toTable(),
    self:getClientOutputConfigurationFromParsedTemplate(_parsedTemplate)
  )
end


-- Private Methods

---
-- Returns the ClientOutput configuration that is stored in the config section of a parsed template.
--
-- @tparam RootNode _parsedTemplate The parsed template's root node
--
-- @treturn table|nil The ClientOutput configuration that is stored in the parsed template
--
function ClientOutputRenderer:getClientOutputConfigurationFromParsedTemplate(_parsedTemplate)

  local templateConfigurationNode = _parsedTemplate:find("config")[1]
  if (templateConfigurationNode) then
    return templateConfigurationNode:toTable()
  end

end


return ClientOutputRenderer
