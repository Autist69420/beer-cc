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

    returned.window = beer_status_window

    function returned.write(text, should_update_x, should_update_y)
        if should_update_y then
            beer_status.index_y = beer_status.index_y + y + 1
        end

        beer_status_window.setCursorPos(beer_status.index_x, beer_status.index_y)
        beer_status_window.write(text)
    end

    function returned.update()
        beer_status_window.clear()
    
        for i = 1, #beer_status.items do
            local item = beer_status.items[i]
            self.write("- " ..item.name .. ": " .. item.count, false, true)
        end
    end

    function returned.addItem(name, count) 
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

        self.items[#self.items + 1] = item
        print("Added item: " .. name .. ": " .. count)
    end

    return returned
end

return beer_status