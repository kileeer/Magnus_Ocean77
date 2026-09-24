-- ===== НАСТРОЙКИ =====
local LOAD_WAIT  = 10   -- прогрузка после захода (сек)
local EVENT_WAIT = 6    -- пауза после ТП в ивент (сек)
local TP_SETTLE  = 0.5  -- пауза после ТП на точку фарма (сек)
local DELAY      = 0.3  -- пауза после бомбы (сек)
local FIRST_TP_WAIT = 1 -- пауза после ПЕРВОГО ТП (сек) — только 1 раз
-- =====================

-- =====================
-- ===== ПЛАТФОРМА =====
-- =====================
local UIS = game:GetService("UserInputService")
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- =====================
-- ===== ТОЧКИ ИВЕНТА ПО МИРАМ =====
-- =====================
local WORLD_SPOTS = {
    [8737899170]      = {name = "Мир 1 (Map)",  pos = Vector3.new(179.04, 16.24, -142.15)},
    [16498369169]     = {name = "Мир 2 (Map2)", pos = Vector3.new(-9954.08, 16.54, -287.74)},
    [17503543197]     = {name = "Мир 3 (Map3)", pos = Vector3.new(-10256.35, 4.17, -7300.98)},
    [140403681187145] = {name = "Мир 4 (Map4)", pos = Vector3.new(-15848.54, 39.92, -193.16)},
}

-- =====================
-- ===== ТОЧКИ ФАРМА (X, Z) =====
-- =====================
local topLayer = {
    {5257.03, -8081.24},
    {5273.52, -8081.50},
    {5287.39, -8081.79},
    {5301.26, -8081.82},
    {5318.57, -8082.13},
    {5327.37, -8083.18},
    {5328.37, -8097.26},
    {5312.77, -8097.05},
    {5297.21, -8096.84},
    {5283.34, -8096.65},
    {5267.78, -8096.44},
    {5253.91, -8096.26},
    {5257.02, -8111.70},
    {5270.89, -8111.82},
    {5286.49, -8112.03},
    {5286.88, -8130.85},
    {5302.09, -8112.25},
    {5317.70, -8112.46},
    {5326.37, -8112.58},
    {5321.34, -8127.49},
    {5309.25, -8126.51},
    {5293.65, -8126.62},
    {5276.34, -8126.54},
    {5262.47, -8126.48},
    {5253.80, -8126.45},
    {5257.11, -8141.37},
    {5270.98, -8142.05},
    {5286.55, -8142.82},
    {5302.16, -8142.82},
    {5317.73, -8142.82},
    {5326.40, -8142.82},
}

-- =====================
-- ===== СЛОИ БОМБ =====
-- =====================
-- { Y, {pc = "ID_PC", mobile = "ID_MOB"}, цвет }
local layers = {
    {16.25,
        {pc = "f20900f76ddf4996a49ceef24dae9ea1", mobile = "a1da7eacd6d6418ca905c1d0fda160e7"},
        Color3.fromRGB(0, 220, 0)},       -- 🟢 Зелёный

    {-183,
        {pc = "5784e1982d0a413884cc69347181b1f9", mobile = "cceefe8e9c77451fa233784980489fc1"},
        Color3.fromRGB(255, 220, 0)},     -- 🟡 Жёлтый

    {-283.75,
        {pc = "5784e1982d0a413884cc69347181b1f9", mobile = "cceefe8e9c77451fa233784980489fc1"},
        Color3.fromRGB(255, 220, 0)},     -- 🟡 Жёлтый

    {-384.77,
        {pc = "5784e1982d0a413884cc69347181b1f9", mobile = "cceefe8e9c77451fa233784980489fc1"},
        Color3.fromRGB(255, 220, 0)},     -- 🟡 Жёлтый
}

-- =====================
-- ===== ГУИ: АВАТАР B1ZE =====
-- =====================
local OWNER_USER_ID   = 11205845971
local LINE_1          = "[B1ZE]"
local LINE_2          = "By Magnus_Ocean77"
local BG_COLOR        = Color3.fromRGB(20, 30, 60)
local BG_TRANSPARENCY = 0.4
local AVATAR_SIZE     = 200

local gui = Instance.new("ScreenGui")
gui.Name = "AvatarGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = game.CoreGui

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = BG_COLOR
bg.BackgroundTransparency = BG_TRANSPARENCY
bg.BorderSizePixel = 0
bg.ZIndex = 1
bg.Parent = gui

