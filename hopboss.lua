repeat task.wait() until game:IsLoaded(5)
getgenv().TargetBoss = getgenv().TargetBoss or "Miyamoto Musashi"

local function instantHop()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId

    print("--- กำลังสุ่มเซิร์ฟเวอร์เพื่อวาร์ปทันที ---")
    
    -- ใช้การสุ่มลำดับ Asc/Desc เพื่อหนีหน้าเดิม
    local sortOrder = (math.random(1, 2) == 1) and "Asc" or "Desc"
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=" .. sortOrder .. "&limit=50"

    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if success and result and result.data then
        local serverList = {}
        for _, server in ipairs(result.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                table.insert(serverList, server.id)
            end
        end

        if #serverList > 0 then
            -- สุ่มเลือกจากรายการที่หาได้ในหน้าแรกเพื่อความไว
            local randomServer = serverList[math.random(1, #serverList)]
            print("พบเซิร์ฟเวอร์เป้าหมาย: " .. randomServer)
            TeleportService:TeleportToPlaceInstance(PlaceId, randomServer)
        else
            -- ถ้าไม่เจอเลย ให้ลองสุ่มวาร์ปแบบสุ่มดวง (Random Join)
            print("ไม่พบเซิร์ฟเวอร์ว่างในหน้าแรก กำลังใช้ระบบสำรอง...")
            TeleportService:Teleport(PlaceId)
        end
    else
        warn("HTTP Error: อาจโดน Rate Limit ให้รอสักครู่...")
        task.wait(2)
        TeleportService:Teleport(PlaceId) -- บังคับสุ่มวาร์ปผ่านระบบหลักของ Roblox
    end
end

local function checkBossExists()
    local target = getgenv().TargetBoss
    local isFound = false

    -- เช็คบอสจาก Attributes (อ้างอิงจาก image_d0a23d.png)
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        local attrDisplayName = obj:GetAttribute("DisplayName")
        local attrMiniboss = obj:GetAttribute("Miniboss")
        
        if (attrDisplayName == target) or (attrMiniboss == target) or (obj.Name:find(target)) then
            isFound = true
            break 
        end
    end

    if not isFound then
        print("ไม่พบ " .. target .. " กำลังย้ายเซิร์ฟเวอร์...")
        instantHop()
    else
        print(target .. " ยังมีชีวิตอยู่.")
    end
end

-- ตั้งเวลาตรวจสอบให้ช้าลงเพื่อไม่ให้โดน Rate Limit
task.spawn(function()
    while true do
        if not game:IsLoaded() then game.Loaded:Wait() end
        checkBossExists()
        task.wait(10) 
    end
end)
