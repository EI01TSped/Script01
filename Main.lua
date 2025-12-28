-- Ped V1 Script (Optimized)
-- Wind UI
local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

-- Serviços
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ==================== CONFIG ====================
local CONFIG = {
    UPDATE_RATE = 0.5,
    GENERATOR_UPDATE_RATE = 7,
    MAX_DISTANCE = 1000, -- Distância máxima para renderizar ESP
    ESP_FADE_DISTANCE = 800, -- Distância onde ESP começa a desaparecer
    HIGHLIGHT_FILL = 0.1,
    TEXT_SIZE = 14,
    KILLER_COLOR = Color3.fromRGB(255, 50, 50),
    SURVIVOR_COLOR = Color3.fromRGB(50, 255, 50),
    GENERATOR_COLOR = Color3.fromRGB(255, 255, 50),
    GIFT_COLOR = Color3.fromRGB(50, 150, 255),
    EXIT_COLOR = Color3.fromRGB(255, 100, 255),
    LOCKER_COLOR = Color3.fromRGB(150, 150, 255)
}

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ==================== CACHE DE OBJETOS ====================
local cachedGenerators = {}
local cachedGifts = {}
local cachedLockers = {}
local cachedExits = {}

-- ==================== WINDOW ====================
local Window = WindUI:CreateWindow({
    Title = "Ped V1",
    Subtitle = "Optimized by yPedroX",
    Icon = "tv-minimal",
    Folder = "PedV1Config",
    Size = UDim2.fromOffset(620, 500),
    Transparent = true,
})

Window:Tag({
    Title = "v1.2 Optimized",
    Icon = "zap",
    Color = Color3.fromHex("#30ff6a"),
})

-- ==================== ABA COMBATE ====================
local CombatTab = Window:Tab({
    Title = "Killer",
    Icon = "sword"
})

local CombatSection = CombatTab:Section({
    Title = "Funções de Combate",
    Closed = false
})

local aimlockEnabled = false
local aimlockTarget = nil

CombatSection:Toggle({
    Title = "Aimlock Local",
    Description = "Trava a mira no inimigo mais próximo",
    Callback = function(v)
        aimlockEnabled = v
        if v then
            WindUI:Notify({
                Title = "Aimlock Ativado",
                Content = "Procurando alvo...",
                Duration = 3
            })
        end
    end
})

CombatSection:Button({
    Title = "Aimlock Avançado",
    Description = "Script externo mais completo",
    Callback = function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/Aepione/Prensado/refs/heads/main/Prensado%20camlock"
        ))()
    end
})

-- ==================== VISUAL ENHANCEMENTS ====================
local VisualTab = Window:Tab({
    Title = "Visual",
    Icon = "eye"
})

local VisualSection = VisualTab:Section({
    Title = "Melhorias Visuais",
    Closed = false
})

local brightnessValue = 1
local fogEnabled = false
local originalFogEnd

VisualSection:Slider({
    Title = "Brilho",
    Description = "Ajusta o brilho do jogo",
    Min = 0.1,
    Max = 5,
    Default = 1,
    Callback = function(v)
        brightnessValue = v
        Lighting.Brightness = v
    end
})

VisualSection:Toggle({
    Title = "Remover Névoa",
    Description = "Remove a névoa do mapa",
    Callback = function(v)
        fogEnabled = v
        if v then
            originalFogEnd = Lighting.FogEnd
            Lighting.FogEnd = 100000
        elseif originalFogEnd then
            Lighting.FogEnd = originalFogEnd
        end
    end
})

-- ==================== ABA SURVIVOR ====================
local SurvivorTab = Window:Tab({
    Title = "Survivor",
    Icon = "user"
})

local SurvivorSection = SurvivorTab:Section({
    Title = "Funções de Sobrevivente",
    Closed = false
})

-- ==================== AUTO SKILL CHECK ====================
local skillCheckEnabled = false
local skillCheckHook

SurvivorSection:Toggle({
    Title = "Auto Skill Check",
    Description = "Sempre acerta o skill check",
    Callback = function(v)
        skillCheckEnabled = v
        
        if v and not skillCheckHook then
            local mt = getrawmetatable(game)
            local oldNamecall = mt.__namecall
            
            skillCheckHook = hookfunction(mt.__namecall, function(self, ...)
                local method = getnamecallmethod()
                
                if method == "FireServer" 
                and tostring(self) == "SkillCheckResultEvent" 
                and skillCheckEnabled then
                    return oldNamecall(self, true)
                end
                
                return oldNamecall(self, ...)
            end)
            
            WindUI:Notify({
                Title = "Auto Skill Check",
                Content = "Ativado com hook seguro",
                Duration = 3
            })
        elseif not v and skillCheckHook then
            -- Restaurar hook original se necessário
        end
    end
})

