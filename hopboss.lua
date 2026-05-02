local function myCustomFunction()
    -- ตั้งค่าสำหรับการเปลี่ยนเซิร์ฟเวอร์
    getgenv().AutoTeleport = true
    getgenv().DontTeleportTheSameNumber = true 
    getgenv().CopytoClipboard = false

    if not game:IsLoaded() then
        repeat task.wait() until game:IsLoaded()
    end

    local maxplayers = math.huge
    local serversmaxplayer
    local goodserver
    local gamelink = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"

    local function serversearch()
        local success, result = pcall(function()
            return game:GetService("HttpService"):JSONDecode(game:HttpGetAsync(gamelink))
        end)
        
        if success and result.data then
            for _, v in pairs(result.data) do
                if type(v) == "table" and v.playing and maxplayers > v.playing then
                    serversmaxplayer = v.maxPlayers
                    maxplayers = v.playing
                    goodserver = v.id
                end
            end
        end
    end

    local function getservers()
        serversearch()
        local success, result = pcall(function()
            return game:GetService("HttpService"):JSONDecode(game:HttpGetAsync(gamelink))
        end)
        
        if success and result.nextPageCursor then
            if gamelink:find("&cursor=") then
                local a = gamelink:find("&cursor=")
                gamelink = gamelink:sub(1, a - 1)
            end
            gamelink = gamelink .. "&cursor=" .. result.nextPageCursor
            getservers()
        end
    end

    print("Searching for an empty server...")
    getservers()

    if goodserver then
        if getgenv().AutoTeleport then
            if getgenv().DontTeleportTheSameNumber and #game:GetService("Players"):GetPlayers() - 1 == maxplayers then
                return warn("Server has same number of players. Staying here.")
            elseif goodserver == game.JobId then
                return warn("Already in the emptiest server.")
            end
            print("Teleporting to: " .. goodserver)
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, goodserver)
        end
    end
end

local function checkBossExists()
    local target = getgenv().TargetBoss
    local isFound = false

    -- ค้นหาผ่าน Descendants เพื่อรองรับชื่อแบบสุ่มในโฟลเดอร์ Live
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        -- ตรวจสอบผ่าน Attributes (DisplayName/Miniboss) ตามภาพ image_d0a23d.png
        local attrDisplayName = obj:GetAttribute("DisplayName")
        local attrMiniboss = obj:GetAttribute("Miniboss")
        
        if (attrDisplayName == target) or (attrMiniboss == target) or (obj.Name:find(target)) then
            isFound = true
            print("Target Found: " .. obj:GetFullName())
            break 
        end
    end

    if not isFound then
        print(target .. " not found. Executing Server Hop...")
        myCustomFunction()
    else
        print(target .. " is alive. Waiting...")
    end
end

-- ใช้ task.spawn เพื่อไม่ให้ลูปหลักค้างขณะรอเปลี่ยนเซิร์ฟเวอร์
task.spawn(function()
    while true do
        checkBossExists()
        task.wait(10) -- เพิ่มเวลาเป็น 10 วินาทีเพื่อลดภาระเครื่อง
    end
end)
