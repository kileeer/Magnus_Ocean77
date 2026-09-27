-- =====================
-- ===== МОДУЛИ =====
-- =====================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = ReplicatedStorage:WaitForChild("Network", 10)
local FJ_Merge = Network:WaitForChild("FJ_Merge", 10)

if not FJ_Merge then
    warn("❌ FJ_Merge не найден! Подожди прогрузку или перезапусти.")
    return
end

-- =====================
-- ===== НАСТРОЙКИ =====
-- =====================
local MAX_PER_CRAFT = 100       -- максимум за 1 крафт
local DEFAULT_INTERVAL = 2      -- интервал 2 сек

-- [tier] = { enabled, amount }
local CRAFTS = {
    [4] = { enabled = true,  amount = 100 },
    [5] = { enabled = true,  amount = 100 },
    [6] = { enabled = true,  amount = 100 },
    [7] = { enabled = false, amount = 20  },
}

-- =====================
-- ===== ГУИ =====
-- =====================
local BG_COLOR    = Color3.fromRGB(20, 30, 60)
local PANEL_COLOR = Color3.fromRGB(10, 15, 30)
local ACCENT      = Color3.fromRGB(100, 150, 255)
local TEXT_COLOR  = Color3.fromRGB(230, 240, 255)
local GREEN       = Color3.fromRGB(0, 220, 0)
local RED         = Color3.fromRGB(255, 100, 100)
local YELLOW      = Color3.fromRGB(255, 220, 0)
local GRAY        = Color3.fromRGB(60, 60, 70)

local function getGuiParent()
    if gethui then
        local ok, res = pcall(gethui)
        if ok and res then return res end
    end
    return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local gui = Instance.new("ScreenGui")
gui.Name = "AutoCraftGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = getGuiParent()

-- Главная панель
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 380, 0, 480)
panel.Position = UDim2.new(0, 10, 0, 10)
panel.BackgroundColor3 = PANEL_COLOR
panel.BackgroundTransparency = 0.15
panel.BorderSizePixel = 0
panel.ZIndex = 5
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = ACCENT
panelStroke.Thickness = 1
panelStroke.Transparency = 0.4
panelStroke.Parent = panel

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Text = "⚒️ АВТО-КРАФТ"
title.TextColor3 = ACCENT
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 6
title.Parent = panel

-- Драг панели
do
    local dragging, dragInput, dragStart, startPos
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Инфо
local limitInfo = Instance.new("TextLabel")
limitInfo.Size = UDim2.new(1, -20, 0, 20)
limitInfo.Position = UDim2.new(0, 10, 0, 42)
limitInfo.BackgroundTransparency = 1
limitInfo.Text = "🔁 Максимум " .. MAX_PER_CRAFT .. " шт за цикл"
limitInfo.TextColor3 = YELLOW
limitInfo.Font = Enum.Font.GothamMedium
limitInfo.TextSize = 12
limitInfo.TextXAlignment = Enum.TextXAlignment.Left
limitInfo.ZIndex = 6
limitInfo.Parent = panel

-- Интервал
local intervalLabel = Instance.new("TextLabel")
intervalLabel.Size = UDim2.new(1, -20, 0, 22)
intervalLabel.Position = UDim2.new(0, 10, 0, 68)
intervalLabel.BackgroundTransparency = 1
intervalLabel.Text = "⏱ Интервал (сек):"
intervalLabel.TextColor3 = TEXT_COLOR
intervalLabel.Font = Enum.Font.GothamMedium
intervalLabel.TextSize = 14
intervalLabel.TextXAlignment = Enum.TextXAlignment.Left
intervalLabel.ZIndex = 6
intervalLabel.Parent = panel

local intervalBox = Instance.new("TextBox")
intervalBox.Size = UDim2.new(0, 80, 0, 26)
intervalBox.Position = UDim2.new(1, -90, 0, 68)
intervalBox.BackgroundColor3 = BG_COLOR
intervalBox.BorderSizePixel = 0
intervalBox.Text = tostring(DEFAULT_INTERVAL)
intervalBox.TextColor3 = TEXT_COLOR
intervalBox.Font = Enum.Font.GothamBold
intervalBox.TextSize = 14
intervalBox.ZIndex = 6
intervalBox.Parent = panel
Instance.new("UICorner", intervalBox).CornerRadius = UDim.new(0, 6)

-- Разделитель
local line1 = Instance.new("Frame")
line1.Size = UDim2.new(1, -20, 0, 1)
line1.Position = UDim2.new(0, 10, 0, 102)
line1.BackgroundColor3 = ACCENT
line1.BackgroundTransparency = 0.7
line1.BorderSizePixel = 0
line1.ZIndex = 6
line1.Parent = panel

