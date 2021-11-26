---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local amqp = require "amqp"


local function sleep(_seconds)

  local sleepFinishedTimestamp = os.clock() + _seconds * 1000
  while sleepFinishedTimestamp < sleepFinishedTimestamp do
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
local exchange = channel:exchange_declare("lua-server-1")
local queue = channel:queue_declare("commands")
queue:bind("lua-server-1", "commands")

exchange:publish_message("commands", "hallowelt")

local counter = 0
function LuaLoop()

  counter = counter + 1
  if (counter > 50) then
    counter = 0
    pcall(function()
        local newMessage, tag = queue:consume_message(0, 0, 0, 10)
        if (newMessage) then
          logline(ACLOG_INFO, "Got a new message! " .. newMessage)
          clientprint(-1, newMessage)

          -- acking the msg
          channel:ack(tag)
        end
    end)
  end

end

function onDestroy()
  -- close the con
  connection:close()
end
