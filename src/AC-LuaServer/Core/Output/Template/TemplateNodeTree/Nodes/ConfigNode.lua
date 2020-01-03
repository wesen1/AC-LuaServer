---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseTemplateNode = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.Nodes.BaseTemplateNode"
local loadstring = loadstring or load

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

  local configEntries = {}

  local getConfigValueFunction
  for configName, configValue in table.concat(self.innerTexts):gmatch("([%a_][%a%d_]*) *=([^;]+);") do

    getConfigValueFunction = loadstring("return " .. configValue)
    if (getConfigValueFunction) then
      configEntries[configName] = getConfigValueFunction()
    end

  end

  return configEntries

end


return ConfigNode
