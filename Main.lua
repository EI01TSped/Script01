-- Carregar Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Criar janela
local Window = Rayfield:CreateWindow({
    Name = "Survival System",
    LoadingTitle = "Carregando...",
    LoadingSubtitle = "Teleporte + Hitbox Expander",
    ConfigurationSaving = {Enabled = false}
})

-- Serviços
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- ============================================
-- CONFIGURAÇÕES
-- ============================================
local teleporting = false
local cooldownTime = 10
local buttonReferences = {}

-- Hitbox Expander
local HITBOX_SIZE = 15
local HEAD_SIZE = 8
local HITBOX_ENABLED = false
local HEAD_ENABLED = false
local expandedHitboxes = {}

-- ============================================
-- TELEPORTE (MANTIDO IGUAL)
-- ============================================
local TeleportLocations = {
    ["Alien Gun"] = {pos = Vector3.new(114.22046661376953, 335.4999084472656, 565.9104614257812), returnToOrigin = true},
    ["Base Segura"] = {pos = Vector3.new(-51.438236236572266, 313.5002746582031, 292.1361999511719), returnToOrigin = false},
    ["Energia"] = {pos = Vector3.new(126.81755828857422, 323.4999694824219, 600.4284057617188), returnToOrigin = true},
    ["Roleta"] = {pos = Vector3.new(111.14323425292969, 313.4999694824219, 350.11810302734375), returnToOrigin = true},
    ["Upgrade"] = {pos = Vector3.new(111.16646575927734, 335.4999694824219, 66.77725982666016), returnToOrigin = true},
    ["2X dano"] = {pos = Vector3.new(98.72466278076172, 271.7002258300781, 176.35610961914062), returnToOrigin = true},
    ["Revive"] = {pos = Vector3.new(183.5561981201172, 313.4999694824219, 434.4063720703125), returnToOrigin = true},
    ["Cura Bala"] = {pos = Vector3.new(-130.79737854003906, 293.4999694824219, 354.90643310546875), returnToOrigin = true},
    ["Colete"] = {pos = Vector3.new(-169.19932556152344, 293.5002746582031, 317.37908935546875), returnToOrigin = true},
    ["Speed Cola"] = {pos = Vector3.new(106.36351013183594, 323.4999694824219, 698.6314697265625), returnToOrigin = true},
    ["Eletric Cherry"] = {pos = Vector3.new(-48.826568603515625, 293.49969482421875, 337.36962890625), returnToOrigin = true}
}

local LocationEmojis = {
    ["Alien Gun"] = "🚀", ["Base Segura"] = "🏠", ["Energia"] = "⚡",
    ["Roleta"] = "🧰", ["Upgrade"] = "🧩", ["2X dano"] = "🔫",
    ["Revive"] = "💙", ["Cura Bala"] = "🍭", ["Colete"] = "🦺",
    ["Speed Cola"] = "☘️", ["Eletric Cherry"] = "🟤"
}

local function teleportToLocation(locationName, teleportData)
    if teleporting then return end
    
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    teleporting = true
    local originalCFrame = hrp.CFrame
    
    hrp.CFrame = CFrame.new(teleportData.pos)
    
    Rayfield:Notify({
        Title = "Teleportado!",
        Content = locationName .. (teleportData.returnToOrigin and " (5 segundos)" : ""),
        Duration = 3
    })
    
    if buttonReferences[locationName] then
        buttonReferences[locationName]:Set("⏳ Teleportando...")
    end
    
    if teleportData.returnToOrigin then
        wait(5)
        hrp.CFrame = originalCFrame
        Rayfield:Notify({
            Title = "Retornado!",
            Content = "Voltou para posição original",
            Duration = 3
        })
    end
    
    if buttonReferences[locationName] then
        local startTime = os.time()
        while os.time() - startTime < cooldownTime do
            local remaining = cooldownTime - (os.time() - startTime)
            buttonReferences[locationName]:Set("⏳ " .. math.floor(remaining) .. "s")
            wait(1)
        end
        buttonReferences[locationName]:Set(LocationEmojis[locationName] .. " " .. locationName)
    end
    
    teleporting = false
