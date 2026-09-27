-- ==========================================
-- M A G N U S   2 4 / 7
-- Фарм → Пауза 2м → Бест-зона → Фарм
-- ==========================================

print("🚀 ЗАПУСК M A G N U S...")

-- =====================
-- ===== НАСТРОЙКИ =====
-- =====================
local LOAD_WAIT  = 10
local EVENT_WAIT = 6
local PRE_FARM_TP = Vector3.new(27610.05, 16.65, -8107.77)
local PRE_FARM_WAIT = 1
local TP_SETTLE  = 0.25
local DELAY      = 0.75
local GREEN_MAX_Y = -60
local REST_WAIT  = 120
-- =====================

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
-- ===== МОДУЛИ =====
-- =====================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = ReplicatedStorage:WaitForChild("Network")
local Save = require(ReplicatedStorage.Library.Client.Save)
local Blocks = require(ReplicatedStorage.Library.Types.Blocks)
local BlockWorldClient = require(ReplicatedStorage.Library.Client.ToolCmds.BlockWorldClient)

local ConsumablesEvent = Network:WaitForChild("Consumables_Consume")

-- =====================
-- ===== БОМБЫ (UID + счёт) =====
-- =====================
local BOMB_UIDS = { green = nil, yellow = nil }

local function findBombUIDs()
    local data = Save.Get()
    if not data or not data.Inventory or not data.Inventory.Consumable then
        return false
    end
    for uid, core in pairs(data.Inventory.Consumable) do
        if core.id == "Drill Array" then
            BOMB_UIDS.green = uid
        elseif core.id == "Core Charge" then
            BOMB_UIDS.yellow = uid
        end
    end
    return BOMB_UIDS.green ~= nil and BOMB_UIDS.yellow ~= nil
end

local function countBombs(bombType)
    local data = Save.Get()
    if not data or not data.Inventory or not data.Inventory.Consumable then
        return 0
    end
    local targetId = (bombType == "green") and "Drill Array" or "Core Charge"
    local total = 0
    for uid, core in pairs(data.Inventory.Consumable) do
        if core.id == targetId then
            total = total + (core._am or core.amount or core.count or 1)
        end
    end
    return total
end

-- =====================
-- ===== СТАРТОВЫЕ ЗНАЧЕНИЯ =====
-- =====================
local START_GREEN  = countBombs("green")
local START_YELLOW = countBombs("yellow")
local START_TIME   = tick()

print(string.format("📊 СТАРТ: 🟢 %d | 🟡 %d", START_GREEN, START_YELLOW))

-- =====================
-- ===== GUI PARENT =====
-- =====================
local function getGuiParent()
    if gethui then
        local ok, res = pcall(gethui)
        if ok and res then return res end
    end
    return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

-- =====================
-- ===== ГУИ =====
-- =====================
local OWNER_USER_ID   = 11205845971
local LINE_1          = "[B1ZE]"
local LINE_2          = "By Magnus_Ocean77"
local BG_COLOR        = Color3.fromRGB(20, 30, 60)
local BG_TRANSPARENCY = 0.4
local AVATAR_SIZE     = 200

local ACCENT     = Color3.fromRGB(100, 150, 255)
local TEXT_COLOR = Color3.fromRGB(230, 240, 255)
local GREEN      = Color3.fromRGB(0, 220, 0)
local RED        = Color3.fromRGB(255, 100, 100)
local YELLOW     = Color3.fromRGB(255, 220, 0)
local PANEL      = Color3.fromRGB(10, 15, 30)

local gui = Instance.new("ScreenGui")
gui.Name = "MagnusGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = getGuiParent()

-- Фон
local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = BG_COLOR
bg.BackgroundTransparency = BG_TRANSPARENCY
bg.BorderSizePixel = 0
bg.ZIndex = 1
bg.Parent = gui

-- Аватар
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

-- Кнопка скрыть
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
stroke.Color = ACCENT
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
-- ===== ПАНЕЛЬ СТАТИСТИКИ =====
-- =====================
local statsPanel = Instance.new("Frame")
statsPanel.Size = UDim2.new(0, 320, 0, 250)
statsPanel.Position = UDim2.new(0, 10, 0, 10)
statsPanel.BackgroundColor3 = PANEL
statsPanel.BackgroundTransparency = 0.15
statsPanel.BorderSizePixel = 0
statsPanel.ZIndex = 5
statsPanel.Parent = gui
Instance.new("UICorner", statsPanel).CornerRadius = UDim.new(0, 10)

