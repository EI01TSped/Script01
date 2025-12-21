-- Ped V1 Script
-- Carregando Wind UI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Serviços
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Criar janela
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

-- ==================== ABA PRINCIPAL ====================
local PerformanceTab = Window:Tab({
    Title = "Principal",
    Icon = "tool-case"
})

local PerformanceSection = PerformanceTab:Section({
    Title = "Otimização",
    Closed = true
})

PerformanceSection:Button({
    Title = "Anti Lag TSB",
    Description = "Remove lag do The Strongest Battlegrounds",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/The-Strongest-Battlegrounds-Antilag-TSB-18306"))()
        WindUI:Notify({
            Title = "Anti Lag Ativado!",
            Content = "Otimização aplicada ao jogo",
            Duration = 3
        })
    end
})

-- ==================== ABA COMBATE ====================
local CombatTab = Window:Tab({
    Title = "Combate",
    Icon = "crosshair"
})

local CombatSection = CombatTab:Section({
    Title = "Assistência de Mira",
    Closed = false
})

CombatSection:Button({
    Title = "Aimlock",
    Description = "Gruda a câmera no inimigo mais próximo",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Aepione/Prensado/refs/heads/main/Prensado%20camlock"))()
        WindUI:Notify({
            Title = "Aimlock Carregado!",
            Content = "Sistema de mira ativado",
            Duration = 3
        })
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

-- ==================== VARIÁVEIS ====================
local espPlayersEnabled = false
local espKillerEnabled = false
local espGeneratorEnabled = false
local espGiftEnabled = false

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
    billboard.Size = UDim2.new(0, 120, 0, 22)
    billboard.StudsOffset = Vector3.new(0, 2.3, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = head
    billboard.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = player.Name
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.TextColor3 = color
    text.TextStrokeTransparency = 0.5
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

-- ==================== TOGGLES ====================
EspSection:Toggle({
    Title = "ESP Players (Verde)",
    Default = false,
    Callback = function(v)
        espPlayersEnabled = v
        for _, p in ipairs(Players:GetPlayers()) do
            if espKillerEnabled and p.Team and p.Team.Name == "Killer" then
                -- Killer tem prioridade
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
        espKillerEnabled = v
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
        espGeneratorEnabled = v
        if v then
            scanModels("Generator", Color3.fromRGB(255,255,0), generatorESP)
        else
            for _, h in pairs(generatorESP) do if h.Parent then h:Destroy() end end
            generatorESP = {}
        end
    end
})

EspSection:Toggle({
    Title = "ESP Gift (Azul Escuro)",
    Default = false,
    Callback = function(v)
        espGiftEnabled = v
        if v then
            scanModels("Gift", Color3.fromRGB(0, 70, 160), giftESP)
        else
            for _, h in pairs(giftESP) do if h.Parent then h:Destroy() end end
            giftESP = {}
        end
    end
})

-- ==================== EVENTOS ====================
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if espKillerEnabled and player.Team and player.Team.Name == "Killer" then
            applyPlayerESP(player, Color3.fromRGB(255,0,0))
        elseif espPlayersEnabled then
            applyPlayerESP(player, Color3.fromRGB(0,255,0))
        end
    end)
end)

Workspace.DescendantAdded:Connect(function(obj)
    if espGeneratorEnabled and obj:IsA("Model") and obj.Name == "Generator" then
        applyObjectESP(obj, Color3.fromRGB(255,255,0), generatorESP)
    end
    if espGiftEnabled and obj:IsA("Model") and obj.Name == "Gift" then
        applyObjectESP(obj, Color3.fromRGB(0,70,160), giftESP)
    end
end)

-- ==================== FINAL ====================
WindUI:Notify({
    Title = "Ped V1 Carregado!",
    Content = "ESP avançado carregado sem conflitos",
    Duration = 7
})

print("Ped V1 carregado com sucesso")
