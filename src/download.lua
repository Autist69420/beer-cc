-- Downloads the files, lmao

-- check if the json is file is there and if not download it
if not fs.exists("json.lua") then
    print("Downloading download.json")

    local JSON_URL = "https://raw.githubusercontent.com/Autist69420/beer-cc/main/src/json.lua"
    local ok, err = http.checkURL(JSON_URL)
    if not ok then
        print("Error: " .. err)
        return
    end

    local json_file, err = http.get(JSON_URL)
    if not json_file then
        print("Error: " .. err)
        return
    end

    local json_data = json_file.readAll()
    local file_handle = fs.open("json.lua", "w")
    file_handle.write(json_data)
    file_handle.close()
end

local json = require("json")

local to_download = arg[1]

local CLIENT_URL = "https://api.github.com/repos/Autist69420/beer-cc/contents/src/beer_client"
local SERVER_URL = "https://api.github.com/repos/Autist69420/beer-cc/contents/src/cbeer_server"
local BEER_FARM = "https://api.github.com/repos/Autist69420/beer-cc/contents/src/beer_farm"

if to_download == "client" then
    -- Download the client files
    local ok, err = http.checkURL(CLIENT_URL)
    if not ok then
        print("Error: " .. err)
        return
    end

    local request = http.get(CLIENT_URL)
    local client_files_json = json.decode(request.readAll())

    for i = 1, #client_files_json do
        local file_name = client_files_json[i].name
        local file_name_no_src = file_name:gsub("src/", "")
        local file_url = client_files_json[i].download_url
        local file_content = http.get(file_url)
        local file_content_str = file_content.readAll()
        local file_path = "beer_client/" .. file_name_no_src
        local file_handle = fs.open(file_path, "w")
        file_handle.write(file_content_str)
        file_handle.close()
    end

    print("Downloaded client.")
elseif to_download == "server" then
    -- Download the server files
    local ok, err = http.checkURL(SERVER_URL)
    if not ok then
        print("Error: " .. err)
        return
    end

    local request = http.get(SERVER_URL)
    local server_files_json = json.decode(request.readAll())

    for i = 1, #server_files_json do
        local file_name = server_files_json[i].name
        local file_url = server_files_json[i].download_url
        local file_content = http.get(file_url)
        local file_content_str = file_content.readAll()
        local file_path = "beer_server/" .. file_name
        local file_handle = fs.open(file_path, "w")
        file_handle.write(file_content_str)
        file_handle.close()
    end

    print("Downloaded server.")

elseif to_download == "farm" then
    -- Download the farm files
    local ok, err = http.checkURL(BEER_FARM)
    if not ok then
        print("Error: " .. err)
        return
    end

    local request = http.get(BEER_FARM)
    local farm_files_json = json.decode(request.readAll())

    for i = 1, #farm_files_json do
        local file_name = farm_files_json[i].name
        local file_url = farm_files_json[i].download_url
        local file_content = http.get(file_url)
        local file_content_str = file_content.readAll()
        local file_path = "beer_farm/" .. file_name
        local file_handle = fs.open(file_path, "w")
        file_handle.write(file_content_str)
        file_handle.close()
    end

    print("Downloaded farm.")
else
    print("Usage: download.lua <client|server|farm>")
    return
end
