local modem = arg[1]
rednet.open(modem)

-- surface api OwO
os.loadAPI("surface")
-- surface.create(width, height, char, backcolor, textcolor)
-- surf:drawText(x, y, text, backcolor, textcolor)
-- surf:drawRect(x1, y1, x2, y2, char, backcolor, textcolor
-- surf:drawRoundRect(x1, y1, x2, y2, char, backcolor, textcolor)
-- surf:fillRoundedRect(x1, y1, x2, y2, radius, char, backcolor, textcolor)
-- surface.render(surface, display, x, y, sx1, sy1, sx2, sy2)

local json = require("../json")

local screen = peripheral.find("monitor") or error("No monitor attached", 0)
local x, y = screen.getSize()

local tab_bar = surface.create(x, 2, " ", colors.gray, colors.white)
local main_surf = surface.create(x, y, " ", colors.blue, colors.white)

tab_bar:drawText(1, 1, "Beer Server")
main_surf:drawText(1, 1, "Welcome to le epic beer server")

main_surf:drawText(1, 3, "- Current beer:")
main_surf:drawText(2, 4, "- Miner's Pale Ale: 5")

tab_bar:render(screen, 1, 1)
main_surf:render(screen, 1, 3)

--[[
while true do
    local id, message = rednet.receive(nil, 5)

    if tostring(message) == "client_request" then
        amount_of_clients = amount_of_clients + 1
        print("Client connected, amount of clients: " .. amount_of_clients)
    elseif string.find(tostring(message), "JSON_BEER_SEND") then
        local msg = string.gsub(tostring(message), "JSON_BEER_SEND:", "")
        local msg_json = json.decode(msg)
        
        local client_id = msg_json.client_id
        local barrel_id = msg_json.barrel_id
        local inventory = msg_json.inventory
        
        local same_items_count = 0
        local same_items_name = ""

        -- loop trough the inventory and check if the client has the item
        for i = 1, #inventory do
            local item_name = inventory[i].name
            local item_amount = inventory[i].count

            same_items_count = same_items_count + item_amount
            same_items_name = item_name
        end

        beer_wind:addItem(same_items_name, same_items_count)
    end

    beer_wind:update()
end
]]
