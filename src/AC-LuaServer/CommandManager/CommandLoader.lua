---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ClassLoader = require("Util/ClassLoader")
local CommandList = require("CommandHandler/CommandList")

---
-- Loads all commands from a specified commands directory.
--
-- @type CommandLoader
--
local CommandLoader = setmetatable({}, {})


---
-- CommandLoader constructor.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
-- @treturn CommandLoader The CommandLoader instance
--
function CommandLoader:__construct()
  local instance = setmetatable({}, {__index = CommandLoader})
  return instance
end

getmetatable(CommandLoader).__call = CommandLoader.__construct


-- Public Methods

---
-- Loads all commands from a specified commands directory and returns a CommandList.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode for the CommandList
-- @tparam string _commandClassesDirectoryPath The path to the command classes directory
--
-- @treturn CommandList The command list that contains the loaded commands
--
function CommandLoader:loadCommands(_parentGemaMode, _commandClassesDirectoryPath)

  local commandList = CommandList(_parentGemaMode)

  -- Load all files whose names end with "Command.lua"
  local commandClasses = ClassLoader.loadClasses(_commandClassesDirectoryPath, "^.+Command.lua$")
  for _, commandClass in ipairs(commandClasses) do
    local commandInstance = commandClass()
    commandList:addCommand(commandInstance)
  end

  return commandList

end


return CommandLoader
