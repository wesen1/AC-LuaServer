---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local cli = require 'cliargs'

cli:argument('', 'path to the input file')
cli:option('-o, --output=FILE', 'path to the output file', './a.out')
cli:flag('-q, --quiet', 'Suppress output.', true)

local result, errorMessage = cli:parse({"cmds", "test"})

print(result, errorMessage)
--for k, v in pairs(result) do
--  print(k, v)
--end
