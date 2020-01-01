---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Provides additional table functions.
--
-- @type TableUtils
--
local TableUtils = Object:extend()


-- Public Methods

---
-- Returns whether a table contains a specific value.
--
-- @tparam table _table The table to search in
-- @tparam mixed _value The value to search for
--
-- @treturn bool True if the table contains the value, false otherwise
--
function TableUtils.tableHasValue(_table, _value)

  for _, value in pairs(_table) do
    if (value == _value) then
      return true
    end
  end

  return false

end


return TableUtils
