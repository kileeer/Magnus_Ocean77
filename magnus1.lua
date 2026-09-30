-- ==========================================
-- M A G N U S   2 4 / 7
-- Фарм через UID + Anti-AFK + Auto-Rejoin (7 мин)
-- ==========================================

-- =====================
-- ===== ЖДЁМ ВСЁ =====
-- =====================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

repeat task.wait(0.5) until Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer

if not game:IsLoaded() then
    game.Loaded:Wait()
end

repeat task.wait(0.5) until LocalPlayer.Character
repeat task.wait(0.5) until LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

repeat task.wait(0.5) until ReplicatedStorage:FindFirstChild("Library")
local Library = ReplicatedStorage:FindFirstChild("Library")

repeat task.wait(0.5) until Library:FindFirstChild("Client")
local Client = Library:FindFirstChild("Client")

repeat task.wait(0.5) until Client:FindFirstChild("Save")

repeat task.wait(0.5) until ReplicatedStorage:FindFirstChild("Network")
local Network = ReplicatedStorage:FindFirstChild("Network")

repeat task.wait(0.5) until Network:FindFirstChild("Consumables_Consume")
local ConsumablesEvent = Network:FindFirstChild("Consumables_Consume")

-- =====================
-- ===== ANTI-AFK =====
-- =====================
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.Jump = true end
            end
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(0, 0))
        end)
    end)

    task.spawn(function()
        while true do
            task.wait(30)
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Jump = true end
                end
            end)
        end
    end)
end)

-- =====================
-- ===== НАСТРОЙКИ =====а
-- =====================
local LOAD_WAIT  = 10
local EVENT_WAIT = 15
local PRE_FARM_TP = Vector3.new(27610.05, 16.65, -8107.77)
local PRE_FARM_WAIT = 3
local TP_SETTLE  = 0.35
local DELAY      = 0.15
local GREEN_MAX_Y = -60

-- 👇 АВТО-РЕДЖОИН ЧЕРЕЗ 7 МИНУТ
local AUTO_REJOIN_MINUTES = 7      -- через сколько минут реджоинить
local AUTO_REJOIN_TIME = AUTO_REJOIN_MINUTES * 60  -- в секундах

local ORE_ID     = "Eclipse Onyx Gem"
local ORE_NAME   = "Eclipse Onyx"

local ACCESS_CODE = "ecd7db501138f7488f2d4ca06a1e6e93"
-- =====================

-- =====================
-- ===== ТОЧКИ ИВЕНТА =====
-- =====================
local WORLD_SPOTS = {
    [8737899170]      = {name = "Мир 1",  pos = Vector3.new(179.04, 16.24, -142.15)},
    [16498369169]     = {name = "Мир 2", pos = Vector3.new(-9954.08, 16.54, -287.74)},
    [17503543197]     = {name = "Мир 3", pos = Vector3.new(-10256.35, 4.17, -7300.98)},
    [140403681187145] = {name = "Мир 4", pos = Vector3.new(-15848.54, 39.92, -193.16)},
}

-- =====================
-- ===== МОДУЛИ =====
-- =====================
local Save = require(Client.Save)
local Blocks = require(Library.Types.Blocks)
local BlockWorldClient = require(Client.ToolCmds.BlockWorldClient)

-- =====================
-- ===== БОМБЫ (UID) =====
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

local function countOre()
    local data = Save.Get()
    if not data or not data.Inventory or not data.Inventory.Misc then
        return 0
    end
    local total = 0
    for uid, item in pairs(data.Inventory.Misc) do
        if item.id == ORE_ID then
            total = total + (item._am or 1)
        end
    end
    return total
end

-- =====================
-- ===== ЖДЁМ ИНВЕНТАРЬ =====
-- =====================
repeat task.wait(0.5) until Save.Get() and Save.Get().Inventory and Save.Get().Inventory.Consumable
task.wait(2)

local START_GREEN  = countBombs("green")
local START_YELLOW = countBombs("yellow")
local START_ORE    = countOre()
local START_TIME   = tick()

-- =====================
-- ===== GUI PARENT =====
-- =====================
local function getGuiParent()
    if gethui then
        local ok, res = pcall(gethui)
        if ok and res then return res end
    end
    return LocalPlayer:WaitForChild("PlayerGui")
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
local GREEN      = Color3.fromRGB(0, 220, 0)
local RED        = Color3.fromRGB(255, 100, 100)
local YELLOW     = Color3.fromRGB(255, 220, 0)
local PANEL      = Color3.fromRGB(10, 15, 30)
local ORE_COLOR  = Color3.fromRGB(180, 130, 255)

local gui = Instance.new("ScreenGui")
gui.Name = "MagnusGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = getGuiParent()

