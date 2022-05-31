local modem_side = arg[1]

rednet.open(modem_side)
local inventory = require("inventory")
local json = require("../json")

while true do
    local beerChests = {}
    local chests = inventory.getChests()

    for _, chest in pairs(chests) do 
        -- inventory.getItemDetailByChestName(name, slot)
        local inv = inventory.getInventoryByChestName(chest)
        local slots = #inv
        if slots > 0 then
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
    end
    
    rednet.send(0, json.encode(beerChests), "BEER")
    print("Sent beer chests")
    -- sleep for 1 second, we do not want it to send 2735429374 times a milisecond
    os.sleep(1)
end