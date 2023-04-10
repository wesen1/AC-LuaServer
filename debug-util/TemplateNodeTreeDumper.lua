
local OldClientOutputRenderer = require "AC-LuaServer.Core.Output.Template.Renderer.ClientOutputRenderer"

local ClientOutputRenderer = OldClientOutputRenderer:extend()


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

  local pretty = require "pl.pretty"
  pretty.dump(contentNode:toTable() or {})

  self:dumpNode(_parsedTemplate)


  return self.clientOutputFactory:getClientOutputTable(
    contentNode and contentNode:toTable() or {},
    configNode and configNode:toTable() or nil
  )
end

function ClientOutputRenderer:dumpNode(_node, _numTabs)

  local numTabs = _numTabs or 0
  local tab = "\t"

  for contentType, content in _node:innerContentsIterator() do

    if (contentType == "text") then
      print(tab:rep(numTabs) .. "text:" .. content)
    else
      print(tab:rep(numTabs) .. content:getName() .. ":")
      self:dumpNode(content, numTabs + 1)
    end

  end

end


return ClientOutputRenderer
