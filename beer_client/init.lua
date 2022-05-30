local modem = peripheral.getName("modem")
local modem_side = arg[1]

local net = rednet.open(modem_side)
local inventory = require("inventory")
local json = require("../json")

if modem_side then
    net.send(0, "client_request")

    while true do
        local barrels = inventory.getBarrels()
        for i = 1, #barrels do
            local barrel_id = barrels[i]:sub(18)
            local inventory = inventory.getInventoryOfBarrelId(barrel_id)
            local msg = {
                client_id = os.getComputerID(),
                barrel_id = barrel_id,
                inventory = inventory
            }
            local msg_json = json.encode(msg)
            net.send(0, "JSON_BEER_SEND:" .. msg_json)
            print("sent")
        end
    end
else
    error("Invalid side or no side given")
end
