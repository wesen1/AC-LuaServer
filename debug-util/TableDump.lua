function TableRenderer:printTable(_table, _indent)

  local indent = " ";
  if (_indent) then
    indent = _indent;
  end

  for k, v in ipairs(_table) do
    print(indent .. "[" .. k .. "] = ");
    if (type(v) == "table") then
      print(indent .. "{");
      self:printTable(v, indent .. "   ");
      print(indent .. "}");
    else
      print(indent .. "'" .. v:gsub("(%\f[A-Za-z0-9])", "") .. "'");
    end
  end

end