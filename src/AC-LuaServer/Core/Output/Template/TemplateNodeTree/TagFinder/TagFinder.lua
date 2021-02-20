---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"
local TemplateTag = require "AC-LuaServer.Core.Output.Template.TemplateNodeTree.TagFinder.TemplateTag"

---
-- Searches strings for tags and provides methods to get the next tags.
--
-- @type TagFinder
--
local TagFinder = Object:extend()


---
-- The list of available tag patterns and their corresponding names
--
-- @tfield string[] tagPatterns
--
TagFinder.tagPatterns = {
  { tagName = "config", pattern = "##+%[ *CONFIG *]#*;" },
  { tagName = "end-config", pattern = "##+%[ *ENDCONFIG *]#*;" },
  { tagName = "custom-field", pattern = "|?%-%-+%[ *FIELD *]%-*;" },
  { tagName = "end-custom-field", pattern = "|?%-%-+%[ *ENDFIELD *]%-*;" },
  { tagName = "row", pattern = "|?__+;" },
  { tagName = "row-field", pattern = "|?%-%-+;" }
}


-- Cache

---
-- The cached template tags that were found before they were the closest tag
-- This list is in the format { ["tagName"] = TemplateTag, ... }
--
-- @tfield TemplateTag[] nextTags
--
TagFinder.nextTags = nil

---
-- The last string that was searched by this TagFinder
-- This is used to check whether the TagFinder can use the cached next tags
--
-- @tfield string lastSearchText
--
TagFinder.lastSearchText = nil


---
-- TagFinder constructor.
--
function TagFinder:new()
  self.nextTags = {}
end


-- Public Methods

---
-- Finds and returns the next tag.
--
-- @tparam string _text The text to search for tags
-- @tparam int _textPosition The start position inside the text to start the search at
--
-- @treturn TemplateTag|nil The next tag or nil if no tag was found
--
function TagFinder:findNextTag(_text, _textPosition)

  local closestNextTemplateTag
  local nextTagPatternTemplateTag
  for _, tagPattern in ipairs(self.tagPatterns) do

    nextTagPatternTemplateTag = self:getNextTagForPattern(
      _text, _textPosition, tagPattern["tagName"], tagPattern["pattern"]
    )
    if (nextTagPatternTemplateTag ~= false and
         (closestNextTemplateTag == nil or
          nextTagPatternTemplateTag:getStartPosition() < closestNextTemplateTag:getStartPosition())) then
      closestNextTemplateTag = nextTagPatternTemplateTag
    end

  end

  if (closestNextTemplateTag ~= nil) then
    -- Remove the cached next tag position of the current closest tag
    self.nextTags[closestNextTemplateTag:getName()] = nil
  end

  return closestNextTemplateTag

end


-- Private Methods

---
-- Returns the next tag for a specified tag pattern inside a text.
--
-- @tparam string _text The text to search for the tag pattern
-- @tparam int _textPosition The start position inside the text
-- @tparam string _tagName The tag name
-- @tparam string _tagPattern The tag pattern
--
-- @treturn TemplateTag|bool The next tag or false if there are no more tags of this tag type inside the text
--
function TagFinder:getNextTagForPattern(_text, _textPosition, _tagName, _tagPattern)

  local nextTemplateTag = self:getCachedTagForPattern(_text, _textPosition, _tagName)
  if (nextTemplateTag == nil) then

    -- Search for the start and end position of the next tag with the pattern
    local nextTagStartPosition, nextTagEndPosition = _text:find(_tagPattern, _textPosition)
    if (nextTagStartPosition == nil) then
      nextTemplateTag = false
    else
      nextTemplateTag = TemplateTag(_tagName, nextTagStartPosition, nextTagEndPosition)
    end

    -- Cache the tag
    self.nextTags[_tagName] = nextTemplateTag

  end

  return nextTemplateTag

end

---
-- Returns the cached next tag for a specified tag pattern inside a text and clears the cache if necessary.
-- Will return false if there is no next occurrence of the specific tag type.
--
-- @tparam string _text The text that is searched for tags
-- @tparam int _textPosition The start position inside the text
-- @tparam string _tagName The tag name
--
-- @treturn TemplateTag|bool|nil The cached tag or nil if there is no cached next tag
--
function TagFinder:getCachedTagForPattern(_text, _textPosition, _tagName)

  if (_text == self.lastSearchText) then

    local cachedTemplateTag = self.nextTags[_tagName]
    if (cachedTemplateTag == false or cachedTemplateTag == nil or cachedTemplateTag:getStartPosition() >= _textPosition) then
      return cachedTemplateTag
    else
      self.nextTags[_tagName] = nil
    end

  else
    -- The last search text differs from the current search text
    -- Therefore all previous cached values must be cleared as they do not reference the same search
    self.lastSearchText = _text
    self.nextTags = {}
  end

end


return TagFinder