SurvivorSection:Toggle({
    Title = "ESP Exits",
    Description = "Mostra saídas do mapa",
    Callback = function(v)
        CONFIG.SHOW_EXITS = v
    end
})

SurvivorSection:Toggle({
    Title = "ESP Lockers",
    Description = "Mostra armários para se esconder",
    Callback = function(v)
        CONFIG.SHOW_LOCKERS = v
    end
})

-- ==================== ABA ESP ====================
local EspTab = Window:Tab({
    Title = "ESP",
    Icon = "brush"
})

local EspSection = EspTab:Section({
    Title = "Configurações de ESP",
    Closed = false
})

-- ==================== VARIÁVEIS ESP ====================
local espPlayers = false
local espKiller = false
local espGenerator = false
local espGift = false
local espHealth = false
local espDistance = false

local playerESP = {}
local generatorESP = {}
local giftESP = {}
local exitESP = {}
local lockerESP = {}

-- ==================== FUNÇÕES UTILITÁRIAS ====================
local function calculateDistance(position1, position2)
    if not position1 or not position2 then return math.huge end
    return (position1 - position2).Magnitude
end

local function isVisible(part)
    if not part then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit
    local ray = Ray.new(origin, direction * CONFIG.MAX_DISTANCE)
    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
    
    return not hit or hit:IsDescendantOf(part.Parent)
end

local function getTransparencyBasedOnDistance(distance)
    if distance > CONFIG.ESP_FADE_DISTANCE then
        return 0.7 + (distance - CONFIG.ESP_FADE_DISTANCE) / 1000
    end
    return 0
end

-- ==================== LIMPEZA DE ESP ====================
local function clearESP(espTable, obj)
    local data = espTable[obj]
    if data then
        for _, element in pairs(data) do
            if typeof(element) == "Instance" and element.Parent then
                element:Destroy()
            end
        end
        espTable[obj] = nil
    end
end

local function cleanupAllESP()
    for p in pairs(playerESP) do clearESP(playerESP, p) end
    for g in pairs(generatorESP) do clearESP(generatorESP, g) end
    for g in pairs(giftESP) do clearESP(giftESP, g) end
    for e in pairs(exitESP) do clearESP(exitESP, e) end
    for l in pairs(lockerESP) do clearESP(lockerESP, l) end
end

-- ==================== PLAYER ESP ====================
local function getPlayerHealth(player)
    local char = player.Character
    if not char then return "N/A" end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        return math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
    end
    
    return "N/A"
end

local function updatePlayerESPData(player, data)
    if not data.part or not data.part.Parent then return false end
    
    local char = player.Character
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local distance = calculateDistance(Camera.CFrame.Position, hrp.Position)
    if distance > CONFIG.MAX_DISTANCE then
        data.hl.Enabled = false
        data.bb.Enabled = false
        return false
    end
    
    local isKiller = player.Team and player.Team.Name == "Killer"
    local shouldShow = (espPlayers and not isKiller) or (espKiller and isKiller)
    
    if not shouldShow then
        data.hl.Enabled = false
        data.bb.Enabled = false
        return true
    end
    
    local transparency = getTransparencyBasedOnDistance(distance)
    local visible = isVisible(hrp)
    
    data.hl.Enabled = true
    data.bb.Enabled = true
    
    -- Atualizar cor baseado na visibilidade
    local color = isKiller and CONFIG.KILLER_COLOR or CONFIG.SURVIVOR_COLOR
    if not visible then
        color = Color3.fromRGB(color.R * 150, color.G * 150, color.B * 150)
    end
    
    data.hl.OutlineColor = color
    data.hl.OutlineTransparency = transparency
    data.hl.FillTransparency = CONFIG.HIGHLIGHT_FILL + transparency
    
    -- Atualizar texto
    local text = player.Name
    if espDistance then
        text = text .. " [" .. math.floor(distance) .. "m]"
    end
    if espHealth then
        text = text .. " - " .. getPlayerHealth(player)
    end
    
    if data.txt then
        data.txt.Text = text
        data.txt.TextColor3 = color
        data.txt.TextTransparency = transparency
    end
    
    return true
