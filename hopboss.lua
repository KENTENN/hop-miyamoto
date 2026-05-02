local function myCustomFunction()
    getgenv().AutoTeleport = true
getgenv().DontTeleportTheSameNumber = true --If you set this true it won't teleport to the server if it has the same number of players as your current server
getgenv().CopytoClipboard = false

if not game:IsLoaded() then
    print("Game is loading waiting... | Amnesia Empty Server Finder")
    repeat
        wait()
    until game:IsLoaded()
    end

local maxplayers = math.huge
local serversmaxplayer;
local goodserver;
local gamelink = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"

function serversearch()
    for _, v in pairs(game:GetService("HttpService"):JSONDecode(game:HttpGetAsync(gamelink)).data) do
        if type(v) == "table" and maxplayers > v.playing then
            serversmaxplayer = v.maxPlayers
            maxplayers = v.playing
            goodserver = v.id
        end
    end
    print("Currently checking the servers with max this number of players : " .. maxplayers .. " | Amnesia Empty Server Finder")
end

function getservers()
    serversearch()
    for i,v in pairs(game:GetService("HttpService"):JSONDecode(game:HttpGetAsync(gamelink))) do
        if i == "nextPageCursor" then
            if gamelink:find("&cursor=") then
                local a = gamelink:find("&cursor=")
                local b = gamelink:sub(a)
                gamelink = gamelink:gsub(b, "")
            end
            gamelink = gamelink .. "&cursor=" ..v
            getservers()
        end
    end
end

getservers()

    print("All of the servers are searched") 
	print("Server : " .. goodserver .. " Players : " .. maxplayers .. "/" .. serversmaxplayer .. " | Amnesia Empty Server Finder")
    if CopytoClipboard then
    setclipboard(goodserver)
    end
    if AutoTeleport then
        if DontTeleportTheSameNumber then 
            if #game:GetService("Players"):GetPlayers() - 1 == maxplayers then
                return warn("It has same number of players (except you)")
            elseif goodserver == game.JobId then
                return warn("Your current server is the most empty server atm") 
            end
        end
        print("AutoTeleport is enabled. Teleporting to : " .. goodserver)
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, goodserver)
    end
end




-- getgenv().TargetBoss = "Miyamoto Musashi"


local function checkBossExists()
    -- ดึงค่าจาก getgenv ถ้าไม่มีให้ใช้ค่า Default เป็น Miyamoto Musashi
    local target = getgenv().TargetBoss or "Miyamoto Musashi"
    local isFound = false

    -- ค้นหาใน Workspace:GetDescendants() เพื่อความยืดหยุ่นตามโครงสร้างใน image_d0a23d.png
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        
        -- ตรวจสอบจาก Attributes ตามที่ปรากฏใน image_d0a23d.png
        local attrDisplayName = obj:GetAttribute("DisplayName")
        local attrMiniboss = obj:GetAttribute("Miniboss")
        
        -- ตรวจสอบจากชื่อ Object (รองรับกรณีชื่อมีจุดนำหน้าหรือรหัสสุ่มท้ายชื่อ)
        local objectName = obj.Name

        if (attrDisplayName == target) or (attrMiniboss == target) or (objectName:find(target)) then
            isFound = true
            print("Found Target: " .. obj:GetFullName() .. " (Matched by: " .. target .. ")")
            break 
        end
    end

    if not isFound then
        myCustomFunction()
    else
        print(target .. " is currently active.")
    end
end



while true do
    checkBossExists()
    wait(5) 
end
