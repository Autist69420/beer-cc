local modem_side = arg[1]

rednet.open(modem_side)
local inventory = require("inventory")
local json = require("../json")

rednet.send(0, "client_request")

while true do
    local barrels = inventory.getBarrels()
    for i = 1, #barrels do
        local barrel_id = barrels[i]:gsub("minecraft:barrel_", "")
        local inventory = inventory.getInventoryOfBarrelId(barrel_id)
        local msg = {
            client_id = os.getComputerID(),
            barrel_id = barrel_id,
            inventory = inventory
        }
        local msg_json = json.encode(msg)
        rednet.send(0, "JSON_BEER_SEND:" .. msg_json)
        print("sent")
    end
end