end

local function applyPlayerESP(player)
    if player == LocalPlayer then return end
    
    local function setupESP()
        local char = player.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not hrp or not head then return end

        clearESP(playerESP, player)

        local hl = Instance.new("Highlight")
        hl.FillColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = CONFIG.HIGHLIGHT_FILL
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Enabled = false
        hl.Parent = char

        local bb = Instance.new("BillboardGui")
        bb.Adornee = head
        bb.Size = UDim2.fromOffset(200, 25)
        bb.StudsOffset = Vector3.new(0, 2.5, 0)
        bb.AlwaysOnTop = true
        bb.Enabled = false
        bb.Parent = head

        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.fromScale(1, 1)
        txt.BackgroundTransparency = 1
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = CONFIG.TEXT_SIZE
        txt.TextStrokeTransparency = 0.5
        txt.Parent = bb

        playerESP[player] = {
            hl = hl, 
            bb = bb, 
            txt = txt,
            part = hrp
        }
    end

    if player.Character then
        setupESP()
    end

    local connection
    connection = player.CharacterAdded:Connect(function()
        setupESP()
    end)
    
    table.insert(playerESP, {player = player, connection = connection})
end

-- ==================== GENERATOR ESP ====================
local function getGeneratorPercent(model)
    local progress = model:GetAttribute("RepairProgress")
    if typeof(progress) == "number" then
        local percent = progress <= 1 and (progress * 100) or progress
        return math.floor(percent)
    end
    return 0
end

local function updateGeneratorESP(model, data)
    if not data.part or not data.part.Parent then return false end
    
    local distance = calculateDistance(Camera.CFrame.Position, data.part.Position)
    if distance > CONFIG.MAX_DISTANCE then
        data.hl.Enabled = false
        data.bb.Enabled = false
        return false
    end
    
    if not espGenerator then
        data.hl.Enabled = false
        data.bb.Enabled = false
        return true
    end
    
    local transparency = getTransparencyBasedOnDistance(distance)
    local percent = getGeneratorPercent(model)
    
    data.hl.Enabled = true
    data.bb.Enabled = true
    data.hl.OutlineColor = CONFIG.GENERATOR_COLOR
    data.hl.OutlineTransparency = transparency
    data.hl.FillTransparency = CONFIG.HIGHLIGHT_FILL + transparency
    
    if data.txt then
        data.txt.Text = "Generator [" .. percent .. "%]"
        data.txt.TextColor3 = CONFIG.GENERATOR_COLOR
        data.txt.TextTransparency = transparency
    end
    
    return true
end

-- ==================== OBJECT SCANNER ====================
local function scanForObjects()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            if obj.Name == "Generator" and not generatorESP[obj] then
                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    local hl = Instance.new("Highlight")
                    hl.FillTransparency = CONFIG.HIGHLIGHT_FILL
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Enabled = false
                    hl.Parent = obj
                    
                    local bb = Instance.new("BillboardGui")
                    bb.Adornee = part
                    bb.Size = UDim2.fromOffset(150, 25)
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.AlwaysOnTop = true
                    bb.Enabled = false
                    bb.Parent = part
                    
                    local txt = Instance.new("TextLabel")
                    txt.Size = UDim2.fromScale(1, 1)
                    txt.BackgroundTransparency = 1
                    txt.Font = Enum.Font.GothamBold
                    txt.TextSize = CONFIG.TEXT_SIZE
                    txt.TextStrokeTransparency = 0.5
                    txt.Parent = bb
                    
                    generatorESP[obj] = {hl = hl, bb = bb, txt = txt, part = part}
                end
                
            elseif obj.Name == "Gift" and not giftESP[obj] then
                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    local hl = Instance.new("Highlight")
                    hl.FillTransparency = CONFIG.HIGHLIGHT_FILL
                    hl.OutlineColor = CONFIG.GIFT_COLOR
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Enabled = false
                    hl.Parent = obj
                    
                    giftESP[obj] = {hl = hl, part = part}
                end
                
            elseif (obj.Name:lower():find("exit") or obj.Name:lower():find("gate")) 
                   and not exitESP[obj] then
                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    local hl = Instance.new("Highlight")
                    hl.FillTransparency = CONFIG.HIGHLIGHT_FILL
                    hl.OutlineColor = CONFIG.EXIT_COLOR
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Enabled = false
                    hl.Parent = obj
                    
                    exitESP[obj] = {hl = hl, part = part}
                end
                
            elseif (obj.Name:lower():find("locker") or obj.Name:lower():find("closet")) 
                   and not lockerESP[obj] then
                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    local hl = Instance.new("Highlight")
                    hl.FillTransparency = CONFIG.HIGHLIGHT_FILL
                    hl.OutlineColor = CONFIG.LOCKER_COLOR
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Enabled = false
                    hl.Parent = obj
                    
                    lockerESP[obj] = {hl = hl, part = part}
                end
            end
        end
    end
