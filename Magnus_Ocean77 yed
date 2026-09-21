-- ===== НАСТРОЙКИ =====
local LOAD_WAIT = 10                      -- прогрузка после захода (сек)
local EVENT_WAIT = 8                      -- пауза в ивенте (сек)
local TP_SETTLE = 0.5                     -- пауза после ТП (сек)
local DELAY = 0.3                         -- пауза после клавиши (сек)
-- =====================

-- Ивент мир
local EVENT_COORDS = Vector3.new(-15845.41, 39.92, -196.47)

-- X, Z (Y и клавиша подставляются отдельно)
local topLayer = {
    {5259.10, -8147.31},
    {5274.16, -8147.37},
    {5286.36, -8147.30},
    {5299.44, -8146.91},
    {5318.80, -8147.24},
    {5322.83, -8137.16},
    {5322.54, -8120.89},
    {5322.82, -8105.42},
    {5323.06, -8090.46},
    {5322.93, -8077.29},
    {5307.78, -8082.00},
    {5291.53, -8082.67},
    {5275.80, -8082.62},
    {5260.77, -8082.44},
    {5250.87, -8082.30},
    {5256.51, -8098.56},
    {5257.31, -8112.00},
    {5257.44, -8128.74},
    {5273.96, -8132.14},
    {5287.50, -8132.32},
    {5302.80, -8132.39},
    {5297.15, -8118.36},
    {5297.46, -8100.93},
    {5312.92, -8102.01},
    {5312.01, -8117.65},
    {5311.62, -8133.36},
    {5277.38, -8112.39},
    {5277.36, -8096.89},
    {5291.56, -8092.06},
    {5286.63, -8106.29},
    {5287.78, -8122.50},
    {5269.00, -8122.40},
    {5267.60, -8101.54},
}

-- Слои: { Y, клавиша }
local layers = {
    {16.25,   Enum.KeyCode.Two},
    {-78.75,  Enum.KeyCode.Two},
    {-283.75, Enum.KeyCode.Three},
}

-- =====================
-- ===== ГУИ "MAGNUS_OCEAN77" =====
-- =====================

local gui = Instance.new("ScreenGui")
gui.Name = "MagnusGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = game.CoreGui

-- Чёрный фон на весь экран
local bg = Instance.new("Frame")
bg.Name = "Background"
bg.Size = UDim2.new(1, 0, 1, 0)
bg.Position = UDim2.new(0, 0, 0, 0)
bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bg.BackgroundTransparency = 0.3
bg.BorderSizePixel = 0
bg.ZIndex = 1
bg.Parent = gui

-- Синяя надпись по центру
local watermark = Instance.new("TextLabel")
watermark.Name = "Watermark"
watermark.Size = UDim2.new(1, 0, 0, 120)
watermark.Position = UDim2.new(0, 0, 0.5, -60)
watermark.BackgroundTransparency = 1
watermark.Text = "Magnus_Ocean77 Farm"
watermark.TextColor3 = Color3.fromRGB(60, 150, 255)
watermark.TextStrokeTransparency = 0.5
watermark.TextStrokeColor3 = Color3.fromRGB(0, 40, 120)
watermark.Font = Enum.Font.GothamBold
watermark.TextScaled = true
watermark.ZIndex = 2
watermark.Parent = gui

local sizeConstraint = Instance.new("UITextSizeConstraint")
sizeConstraint.MaxTextSize = 90
sizeConstraint.MinTextSize = 30
sizeConstraint.Parent = watermark

-- =====================
-- ===== КНОПКА В УГЛУ =====
-- =====================

