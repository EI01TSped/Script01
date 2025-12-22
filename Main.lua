-- Ped V1 Script
-- Wind UI
local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

-- Serviços
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local MAX_DISTANCE = 600

-- ==================== WINDOW ====================
local Window = WindUI:CreateWindow({
    Title = "Ped V1",
    Subtitle = "by yPedroX",
    Icon = "tv-minimal",
    Author = "yPedroX",
    Folder = "PedV1Config",
    Size = UDim2.fromOffset(580, 460),
    KeySystem = false,
    Transparent = true,
})

Window:Tag({
    Title = "v1.2",
    Icon = "github",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 0,
})

-- ==================== ABA KILLER ====================
local KillerTab = Window:Tab({
    Title = "Killer",
    Icon = "sword"
})

local KillerSection = KillerTab:Section({
    Title = "Funções",
    Closed = false
})

KillerSection:Button({
    Title = "Aimlock",
    Desc = "Trava a câmera automaticamente no inimigo",
    Callback = function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/Aepione/Prensado/refs/heads/main/Prensado%20camlock"
        ))()
    end
})

-- ==================== ABA SURVIVOR ====================
local SurvivorTab = Window:Tab({
    Title = "Survivor",
    Icon = "user"
})

local SurvivorSection = SurvivorTab:Section({
    Title = "Geradores",
    Closed = false
})

-- ==================== AUTO SKILL CHECK ====================
local skillCheckEnabled = false
local oldNamecall
local mt = getrawmetatable(game)

SurvivorSection:Toggle({
    Title = "Auto Skill Check (Nunca Errar)",
    Desc = "Acerta automaticamente todos os skill checks",
    Default = false,
    Callback = function(v)
        skillCheckEnabled = v

        if v then
            setreadonly(mt, false)
            oldNamecall = mt.__namecall

            mt.__namecall = newcclosure(function(self, ...)
                local args = {...}
                if getnamecallmethod() == "FireServer"
                    and tostring(self) == "SkillCheckResultEvent" then
                    args[1] = true
                    return oldNamecall(self, unpack(args))
                end
                return oldNamecall(self, ...)
            end)

            setreadonly(mt, true)
        else
            if oldNamecall then
                setreadonly(mt, false)
                mt.__namecall = oldNamecall
                setreadonly(mt, true)
            end
        end
    end
})

-- ==================== ABA ESP ====================
local EspTab = Window:Tab({
    Title = "ESP",
    Icon = "brush"
})

local EspSection = EspTab:Section({
    Title = "ESP Config [BETA]",
    Closed = false
})

-- ==================== VARIÁVEIS ====================
local espPlayers, espKiller, espGenerator, espGift = false, false, false, false
local playerESP = {}
local generatorESP = {}
local giftESP = {}

-- ==================== FUNÇÕES BASE ====================
local function getRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function inDistance(pos)
    local root = getRoot()
    if not root then return false end
    return (root.Position - pos).Magnitude <= MAX_DISTANCE
end

-- ==================== PLAYER ESP ====================
local function clearPlayerESP(player)
    if playerESP[player] then
        for _, v in pairs(playerESP[player]) do
            if v then v:Destroy() end
        end
        playerESP[player] = nil
    end
end

local function applyPlayerESP(player, color)
    if player == LocalPlayer or not player.Character then return end
    if playerESP[player] then return end

    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    local head = player.Character:FindFirstChild("Head")
    if not hrp or not head then return end

    local h = Instance.new("Highlight")
    h.FillTransparency = 1
    h.OutlineTransparency = 0.45
    h.OutlineColor = color
    h.Adornee = player.Character
    h.Parent = player.Character

    local gui = Instance.new("BillboardGui")
    gui.Adornee = head
    gui.Size = UDim2.fromOffset(110, 18)
    gui.StudsOffset = Vector3.new(0, 2.2, 0)
    gui.AlwaysOnTop = true
    gui.Parent = head

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.fromScale(1,1)
    txt.BackgroundTransparency = 1
    txt.Text = player.Name
    txt.TextColor3 = color
    txt.TextSize = 14
    txt.Font = Enum.Font.Gotham
    txt.TextStrokeTransparency = 0.8
    txt.Parent = gui

    playerESP[player] = {h, gui}