local statsStroke = Instance.new("UIStroke")
statsStroke.Color = ACCENT
statsStroke.Thickness = 1
statsStroke.Transparency = 0.3
statsStroke.Parent = statsPanel

local statsTitle = Instance.new("TextLabel")
statsTitle.Size = UDim2.new(1, -20, 0, 24)
statsTitle.Position = UDim2.new(0, 10, 0, 8)
statsTitle.BackgroundTransparency = 1
statsTitle.Text = "📊 СТАТИСТИКА"
statsTitle.TextColor3 = ACCENT
statsTitle.Font = Enum.Font.GothamBold
statsTitle.TextSize = 15
statsTitle.TextXAlignment = Enum.TextXAlignment.Left
statsTitle.ZIndex = 6
statsTitle.Parent = statsPanel

-- Драг
do
    local dragging, dragInput, dragStart, startPos
    statsTitle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = statsPanel.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    statsTitle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            statsPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function makeLine(yPos, color, defaultText, fontSize)
    local line = Instance.new("TextLabel")
    line.Size = UDim2.new(1, -20, 0, 22)
    line.Position = UDim2.new(0, 10, 0, yPos)
    line.BackgroundTransparency = 1
    line.Text = defaultText
    line.TextColor3 = color
    line.Font = Enum.Font.GothamMedium
    line.TextSize = fontSize or 14
    line.TextXAlignment = Enum.TextXAlignment.Left
    line.ZIndex = 6
    line.Parent = statsPanel
    return line
end

local greenLabel   = makeLine(38,  GREEN,  "🟢 TNT: 0")
local greenSpent   = makeLine(60,  Color3.fromRGB(255, 180, 180), "   Потрачено: 0")
local greenPerHour = makeLine(82,  Color3.fromRGB(255, 140, 140), "   За час: 0")
local yellowLabel  = makeLine(108, YELLOW, "🟡 TNT: 0")
local yellowSpent  = makeLine(130, Color3.fromRGB(255, 180, 180), "   Потрачено: 0")
local yellowPerHour = makeLine(152, Color3.fromRGB(255, 140, 140), "   За час: 0")
local afkLabel     = makeLine(178, Color3.fromRGB(255, 180, 100), "💤 АФК: 00:00:00")
local statusLabel  = makeLine(200, Color3.fromRGB(180, 200, 255), "⚙️ Статус: загрузка...")
local zoneLabel    = makeLine(222, Color3.fromRGB(180, 255, 180), "🎯 Бест-зона: поиск...")

-- =====================
-- ===== ТАЙМЕР АФК =====
-- =====================
local function formatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

-- =====================
-- ===== ОБНОВЛЕНИЕ СТАТИСТИКИ =====
-- =====================
local function updateStats()
    pcall(function()
        local curGreen  = countBombs("green")
        local curYellow = countBombs("yellow")
        local spentGreen  = math.max(0, START_GREEN  - curGreen)
        local spentYellow = math.max(0, START_YELLOW - curYellow)

        -- Сколько прошло времени
        local elapsed = tick() - START_TIME
        local hours = elapsed / 3600
        if hours < 0.001 then hours = 0.001 end  -- чтобы не делить на 0

        -- Трата за час (экстраполяция)
        local greenPerHour  = math.floor(spentGreen / hours)
        local yellowPerHour = math.floor(spentYellow / hours)

        -- Основные счётчики
        greenLabel.Text   = "🟢 TNT: " .. curGreen
        greenSpent.Text   = "   Потрачено: " .. spentGreen
        greenPerHour.Text = "   За час: " .. greenPerHour

        yellowLabel.Text   = "🟡 TNT: " .. curYellow
        yellowSpent.Text   = "   Потрачено: " .. spentYellow
        yellowPerHour.Text = "   За час: " .. yellowPerHour

        -- АФК таймер
        afkLabel.Text = "💤 АФК: " .. formatTime(elapsed)
    end)
end

task.spawn(function()
    while true do
        updateStats()
        task.wait(1)
    end
end)

-- =====================
-- ===== ПРОГРЕСС-БАР =====================
-- =====================
local progressBg = Instance.new("Frame")
progressBg.Size = UDim2.new(0, 400, 0, 30)
progressBg.Position = UDim2.new(0.5, -200, 1, -50)
progressBg.BackgroundColor3 = PANEL
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
progressText.Text = "Загрузка..."
progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
progressText.TextStrokeTransparency = 0.5
progressText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
progressText.Font = Enum.Font.GothamBold
progressText.TextSize = 14
progressText.ZIndex = 7
progressText.Parent = progressBg

