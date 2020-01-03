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
  local configNode = _parsedTemplate:find("config")[1]
  local contentNode = _parsedTemplate:find("content")[1]

  return self.clientOutputFactory:getClientOutputString(
    contentNode and contentNode:toString() or "",
    configNode and configNode:toTable() or nil
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
  local configNode = _parsedTemplate:find("config")[1]
  local contentNode = _parsedTemplate:find("content")[1]

  return self.clientOutputFactory:getClientOutputTable(
    contentNode and contentNode:toTable() or {},
    configNode and configNode:toTable() or nil
  )
end


return ClientOutputRenderer