-- Заголовки колонок
local headerTier = Instance.new("TextLabel")
headerTier.Size = UDim2.new(0, 80, 0, 20)
headerTier.Position = UDim2.new(0, 40, 0, 108)
headerTier.BackgroundTransparency = 1
headerTier.Text = "TIER"
headerTier.TextColor3 = ACCENT
headerTier.Font = Enum.Font.GothamBold
headerTier.TextSize = 11
headerTier.TextXAlignment = Enum.TextXAlignment.Left
headerTier.ZIndex = 6
headerTier.Parent = panel

local headerTotal = Instance.new("TextLabel")
headerTotal.Size = UDim2.new(0, 70, 0, 20)
headerTotal.Position = UDim2.new(0, 165, 0, 108)
headerTotal.BackgroundTransparency = 1
headerTotal.Text = "ЗА РАЗ"
headerTotal.TextColor3 = ACCENT
headerTotal.Font = Enum.Font.GothamBold
headerTotal.TextSize = 11
headerTotal.TextXAlignment = Enum.TextXAlignment.Left
headerTotal.ZIndex = 6
headerTotal.Parent = panel

local headerCount = Instance.new("TextLabel")
headerCount.Size = UDim2.new(0, 100, 0, 20)
headerCount.Position = UDim2.new(1, -110, 0, 108)
headerCount.BackgroundTransparency = 1
headerCount.Text = "ВСЕГО СДЕЛАНО"
headerCount.TextColor3 = ACCENT
headerCount.Font = Enum.Font.GothamBold
headerCount.TextSize = 11
headerCount.TextXAlignment = Enum.TextXAlignment.Right
headerCount.ZIndex = 6
headerCount.Parent = panel

-- =====================
-- ===== СТРОКИ КРАФТОВ =====
-- =====================
local craftRows = {}

local function makeCraftRow(tier, yPos)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 42)
    row.Position = UDim2.new(0, 10, 0, yPos)
    row.BackgroundColor3 = BG_COLOR
    row.BackgroundTransparency = 0.5
    row.BorderSizePixel = 0
    row.ZIndex = 6
    row.Parent = panel
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    -- Чекбокс
    local check = Instance.new("TextButton")
    check.Size = UDim2.new(0, 26, 0, 26)
    check.Position = UDim2.new(0, 8, 0, 8)
    check.BackgroundColor3 = CRAFTS[tier].enabled and GREEN or GRAY
    check.BorderSizePixel = 0
    check.Text = CRAFTS[tier].enabled and "✓" or ""
    check.TextColor3 = Color3.fromRGB(255, 255, 255)
    check.Font = Enum.Font.GothamBold
    check.TextSize = 16
    check.ZIndex = 7
    check.Parent = row
    Instance.new("UICorner", check).CornerRadius = UDim.new(0, 6)

    -- Название
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 100, 0, 26)
    nameLabel.Position = UDim2.new(0, 42, 0, 8)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Tier " .. tier
    nameLabel.TextColor3 = CRAFTS[tier].enabled and TEXT_COLOR or GRAY
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 15
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 7
    nameLabel.Parent = row

    -- Поле "ЗА РАЗ"
    local amountBox = Instance.new("TextBox")
    amountBox.Size = UDim2.new(0, 70, 0, 26)
    amountBox.Position = UDim2.new(0, 145, 0, 8)
    amountBox.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    amountBox.BorderSizePixel = 0
    amountBox.Text = tostring(CRAFTS[tier].amount)
    amountBox.TextColor3 = TEXT_COLOR
    amountBox.Font = Enum.Font.GothamBold
    amountBox.TextSize = 14
    amountBox.ZIndex = 7
    amountBox.Parent = row
    Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

    -- Счётчик всего сделано
    local countLabel = Instance.new("TextLabel")
    countLabel.Size = UDim2.new(0, 130, 0, 26)
    countLabel.Position = UDim2.new(1, -138, 0, 8)
    countLabel.BackgroundTransparency = 1
    countLabel.Text = "0"
    countLabel.TextColor3 = YELLOW
    countLabel.Font = Enum.Font.GothamBold
    countLabel.TextSize = 13
    countLabel.TextXAlignment = Enum.TextXAlignment.Right
    countLabel.ZIndex = 7
    countLabel.Parent = row

    -- Обработчики
    check.MouseButton1Click:Connect(function()
        CRAFTS[tier].enabled = not CRAFTS[tier].enabled
        check.BackgroundColor3 = CRAFTS[tier].enabled and GREEN or GRAY
        check.Text = CRAFTS[tier].enabled and "✓" or ""
        nameLabel.TextColor3 = CRAFTS[tier].enabled and TEXT_COLOR or GRAY
        row.BackgroundTransparency = CRAFTS[tier].enabled and 0.5 or 0.8
    end)

    amountBox.FocusLost:Connect(function()
        local num = tonumber(amountBox.Text)
        if num and num > 0 then
            CRAFTS[tier].amount = math.min(math.floor(num), MAX_PER_CRAFT)
            amountBox.Text = tostring(CRAFTS[tier].amount)
        else
            amountBox.Text = tostring(CRAFTS[tier].amount)
        end
    end)

    craftRows[tier] = {
        row = row,
        check = check,
        amountBox = amountBox,
        countLabel = countLabel,
        nameLabel = nameLabel,
        totalDone = 0,
    }
