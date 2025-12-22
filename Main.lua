-- Ped V1 Script
-- Wind UI
local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

-- Serviços
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
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
    Title = "Combate",
    Icon = "crosshair"
})

local CombatSection = CombatTab:Section({
    Title = "Assistência",
    Closed = false
})

-- Aimlock
CombatSection:Button({
    Title = "Aimlock",
    Description = "Gruda a câmera no inimigo",
    Callback = function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/Aepione/Prensado/refs/heads/main/Prensado%20camlock"
        ))()
    end
})

-- ==================== SKILL CHECK (NUNCA ERRAR) ====================
local skillCheckEnabled = false
local oldNamecall
local mt = getrawmetatable(game)

CombatSection:Toggle({
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
                    args[1] = true -- força acerto
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

-- ==================== FUNÇÕES PLAYER ESP ====================
local function clearESP(player)
    if espCache[player] then
        for _, obj in ipairs(espCache[player]) do
            if obj and obj.Parent then obj:Destroy() end
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
    billboard.Size = UDim2.fromOffset(110, 18) -- tamanho fixo
    billboard.StudsOffset = Vector3.new(0, 2.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 1
    text.Text = player.Name
    text.TextColor3 = color
    text.TextSize = 14 -- FIXO (não cresce com distância)
    text.Font = Enum.Font.Gotham -- fonte fina
    text.TextStrokeTransparency = 0.8
    text.Parent = billboard

    espCache[player] = {highlight, billboard}
end

-- ==================== ESP OBJETOS ====================
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

local function scanModels(name, color, cache)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == name then
            applyObjectESP(obj, color, cache)
        end
    end
end

-- ==================== TOGGLES ESP ====================
EspSection:Toggle({
    Title = "ESP Players (Verde)",
    Default = false,
    Callback = function(v)
        espPlayers = v
        for _, p in ipairs(Players:GetPlayers()) do
            if espKiller and p.Team and p.Team.Name == "Killer" then
                -- prioridade Killer
            elseif v then
                applyPlayerESP(p, Color3.fromRGB(0,255,0))
            else
                clearESP(p)
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
    Title = "ESP Generator (Amarelo)",
    Default = false,
    Callback = function(v)
        espGenerator = v
        if v then
            scanModels("Generator", Color3.fromRGB(255,255,0), generatorESP)
        else
            for _, h in pairs(generatorESP) do if h.Parent then h:Destroy() end end
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
            scanModels("Gift", Color3.fromRGB(0,70,160), giftESP)
        else
            for _, h in pairs(giftESP) do if h.Parent then h:Destroy() end end
            giftESP = {}
        end
    end
})

-- ==================== EVENTOS (ANTI SUMIR ESP) ====================
local function refreshPlayer(player)
    task.wait(0.8)
    if espKiller and player.Team and player.Team.Name == "Killer" then
        applyPlayerESP(player, Color3.fromRGB(255,0,0))
    elseif espPlayers then
        applyPlayerESP(player, Color3.fromRGB(0,255,0))
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    p.CharacterAdded:Connect(function()
        refreshPlayer(p)
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        refreshPlayer(player)
    end)
end)

Workspace.DescendantAdded:Connect(function(obj)
    if espGenerator and obj:IsA("Model") and obj.Name == "Generator" then
        applyObjectESP(obj, Color3.fromRGB(255,255,0), generatorESP)
    end
    if espGift and obj:IsA("Model") and obj.Name == "Gift" then
        applyObjectESP(obj, Color3.fromRGB(0,70,160), giftESP)
    end
end)

-- ==================== FINAL ====================
WindUI:Notify({
    Title = "Ped V1 Carregado!",
    Content = "Script carregado com sucesso",
    Duration = 6
})

print("Ped V1 carregado com sucesso")