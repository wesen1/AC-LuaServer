---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseTemplateNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode"
local StringUtils = require "AC-LuaServer.Core.Util.StringUtils"

---
-- Represents the config section of a template.
--
-- @type ConfigNode
--
local ConfigNode = BaseTemplateNode:extend()


---
-- ConfigNode constructor.
--
function ConfigNode:new()
  self.super.new(self, "config", { "config" }, { "end-config" })
end


-- Public Methods

---
-- Generates and returns a table from this node and its inner contents.
--
-- @treturn table The table representation of this node
--
function ConfigNode:toTable()

  local getConfigurationFunction = loadstring("return " .. self:getTableStringFromInnerTexts())
  if (getConfigurationFunction) then
    return getConfigurationFunction()
  else
    return {}
  end

end


-- Private Methods

---
-- Returns a string that defines a lua table from the inner texts of this node.
--
-- @treturn string The table string
--
function ConfigNode:getTableStringFromInnerTexts()

  -- Convert the configuration string to a lua table
  local configurationValues = table.concat(self.innerTexts)

  local configurationTableFields = ""
  local isFirstValue = true
  for _, configurationValue in ipairs(StringUtils.split(configurationValues, "[^%];\n")) do

    if (isFirstValue) then
      isFirstValue = false
    else
      configurationTableFields = configurationTableFields .. ","
    end

    configurationTableFields = configurationTableFields .. configurationValue
  end

  return "{" .. configurationTableFields .. "}"

end


return ConfigNode