local container = Instance.new("Frame")
container.Size = UDim2.new(0, AVATAR_SIZE, 0, AVATAR_SIZE + 100)
container.Position = UDim2.new(0.5, -AVATAR_SIZE/2, 0.5, -(AVATAR_SIZE + 100)/2)
container.BackgroundTransparency = 1
container.ZIndex = 2
container.Parent = gui

local img = Instance.new("ImageLabel")
img.Size = UDim2.new(0, AVATAR_SIZE, 0, AVATAR_SIZE)
img.BackgroundTransparency = 1
img.Image = "rbxthumb://type=AvatarHeadShot&id=" .. OWNER_USER_ID .. "&w=420&h=420"
img.ScaleType = Enum.ScaleType.Fit
img.ZIndex = 3
img.Parent = container

local line1 = Instance.new("TextLabel")
line1.Size = UDim2.new(1, 0, 0, 50)
line1.Position = UDim2.new(0, 0, 0, AVATAR_SIZE + 5)
line1.BackgroundTransparency = 1
line1.Text = LINE_1
line1.TextColor3 = Color3.fromRGB(255, 255, 255)
line1.TextStrokeTransparency = 0
line1.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
line1.Font = Enum.Font.GothamBlack
line1.TextScaled = true
line1.ZIndex = 3
line1.Parent = container

local sizeC1 = Instance.new("UITextSizeConstraint")
sizeC1.MaxTextSize = 45
sizeC1.MinTextSize = 25
sizeC1.Parent = line1

local line2 = Instance.new("TextLabel")
line2.Size = UDim2.new(1, 0, 0, 28)
line2.Position = UDim2.new(0, 0, 0, AVATAR_SIZE + 55)
line2.BackgroundTransparency = 1
line2.Text = LINE_2
line2.TextColor3 = Color3.fromRGB(180, 200, 255)
line2.TextStrokeTransparency = 0.6
line2.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
line2.Font = Enum.Font.GothamBold
line2.TextScaled = true
line2.ZIndex = 3
line2.Parent = container

local sizeC2 = Instance.new("UITextSizeConstraint")
sizeC2.MaxTextSize = 22
sizeC2.MinTextSize = 12
sizeC2.Parent = line2

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 110, 0, 32)
btn.Position = UDim2.new(1, -120, 0, 10)
btn.BackgroundColor3 = Color3.fromRGB(10, 15, 30)
btn.BorderSizePixel = 0
btn.Text = "👁 Скрыть"
btn.TextColor3 = Color3.fromRGB(150, 200, 255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 13
btn.ZIndex = 5
btn.Parent = gui
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 150, 255)
stroke.Thickness = 1
stroke.Parent = btn

local visible = true
btn.MouseButton1Click:Connect(function()
    visible = not visible
    bg.Visible = visible
    container.Visible = visible
    btn.Text = visible and "👁 Скрыть" or "👁 Показать"
end)

-- =====================
-- ===== ПРОГРЕСС-БАР =====
-- =====================
local progressBg = Instance.new("Frame")
progressBg.Size = UDim2.new(0, 400, 0, 30)
progressBg.Position = UDim2.new(0.5, -200, 1, -50)
progressBg.BackgroundColor3 = Color3.fromRGB(10, 15, 30)
progressBg.BackgroundTransparency = 0.2
progressBg.BorderSizePixel = 0
progressBg.ZIndex = 5
progressBg.Parent = gui
Instance.new("UICorner", progressBg).CornerRadius = UDim.new(0, 8)

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
progressFill.BorderSizePixel = 0
progressFill.ZIndex = 6
progressFill.Parent = progressBg
Instance.new("UICorner", progressFill).CornerRadius = UDim.new(0, 8)

local progressText = Instance.new("TextLabel")
progressText.Size = UDim2.new(1, 0, 1, 0)
progressText.BackgroundTransparency = 1
progressText.Text = "0%"
progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
progressText.TextStrokeTransparency = 0.5
progressText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
progressText.Font = Enum.Font.GothamBold
progressText.TextSize = 14
progressText.ZIndex = 7
progressText.Parent = progressBg

