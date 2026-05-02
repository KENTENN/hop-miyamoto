repeat task.wait() until game:IsLoaded(5)
getgenv().TargetBoss = getgenv().TargetBoss or "Miyamoto Musashi"

local function fastHop()
    print("--- เริ่มการบังคับย้ายเซิร์ฟเวอร์ (Force Hop) ---")
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId

    -- ดึงข้อมูลเซิร์ฟเวอร์แบบสุ่มหน้า (Random Page) เพื่อลดโอกาสเจอหน้าเดิม
    local sortOrder = (math.random(1, 2) == 1) and "Asc" or "Desc"
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=" .. sortOrder .. "&limit=100"

    local function search()
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if success and result and result.data then
            for _, server in ipairs(result.data) do
                -- เงื่อนไข: ไม่ใช่เซิร์ฟเวอร์เดิม และ คนไม่เต็ม
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    print("เจอเซิร์ฟเวอร์ใหม่แล้ว: " .. server.id)
                    TeleportService:TeleportToPlaceInstance(PlaceId, server.id)
                    return -- หยุดการทำงานทันทีที่เจอเพื่อวาร์ป
                end
            end
            
            -- ถ้าหน้าแรกไม่เจอ ให้ลองสุ่มไปหน้าถัดไปหนึ่งครั้ง
            if result.nextPageCursor then
                url = url .. "&cursor=" .. result.nextPageCursor
                task.wait(0.1)
                search()
            end
        else
            warn("ดึงข้อมูลเซิร์ฟเวอร์ไม่สำเร็จ กำลังลองใหม่...")
            task.wait(1)
            search()
        end
    end

    search()
end

local function checkBossExists()
    local target = getgenv().TargetBoss
    local isFound = false

    -- ตรวจสอบบอสจาก Attributes ตามภาพ image_d0a23d.png
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        local attrDisplayName = obj:GetAttribute("DisplayName")
        local attrMiniboss = obj:GetAttribute("Miniboss")
        
        if (attrDisplayName == target) or (attrMiniboss == target) or (obj.Name:find(target)) then
            isFound = true
            break 
        end
    end

    if not isFound then
        -- ถ้าไม่เจอ ให้เปลี่ยนเซิร์ฟเวอร์ทันที
        fastHop()
    else
        print(target .. " ยังอยู่ รอดำเนินการ...")
    end
end


task.spawn(function()
    while true do
        if not game:IsLoaded() then game.Loaded:Wait() end
        checkBossExists()
        task.wait(10)
    end
end)
