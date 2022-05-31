-- > inventory handler

return {
    getChests = function() 
        local chests = peripheral.getNames()
        local actual_chests = {}

        for i = 1, #chests do
            if chests[i]:find("chest") then
                actual_chests[#actual_chests + 1] = chests[i]
            end
        end

        return actual_chests
    end,

    getInventoryByChestName = function(name)
        local chest = peripheral.wrap(name) or error("Chest not found", 0)
        local inventory = chest.list()
        return inventory
    end,

    getItemDetailByChestName = function(name, slot)
        local chest = peripheral.wrap(name) or error("Chest not found", 0)
        local detail = chest.getItemDetail(tonumber(slot))
        return detail
    end
}