end

-- ============================================
-- HITBOX EXPANDER INVISÍVEL (CORRIGIDO)
-- ============================================
local function createInvisibleHitbox(originalPart, size, isHead)
    local hitbox = Instance.new("Part")
    hitbox.Name = "InvisibleHitbox_" .. (isHead and "Head" : "Body")
    hitbox.Size = Vector3.new(size, size, size)
    hitbox.CFrame = originalPart.CFrame
    hitbox.Anchored = false
    hitbox.CanCollide = false
    hitbox.Transparency = 1 -- TOTALMENTE INVISÍVEL
    hitbox.Material = Enum.Material.SmoothPlastic
    hitbox.CastShadow = false
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = originalPart
    weld.Part1 = hitbox
    weld.Parent = hitbox
    
    return hitbox
end

local function expandMonster(monster)
    if not monster or expandedHitboxes[monster] then return end
    
    local hrp = monster:FindFirstChild("HumanoidRootPart")
    local head = monster:FindFirstChild("Head")
    if not hrp then return end
    
    local hitboxes = {}
    
    if HITBOX_ENABLED then
        hitboxes.body = createInvisibleHitbox(hrp, HITBOX_SIZE, false)
        hitboxes.body.Parent = monster
    end
    
    if HEAD_ENABLED and head then
        hitboxes.head = createInvisibleHitbox(head, HEAD_SIZE, true)
        hitboxes.head.Parent = monster
    end
    
    if next(hitboxes) ~= nil then
        expandedHitboxes[monster] = hitboxes
    end
end

local function restoreMonster(monster)
    local hitboxes = expandedHitboxes[monster]
    if not hitboxes then return end
    
    if hitboxes.body then hitboxes.body:Destroy() end
    if hitboxes.head then hitboxes.head:Destroy() end
    
    expandedHitboxes[monster] = nil
end

local function updateAllHitboxes()
    local killers = Workspace:FindFirstChild("Killers")
    if not killers then return end
    
    for monster, _ in pairs(expandedHitboxes) do
        if not monster.Parent then
            restoreMonster(monster)
        end
    end
    
    for _, monster in pairs(killers:GetChildren()) do
        if monster:IsA("Model") then
            if HITBOX_ENABLED or HEAD_ENABLED then
                expandMonster(monster)
            else
                restoreMonster(monster)
            end
        end
    end
end

-- ============================================
-- INTERFACE (MESMA DO SEU SCRIPT)
-- ============================================

-- Categorias
local function createTeleportButton(tab, locationName, teleportData, emoji)
    local button = tab:CreateButton({
        Name = emoji .. " " .. locationName,
        Callback = function()
            teleportToLocation(locationName, teleportData)
        end
    })
    buttonReferences[locationName] = button
    return button
end

local function createCategory(tabName, iconId, categoryTitle, locations)
    local Tab = Window:CreateTab(tabName, iconId)
    Tab:CreateSection("📌 " .. categoryTitle)
    Tab:CreateLabel("Cooldown: " .. cooldownTime .. " segundos")
    Tab:CreateSection("📍 Locais Disponíveis")
    
    for locationName, teleportData in pairs(locations) do
        local emoji = LocationEmojis[locationName] or "📍"
        createTeleportButton(Tab, locationName, teleportData, emoji)
    end
    
    return Tab
end

-- Armas
createCategory("Armas", 7733765391, "Armas", {
    ["Alien Gun"] = TeleportLocations["Alien Gun"]
})

-- Bases
createCategory("Bases", 4483362458, "Bases e Locais", {
    ["Base Segura"] = TeleportLocations["Base Segura"],
    ["Energia"] = TeleportLocations["Energia"],
    ["Roleta"] = TeleportLocations["Roleta"],
    ["Upgrade"] = TeleportLocations["Upgrade"]
})

