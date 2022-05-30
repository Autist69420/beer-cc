-- Downloads the files, lmao

local json = require("json")

local to_download = arg[1]

local CLIENT_URL = "https://api.github.com/repos/Autist69420/beer-cc/contents/beer_client"
local SERVER_URL = "https://api.github.com/repos/Autist69420/beer-cc/contents/beer_server"

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
        local file_url = client_files_json[i].download_url
        local file_content = http.get(file_url)
        local file_content_str = file_content.readAll()
        local file_path = "beer_client/" .. file_name
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
else
    error("Invalid argument, either choose from 'client' or 'server'", 0)
    exit()
end