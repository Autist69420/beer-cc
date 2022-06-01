local modem_side = arg[1]
local monitor = arg[2] or "top"

local monitor_wrapped = peripheral.wrap(monitor)

rednet.open(modem_side)
local inventory = require("inventory")
local json = require("../json")

while true do
    monitor_wrapped.clear()
    monitor_wrapped.setCursorPos(1, 1)
    monitor_wrapped.write("Beer client is running...")
    monitor_wrapped.setCursorPos(1, 2)
    monitor_wrapped.write("Computer ID: " .. tostring(os.getComputerID()))

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
