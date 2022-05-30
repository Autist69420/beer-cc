local beer_status = {index_x = 1, index_y = 1, items = {}}

function beer_status:init()
    local returned = {}
    local screen = peripheral.find("monitor") or error("No monitor attached", 0)
    local x, y = screen.getSize()
    screen.clear()

    local beer_status_window = window.create(screen, 1, 1, x, y)

    beer_status_window.setBackgroundColour(colours.blue)
    beer_status_window.setTextColour(colours.white)
    beer_status_window.clear()
    beer_status_window.write("Beer status", 1, 1)

    function returned.write(text, x)
        local _, y = beer_status_window.getCursorPos()
        beer_status_window.setCursorPos(x, y+1)
        beer_status_window.write(text)
    end

    function returned:update()
        beer_status_window.clear()
    
        for i = 1, #beer_status.items do
            local item = beer_status.items[i]
            returned.write("- " ..item.name .. ": " .. item.count, false, true)
        end
    end

    function returned:addItem(name, count) 
        -- check for duplicates
        for i = 1, #beer_status.items do
            local item = beer_status.items[i]
            if item.name == name then
                return
            end
        end

        local item = {
            name = name,
            count = count
        }

        beer_status.items[#beer_status.items + 1] = item
        print("Added item: " .. name .. ": " .. count)
    end

    return returned
end

return beer_status