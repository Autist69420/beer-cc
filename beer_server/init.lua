local modem = peripheral.find("modem") or error("No modem attached", 0)
local json = require("../json")

local amount_of_clients = 0

modem.open(81)
print("Opened to port 81")

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    if channel == 81 then
        if tostring(message) == "client_request" then
            amount_of_clients = amount_of_clients + 1
            print("Client connected, amount of clients: " .. amount_of_clients)
        else
            local msg = tostring(message)
            local msg_json = json.decode(msg)
            
            local client_id = msg_json.client_id
            local barrel_id = msg_json.barrel_id
            local inventory = msg_json.inventory

            -- loop trough the inventory and check if the client has the item
            for i = 1, #inventory do
                local item_name = inventory[i].name
                local item_amount = inventory[i].count

                print(item_name, item_amount)
            end
        end
    end
end