---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local amqp = require "amqp"


local function sleep(_seconds)

  local sleepFinishedTimestamp = os.clock() + _seconds * 1000
  while os.clock() < sleepFinishedTimestamp do
    --nothing
  end

end


local connection
while (not connection)  do
  local callWasSuccessful, exception = pcall(function()
      connection = amqp.new({
          host = "message-broker"
      })
  end)

  if (not callWasSuccessful) then
    sleep(1)
  end
end


local channel = connection:open_channel()
local exchange = channel:exchange("lua-server-1")

exchange:publish_message("commands", "this is a test")

-- close the con
connection:close()
print("DONE")
