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

local tab_bar = surface.create(x, 1, " ", colors.gray, colors.white)
local main_surf = surface.create(x, y, " ", colors.blue, colors.white)

tab_bar:drawText(1, 1, "Beer Server")
main_surf:drawText(1, 1, "Welcome to le epic beer server")

tab_bar:render(screen, 1, 1)
main_surf:render(screen, 1, 2)

while true do
    main_surf:drawText(1, 3, "- Current beer:")

    local id, msg = rednet.receive()
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

