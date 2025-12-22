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
    Title = "v1.0",
    Icon = "github",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 0,
})

-- ==================== ABA KILLER ====================
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
                local method = getnamecallmethod()

                if method == "FireServer"
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

-- ==================== VARIÁVEIS ====================
local espPlayers, espKiller, espGenerator, espGift = false, false, false, false
local playerESP = {}
local generatorESP = {}
local giftESP = {}

-- ==================== FUNÇÕES ÚTEIS ====================
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

    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local h = Instance.new("Highlight")
    h.FillTransparency = 1
    h.OutlineTransparency = 0.4
    h.OutlineColor = color
    h.Adornee = player.Character
    h.Parent = player.Character

    playerESP[player] = {h}
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
    gui.Size = UDim2.fromOffset(120,22)
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

    generatorESP[model] = {h = h, gui = gui, txt = txt}
end

-- ==================== TOGGLES ====================
EspSection:Toggle({
    Title = "ESP Generator (Amarelo + %)",
    Desc = "Mostra geradores próximos com progresso",
    Callback = function(v)
        espGenerator = v
        if not v then
            for _, d in pairs(generatorESP) do
                if d.h then d.h:Destroy() end
                if d.gui then d.gui:Destroy() end
            end
            generatorESP = {}
        end
    end
})

-- ==================== UPDATE GLOBAL ====================
RunService.RenderStepped:Connect(function()
    if espGenerator then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Generator" then
                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if part and inDistance(part.Position) then
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
    end
end)

-- ==================== FINAL ====================
WindUI:Notify({
    Title = "Ped V1",
    Content = "ESP com limite de 600 studs ativo",
    Duration = 6
})

print("Ped V1 carregado com sucesso")