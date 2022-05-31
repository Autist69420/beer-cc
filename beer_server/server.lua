local modem = arg[1]
rednet.open(modem)

-- surface api OwO
os.loadAPI("surface")

local json = require("../json")

local screen = peripheral.find("monitor") or error("No monitor attached", 0)
local x, y = screen.getSize()

local tab_bar = surface.create(x, 1, " ", colors.gray, colors.white)
local main_surf = surface.create(x, y, " ", colors.blue, colors.white)

tab_bar:drawText(1, 1, "Beer Server")
main_surf:drawText(1, 1, "Welcome to le epic beer server")

tab_bar:render(screen, 1, 1)
main_surf:render(screen, 1, 2)

while true do
    main_surf:drawText(1, 3, "- Current beer:")

    local id, msg = rednet.receive("BEER")
    local beerChests = json.decode(msg)
    
    for i, chest in pairs(beerChests) do
        local name = chest.name
        local count = chest.count
        local slots = chest.slots
        main_surf:drawText(2, 2 + i, "- " .. name .. ": " .. tostring(count) .. " (" .. tostring(slots) .. " slots)")
    end

    tab_bar:render(screen, 1, 1)
    main_surf:render(screen, 1, 2)
end
