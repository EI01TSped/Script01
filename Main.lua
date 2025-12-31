-- Carregar Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Criar janela
local Window = Rayfield:CreateWindow({
    Name = "Survival Helper",
    LoadingTitle = "Carregando...",
    LoadingSubtitle = "Sistema Otimizado",
    ConfigurationSaving = {Enabled = false}
})

-- Serviços
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- ============================================
-- CONFIGURAÇÕES SIMPLIFICADAS
-- ============================================
local teleporting = false
local cooldownTime = 10
local buttonReferences = {}

-- Configurações do Hitbox Expander
local HITBOX_SIZE = 15
local HEAD_SIZE = 8
local HITBOX_ENABLED = false
local HEAD_ENABLED = false
local expandedHitboxes = {}

-- ============================================
-- TELEPORTE SIMPLIFICADO
-- ============================================
local TeleportLocations = {
    -- ARMAS
    ["Alien Gun"] = Vector3.new(114.22046661376953, 335.4999084472656, 565.9104614257812),
    
    -- BASES
    ["Base Segura"] = Vector3.new(-51.438236236572266, 313.5002746582031, 292.1361999511719),
    ["Energia"] = Vector3.new(126.81755828857422, 323.4999694824219, 600.4284057617188),
    ["Roleta"] = Vector3.new(111.14323425292969, 313.4999694824219, 350.11810302734375),
    ["Upgrade"] = Vector3.new(111.16646575927734, 335.4999694824219, 66.77725982666016),
    
    -- POWERS
    ["2X dano"] = Vector3.new(98.72466278076172, 271.7002258300781, 176.35610961914062),
    ["Revive"] = Vector3.new(183.5561981201172, 313.4999694824219, 434.4063720703125),
    ["Cura Bala"] = Vector3.new(-130.79737854003906, 293.4999694824219, 354.90643310546875),
    ["Colete"] = Vector3.new(-169.19932556152344, 293.5002746582031, 317.37908935546875),
    ["Speed Cola"] = Vector3.new(106.36351013183594, 323.4999694824219, 698.6314697265625),
    ["Eletric Cherry"] = Vector3.new(-48.826568603515625, 293.49969482421875, 337.36962890625)
}

local LocationEmojis = {
    ["Alien Gun"] = "🚀",
    ["Base Segura"] = "🏠",
    ["Energia"] = "⚡",
    ["Roleta"] = "🧰",
    ["Upgrade"] = "🧩",
    ["2X dano"] = "🔫",
    ["Revive"] = "💙",
    ["Cura Bala"] = "🍭",
    ["Colete"] = "🦺",
    ["Speed Cola"] = "☘️",
    ["Eletric Cherry"] = "🟤"
}

local function teleportToLocation(locationName, position)
    if teleporting then return end
    
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    teleporting = true
    local originalCFrame = hrp.CFrame
    
    -- Teleportar
    hrp.CFrame = CFrame.new(position)
    
    Rayfield:Notify({
        Title = "Teleportado!",
        Content = locationName .. " (5 segundos)",
        Duration = 3
    })
    
    -- Atualizar botão
    if buttonReferences[locationName] then
        buttonReferences[locationName]:Set("⏳ Teleportando...")
    end
    
    -- Só volta se NÃO for Base Segura
    if locationName ~= "Base Segura" then
        wait(5)
        hrp.CFrame = originalCFrame
        Rayfield:Notify({
            Title = "Retornado!",
            Content = "Voltou para posição original",
            Duration = 3
        })
    end
    
    -- Recarga
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
-- HITBOX EXPANDER INVISÍVEL (SIMPLIFICADO)
-- ============================================
local function createInvisibleHitbox(originalPart, sizeMultiplier, isHead)
    -- Cria uma hitbox INVISÍVEL
    local hitbox = Instance.new("Part")
    hitbox.Name = "InvisibleHitbox_" .. (isHead and "Head" or "Body")
    hitbox.Size = originalPart.Size * sizeMultiplier
    hitbox.CFrame = originalPart.CFrame
    hitbox.Anchored = false
    hitbox.CanCollide = false
    hitbox.Transparency = 1 -- 100% INVISÍVEL
    hitbox.Color = Color3.new(1, 0, 0) -- Só para debug, invisível mesmo
    
    -- Não mostra nada
    hitbox.Material = Enum.Material.SmoothPlastic
    
    -- Conecta à parte original
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = originalPart
    weld.Part1 = hitbox
    weld.Parent = hitbox
    
    -- Remove qualquer sombra/reflexo
    hitbox.CastShadow = false
    
    return hitbox
end