end

-- ==================== TOGGLES ====================
EspSection:Toggle({
    Title = "ESP Players (Verde)",
    Description = "Mostra sobreviventes",
    Callback = function(v) 
        espPlayers = v 
        if not v then
            for _, data in pairs(playerESP) do
                if data.hl and not data.isKiller then
                    data.hl.Enabled = false
                    if data.bb then data.bb.Enabled = false end
                end
            end
        end
    end
})

EspSection:Toggle({
    Title = "ESP Killer (Vermelho)",
    Description = "Mostra o killer",
    Callback = function(v) 
        espKiller = v 
        if not v then
            for _, data in pairs(playerESP) do
                if data.hl and data.isKiller then
                    data.hl.Enabled = false
                    if data.bb then data.bb.Enabled = false end
                end
            end
        end
    end
})

EspSection:Toggle({
    Title = "ESP Generator (Amarelo)",
    Description = "Mostra geradores com porcentagem",
    Callback = function(v) 
        espGenerator = v 
        if not v then
            for _, data in pairs(generatorESP) do
                data.hl.Enabled = false
                if data.bb then data.bb.Enabled = false end
            end
        end
    end
})

EspSection:Toggle({
    Title = "ESP Gift (Azul)",
    Description = "Mostra presentes",
    Callback = function(v) 
        espGift = v 
        if not v then
            for _, data in pairs(giftESP) do
                data.hl.Enabled = false
            end
        end
    end
})

EspSection:Toggle({
    Title = "Mostrar Vida",
    Description = "Exibe vida dos players",
    Callback = function(v) espHealth = v end
})

EspSection:Toggle({
    Title = "Mostrar Distância",
    Description = "Exibe distância dos objetos",
    Callback = function(v) espDistance = v end
})

EspSection:Button({
    Title = "Limpar Todos ESP",
    Description = "Remove todos os ESP da tela",
    Callback = cleanupAllESP
})

-- ==================== AIMLOCK SISTEMA ====================
local function findNearestTarget()
    local nearest = nil
    local nearestDist = math.huge
    local localHRP = getHRP()
    
    if not localHRP then return nil end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (localHRP.Position - hrp.Position).Magnitude
                if dist < nearestDist and dist < 50 then
                    nearest = player
                    nearestDist = dist
                end
            end
        end
    end
    
    return nearest
end

-- ==================== LOOP PRINCIPAL OTIMIZADO ====================
local updateTimer = 0
local scanTimer = 0
local generatorUpdateTimer = 0