end

local yStart = 130
for tier, _ in pairs(CRAFTS) do
    makeCraftRow(tier, yStart)
    yStart = yStart + 48
end

-- Разделитель 2
local line2 = Instance.new("Frame")
line2.Size = UDim2.new(1, -20, 0, 1)
line2.Position = UDim2.new(0, 10, 0, yStart + 5)
line2.BackgroundColor3 = ACCENT
line2.BackgroundTransparency = 0.7
line2.BorderSizePixel = 0
line2.ZIndex = 6
line2.Parent = panel

-- Кнопка Старт/Стоп
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 44)
toggleBtn.Position = UDim2.new(0, 10, 0, yStart + 15)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "▶ СТАРТ"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 17
toggleBtn.ZIndex = 6
toggleBtn.Parent = panel
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

-- Статус
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 22)
statusLabel.Position = UDim2.new(0, 10, 0, yStart + 66)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "⏹ Остановлено"
statusLabel.TextColor3 = RED
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 14
statusLabel.ZIndex = 6
statusLabel.Parent = panel

-- Инфо
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 0, 22)
infoLabel.Position = UDim2.new(0, 10, 0, yStart + 88)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Выполнено циклов: 0"
infoLabel.TextColor3 = TEXT_COLOR
infoLabel.Font = Enum.Font.GothamMedium
infoLabel.TextSize = 13
infoLabel.ZIndex = 6
infoLabel.Parent = panel

-- =====================
-- ===== ЛОГИКА =====
-- =====================
local running = false
local totalCycles = 0

local function craftLoop()
    while running do
        local interval = tonumber(intervalBox.Text) or DEFAULT_INTERVAL
        local activeTiers = {}

        -- Собираем включённые тиры
        for tier = 1, 20 do
            local cfg = CRAFTS[tier]
            if cfg and cfg.enabled then
                table.insert(activeTiers, tier)
            end
        end

        if #activeTiers == 0 then
            running = false
            toggleBtn.Text = "▶ СТАРТ"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            statusLabel.Text = "⚠️ Выбери хотя бы 1 тир!"
            statusLabel.TextColor3 = RED
            break
        end

        -- Крафтим все включённые тиры
        for _, tier in ipairs(activeTiers) do
            if not running then break end
            local cfg = CRAFTS[tier]

            statusLabel.Text = "⚒️ Крафчу Tier " .. tier
            statusLabel.TextColor3 = YELLOW

            pcall(function()
                FJ_Merge:InvokeServer(
                    "MiningCraftMachine",
                    tier,
                    cfg.amount,
                    { shiny = false, pt = 0 }
                )
            end)

            if craftRows[tier] then
                craftRows[tier].totalDone = craftRows[tier].totalDone + cfg.amount
                craftRows[tier].countLabel.Text = tostring(craftRows[tier].totalDone)
            end

            -- Пауза между тирами
            local t1 = os.clock()
            repeat task.wait() until os.clock() - t1 >= 0.3
        end

        totalCycles = totalCycles + 1
        infoLabel.Text = "Выполнено циклов: " .. totalCycles
        statusLabel.Text = "⏳ Жду " .. interval .. " сек..."
        statusLabel.TextColor3 = ACCENT

        -- Интервал между циклами
        local waitStart = os.clock()
        repeat
            if not running then break end
            task.wait()
        until os.clock() - waitStart >= interval
    end
end

-- =====================
-- ===== КНОПКА СТАРТ/СТОП =====
-- =====================
toggleBtn.MouseButton1Click:Connect(function()
    if running then
        running = false
        toggleBtn.Text = "▶ СТАРТ"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        statusLabel.Text = "⏹ Остановлено"
        statusLabel.TextColor3 = RED
    else
        running = true
        toggleBtn.Text = "⏹ СТОП"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        statusLabel.Text = "▶ Работает..."
        statusLabel.TextColor3 = GREEN
        task.spawn(craftLoop)
    end
end)

-- =====================
-- ===== ГОРЯЧАЯ КЛАВИША (K) =====
-- =====================
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K then
        toggleBtn.MouseButton1Click:Fire()
    end
end)

print("✅ Авто-крафт загружен. Нажми K чтобы старт/стоп")
