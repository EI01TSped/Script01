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

-- ==================== CONFIG ====================
local MAX_DISTANCE = 600

local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function inDistance(part)
    local hrp = getHRP()
    return hrp and (hrp.Position - part.Position).Magnitude <= MAX_DISTANCE
end

-- ==================== WINDOW ====================
local Window = WindUI:CreateWindow({
    Title = "Ped V1",
    Subtitle = "by yPedroX",
    Icon = "tv-minimal",
    Folder = "PedV1Config",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
})

Window:Tag({
    Title = "v1.0",
    Icon = "github",
    Color = Color3.fromHex("#30ff6a"),
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

-- ==================== SKILL CHECK ====================
local skillCheckEnabled = false
local oldNamecall
local mt = getrawmetatable(game)

SurvivorSection:Toggle({
    Title = "Auto Skill Check (Nunca Errar)",
    Description = "Sempre acerta o skill check do Generator",
    Callback = function(v)
        skillCheckEnabled = v

        if v then
            setreadonly(mt, false)
            oldNamecall = mt.__namecall

            mt.__namecall = newcclosure(function(self, ...)
                local args = {...}
                if getnamecallmethod() == "FireServer"
                and tostring(self) == "SkillCheckResultEvent"
                and skillCheckEnabled then
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

local playerESP = {}
local generatorESP = {}
local giftESP = {}

-- ==================== PLAYER ESP ====================
local function applyPlayerESP(player, color)
    if player == LocalPlayer or not player.Character then return end
    if playerESP[player] then return end

    local char = player.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not hrp or not head then return end

    local hl = Instance.new("Highlight")
    hl.FillTransparency = 1
    hl.OutlineColor = color
    hl.Parent = char

    local bb = Instance.new("BillboardGui")
    bb.Adornee = head
    bb.Size = UDim2.fromOffset(110, 18)
    bb.StudsOffset = Vector3.new(0, 2.2, 0)
    bb.AlwaysOnTop = true
    bb.Parent = head

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.fromScale(1,1)
    txt.BackgroundTransparency = 1
    txt.Text = player.Name
    txt.TextColor3 = color
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 14
    txt.TextStrokeTransparency = 0.7
    txt.Parent = bb

    playerESP[player] = {hl = hl, bb = bb, part = hrp}
end

-- ==================== GENERATOR % ====================
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

    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local hl = Instance.new("Highlight")
    hl.FillTransparency = 1
    hl.OutlineColor = Color3.fromRGB(255,255,0)
    hl.Parent = model

    local bb = Instance.new("BillboardGui")
    bb.Adornee = part
    bb.Size = UDim2.fromOffset(130, 22)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = part

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.fromScale(1,1)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(255,255,0)
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 14
    txt.TextStrokeTransparency = 0.7
    txt.Parent = bb

    generatorESP[model] = {hl = hl, bb = bb, txt = txt, part = part}
end

-- ==================== GIFT ESP ====================
local function applyGiftESP(model)
    if giftESP[model] then return end

    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local hl = Instance.new("Highlight")
    hl.FillTransparency = 1
    hl.OutlineColor = Color3.fromRGB(0,70,160)
    hl.Parent = model

    giftESP[model] = {hl = hl, part = part}
end

-- ==================== TOGGLES ====================
EspSection:Toggle({
    Title = "ESP Players (Verde)",
    Callback = function(v) espPlayers = v end
})

EspSection:Toggle({
    Title = "ESP Killer (Vermelho)",
    Callback = function(v) espKiller = v end
})

EspSection:Toggle({
    Title = "ESP Generator (Amarelo + %)",
    Callback = function(v) espGenerator = v end
})

EspSection:Toggle({
    Title = "ESP Gift (Azul)",
    Callback = function(v) espGift = v end
})

-- ==================== UPDATE LEVE (SEM LAG) ====================
local timer = 0
RunService.Heartbeat:Connect(function(dt)
    timer += dt
    if timer < 0.25 then return end
    timer = 0

    for p,d in pairs(playerESP) do
        local ok = inDistance(d.part)
        d.hl.Enabled = ok and ((espPlayers) or (espKiller and p.Team and p.Team.Name == "Killer"))
        d.bb.Enabled = d.hl.Enabled
    end

    for m,d in pairs(generatorESP) do
        local ok = espGenerator and inDistance(d.part)
        d.hl.Enabled = ok
        d.bb.Enabled = ok
        if ok then
            d.txt.Text = "Generator [" .. getGeneratorPercent(m) .. "]"
        end
    end

    for _,d in pairs(giftESP) do
        d.hl.Enabled = espGift and inDistance(d.part)
    end
end)

-- ==================== SCAN INICIAL ====================
for _,o in ipairs(Workspace:GetDescendants()) do
    if o:IsA("Model") then
        if o.Name == "Generator" then
            applyGeneratorESP(o)
        elseif o.Name == "Gift" then
            applyGiftESP(o)
        end
    end
end

for _,p in ipairs(Players:GetPlayers()) do
    applyPlayerESP(p, Color3.fromRGB(0,255,0))
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Wait()
    applyPlayerESP(p, Color3.fromRGB(0,255,0))
end)

-- ==================== FINAL ====================
WindUI:Notify({
    Title = "Ped V1 Carregado!",
    Content = "ESP funcionando + limite 600 studs (sem lag)",
    Duration = 6
})

print("Ped V1 carregado com sucesso")