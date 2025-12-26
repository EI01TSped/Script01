-- Ped V1 Script (Optimized)
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
local UPDATE_RATE = 0.5 -- Taxa de atualização do ESP
local GENERATOR_UPDATE_RATE = 7 -- Atualiza porcentagem do gerador a cada 7 segundos

local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
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
    Title = "v1.0 Optimized",
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
setreadonly(mt, false)

SurvivorSection:Toggle({
    Title = "Auto Skill Check (Nunca Errar)",
    Description = "Sempre acerta o skill check do Generator",
    Callback = function(v)
        skillCheckEnabled = v

        if v and not oldNamecall then
            oldNamecall = mt.__namecall

            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                
                if method == "FireServer" 
                and tostring(self) == "SkillCheckResultEvent" 
                and skillCheckEnabled then
                    args[1] = true
                end
                
                return oldNamecall(self, unpack(args))
            end)
        end
    end
})

setreadonly(mt, true)

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

-- ==================== LIMPEZA DE ESP ====================
local function clearESP(espTable, obj)
    local data = espTable[obj]
    if data then
        if data.hl and data.hl.Parent then data.hl:Destroy() end
        if data.bb and data.bb.Parent then data.bb:Destroy() end
        espTable[obj] = nil
    end
end

-- ==================== PLAYER ESP ====================
local function applyPlayerESP(player)
    if player == LocalPlayer then return end
    
    local function setupESP()
        local char = player.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not hrp or not head then return end

        -- Remove ESP antigo se existir
        clearESP(playerESP, player)

        -- Determina cor baseado no time
        local isKiller = player.Team and player.Team.Name == "Killer"
        local color = isKiller and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)

        local hl = Instance.new("Highlight")
        hl.FillTransparency = 1
        hl.OutlineColor = color
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Enabled = false
        hl.Parent = char

        local bb = Instance.new("BillboardGui")
        bb.Adornee = head
        bb.Size = UDim2.fromOffset(110, 18)
        bb.StudsOffset = Vector3.new(0, 2.2, 0)
        bb.AlwaysOnTop = true
        bb.Enabled = false
        bb.Parent = head

        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.fromScale(1, 1)
        txt.BackgroundTransparency = 1
        txt.Text = player.Name
        txt.TextColor3 = color
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 14
        txt.TextStrokeTransparency = 0.5
        txt.Parent = bb

        playerESP[player] = {
            hl = hl, 
            bb = bb, 
            part = hrp, 
            isKiller = isKiller,
            lastUpdate = 0
        }
    end

    if player.Character then
        setupESP()
    end

    player.CharacterAdded:Connect(setupESP)
end

-- ==================== GENERATOR ESP ====================
local function getGeneratorPercent(model)
    local v = model:GetAttribute("RepairProgress")
    if typeof(v) ~= "number" then return "0%" end
    local percent = v <= 1 and (v * 100) or v
    return math.floor(percent) .. "%"
end

local function applyGeneratorESP(model)
    if generatorESP[model] then return end

    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local hl = Instance.new("Highlight")
    hl.FillTransparency = 1
    hl.OutlineColor = Color3.fromRGB(255, 255, 0)
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = false
    hl.Parent = model

    local bb = Instance.new("BillboardGui")
    bb.Adornee = part
    bb.Size = UDim2.fromOffset(130, 22)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Enabled = false
    bb.Parent = part

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.fromScale(1, 1)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(255, 255, 0)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 14
    txt.TextStrokeTransparency = 0.5
    txt.Parent = bb

    generatorESP[model] = {
        hl = hl, 
        bb = bb, 
        txt = txt, 
        part = part,
        lastUpdate = 0
    }
end

-- ==================== GIFT ESP ====================
local function applyGiftESP(model)
    if giftESP[model] then return end

    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local hl = Instance.new("Highlight")
    hl.FillTransparency = 1
    hl.OutlineColor = Color3.fromRGB(0, 150, 255)
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = false
    hl.Parent = model

    giftESP[model] = {
        hl = hl, 
        part = part,
        lastUpdate = 0
    }
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

-- ==================== UPDATE OTIMIZADO ====================
local updateTimer = 0
local generatorUpdateTimer = 0

RunService.Heartbeat:Connect(function(dt)
    updateTimer += dt
    generatorUpdateTimer += dt
    
    if updateTimer < UPDATE_RATE then return end
    updateTimer = 0

    -- Limpa ESP de objetos destruídos
    for p, d in pairs(playerESP) do
        if not p.Parent or not d.part.Parent then
            clearESP(playerESP, p)
        end
    end

    for m, d in pairs(generatorESP) do
        if not m.Parent or not d.part.Parent then
            clearESP(generatorESP, m)
        end
    end

    for m, d in pairs(giftESP) do
        if not m.Parent or not d.part.Parent then
            clearESP(giftESP, m)
        end
    end

    -- Atualiza ESP de players (sem limite de distância)
    for p, d in pairs(playerESP) do
        if d.part and d.part.Parent then
            local shouldShow = (espPlayers and not d.isKiller) or (espKiller and d.isKiller)
            d.hl.Enabled = shouldShow
            d.bb.Enabled = shouldShow
        end
    end

    -- Atualiza ESP de generators (sem limite de distância)
    for m, d in pairs(generatorESP) do
        if d.part and d.part.Parent then
            d.hl.Enabled = espGenerator
            d.bb.Enabled = espGenerator
            
            -- Atualiza porcentagem apenas a cada 7 segundos
            if espGenerator and generatorUpdateTimer >= GENERATOR_UPDATE_RATE then
                d.txt.Text = "Generator [" .. getGeneratorPercent(m) .. "]"
            end
        end
    end

    -- Reseta timer de atualização dos generators
    if generatorUpdateTimer >= GENERATOR_UPDATE_RATE then
        generatorUpdateTimer = 0
    end

    -- Atualiza ESP de gifts (sem limite de distância)
    for m, d in pairs(giftESP) do
        if d.part and d.part.Parent then
            d.hl.Enabled = espGift
        end
    end
end)

-- ==================== SCAN INICIAL ====================
task.spawn(function()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            if obj.Name == "Generator" then
                applyGeneratorESP(obj)
            elseif obj.Name == "Gift" then
                applyGiftESP(obj)
            end
        end
    end
end)

-- Monitora novos objetos
Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") then
        if obj.Name == "Generator" then
            applyGeneratorESP(obj)
        elseif obj.Name == "Gift" then
            applyGiftESP(obj)
        end
    end
end)

-- Players
for _, p in ipairs(Players:GetPlayers()) do
    applyPlayerESP(p)
end

Players.PlayerAdded:Connect(applyPlayerESP)

Players.PlayerRemoving:Connect(function(p)
    clearESP(playerESP, p)
end)

-- ==================== FINAL ====================
WindUI:Notify({
    Title = "Ped V1 Carregado!",
    Content = "ESP sem limite de distância + otimizado",
    Duration = 6
})

print("Ped V1 (Optimized) carregado com sucesso")