---
-- @author wesen
-- @copyright 2018-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local LuaRestyTemplateEngine = require "resty.template"
local Object = require "classic"
local Path = require "AC-LuaServer.Core.Path"
local path = require "pl.path"
local tablex = require "pl.tablex"

---
-- Renders template files as strings using the lua resty template engine.
--
-- Template tags are not parsed by this Renderer, it only renders lua resty template code and replaces
-- <whitespace> tags with corresponding strings.
-- Templates will be rendered as a single row, leading and trailing whitespace per line, empty lines
-- and line endings are removed.
--
-- @type StringRenderer
--
local StringRenderer = Object:extend()


---
-- The default template values that will be passed as arguments to the template renderer and may be accessed
-- in templates
--
-- @tfield mixed[] defaultTemplateValues
--
StringRenderer.defaultTemplateValues = nil

---
-- The list of template base directory paths
-- These will be the directories in which this class will search for "*.template" files
--
-- The default directory is "<src>/AC-LuaServer/Templates"
-- Any custom base directory will have a higher priority than the default directory
--
-- The paths must end with a "/"
--
-- @tfield string[] templateBaseDirectoryPaths
--
StringRenderer.templateBaseDirectoryPaths = nil

---
-- StringRenderer constructor.
--
function StringRenderer:new()
  self.defaultTemplateValues = {}
  self.templateBaseDirectoryPaths = {
    Path.getSourceDirectoryPath() .. "/AC-LuaServer/Templates/"
  }
end


---
-- Returns the absolute template path to a template file from a path that is relative to one of the
-- template base directories.
--
-- @tparam string _relativeTemplatePath The relative template path
--
-- @treturn string The absolute path to the template
--
function StringRenderer:getAbsoluteTemplatePath(_relativeTemplatePath)

  local templateFilePath
  for _, templateBaseDirectoryPath in ipairs(self.templateBaseDirectoryPaths) do
    templateFilePath = templateBaseDirectoryPath .. _relativeTemplatePath .. ".template"
    if (path.exists(templateFilePath)) then
      return templateFilePath
    end
  end

  return _relativeTemplatePath

end

-- Public Methods

---
-- Configures this StringRenderer.
--
-- @tparam table _configuration The configuration to apply
--
function StringRenderer:configure(_configuration)

  if (type(_configuration) == "table") then
    if (type(_configuration["defaultTemplateValues"]) == "table") then
      self.defaultTemplateValues = _configuration["defaultTemplateValues"]
    end

    if (type(_configuration["templateBaseDirectoryPaths"]) == "table") then

      -- Copy the configuration table and cast all values to strings
      local templateBaseDirectoryPaths = tablex.map(
        function(_value)
          return tostring(_value)
        end,
        _configuration["templateBaseDirectoryPaths"]
      )

      -- Append the default template base directory paths to the end of the new list
      tablex.insertvalues(templateBaseDirectoryPaths, self.templateBaseDirectoryPaths)

      self.templateBaseDirectoryPaths = templateBaseDirectoryPaths
    end

  end

end

---
-- Renders a template and returns the rendered string.
--
-- @tparam Template _template The template to render
--
-- @treturn string The rendered template
--
function StringRenderer:render(_template)
  local renderedTemplateString = self:renderTemplate(_template)
  return self:normalizeRenderedTemplate(renderedTemplateString)
end


-- Private Methods

---
-- Renders a template using the lua resty template engine.
--
-- @tparam Template _template The template
--
-- @treturn string The rendered template string
--
function StringRenderer:renderTemplate(_template)

  -- Prepare the template values
  local templateValues = {
    ["getAbsoluteTemplatePath"] = function(_relativeTemplatePath)
      return self:getAbsoluteTemplatePath(_relativeTemplatePath)
    end
  }

  -- Apply the default values
  for templateValueName, templateValue in pairs(self.defaultTemplateValues) do
    templateValues[templateValueName] = templateValue
  end

  -- Apply the Template's template values
  for templateValueName, templateValue in pairs(_template:getTemplateValues()) do
    templateValues[templateValueName] = templateValue
  end


  -- Prepare the template
  local absoluteTemplatePath = self:getAbsoluteTemplatePath(_template:getTemplatePath())
  local compiledTemplate = LuaRestyTemplateEngine.compile(absoluteTemplatePath)

  -- Render the template
  return compiledTemplate(templateValues)

end

---
-- Normalizes a rendered template string.
-- This includes whitespace trimming and replacing special tags.
--
-- @tparam string _renderedTemplateString The rendered template string
--
-- @treturn string The normalized template string
--
function StringRenderer:normalizeRenderedTemplate(_renderedTemplateString)

  -- Remove empty lines, leading and trailing whitespace per line and line breaks
  local renderedTemplateString = _renderedTemplateString:gsub(" *\n+ *", "")

  -- Remove leading whitespace from the total string
  renderedTemplateString = renderedTemplateString:gsub("^ +", "")

  -- Remove trailing whitespace from the total string
  renderedTemplateString = renderedTemplateString:gsub(" +$", "")

  -- Find and replace <whitespace> tags
  renderedTemplateString = renderedTemplateString:gsub(
    "< *whitespace[^>]*>",
    function(_whitespaceTagString)
      return self:getWhitespaceTagReplacement(_whitespaceTagString)
    end
  )

  return renderedTemplateString

end

---
-- Returns the corresponding replacement for a whitespace tag.
--
-- @tparam string _whitespaceTagString The whitespace tag string
--
-- @treturn string The corresponding number of whitespaces
--
function StringRenderer:getWhitespaceTagReplacement(_whitespaceTagString)

  local numberOfWhitespaceCharacters = 1

  -- Check the defined number of whitespace characters (the number behind "whitespace:")
  local definedNumberOfWhitespaceCharactersString = _whitespaceTagString:match(":(%d)")
  if (definedNumberOfWhitespaceCharactersString ~= nil) then
    local definedNumberOfWhitespaceCharacters = tonumber(definedNumberOfWhitespaceCharactersString)
    if (definedNumberOfWhitespaceCharacters > numberOfWhitespaceCharacters) then
      numberOfWhitespaceCharacters = definedNumberOfWhitespaceCharacters
    end
  end

  return string.rep(" ", numberOfWhitespaceCharacters)

end


return StringRenderer