local mainContainer = Instance.new("Frame")
mainContainer.Size = UDim2.new(1, 0, 1, 0)
mainContainer.BackgroundTransparency = 1
mainContainer.ZIndex = 1
mainContainer.Parent = gui

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = BG_COLOR
bg.BackgroundTransparency = BG_TRANSPARENCY
bg.BorderSizePixel = 0
bg.ZIndex = 1
bg.Parent = mainContainer

local container = Instance.new("Frame")
container.Size = UDim2.new(0, AVATAR_SIZE, 0, AVATAR_SIZE + 100)
container.Position = UDim2.new(0.5, -AVATAR_SIZE/2, 0.5, -(AVATAR_SIZE + 100)/2)
container.BackgroundTransparency = 1
container.ZIndex = 2
container.Parent = mainContainer

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

-- Панель статистики
local statsPanel = Instance.new("Frame")
statsPanel.Size = UDim2.new(0, 380, 0, 310)
statsPanel.Position = UDim2.new(0, 10, 0, 10)
statsPanel.BackgroundColor3 = PANEL
statsPanel.BackgroundTransparency = 0.15
statsPanel.BorderSizePixel = 0
statsPanel.ZIndex = 5
statsPanel.Parent = mainContainer
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
statsTitle.Text = "📊 СТАТИСТИКА (UID + 7 мин)"
statsTitle.TextColor3 = ACCENT
statsTitle.Font = Enum.Font.GothamBold
statsTitle.TextSize = 14
statsTitle.TextXAlignment = Enum.TextXAlignment.Left
statsTitle.ZIndex = 6
statsTitle.Parent = statsPanel

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

local greenLabel    = makeLine(38,  GREEN,  "🟢 TNT: 0")
local greenSpent    = makeLine(64,  Color3.fromRGB(255, 180, 180), "   Потрачено: 0")
local greenPerHour  = makeLine(90,  Color3.fromRGB(255, 140, 140), "   За час: 0")
local yellowLabel   = makeLine(120, YELLOW, "🟡 TNT: 0")
local yellowSpent   = makeLine(146, Color3.fromRGB(255, 180, 180), "   Потрачено: 0")
local yellowPerHour = makeLine(172, Color3.fromRGB(255, 140, 140), "   За час: 0")
local oreLabel      = makeLine(202, ORE_COLOR, "💎 " .. ORE_NAME .. ": 0")
local oreEarned     = makeLine(228, Color3.fromRGB(200, 160, 255), "   Нафармлено: 0")
local afkLabel      = makeLine(258, Color3.fromRGB(255, 180, 100), "💤 АФК: 00:00:00")
local rejoinTimer   = makeLine(284, Color3.fromRGB(255, 140, 100), "🔄 Реджоин через: 7:00")

-- Кнопки
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 160, 0, 40)
closeBtn.Position = UDim2.new(1, -170, 1, -56)
closeBtn.BackgroundColor3 = PANEL
closeBtn.BackgroundTransparency = 0.15
closeBtn.BorderSizePixel = 0
closeBtn.Text = "❌  ЗАКРЫТЬ МЕНЮ"
closeBtn.TextColor3 = RED
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.ZIndex = 10
closeBtn.Parent = gui
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 10)

local closeStroke = Instance.new("UIStroke")
closeStroke.Color = RED
closeStroke.Thickness = 1
closeStroke.Transparency = 0.3
closeStroke.Parent = closeBtn

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 160, 0, 40)
openBtn.Position = UDim2.new(1, -170, 1, -56)
openBtn.BackgroundColor3 = PANEL
openBtn.BackgroundTransparency = 0.15
openBtn.BorderSizePixel = 0
openBtn.Text = "✅  ОТКРЫТЬ МЕНЮ"
openBtn.TextColor3 = GREEN
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 14
openBtn.ZIndex = 10
openBtn.Visible = false
openBtn.Parent = gui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 10)

local openStroke = Instance.new("UIStroke")
openStroke.Color = GREEN
openStroke.Thickness = 1
openStroke.Transparency = 0.3
openStroke.Parent = openBtn

closeBtn.MouseButton1Click:Connect(function()
    mainContainer.Visible = false
    closeBtn.Visible = false
    openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
    mainContainer.Visible = true
    openBtn.Visible = false
    closeBtn.Visible = true
end)

