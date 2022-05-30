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

    local barrels = inventory.getBarrels()
    for i = 1 in #barrels do
        local barrel_id = barrels[i]:sub(11)
        local inventory = inventory.getInventoryOfBarrelId(barrel_id)
        local msg = {
            client_id = 1,
            barrel_id = barrel_id,
            inventory = inventory
        }
        local msg_json = json.encode(msg)
        modem.transmit(81, 80, msg_json)
    end
    end
end