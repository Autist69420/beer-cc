local modem = peripheral.find("modem") or error("No modem attached", 0)
local inventory = require("inventory")

modem.open(80)
print("Opened to port 80")

modem.transmit(81, 80, "client_request")

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    if channel == 80 then
        print("Received a reply: " .. tostring(message))
    end
end