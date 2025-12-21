-- Ped V1 Script
-- Carregando Wind UI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Serviços
local Players = game:GetService("Players")
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
local UtilTab = Window:Tab({
    Title = "ESP",
    Icon = "brush"
})

local UtilSection = UtilTab:Section({
    Title = "ESP Config",
    Closed = false
})

-- ==================== SISTEMA ESP ====================
local espEnabled = false
local espObjects = {}

local function createESP(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    if espObjects[player] then return end

    local char = player.Character
    local head = char:FindFirstChild("Head")
    if not head then return end

    -- Highlight (contorno)
    local highlight = Instance.new("Highlight")
    highlight.Name = "PedESP"
    highlight.Adornee = char
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
    highlight.Parent = char

    -- Nome
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PedESPName"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = player.Name
    text.TextColor3 = Color3.fromRGB(0, 255, 0)
    text.TextStrokeTransparency = 0.4
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.Parent = billboard

    espObjects[player] = {highlight, billboard}
end

local function removeESP(player)
    if espObjects[player] then
        for _, obj in ipairs(espObjects[player]) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
        espObjects[player] = nil
    end
end

local function enableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        createESP(player)
    end

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            task.wait(1)
            if espEnabled then
                createESP(player)
            end
        end)
    end)
end

local function disableESP()
    for player, _ in pairs(espObjects) do
        removeESP(player)
    end
end

-- ==================== TOGGLE ESP ====================
UtilSection:Toggle({
    Title = "ESP Players",
    Description = "Contorno verde e nome dos jogadores",
    Default = false,
    Callback = function(value)
        espEnabled = value

        if value then
            enableESP()
            WindUI:Notify({
                Title = "ESP Ativado",
                Content = "ESP leve ligado",
                Duration = 3
            })
        else
            disableESP()
            WindUI:Notify({
                Title = "ESP Desativado",
                Content = "ESP desligado",
                Duration = 3
            })
        end
    end
})

-- ==================== NOTIFICAÇÃO FINAL ====================
WindUI:Notify({
    Title = "Ped V1 Carregado!",
    Content = "Script desenvolvido por yPedroX",
    Duration = 7
})

print("==========================================")
print("Ped V1 - Carregado com Sucesso!")
print("Desenvolvido por: yPedroX")
print("==========================================")