RunService.Heartbeat:Connect(function(dt)
    updateTimer += dt
    scanTimer += dt
    generatorUpdateTimer += dt
    
    -- AIMLOCK
    if aimlockEnabled then
        if not aimlockTarget or not aimlockTarget.Character then
            aimlockTarget = findNearestTarget()
        end
        
        if aimlockTarget and aimlockTarget.Character then
            local targetHRP = aimlockTarget.Character:FindFirstChild("HumanoidRootPart")
            local localChar = LocalPlayer.Character
            local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
            
            if targetHRP and localHRP then
                local direction = (targetHRP.Position - localHRP.Position).Unit
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHRP.Position)
            end
        end
    end
    
    -- SCAN PERIÓDICO (a cada 5 segundos)
    if scanTimer >= 5 then
        scanTimer = 0
        task.spawn(scanForObjects)
    end
    
    -- ATUALIZAÇÃO GERAL (a cada 0.5 segundos)
    if updateTimer >= CONFIG.UPDATE_RATE then
        updateTimer = 0
        
        -- Atualizar players
        for player, data in pairs(playerESP) do
            if not updatePlayerESPData(player, data) then
                clearESP(playerESP, player)
            end
        end
        
        -- Atualizar generators
        for model, data in pairs(generatorESP) do
            if not updateGeneratorESP(model, data) then
                clearESP(generatorESP, model)
            end
        end
        
        -- Atualizar gifts
        for model, data in pairs(giftESP) do
            if not data.part or not data.part.Parent then
                clearESP(giftESP, model)
            else
                local distance = calculateDistance(Camera.CFrame.Position, data.part.Position)
                data.hl.Enabled = espGift and distance <= CONFIG.MAX_DISTANCE
                if data.hl.Enabled then
                    local transparency = getTransparencyBasedOnDistance(distance)
                    data.hl.OutlineTransparency = transparency
                    data.hl.FillTransparency = CONFIG.HIGHLIGHT_FILL + transparency
                end
            end
        end
        
        -- Atualizar exits
        for model, data in pairs(exitESP) do
            if not data.part or not data.part.Parent then
                clearESP(exitESP, model)
            else
                local distance = calculateDistance(Camera.CFrame.Position, data.part.Position)
                data.hl.Enabled = CONFIG.SHOW_EXITS and distance <= CONFIG.MAX_DISTANCE
                if data.hl.Enabled then
                    local transparency = getTransparencyBasedOnDistance(distance)
                    data.hl.OutlineTransparency = transparency
                    data.hl.FillTransparency = CONFIG.HIGHLIGHT_FILL + transparency
                end
            end
        end
        
        -- Atualizar lockers
        for model, data in pairs(lockerESP) do
            if not data.part or not data.part.Parent then
                clearESP(lockerESP, model)
            else
                local distance = calculateDistance(Camera.CFrame.Position, data.part.Position)
                data.hl.Enabled = CONFIG.SHOW_LOCKERS and distance <= CONFIG.MAX_DISTANCE
                if data.hl.Enabled then
                    local transparency = getTransparencyBasedOnDistance(distance)
                    data.hl.OutlineTransparency = transparency
                    data.hl.FillTransparency = CONFIG.HIGHLIGHT_FILL + transparency
                end
            end
        end
    end
    
    -- Atualizar porcentagem dos generators (a cada 7 segundos)
    if generatorUpdateTimer >= CONFIG.GENERATOR_UPDATE_RATE then
        generatorUpdateTimer = 0
        for model, data in pairs(generatorESP) do
            if data.txt and data.part and data.part.Parent then
                local percent = getGeneratorPercent(model)
                data.txt.Text = "Generator [" .. percent .. "%]"
            end
        end
    end
end)

-- ==================== SCAN INICIAL ====================
task.spawn(function()
    wait(2) -- Esperar carregamento inicial
    scanForObjects()
    
    -- Monitorar novos objetos
    Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") then
            if obj.Name == "Generator" then
                task.wait(0.5) -- Esperar carregamento
                scanForObjects()
            elseif obj.Name == "Gift" or obj.Name:lower():find("exit") or obj.Name:lower():find("locker") then
                task.wait(0.5)
                scanForObjects()
            end
        end
    end)
end)

-- Players
for _, player in ipairs(Players:GetPlayers()) do
    applyPlayerESP(player)
end

Players.PlayerAdded:Connect(applyPlayerESP)

Players.PlayerRemoving:Connect(function(player)
    clearESP(playerESP, player)
end)

-- ==================== HOTKEYS ====================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.RightControl then
        aimlockEnabled = not aimlockEnabled
        WindUI:Notify({
            Title = "Aimlock",
            Content = aimlockEnabled and "Ativado" or "Desativado",
            Duration = 2
        })
    elseif input.KeyCode == Enum.KeyCode.Insert then
        Window:Toggle()
    end
end)

-- ==================== CLEANUP ON GAME LEAVE ====================
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "WindUI" then
        cleanupAllESP()
    end
end)

-- ==================== FINAL ====================
WindUI:Notify({
    Title = "Ped V1 Optimized Carregado!",
    Content = "Pressione Insert para abrir/fechar menu\nRightControl para aimlock",
    Duration = 8
})

print("🎮 Ped V1 (Optimized v1.2) carregado com sucesso!")
print("📊 ESP otimizado com limpeza automática")
print("🎯 Aimlock local ativável com RightControl")
print("👁️  Visual enhancements disponíveis")