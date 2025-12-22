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
    Title = "v1.0",
    Icon = "github",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 0,
})

-- ==================== ABA COMBATE ====================
local CombatTab = Window:Tab({
    Title = "Killer",
    Icon = "crosshair"
})

local CombatSection = CombatTab:Section({
    Title = "Assistência",
    Closed = false
})

CombatSection:Button({
    Title = "Aimlock",
    Description = "Gruda a câmera no inimigo",
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

-- ==================== SKILL CHECK (NUNCA ERRAR) ====================
local skillCheckEnabled = false
local oldNamecall
local mt = getrawmetatable(game)

SurvivorSection:Toggle({
    Title = "Auto Skill Check (Nunca Errar)",
    Description = "Sempre acerta o skill check do Generator",
    Default = false,
    Callback = function(v)
        skillCheckEnabled = v

        if v then
            setreadonly(mt, false)
            oldNamecall = mt.__namecall

            mt.__namecall = newcclosure(function(self, ...)
                local args = {...}
                local method = getnamecallmethod()

                if skillCheckEnabled
                    and method == "FireServer"
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
    Title = "ESP Config",
    Closed = false
})

-- ==================== VARIÁVEIS ESP ====================
local espPlayers = false
local espKiller = false
local espGenerator = false
local espGift = false

local espCache = {}
local generatorESP = {}
local giftESP = {}

-- ==================== PLAYER ESP ====================
local function clearESP(player)
    if espCache[player] then
        for _, v in ipairs(espCache[player]) do
            if v and v.Parent then v:Destroy() end
        end
        espCache[player] = nil
    end
end

local function applyPlayerESP(player, color)
    if player == LocalPlayer then return end
    if not player.Character then return end

    clearESP(player)

    local char = player.Character
    local head = char:FindFirstChild("Head")
    if not head then return end

    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0.5
    highlight.OutlineColor = color
    highlight.Adornee = char
    highlight.Parent = char

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = head
    billboard.Size = UDim2.fromOffset(110, 18)
    billboard.StudsOffset = Vector3.new(0, 2.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1,1)
    text.BackgroundTransparency = 1
    text.Text = player.Name
    text.TextColor3 = color
    text.TextSize = 14
    text.Font = Enum.Font.Gotham
    text.TextStrokeTransparency = 0.8
    text.Parent = billboard

    espCache[player] = {highlight, billboard}
end

-- ==================== OBJECT ESP ====================
local function applyObjectESP(model, color, cache)
    if cache[model] then return end

    local h = Instance.new("Highlight")
    h.FillTransparency = 1
    h.OutlineTransparency = 0.4
    h.OutlineColor = color
    h.Adornee = model
    h.Parent = model

    cache[model] = h
end

-- ==================== GERADOR % ====================
local function getGeneratorPercent(model)
    local v = model:GetAttribute("RepairProgress")
    if typeof(v) ~= "number" then return "0%" end
    if v <= 1 then
        return math.floor(v * 100) .. "%"
    end
    return math.floor(v) .. "%"
end

local function applyGeneratorESP(model)
    if generatorESP[model] then return end

    applyObjectESP(model, Color3.fromRGB(255,255,0), generatorESP)

    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local gui = Instance.new("BillboardGui")
    gui.Adornee = part
    gui.Size = UDim2.fromOffset(130, 22)
    gui.StudsOffset = Vector3.new(0, 3, 0)
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

    generatorESP[model] = {h = generatorESP[model], gui = gui, txt = txt}
end

-- ==================== TOGGLES ESP ====================
EspSection:Toggle({
    Title = "ESP Players (Verde)",
    Default = false,
    Callback = function(v)
        espPlayers = v
        for _, p in ipairs(Players:GetPlayers()) do
            if not (espKiller and p.Team and p.Team.Name == "Killer") then
                if v then
                    applyPlayerESP(p, Color3.fromRGB(0,255,0))
                else
                    clearESP(p)
                end
            end
        end
    end
})

EspSection:Toggle({
    Title = "ESP Killer (Vermelho)",
    Default = false,
    Callback = function(v)
        espKiller = v
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Team and p.Team.Name == "Killer" then
                if v then
                    applyPlayerESP(p, Color3.fromRGB(255,0,0))
                else
                    clearESP(p)
                end
            end
        end
    end
})

EspSection:Toggle({
    Title = "ESP Generator (Amarelo + %)",
    Default = false,
    Callback = function(v)
        espGenerator = v
        if v then
            for _, o in ipairs(Workspace:GetDescendants()) do
                if o:IsA("Model") and o.Name == "Generator" then
                    applyGeneratorESP(o)
                end
            end
        else
            for _, d in pairs(generatorESP) do
                if d.gui then d.gui:Destroy() end
                if d.h then d.h:Destroy() end
            end
            generatorESP = {}
        end
    end
})

EspSection:Toggle({
    Title = "ESP Gift (Azul)",
    Default = false,
    Callback = function(v)
        espGift = v
        if v then
            for _, o in ipairs(Workspace:GetDescendants()) do
                if o:IsA("Model") and o.Name == "Gift" then
                    applyObjectESP(o, Color3.fromRGB(0,70,160), giftESP)
                end
            end
        else
            for _, h in pairs(giftESP) do
                if h.Parent then h:Destroy() end
            end
            giftESP = {}
        end
    end
})

-- ==================== UPDATE % ====================
RunService.RenderStepped:Connect(function()
    if not espGenerator then return end
    for model, d in pairs(generatorESP) do
        if d.txt and model then
            d.txt.Text = "Generator [" .. getGeneratorPercent(model) .. "]"
        end
    end
end)

-- ==================== FINAL ====================
WindUI:Notify({
    Title = "Ped V1 Carregado!",
    Content = "Script carregado com sucesso",
    Duration = 6
})

print("Ped V1 carregado com sucesso")