-- this will automatically farm wheat for the beer.

-- TODO?: Possiblely send the server a list of what the farm bot has.

local wheat_slot = 16
local wheat_stack = 64
local wheat_grown_age = 7

local wheat_seed_slot = 1
local wheat_seed_stack = 64

local inventory_slots_amount = 16

local switch = false

local function refuel()
    local old = turtle.getSelectedSlot()
    for i=1, inventory_slots_amount, 1 do
        turtle.select(i)
        turtle.refuel()
    end
    turtle.select(old)
    print("Attempted to refuel.")
end

local function fuckAllSeeds()
    local old = turtle.getSelectedSlot()
    for i=2, inventory_slots_amount, 1 do
        local item = turtle.getItemDetail(i)
        if item and item.name == "minecraft:wheat_seeds" then
            turtle.select(i)
            turtle.drop()
        end  
    end
    turtle.select(old)
end

local function checkForBlockInfront(block_id)
    local is_infront, infront = turtle.inspect()
    if is_infront and infront.name == block_id then
        return true
    end
    return false
end

local function harvest()
    while true do
        local ok, ins_down = turtle.inspectDown()
        local is_a_table = type(ins_down) == "table"

        if is_a_table and ins_down.name == "minecraft:wheat" then
            if ins_down.state.age == wheat_grown_age then
                local item = turtle.getItemDetail(wheat_slot)
                if item and item.count == wheat_stack then
                    wheat_slot = wheat_slot - 1
                end
                turtle.select(wheat_slot)
                turtle.digDown()
                turtle.select(wheat_seed_slot)
                turtle.placeDown()
                turtle.forward()
                print("Harvested weed")
            else
                turtle.forward()
            end
        else
            turtle.turnRight()
            local is_andesite = checkForBlockInfront("minecraft:andesite")
            turtle.turnLeft()
            
            if is_andesite then
                turtle.turnRight()
                turtle.turnRight()
                turtle.forward()
                main()
                return
            end

            -- turn right, go forwards, turn right, go forward
            if not switch then
                turtle.turnRight()
                turtle.forward()
                turtle.turnRight()
                turtle.forward()
                switch = true
            else
                turtle.turnLeft()
                turtle.forward()
                turtle.turnLeft()
                turtle.forward()
                switch = false
            end
        end
    end
end

local function main()
    refuel()
    fuckAllSeeds()
    
    harvest()
end

main()