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
