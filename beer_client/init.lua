local modem = peripheral.find("modem") or error("No modem attached", 0)
local inventory = require("inventory")
local json = require("../json")

modem.open(80)
print("Opened to port 80")

modem.transmit(81, 80, "client_request")

while true do
    local barrels = inventory.getBarrels()
    for i = 1, #barrels do
        local barrel_id = barrels[i]:sub(18)
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