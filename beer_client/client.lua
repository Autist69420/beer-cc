local modem_side = arg[1]

rednet.open(modem_side)
local inventory = require("inventory")
local json = require("../json")

rednet.send(0, "client_request")

while true do
    local beerChests = {}
    local chests = inventory.getChests()
    -- for i = 1, #barrels do
    --     local barrel_id = barrels[i]:gsub("minecraft:barrel_", "")
    --     local inventory = inventory.getInventoryOfBarrelId(barrel_id)
    --     local msg = {
    --         client_id = os.getComputerID(),
    --         barrel_id = barrel_id,
    --         inventory = inventory
    --     }
    --     local msg_json = json.encode(msg)
    --     rednet.send(0, "JSON_BEER_SEND:" .. msg_json)
    --     print("sent")
    -- end

    for _, chest in pairs(chests) do 
        -- inventory.getItemDetailByChestName(name, slot)
        local inv = inventory.getInventoryByChestName(chest)
        local slots = #inv
        local name = inventory.getItemDetailByChestName(chest, 1).displayName
        local count = 0
        
        for i, _ in pairs(inv) do
            local detail = inventory.getItemDetailByChestName(chest, i)
            count = count + detail.count
        end
        
        -- add to beerChests
        beerChests[#beerChests + 1] = {
            name = name,
            count = count,
            slots = slots
        }
    end
    
    rednet.send(0, json.encode(beerChests), "BEER")
    -- sleep for 5 second, we do not want it to send 2735429374 times a second
    os.sleep(5)
end