local function updateProgress(current, total, layerColor)
    local percent = math.floor((current / total) * 100)
    progressFill.Size = UDim2.new(percent / 100, 0, 1, 0)
    if layerColor then
        progressFill.BackgroundColor3 = layerColor
    end
    progressText.Text = percent .. "% (" .. current .. "/" .. total .. ")"
end

-- =====================
-- ===== ЛОГИКА =====
-- =====================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local running = false

local Network = ReplicatedStorage:WaitForChild("Network")
local ConsumablesEvent = Network:WaitForChild("Consumables_Consume")

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function teleportTo(pos)
    local hrp = getHRP()
    if not hrp then return end
    hrp.Velocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero
    hrp.CFrame = CFrame.new(pos)
end

-- 🧨 Бомба с учётом платформы
local function useBomb(bombData)
    local id = isMobile and bombData.mobile or bombData.pc
    pcall(function()
        ConsumablesEvent:InvokeServer(id, 1)
    end)
end

-- ===== ОПРЕДЕЛЕНИЕ МИРА =====
local function goToWorldSpot()
    local placeId = game.PlaceId
    local spot = WORLD_SPOTS[placeId]
    if not spot then return false end
    teleportTo(spot.pos)
    return true
end

local function farm()
    running = true

    local totalSteps = #layers * #topLayer
    local currentStep = 0
    local firstTpDone = false

    updateProgress(0, totalSteps)

    for _, layer in ipairs(layers) do
        if not running then break end
        local y = layer[1]
        local bombData = layer[2]
        local layerColor = layer[3]

        for i, t in ipairs(topLayer) do
            if not running then break end
            if not getHRP() then task.wait(0.5) end

            local pos = Vector3.new(t[1], y, t[2])
            teleportTo(pos)

            currentStep = currentStep + 1
            updateProgress(currentStep, totalSteps, layerColor)

            -- Пауза 1 сек после первого ТП
            if not firstTpDone and t[1] == 5257.03 and t[2] == -8081.24 then
                firstTpDone = true
                task.wait(FIRST_TP_WAIT)
            end

            task.wait(TP_SETTLE)
            useBomb(bombData)
            task.wait(DELAY)
        end
    end

    running = false
    updateProgress(totalSteps, totalSteps)
end

-- ===== СЕРВЕРХОП =====
local function serverHop()
    local PlaceID = game.PlaceId
    local AllIDs = {}
    local foundAnything = ""
    local actualHour = os.date("!*t").hour
    local File = pcall(function()
        AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
    end)
    if not File then
        table.insert(AllIDs, actualHour)
        writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
    end

    local function TPReturner()
        local Site
        if foundAnything == "" then
            Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
        else
            Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
        end
        local ID = ""
        if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
            foundAnything = Site.nextPageCursor
        end
        local num = 0
        for i, v in pairs(Site.data) do
            local Possible = true
            ID = tostring(v.id)
            if tonumber(v.maxPlayers) > tonumber(v.playing) then
                for _, Existing in pairs(AllIDs) do
                    if num ~= 0 then
                        if ID == tostring(Existing) then
                            Possible = false
                        end
                    else
                        if tonumber(actualHour) ~= tonumber(Existing) then
                            pcall(function()
                                delfile("NotSameServers.json")
                                AllIDs = {}
                                table.insert(AllIDs, actualHour)
                            end)
                        end
                    end
                    num = num + 1
                end
                if Possible == true then
                    table.insert(AllIDs, ID)
                    task.wait()
                    pcall(function()
                        writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                        task.wait()
                        game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                    end)
                    task.wait(4)
                end
            end
        end
    end

    while task.wait() do
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then
                TPReturner()
            end
        end)
    end
end

-- ===== ПОЛНЫЙ ЦИКЛ =====
local function fullCycle()
    local ok = goToWorldSpot()
    if not ok then return end

    task.wait(1)
    task.wait(EVENT_WAIT)

    farm()
    serverHop()
end

-- ===== АВТОЗАПУСК =====
task.spawn(function()
    repeat task.wait(0.2) until LocalPlayer
    repeat task.wait(0.2) until LocalPlayer.Character
    repeat task.wait(0.2) until LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if game.IsLoaded then
        repeat task.wait(0.2) until game:IsLoaded()
    end
    task.wait(LOAD_WAIT)
    fullCycle()
end)

-- ===== УПРАВЛЕНИЕ =====
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.T then
        running = false
    end
end)