local function formatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function updateStats()
    local curGreen, curYellow, curOre = 0, 0, 0

    local okG, resG = pcall(countBombs, "green")
    if okG then curGreen = resG end

    local okY, resY = pcall(countBombs, "yellow")
    if okY then curYellow = resY end

    local okO, resO = pcall(countOre)
    if okO then curOre = resO end

    if START_GREEN == 0 and curGreen > 0 then START_GREEN = curGreen end
    if START_YELLOW == 0 and curYellow > 0 then START_YELLOW = curYellow end

    local spentGreen  = math.max(0, START_GREEN  - curGreen)
    local spentYellow = math.max(0, START_YELLOW - curYellow)
    local earnedOre   = math.max(0, curOre - START_ORE)

    local elapsed = tick() - START_TIME
    local hours = elapsed / 3600
    if hours < 0.001 then hours = 0.001 end

    local greenPerHour  = math.floor(spentGreen / hours)
    local yellowPerHour = math.floor(spentYellow / hours)

    pcall(function() greenLabel.Text = "🟢 TNT: " .. curGreen end)
    pcall(function() greenSpent.Text = "   Потрачено: " .. spentGreen end)
    pcall(function() greenPerHour.Text = "   За час: " .. greenPerHour end)

    pcall(function() yellowLabel.Text = "🟡 TNT: " .. curYellow end)
    pcall(function() yellowSpent.Text = "   Потрачено: " .. spentYellow end)
    pcall(function() yellowPerHour.Text = "   За час: " .. yellowPerHour end)

    pcall(function() oreLabel.Text = "💎 " .. ORE_NAME .. ": " .. curOre end)
    pcall(function() oreEarned.Text = "   Нафармлено: " .. earnedOre end)

    pcall(function() afkLabel.Text = "💤 АФК: " .. formatTime(elapsed) end)

    -- Таймер до реджоина
    local timeLeft = AUTO_REJOIN_TIME - elapsed
    if timeLeft < 0 then timeLeft = 0 end
    local mins = math.floor(timeLeft / 60)
    local secs = math.floor(timeLeft % 60)
    pcall(function() 
        rejoinTimer.Text = string.format("🔄 Реджоин через: %d:%02d", mins, secs) 
    end)
end

task.spawn(function()
    while true do
        updateStats()
        task.wait(1)
    end
end)

-- =====================
-- ===== ЮЗ БОМБЫ ЧЕРЕЗ UID =====
-- =====================
local function useBomb(bombKey)
    local uid = BOMB_UIDS[bombKey]
    if not uid then return end
    pcall(function()
        ConsumablesEvent:InvokeServer(uid, 1)
    end)
end

-- =====================
-- ===== ЛОГИКА =====
-- =====================
local TeleportService = game:GetService("TeleportService")
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

local function rejoinVIP()
    pcall(function()
        LocalPlayer:Kick("Rejoining...")
    end)
    task.wait(1)

    local success, err = pcall(function()
        TeleportService:TeleportToPrivateServer(
            game.PlaceId,
            ACCESS_CODE,
            {LocalPlayer}
        )
    end)

    if not success then
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.T then
        running = false
    end
end)

local region, origin, startX, startZ, STEP, HEIGHT_OFFSET
local world = nil

local function teleportToGrid(gridX, gridY, gridZ)
    local cf = Blocks.BlockCFrame(origin, Vector3int16.new(gridX, gridY, gridZ))
    local target = cf.Position + Vector3.new(0, HEIGHT_OFFSET, 0)
    teleportTo(target)
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
-- ===== ТАЙМЕР АВТО-РЕДЖОИНА =====
-- =====================
local farmStartTime = tick()

task.spawn(function()
    while running do
        task.wait(1)
        if tick() - farmStartTime >= AUTO_REJOIN_TIME then
            running = false
            rejoinVIP()
            break
        end
    end
end)

-- =====================
-- ===== ФАРМ =====
-- =====================
local function farmOnce()
    world = nil
    local attempts = 0
    repeat
        task.wait(0.5)
        world = BlockWorldClient.GetLocal()
        attempts = attempts + 1
    until world or attempts > 60

    if not world then return false end
    if not findBombUIDs() then return false end

    region = world:GetRegion()
    origin = world:GetOrigin()
    startX = region.Min.X + 1
    startZ = region.Min.Z + 1
    STEP = 3
    HEIGHT_OFFSET = 3

    -- 👇 ЗАПОМИНАЕМ ВРЕМЯ НАЧАЛА ФАРМА
    farmStartTime = tick()

    while running do
        local y = findHighestYInColumn()
        if not y then break end

        local bombKey = getBombKey(y)

        for x = startX, region.Max.X - 1, STEP do
            if not running then break end
            for z = startZ, region.Max.Z - 1, STEP do
                if not running then break end

                local block = world:GetBlock(Vector3int16.new(x, y, z))
                if block then
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
for i = LOAD_WAIT, 1, -1 do
    task.wait(1)
end

local spot = WORLD_SPOTS[game.PlaceId]
if spot then
    teleportTo(spot.pos)
    task.wait(EVENT_WAIT)
    teleportTo(PRE_FARM_TP)
    task.wait(PRE_FARM_WAIT)

    local ok = farmOnce()

    if running then
        rejoinVIP()
    end
end