local function expandMonster(monster)
    if not monster or expandedHitboxes[monster] then return end
    
    local hrp = monster:FindFirstChild("HumanoidRootPart")
    local head = monster:FindFirstChild("Head")
    if not hrp then return end
    
    local hitboxes = {}
    
    -- Expansão do corpo
    if HITBOX_ENABLED then
        local bodyHitbox = createInvisibleHitbox(hrp, HITBOX_SIZE / hrp.Size.X, false)
        bodyHitbox.Parent = monster
        hitboxes.body = bodyHitbox
    end
    
    -- Expansão da cabeça
    if HEAD_ENABLED and head then
        local headHitbox = createInvisibleHitbox(head, HEAD_SIZE / head.Size.X, true)
        headHitbox.Parent = monster
        hitboxes.head = headHitbox
    end
    
    if next(hitboxes) ~= nil then
        expandedHitboxes[monster] = hitboxes
        return true
    end
    
    return false
end

local function restoreMonster(monster)
    local hitboxes = expandedHitboxes[monster]
    if not hitboxes then return end
    
    if hitboxes.body and hitboxes.body.Parent then
        hitboxes.body:Destroy()
    end
    
    if hitboxes.head and hitboxes.head.Parent then
        hitboxes.head:Destroy()
    end
    
    expandedHitboxes[monster] = nil
end

local function updateAllHitboxes()
    local killers = Workspace:FindFirstChild("Killers")
    if not killers then return end
    
    -- Limpa monstros que não existem mais
    for monster, _ in pairs(expandedHitboxes) do
        if not monster.Parent then
            restoreMonster(monster)
        end
    end
    
    -- Aplica hitboxes
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
-- INTERFACE RAYFIELD SIMPLIFICADA
-- ============================================

-- Aba de Teleportes
local TeleportTab = Window:CreateTab("Teleportes", 4483362458)

-- Armas
TeleportTab:CreateSection("🔫 Armas")
local function createTeleportButton(locationName)
    local button = TeleportTab:CreateButton({
        Name = (LocationEmojis[locationName] or "📍") .. " " .. locationName,
        Callback = function()
            teleportToLocation(locationName, TeleportLocations[locationName])
        end
    })
    buttonReferences[locationName] = button
end

createTeleportButton("Alien Gun")

-- Bases
TeleportTab:CreateSection("🏠 Bases")
createTeleportButton("Base Segura")
createTeleportButton("Energia")
createTeleportButton("Roleta")
createTeleportButton("Upgrade")

-- Powers
TeleportTab:CreateSection("⚡ Powers")
createTeleportButton("2X dano")
createTeleportButton("Revive")
createTeleportButton("Cura Bala")
createTeleportButton("Colete")
createTeleportButton("Speed Cola")
createTeleportButton("Eletric Cherry")

-- Aba do Hitbox Expander
local HitboxTab = Window:CreateTab("🎯 Hitbox", 7733765391)

HitboxTab:CreateSection("Expansor de Hitbox INVISÍVEL")
HitboxTab:CreateLabel("Hitboxes expandidas são 100% invisíveis")

-- Toggles
local BodyToggle = HitboxTab:CreateToggle({
    Name = "Expandir Corpo",
    CurrentValue = HITBOX_ENABLED,
    Callback = function(value)
        HITBOX_ENABLED = value
        updateAllHitboxes()
    end
})

local HeadToggle = HitboxTab:CreateToggle({
    Name = "Expandir Cabeça",
    CurrentValue = HEAD_ENABLED,
    Callback = function(value)
        HEAD_ENABLED = value
        updateAllHitboxes()
    end
})

-- Sliders
HitboxTab:CreateSlider({
    Name = "Tamanho do Corpo",
    Range = {1, 30},
    Increment = 1,
    Suffix = "x",
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
    Range = {1, 20},
    Increment = 1,
    Suffix = "x",
    CurrentValue = HEAD_SIZE,
    Callback = function(value)
        HEAD_SIZE = value
        if HEAD_ENABLED then
            updateAllHitboxes()
        end
    end
})

-- Botão de atualização
HitboxTab:CreateButton({
    Name = "Atualizar Hitboxes",
    Callback = updateAllHitboxes
})

-- ============================================
-- INICIALIZAÇÃO
-- ============================================
spawn(function()
    wait(2)
    
    -- Inicializar hitboxes se ativado
    if HITBOX_ENABLED or HEAD_ENABLED then
        updateAllHitboxes()
    end
    
    -- Loop de atualização
    while true do
        wait(1)
        if HITBOX_ENABLED or HEAD_ENABLED then
            updateAllHitboxes()
        end
    end
end)

print("✅ Sistema carregado com sucesso!")
print("🎯 Hitbox Expander: " .. (HITBOX_ENABLED and "Corpo ON" : "OFF") .. " | " .. (HEAD_ENABLED and "Cabeça ON" : "OFF"))

Rayfield:Notify({
    Title = "Sistema Pronto!",
    Content = "Teleportes e Hitbox Expander carregados",
    Duration = 3
})