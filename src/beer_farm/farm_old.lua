function goHome()
    turtle.turnRight() 
    local ok, ins = turtle.inspect()
    turtle.turnLeft()
    if ins.name == "minecraft:andesite" then 
        turtle.turnRight()
        turtle.turnRight()
        turtle.forward()
        for i=1, 16, 1 do
            turtle.select(i)
            turtle.refuel()
        end
        os.sleep(40)
        harvestRow()    
    end
    local c = false
    while true do
        local ok, ins_down = turtle.inspectDown()
        
        print(ok)
        if not ok and not c then 
            c = true
            --return
            turtle.back()
            turtle.turnRight()
            turtle.forward()
            turtle.turnLeft()
        elseif not ok then
            turtle.forward() 
            harvestRow()
        end
        turtle.back()
    end
    turtle.forward()
    harvestRow()
end

function harvestRow() 
    local c = true
    while c do
        local ok, ins_down = turtle.inspectDown()
        --print(ok, ins_down, type(ins_down))
        if type(ins_down) == "string" then
            c = false
            
            goHome()
            return            
        end
        
        if ins_down.state.age == 7 then
            turtle.select(16)
            turtle.digDown()
            turtle.select(1)
            turtle.placeDown()
            turtle.forward()
            print("dug el weed")
        elseif ins_down.state.age < 7 then
            turtle.forward()
            print("no weed")
        end
    end
end

harvestRow()