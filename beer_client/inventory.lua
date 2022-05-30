-- > inventory handler

return {
    getBarrels = function() 
        local barrels = peripheral.getNames()
        local actual_barrels = {}

        for i = 1, #barrels do
            if barrels[i]:find("barrel") then
                actual_barrels[#actual_barrels + 1] = barrels[i]
            end
        end

        return actual_barrels
    end,

    getInventoryOfBarrelId = function(id)
        local barrel = peripheral.wrap("minecraft:barrel_"..tostring(id)) or error("Barrel not found", 0)
        local inventory = barrel.list()
        return inventory
    end,
    
    getSlotOfBarrel = function(inv, slot)
        return inv[slot]
    end

    getBarrelTotalItems = function(inv)
        local total = 0
        for i = 1, #inv do
            local item = inv[i]
            total = total + item.count
        end
        return total
    end
}