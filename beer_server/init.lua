local modem = arg[1]
rednet.open(modem)

local screen = require("screen")
local json = require("../json")

local amount_of_clients = 0
local beer_wind = screen.init()

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

        -- loop trough the inventory and check if the client has the item
        for i = 1, #inventory do
            local item_name = inventory[i].name
            local item_amount = inventory[i].count
            print(item_name, item_amount)
            beer_wind:addItem(item_name, item_amount)
        end
    end

    beer_wind:update()
end