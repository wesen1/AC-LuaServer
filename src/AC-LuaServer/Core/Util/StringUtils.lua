---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Provides additional string functions.
--
-- @type StringUtils
--
local StringUtils = Object:extend()


-- Public Methods

---
-- Splits a string everytime the delimiter appears in it.
--
-- This function is based on the example from PeterPrade
-- @see http://lua-users.org/wiki/SplitJoin
--
-- @tparam string _text The string
-- @tparam string _delimiter The delimiter at which the string will be split
-- @tparam bool _keepEmptyTextParts If set to true empty text parts will be included in the result
--
-- @treturn string[] The splits
--
function StringUtils.split(_text, _delimiter, _keepEmptyTextParts)

  if (_delimiter == "") then
    return StringUtils.splitIntoCharacters(_text)

  else
    -- Split the string into words with the delimiter
    local text = _text
    local words = {}

    local stringPosition = 1
    local delimiterStartPosition, delimiterEndPosition, word
    repeat

      delimiterStartPosition, delimiterEndPosition = text:find(_delimiter, stringPosition)

      -- Get the next word
      if (delimiterStartPosition) then
        word = text:sub(stringPosition, delimiterStartPosition - 1)
        stringPosition = delimiterEndPosition + 1
      else
        word = text:sub(stringPosition)
      end

      if (_keepEmptyTextParts or word ~= "") then
        table.insert(words, word)
      end

    until (not delimiterStartPosition)

    return words

  end

end

---
-- Splits a string into a list of characters.
--
-- @tparam string _string The string
--
-- @treturn string[] The list of characters
--
function StringUtils.splitIntoCharacters(_string)

  local characters = {}
  for character in _string:gmatch(".") do
    table.insert(characters, character)
  end

  return characters

end


return StringUtils
