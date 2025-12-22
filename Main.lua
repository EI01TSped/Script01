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
    Icon = "sword"
})

local CombatSection = CombatTab:Section({
    Title = "Funções",
    Closed = false
})

CombatSection:Button({
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

-- ==================== SKILL CHECK (NUNCA ERRAR) ====================
local skillCheckEnabled = false
local oldNamecall
local mt = getrawmetatable(game)

SurvivorSection:Toggle({
    Title = "Auto Skill Check (Nunca Errar)",
    Desc = "Acerta automaticamente todos os skill checks dos geradores",
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

-- ==================== GERADOR % ====================
local function getGeneratorPercent(model)
    local v = model:GetAttribute("RepairProgress")
    if typeof(v) ~= "number" then return "0%" end
    if v <= 1 then
        return math.floor(v * 100) .. "%"
    end
    return math.floor(v) .. "%"
end

-- ==================== TOGGLES ESP ====================
EspSection:Toggle({
    Title = "ESP Players (Verde)",
    Desc = "Mostra todos os sobreviventes em verde",
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
    Desc = "Destaca o Killer em vermelho",
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
    Desc = "Mostra os geradores com progresso em porcentagem",
    Default = false,
    Callback = function(v)
        espGenerator = v
    end
})

EspSection:Toggle({
    Title = "ESP Gift (Azul)",
    Desc = "Destaca os Gifts no mapa em azul escuro",
    Default = false,
    Callback = function(v)
        espGift = v
    end
})

-- ==================== FINAL ====================
WindUI:Notify({
    Title = "Ped V1 Carregado!",
    Content = "Script carregado com sucesso",
    Duration = 6
})

print("Ped V1 carregado com sucesso")