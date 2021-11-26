---
-- @author wesen
-- @copyright 2017-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Handles loading of the color configuration.
--
-- @type ColorLoader
--
local ColorLoader = Object:extend()


---
-- The name of the lua configuration file for colors
--
-- @tfield string colorConfigFileName
--
ColorLoader.colorConfigFileName = nil


---
-- ColorLoader constructor.
--
-- @tparam string _colorConfigFileName The name of the lua configuration file for colors
--
function ColorLoader:new(_colorConfigFileName)
  self.colorConfigFileName = _colorConfigFileName
end


-- Public Methods

---
-- Returns the colors from the configured color config file.
--
-- @treturn string[] The colors
--
function ColorLoader:getColors()

  local colorConfiguration = cfg.totable(self.colorConfigFileName)

  local colors = {}
  for colorName, colorId in pairs(colorConfiguration) do
    colors[colorName] = "\f" .. colorId
  end

  return colors

end


return ColorLoader
