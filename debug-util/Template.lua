-- Public Methods


function Template:dumpNode(_node, _numTabs)

  local numTabs = _numTabs or 0
  local textNumber = 0
  local nodeNumber = 0
  local tab = "\t"

  for _, contentType in ipairs(_node.innerContents) do

    if (contentType == "text") then
      textNumber = textNumber + 1
      print(tab:rep(numTabs) .. "text:" .. _node.innerTexts[textNumber])
    else
      nodeNumber = nodeNumber + 1
      local node = _node.innerNodes[nodeNumber]
      print(tab:rep(numTabs) .. node:getName() .. ":")
      self:dumpNode(node, numTabs + 1)
    end

  end

end