local btn = Instance.new("TextButton")
btn.Name = "ToggleBtn"
btn.Size = UDim2.new(0, 110, 0, 32)
btn.Position = UDim2.new(1, -120, 0, 10)
btn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
btn.BorderSizePixel = 0
btn.Text = "👁 Скрыть"
btn.TextColor3 = Color3.fromRGB(60, 150, 255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 13
btn.ZIndex = 5
btn.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = btn

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(60, 150, 255)
stroke.Thickness = 1
stroke.Parent = btn

local visible = true

btn.MouseButton1Click:Connect(function()
    visible = not visible
    bg.Visible = visible
    watermark.Visible = visible
    if visible then
        btn.Text = "👁 Скрыть"
    else
        btn.Text = "👁 Показать"
    end
end)

-- =====================
-- ===== ЛОГИКА ФАРМА =====
-- =====================

local running = false

local function getHRP()
    local lp = game.Players.LocalPlayer
    local char = lp.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function teleportTo(pos)
    local hrp = getHRP()
    if not hrp then return end
    hrp.Velocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero
    hrp.CFrame = CFrame.new(pos)
end

local function pressKey(key)
    local vim = game:GetService("VirtualInputManager")
    vim:SendKeyEvent(true, key, false, game)
    task.wait(0.05)
    vim:SendKeyEvent(false, key, false, game)
end

-- ===== ФАРМ =====
local function farm()
    running = true

    for _, layer in ipairs(layers) do
        if not running then break end
        local y = layer[1]
        local key = layer[2]
        print(string.format("=== СЛОЙ Y = %.2f | клавиша: %s ===", y, key.Name))

        for i, t in ipairs(topLayer) do
            if not running then break end
            if not getHRP() then task.wait(0.5) end

            local pos = Vector3.new(t[1], y, t[2])
            teleportTo(pos)
            print(string.format("[%d/%d] TP -> %.2f, %.2f, %.2f",
                i, #topLayer, pos.X, pos.Y, pos.Z))

            task.wait(TP_SETTLE)
            pressKey(key)
            task.wait(DELAY)
        end
    end

    running = false
    print("✅ Фарм завершён")
end

-- ===== СЕРВЕРХОП =====
local function serverHop()
    print("⬆ Серверхоп...")

    local PlaceID = game.PlaceId
    local AllIDs = {}
    local foundAnything = ""
    local actualHour = os.date("!*t").hour

    local File = pcall(function()
        AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
    end)
    if not File then
        table.insert(AllIDs, actualHour)
        pcall(function()
            writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
        end)
    end

    local function TPReturner()
        local Site
        if foundAnything == "" then
            Site = game.HttpService:JSONDecode(game:HttpGet(
                'https://games.roblox.com/v1/games/' .. PlaceID ..
                '/servers/Public?sortOrder=Asc&limit=100'))
        else
            Site = game.HttpService:JSONDecode(game:HttpGet(
                'https://games.roblox.com/v1/games/' .. PlaceID ..
                '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
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
                        writefile("NotSameServers.json",
                            game:GetService('HttpService'):JSONEncode(AllIDs))
                        task.wait()
                        game:GetService("TeleportService"):TeleportToPlaceInstance(
                            PlaceID, ID, game.Players.LocalPlayer)
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
    print("🎉 ТП в ивент...")
    teleportTo(EVENT_COORDS)
    task.wait(1)

    print(string.format("⏳ Ждём %d сек в ивенте...", EVENT_WAIT))
    task.wait(EVENT_WAIT)

    print("▶ Фарм...")
    farm()

    serverHop()
end

-- ===== АВТОЗАПУСК =====
task.spawn(function()
    print("=== СКРИПТ ЗАПУЩЕН ===")
    repeat task.wait(0.2) until game.Players.LocalPlayer
    repeat task.wait(0.2) until game.Players.LocalPlayer.Character
    repeat task.wait(0.2) until game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if game.IsLoaded then
        repeat task.wait(0.2) until game:IsLoaded()
    end

    print("⏳ Прогрузка " .. LOAD_WAIT .. " сек...")
    task.wait(LOAD_WAIT)

    print("🚀 Старт цикла")
    fullCycle()
end)

-- ===== УПРАВЛЕНИЕ =====
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.T then
        running = false
        print("⏹ Стоп фарма")
    end
end)

print("✅ Загружено. ГУИ: Magnus_Ocean77. T — стоп.")
