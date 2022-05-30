local modem = arg[1]
local net = rednet.open(modem)

local screen = require("screen")
local json = require("../json")

local amount_of_clients = 0
local beer_wind = screen.init()

while true do
    local id, message = rednet.receive(nil, 5)

    if tostring(message) == "client_request" then
        amount_of_clients = amount_of_clients + 1
        print("Client connected, amount of clients: " .. amount_of_clients)
    elseif tostring("message"):find("JSON_BEER_SEND") then
        local msg = tostring(message)
        local msg_json = json.decode(msg:sub(15))
        
        local client_id = msg_json.client_id
        local barrel_id = msg_json.barrel_id
        local inventory = msg_json.inventory

        -- loop trough the inventory and check if the client has the item
        for i = 1, #inventory do
            local item_name = inventory[i].name
            local item_amount = inventory[i].count

            beer_wind.addItem(item_name, item_amount)
        end
    end

    beer_wind.update()
end