local function updateProgress(current, total, color, text)
    pcall(function()
        local percent = 0
        if total and total > 0 then
            percent = math.floor((current / total) * 100)
        end
        progressFill.Size = UDim2.new(percent / 100, 0, 1, 0)
        if color then
            progressFill.BackgroundColor3 = color
        end
        if text then
            progressText.Text = text
        else
            progressText.Text = percent .. "%"
        end
    end)
end

-- =====================
-- ===== ЛОГИКА =====
-- =====================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local running = true

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

-- Стоп по T
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.T then
        running = false
        updateProgress(0, 100, Color3.fromRGB(255, 100, 100), "⏹ Стоп")
        statusLabel.Text = "⚙️ Статус: остановлено"
        statusLabel.TextColor3 = RED
        print("⏹ Стоп")
    end
end)

-- =====================
-- ===== ФУНКЦИИ ФАРМА =====
-- =====================
local region, origin, startX, startZ, STEP, HEIGHT_OFFSET
local world = nil

local function teleportToGrid(gridX, gridY, gridZ)
    local cf = Blocks.BlockCFrame(origin, Vector3int16.new(gridX, gridY, gridZ))
    local target = cf.Position + Vector3.new(0, HEIGHT_OFFSET, 0)
    teleportTo(target)
end

local function useBomb(bombKey)
    local uid = BOMB_UIDS[bombKey]
    if not uid then return end
    pcall(function()
        ConsumablesEvent:InvokeServer(uid, 1)
    end)
end

local function getBombKey(y)
    return y >= GREEN_MAX_Y and "green" or "yellow"
end

local function findHighestYInColumn()
    for y = region.Max.Y, region.Min.Y, -1 do
        if world:GetBlock(Vector3int16.new(startX, y, startZ)) then
            return y
        end
    end
    return nil
end

-- =====================
-- ===== ПОИСК БЕСТ-ЗОНЫ =====
-- =====================
local function findBestZone()
    statusLabel.Text = "🎯 Бест-зона: сканирую..."
    statusLabel.TextColor3 = YELLOW

    local bestX, bestZ, bestCount = startX, startZ, 0
    local sampleStep = STEP * 4

    for x = startX, region.Max.X - 1, sampleStep do
        if not running then break end
        for z = startZ, region.Max.Z - 1, sampleStep do
            local count = 0
            for y = region.Max.Y, region.Min.Y, -1 do
                if world:GetBlock(Vector3int16.new(x, y, z)) then
                    count = count + 1
                end
            end
            if count > bestCount then
                bestCount = count
                bestX = x
                bestZ = z
            end
        end
        task.wait()
    end

    zoneLabel.Text = string.format("🎯 Бест-зона: X=%d Z=%d (%d)", bestX, bestZ, bestCount)
    zoneLabel.TextColor3 = GREEN
    print(string.format("🎯 Бест-зона: X=%d Z=%d | Блоков: %d", bestX, bestZ, bestCount))

    local cf = Blocks.BlockCFrame(origin, Vector3int16.new(bestX, region.Max.Y, bestZ))
    return cf.Position + Vector3.new(0, HEIGHT_OFFSET, 0)
end