-- Powers
createCategory("Powers", 9753762469, "Poderes e Buffs", {
    ["2X dano"] = TeleportLocations["2X dano"],
    ["Revive"] = TeleportLocations["Revive"],
    ["Cura Bala"] = TeleportLocations["Cura Bala"],
    ["Colete"] = TeleportLocations["Colete"],
    ["Speed Cola"] = TeleportLocations["Speed Cola"],
    ["Eletric Cherry"] = TeleportLocations["Eletric Cherry"]
})

-- ============================================
-- ABA DO HITBOX EXPANDER (SIMPLIFICADA)
-- ============================================
local HitboxTab = Window:CreateTab("Hitbox Expander", 6031300884)

HitboxTab:CreateSection("🎯 Expansor de Hitbox")
HitboxTab:CreateLabel("Hitboxes expandidas são INVISÍVEIS")

-- Toggles
HitboxTab:CreateToggle({
    Name = "Ativar Hitbox do Corpo",
    CurrentValue = HITBOX_ENABLED,
    Callback = function(value)
        HITBOX_ENABLED = value
        updateAllHitboxes()
    end
})

HitboxTab:CreateToggle({
    Name = "Ativar Hitbox da Cabeça",
    CurrentValue = HEAD_ENABLED,
    Callback = function(value)
        HEAD_ENABLED = value
        updateAllHitboxes()
    end
})

-- Sliders
HitboxTab:CreateSlider({
    Name = "Tamanho do Corpo",
    Range = {5, 50},
    Increment = 1,
    Suffix = " unidades",
    CurrentValue = HITBOX_SIZE,
    Callback = function(value)
        HITBOX_SIZE = value
        if HITBOX_ENABLED then
            updateAllHitboxes()
        end
    end
})

HitboxTab:CreateSlider({
    Name = "Tamanho da Cabeça",
    Range = {3, 20},
    Increment = 1,
    Suffix = " unidades",
    CurrentValue = HEAD_SIZE,
    Callback = function(value)
        HEAD_SIZE = value
        if HEAD_ENABLED then
            updateAllHitboxes()
        end
    end
})

HitboxTab:CreateButton({
    Name = "🔄 Atualizar Hitboxes",
    Callback = updateAllHitboxes
})

-- Informações
HitboxTab:CreateSection("📊 Informações")
HitboxTab:CreateLabel("Corpo: " .. HITBOX_SIZE .. " | Cabeça: " .. HEAD_SIZE)

-- ============================================
-- ABA DE INFORMAÇÕES
-- ============================================
local InfoTab = Window:CreateTab("Informações", 6031068421)

InfoTab:CreateSection("📋 Sistema Completo")
InfoTab:CreateLabel("Teleport System + Hitbox Expander")
InfoTab:CreateLabel("Total de locais: 11")
InfoTab:CreateLabel("Cooldown: " .. cooldownTime .. "s")

InfoTab:CreateSection("⚙️ Configurações")
InfoTab:CreateLabel("Base Segura: Teleporte permanente")
InfoTab:CreateLabel("Hitbox: Corpo e Cabeça ajustáveis")
InfoTab:CreateLabel("Hitboxes são INVISÍVEIS")

-- ============================================
-- INICIALIZAÇÃO
-- ============================================
spawn(function()
    wait(2)
    
    local killers = Workspace:FindFirstChild("Killers")
    if killers then
        print("✅ Killers encontrados: " .. #killers:GetChildren())
        
        killers.ChildAdded:Connect(function()
            if HITBOX_ENABLED or HEAD_ENABLED then
                wait(0.5)
                updateAllHitboxes()
            end
        end)
        
        killers.ChildRemoved:Connect(function(child)
            if expandedHitboxes[child] then
                restoreMonster(child)
            end
        end)
        
        if HITBOX_ENABLED or HEAD_ENABLED then
            updateAllHitboxes()
        end
    else
        print("⚠️ Pasta Killers não encontrada")
    end
end)

-- ============================================
-- FINAL
-- ============================================
print("✅ Sistema carregado!")

Rayfield:Notify({
    Title = "Sistema Pronto!",
    Content = "Teleporte + Hitbox Expander carregados",
    Duration = 3
})