end

-- ==================== GERADOR % ====================
local function getGeneratorPercent(model)
    local v = model:GetAttribute("RepairProgress")
    if typeof(v) ~= "number" then return "0%" end
    if v <= 1 then return math.floor(v * 100) .. "%" end
    return math.floor(v) .. "%"
end

local function applyGeneratorESP(model)
    if generatorESP[model] then return end

    local h = Instance.new("Highlight")
    h.FillTransparency = 1
    h.OutlineTransparency = 0.4
    h.OutlineColor = Color3.fromRGB(255,255,0)
    h.Adornee = model
    h.Parent = model

    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local gui = Instance.new("BillboardGui")
    gui.Adornee = part
    gui.Size = UDim2.fromOffset(130,22)
    gui.StudsOffset = Vector3.new(0,3,0)
    gui.AlwaysOnTop = true
    gui.Parent = part

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.fromScale(1,1)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(255,255,0)
    txt.TextSize = 14
    txt.Font = Enum.Font.Gotham
    txt.TextStrokeTransparency = 0.7
    txt.Parent = gui

    generatorESP[model] = {h=h, gui=gui, txt=txt}
end

-- ==================== GIFT ESP ====================
local function applyGiftESP(model)
    if giftESP[model] then return end

    local h = Instance.new("Highlight")
    h.FillTransparency = 1
    h.OutlineTransparency = 0.4
    h.OutlineColor = Color3.fromRGB(0,70,160)
    h.Adornee = model
    h.Parent = model

    giftESP[model] = h
end

-- ==================== TOGGLES ====================
EspSection:Toggle({
    Title = "ESP Players (Verde)",
    Desc = "Mostra sobreviventes próximos",
    Callback = function(v) espPlayers = v end
})

EspSection:Toggle({
    Title = "ESP Killer (Vermelho)",
    Desc = "Mostra o Killer próximo",
    Callback = function(v) espKiller = v end
})

EspSection:Toggle({
    Title = "ESP Generator (Amarelo + %)",
    Desc = "Mostra geradores próximos e progresso",
    Callback = function(v) espGenerator = v end
})

EspSection:Toggle({
    Title = "ESP Gift (Azul)",
    Desc = "Mostra presentes próximos",
    Callback = function(v) espGift = v end
})

-- ==================== LOOP PRINCIPAL ====================
RunService.RenderStepped:Connect(function()
    local root = getRoot()
    if not root then return end

    -- PLAYERS
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp and inDistance(hrp.Position) then
                if espKiller and p.Team and p.Team.Name == "Killer" then
                    applyPlayerESP(p, Color3.fromRGB(255,0,0))
                elseif espPlayers then
                    applyPlayerESP(p, Color3.fromRGB(0,255,0))
                end
            else
                clearPlayerESP(p)
            end
        end
    end

    -- GENERATORS
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Generator" then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if espGenerator and part and inDistance(part.Position) then
                applyGeneratorESP(obj)
                generatorESP[obj].txt.Text =
                    "Generator [" .. getGeneratorPercent(obj) .. "]"
            elseif generatorESP[obj] then
                generatorESP[obj].h:Destroy()
                generatorESP[obj].gui:Destroy()
                generatorESP[obj] = nil
            end
        end
    end

    -- GIFTS
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Gift" then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if espGift and part and inDistance(part.Position) then
                applyGiftESP(obj)
            elseif giftESP[obj] then
                giftESP[obj]:Destroy()
                giftESP[obj] = nil
            end
        end
    end
end)

-- ==================== FINAL ====================
WindUI:Notify({
    Title = "Ped V1",
    Content = "Todos os ESPs ativos com limite de 600 studs",
    Duration = 6
})

print("Ped V1 carregado com sucesso")