-- =====================
-- ===== ОДИН КРУГ ФАРМА =====
-- =====================
local function farmOnce()
    updateProgress(0, 100, Color3.fromRGB(255, 220, 0), "⏳ Ждём мир...")
    world = nil
    local attempts = 0
    repeat
        task.wait(0.5)
        world = BlockWorldClient.GetLocal()
        attempts = attempts + 1
    until world or attempts > 60

    if not world then
        updateProgress(0, 100, Color3.fromRGB(255, 100, 100), "❌ Мир не загрузился")
        return false
    end

    updateProgress(100, 100, Color3.fromRGB(0, 220, 0), "✅ Мир найден")

    if not findBombUIDs() then
        updateProgress(0, 100, Color3.fromRGB(255, 100, 100), "❌ Бомбы не найдены")
        return false
    end

    region = world:GetRegion()
    origin = world:GetOrigin()
    startX = region.Min.X + 1
    startZ = region.Min.Z + 1
    STEP = 3
    HEIGHT_OFFSET = 3

    updateProgress(0, 100, Color3.fromRGB(60, 150, 255), "▶ Фарм")
    statusLabel.Text = "⚙️ Статус: фарм..."
    statusLabel.TextColor3 = GREEN

    while running do
        local y = findHighestYInColumn()
        if not y then break end

        local bombKey = getBombKey(y)
        local bombColor = bombKey == "green" and Color3.fromRGB(0, 220, 0) or Color3.fromRGB(255, 220, 0)

        local totalPoints = 0
        for x = startX, region.Max.X - 1, STEP do
            for z = startZ, region.Max.Z - 1, STEP do
                if world:GetBlock(Vector3int16.new(x, y, z)) then
                    totalPoints = totalPoints + 1
                end
            end
        end

        local currentPoint = 0

        for x = startX, region.Max.X - 1, STEP do
            if not running then break end
            for z = startZ, region.Max.Z - 1, STEP do
                if not running then break end

                local block = world:GetBlock(Vector3int16.new(x, y, z))
                if block then
                    currentPoint = currentPoint + 1
                    updateProgress(currentPoint, totalPoints, bombColor,
                        string.format("Y=%d | %d/%d %s", y, currentPoint, totalPoints,
                            bombKey == "green" and "🟢" or "🟡"))

                    if not getHRP() then task.wait(0.5) end
                    teleportToGrid(x, y, z)
                    task.wait(TP_SETTLE)
                    useBomb(bombKey)
                    task.wait(DELAY)
                end
            end
        end
    end
    return true
end

-- =====================
-- ===== ЗАПУСК =====
-- =====================
repeat task.wait(0.2) until LocalPlayer
repeat task.wait(0.2) until LocalPlayer.Character
repeat task.wait(0.2) until LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if game:IsLoaded() == false then
    repeat task.wait(0.2) until game:IsLoaded()
end

for i = LOAD_WAIT, 1, -1 do
    local percent = math.floor(((LOAD_WAIT - i) / LOAD_WAIT) * 100)
    updateProgress(percent, 100, Color3.fromRGB(255, 220, 0), "Прогрузка... " .. i .. "с")
    task.wait(1)
end

-- =====================
-- ===== ОСНОВНОЙ ЦИКЛ =====
-- =====================
while running do
    local spot = WORLD_SPOTS[game.PlaceId]
    if not spot then
        updateProgress(0, 100, Color3.fromRGB(255, 100, 100), "❌ Мир не найден")
        break
    end

    updateProgress(100, 100, Color3.fromRGB(150, 200, 255), "🌍 " .. spot.name)
    teleportTo(spot.pos)

    task.wait(1)
    for i = EVENT_WAIT, 1, -1 do
        if not running then break end
        local percent = math.floor(((EVENT_WAIT - i) / EVENT_WAIT) * 100)
        updateProgress(percent, 100, Color3.fromRGB(150, 200, 255), "⏳ Ивент... " .. i .. "с")
        task.wait(1)
    end
    if not running then break end

    updateProgress(100, 100, Color3.fromRGB(150, 200, 255), "🎯 Остаток лока")
    teleportTo(PRE_FARM_TP)
    task.wait(PRE_FARM_WAIT)

    local ok = farmOnce()
    if not ok and running then task.wait(5) end
    if not running then break end

    statusLabel.Text = "⚙️ Статус: пауза..."
    statusLabel.TextColor3 = YELLOW
    for i = REST_WAIT, 1, -1 do
        if not running then break end
        local percent = math.floor(((REST_WAIT - i) / REST_WAIT) * 100)
        local mins = math.floor(i / 60)
        local secs = i % 60
        updateProgress(percent, 100, Color3.fromRGB(255, 180, 0),
            string.format("💤 Пауза %d:%02d", mins, secs))
        task.wait(1)
    end
    if not running then break end

    updateProgress(100, 100, Color3.fromRGB(180, 255, 180), "🎯 Ищу бест-зону...")
    local bestZonePos = findBestZone()
    teleportTo(bestZonePos)
    task.wait(1)
end

if running then
    updateProgress(100, 100, Color3.fromRGB(0, 220, 0), "✅ Завершено")
    print("✅ Скрипт завершён")
else
    updateProgress(0, 100, Color3.fromRGB(255, 100, 100), "⏹ Стоп")
    print("⏹ Скрипт остановлен")
end
