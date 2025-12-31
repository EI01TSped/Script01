-- Carregar Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Criar janela
local Window = Rayfield:CreateWindow({
    Name = "Survival System",
    LoadingTitle = "Carregando utilitários...",
    LoadingSubtitle = "Teleporte + Hitbox Expander",
    ConfigurationSaving = {
        Enabled = false
    }
})

-- ============================================
-- CONFIGURAÇÕES GERAIS
-- ============================================
local teleporting = false
local teleportCooldowns = {}
local cooldownTime = 10
local buttonReferences = {}

-- Serviços
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- ============================================
-- SISTEMA DE TELEPORTE
-- ============================================

-- Coordenadas dos teleportes organizadas por categoria
local TeleportLocations = {
    -- CATEGORIA: ARMAS
    ["Alien Gun"] = {pos = Vector3.new(114.22046661376953, 335.4999084472656, 565.9104614257812), returnToOrigin = true},
    
    -- CATEGORIA: BASES/LOCAIS
    ["Base Segura"] = {pos = Vector3.new(-51.438236236572266, 313.5002746582031, 292.1361999511719), returnToOrigin = false}, -- NÃO VOLTA
    ["Energia"] = {pos = Vector3.new(126.81755828857422, 323.4999694824219, 600.4284057617188), returnToOrigin = true},
    ["Roleta"] = {pos = Vector3.new(111.14323425292969, 313.4999694824219, 350.11810302734375), returnToOrigin = true},
    ["Upgrade"] = {pos = Vector3.new(111.16646575927734, 335.4999694824219, 66.77725982666016), returnToOrigin = true},
    
    -- CATEGORIA: POWERS
    ["2X dano"] = {pos = Vector3.new(98.72466278076172, 271.7002258300781, 176.35610961914062), returnToOrigin = true},
    ["Revive"] = {pos = Vector3.new(183.5561981201172, 313.4999694824219, 434.4063720703125), returnToOrigin = true},
    ["Cura Bala"] = {pos = Vector3.new(-130.79737854003906, 293.4999694824219, 354.90643310546875), returnToOrigin = true},
    ["Colete"] = {pos = Vector3.new(-169.19932556152344, 293.5002746582031, 317.37908935546875), returnToOrigin = true},
    ["Speed Cola"] = {pos = Vector3.new(106.36351013183594, 323.4999694824219, 698.6314697265625), returnToOrigin = true},
    ["Eletric Cherry"] = {pos = Vector3.new(-48.826568603515625, 293.49969482421875, 337.36962890625), returnToOrigin = true}
}

-- Emojis para cada local
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

-- Função principal de teleporte
local function teleportToLocation(locationName, teleportData)
    if teleporting then 
        Rayfield:Notify({
            Title = "Aguarde",
            Content = "Já há um teleporte em andamento!",
            Duration = 3,
            Image = 4483362458
        })
        return 
    end
    
    -- Verificar recarga
    if teleportCooldowns[locationName] and os.time() - teleportCooldowns[locationName] < cooldownTime then
        local remaining = cooldownTime - (os.time() - teleportCooldowns[locationName])
        Rayfield:Notify({
            Title = "Em Recarga",
            Content = locationName .. " estará disponível em " .. math.floor(remaining) .. " segundos",
            Duration = 3,
            Image = 4483362458
        })
        return
    end
    
    -- Verificar player
    local player = Players.LocalPlayer
    local character = player.Character
    
    if not character then
        Rayfield:Notify({
            Title = "Erro",
            Content = "Personagem não encontrado!",
            Duration = 3,
            Image = 4483362458
        })
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        Rayfield:Notify({
            Title = "Erro",
            Content = "HumanoidRootPart não encontrado!",
            Duration = 3,
            Image = 4483362458
        })
        return
    end
    
    teleporting = true
    local originalCFrame = humanoidRootPart.CFrame
    
    -- Teleportar
    humanoidRootPart.CFrame = CFrame.new(teleportData.pos)
    
    Rayfield:Notify({
        Title = "Teleportado!",
        Content = "Você foi para " .. locationName .. (teleportData.returnToOrigin and " por 5 segundos" or ""),
        Duration = 5,
        Image = 4483362458
    })
    
    -- Atualizar botão
    if buttonReferences[locationName] then
        buttonReferences[locationName]:Set("⏳ Teleportando...")
    end
    
    -- Se for para retornar, espera 5 segundos e volta
    if teleportData.returnToOrigin then
        wait(5)
        
        -- Voltar
        humanoidRootPart.CFrame = originalCFrame
        
        Rayfield:Notify({
            Title = "Retornado!",
            Content = "Você voltou para sua posição original",
            Duration = 3,
            Image = 4483362458
        })
    end
    
    -- Ativar recarga
    teleportCooldowns[locationName] = os.time()
    
    -- Iniciar contagem regressiva no botão
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

-- Função para criar botão de teleporte
local function createTeleportButton(tab, locationName, teleportData, emoji)
    local button = tab:CreateButton({
        Name = emoji .. " " .. locationName,
        Callback = function()
            teleportToLocation(locationName, teleportData)
        end,
    })
    
    -- Guardar referência do botão
    buttonReferences[locationName] = button
    return button
end

-- Função para criar categoria com todos os botões
local function createCategory(tabName, iconId, categoryTitle, locations)
    local Tab = Window:CreateTab(tabName, iconId)
    
    -- Seção de informações
    Tab:CreateSection("📌 " .. categoryTitle)
    Tab:CreateLabel("Cooldown: " .. cooldownTime .. " segundos")
    
    -- Seção de locais
    Tab:CreateSection("📍 Locais Disponíveis")
    
    -- Criar botões para cada local
    for locationName, teleportData in pairs(locations) do
        local emoji = LocationEmojis[locationName] or "📍"
        createTeleportButton(Tab, locationName, teleportData, emoji)
    end
    
    return Tab
end

-- ============================================
-- SISTEMA HITBOX EXPANDER (COMPLETO COM HEADSHOT)
-- ============================================

-- Configurações do Hitbox Expander
local HITBOX_SIZE = 15 -- Tamanho do corpo
local HEAD_SIZE = 8 -- Tamanho da cabeça
local UPDATE_RATE = 1
local HITBOX_ENABLED = true
local HEAD_ENABLED = true
local expandedHitboxes = {}
local LocalPlayer = Players.LocalPlayer

-- Funções do Hitbox Expander
local function expandHitbox(killer)
    if not killer or expandedHitboxes[killer] then return end
    
    local hrp = killer:FindFirstChild("HumanoidRootPart")
    local head = killer:FindFirstChild("Head")
    if not hrp then return end
    
    -- Salva valores originais do corpo
    local originalSize = hrp.Size
    local originalCanCollide = hrp.CanCollide
    
    local data = {
        hrp = hrp,
        originalSize = originalSize,
        originalCanCollide = originalCanCollide
    }
    
    -- Se tem cabeça, salva os valores originais dela também
    if head then
        data.head = head
        data.originalHeadSize = head.Size
        data.originalHeadCanCollide = head.CanCollide
    end
    
    expandedHitboxes[killer] = data
    
    -- Aplica expansão no corpo
    if HITBOX_ENABLED then
        hrp.Size = Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE)
        hrp.CanCollide = false
    end
    
    -- Aplica expansão na cabeça (para headshots)
    if HEAD_ENABLED and head then
        head.Size = Vector3.new(HEAD_SIZE, HEAD_SIZE, HEAD_SIZE)
        head.CanCollide = false
    end
end

local function restoreHitbox(killer)
    local data = expandedHitboxes[killer]
    if not data then return end
    
    -- Restaura corpo
    local hrp = data.hrp
    if hrp and hrp.Parent then
        hrp.Size = data.originalSize
        hrp.CanCollide = data.originalCanCollide
    end
    
    -- Restaura cabeça
    local head = data.head
    if head and head.Parent then
        head.Size = data.originalHeadSize
        head.CanCollide = data.originalHeadCanCollide
    end
    
    expandedHitboxes[killer] = nil
end

local function updateAllHitboxes()
    local killersFolder = Workspace:FindFirstChild("Killers")
    if not killersFolder then 
        print("❌ Pasta Killers não encontrada!")
        return 
    end
    
    -- Remove hitboxes de killers que não existem mais
    for killer, _ in pairs(expandedHitboxes) do
        if not killer.Parent then
            restoreHitbox(killer)
        end
    end
    
    -- Adiciona/atualiza hitboxes de killers existentes
    for _, killer in ipairs(killersFolder:GetChildren()) do
        if killer:IsA("Model") then
            if HITBOX_ENABLED then
                expandHitbox(killer)
                
                -- Atualiza tamanho se mudou
                local data = expandedHitboxes[killer]
                if data and data.hrp and data.hrp.Parent then
                    data.hrp.Size = Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE)
                    data.hrp.CanCollide = false
                    
                    -- Atualiza cabeça também
                    if HEAD_ENABLED and data.head and data.head.Parent then
                        data.head.Size = Vector3.new(HEAD_SIZE, HEAD_SIZE, HEAD_SIZE)
                        data.head.CanCollide = false
                    end
                end
            else
                restoreHitbox(killer)
            end
        end
    end
end

local function toggleHitboxes(enabled)
    HITBOX_ENABLED = enabled
    
    if not enabled then
        -- Restaura todas as hitboxes
        for killer, _ in pairs(expandedHitboxes) do
            restoreHitbox(killer)
        end
    else
        -- Reaplica todas as hitboxes
        updateAllHitboxes()
    end
end

local function toggleHead(enabled)
    HEAD_ENABLED = enabled
    updateAllHitboxes()
end

local function setHitboxSize(size)
    HITBOX_SIZE = size
    updateAllHitboxes()
end

local function setHeadSize(size)
    HEAD_SIZE = size
    updateAllHitboxes()
end

-- ============================================
-- CATEGORIAS DO TELEPORTE
-- ============================================

-- Categoria: ARMAS
local ArmasCategory = {
    ["Alien Gun"] = TeleportLocations["Alien Gun"]
}

-- Categoria: BASES/LOCAIS
local BasesCategory = {
    ["Base Segura"] = TeleportLocations["Base Segura"],
    ["Energia"] = TeleportLocations["Energia"],
    ["Roleta"] = TeleportLocations["Roleta"],
    ["Upgrade"] = TeleportLocations["Upgrade"]
}

-- Categoria: POWERS
local PowersCategory = {
    ["2X dano"] = TeleportLocations["2X dano"],
    ["Revive"] = TeleportLocations["Revive"],
    ["Cura Bala"] = TeleportLocations["Cura Bala"],
    ["Colete"] = TeleportLocations["Colete"],
    ["Speed Cola"] = TeleportLocations["Speed Cola"],
    ["Eletric Cherry"] = TeleportLocations["Eletric Cherry"]
}

-- Criar as abas
createCategory("Armas", 7733765391, "Armas", ArmasCategory)
createCategory("Bases", 4483362458, "Bases e Locais", BasesCategory)
createCategory("Powers", 9753762469, "Poderes e Buffs", PowersCategory)

-- ============================================
-- ABA DO HITBOX EXPANDER (RAYFIELD) - COM 2 SLIDERS
-- ============================================
local HitboxTab = Window:CreateTab("Hitbox Expander", 6031300884)

HitboxTab:CreateSection("🎯 Expansor de Hitbox")
HitboxTab:CreateLabel("Aumenta a hitbox dos inimigos para facilitar acertos")

-- Toggle do Hitbox Expander (CORPO)
local HitboxToggle = HitboxTab:CreateToggle({
    Name = "✅ Ativar Hitbox do Corpo",
    CurrentValue = HITBOX_ENABLED,
    Callback = function(value)
        HITBOX_ENABLED = value
        toggleHitboxes(value)
        
        if value then
            Rayfield:Notify({
                Title = "Hitbox Corpo",
                Content = "Ativado! Corpo dos inimigos expandido.",
                Duration = 4,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Hitbox Corpo",
                Content = "Desativado! Corpo voltou ao normal.",
                Duration = 4,
                Image = 4483362458
            })
        end
    end,
})

-- Slider 1: Tamanho da hitbox do CORPO
HitboxTab:CreateSlider({
    Name = "📦 Tamanho do Corpo",
    Range = {5, 50},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = HITBOX_SIZE,
    Callback = function(value)
        setHitboxSize(value)
    end,
})

HitboxTab:CreateSection("🎯 Expansor de Headshot")
HitboxTab:CreateLabel("Expande a cabeça para facilitar headshots (mais dano!)")

-- Toggle do Hitbox Expander (CABEÇA)
local HeadToggle = HitboxTab:CreateToggle({
    Name = "🎯 Ativar Hitbox da Cabeça",
    CurrentValue = HEAD_ENABLED,
    Callback = function(value)
        HEAD_ENABLED = value
        toggleHead(value)
        
        if value then
            Rayfield:Notify({
                Title = "Hitbox Cabeça",
                Content = "Ativado! Headshots ficaram mais fáceis!",
                Duration = 4,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Hitbox Cabeça",
                Content = "Desativado! Cabeça voltou ao normal.",
                Duration = 4,
                Image = 4483362458
            })
        end
    end,
})

-- Slider 2: Tamanho da hitbox da CABEÇA
HitboxTab:CreateSlider({
    Name = "🎯 Tamanho da Cabeça (Headshot)",
    Range = {3, 20},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = HEAD_SIZE,
    Callback = function(value)
        setHeadSize(value)
    end,
})

-- Botão para atualizar hitboxes
HitboxTab:CreateButton({
    Name = "🔄 Atualizar Hitboxes Manualmente",
    Callback = function()
        updateAllHitboxes()
        Rayfield:Notify({
            Title = "Hitboxes Atualizadas",
            Content = "Corpo e cabeça dos inimigos atualizados!",
            Duration = 3,
            Image = 4483362458
        })
    end,
})

-- Informações
HitboxTab:CreateSection("📊 Informações")
HitboxTab:CreateLabel("🎯 Headshots causam MAIS dano!")
HitboxTab:CreateLabel("📦 Corpo: " .. HITBOX_SIZE .. " studs")
HitboxTab:CreateLabel("🎯 Cabeça: " .. HEAD_SIZE .. " studs")
HitboxTab:CreateLabel("Inimigos em: Workspace.Killers")

-- ============================================
-- ABA DE INFORMAÇÕES
-- ============================================
local InfoTab = Window:CreateTab("Informações", 6031068421)

InfoTab:CreateSection("📋 Sistema Completo")
InfoTab:CreateLabel("Teleport System + Hitbox Expander")
InfoTab:CreateLabel("Total de locais: 11")
InfoTab:CreateLabel("Cooldown teleporte: " .. cooldownTime .. "s")

InfoTab:CreateSection("🎮 Como Usar")
InfoTab:CreateLabel("• Teleportes: 5s no local (Base Segura não volta)")
InfoTab:CreateLabel("• Hitbox Corpo: Facilita acertar inimigos")
InfoTab:CreateLabel("• Hitbox Cabeça: Facilita headshots (+ dano)")
InfoTab:CreateLabel("• Monstros: Na pasta workspace.Killers")

InfoTab:CreateSection("⚙️ Configurações")
InfoTab:CreateLabel("Base Segura: Teleporte permanente")
InfoTab:CreateLabel("Outros: Teleporte temporário (5s)")
InfoTab:CreateLabel("Corpo padrão: 15 studs")
InfoTab:CreateLabel("Cabeça padrão: 8 studs")

InfoTab:CreateSection("🎯 Dicas")
InfoTab:CreateLabel("✅ Ative ambas as hitboxes para melhor resultado")
InfoTab:CreateLabel("🎯 Mire na cabeça para causar mais dano")
InfoTab:CreateLabel("📦 Ajuste os sliders ao seu gosto")

-- ============================================
-- INICIALIZAÇÃO DO HITBOX EXPANDER
-- ============================================
spawn(function()
    wait(2) -- Esperar carregar
    
    -- Verificar se existe pasta Killers
    local killersFolder = Workspace:FindFirstChild("Killers")
    if killersFolder then
        print("✅ Pasta Killers encontrada!")
        print("📊 Inimigos: " .. #killersFolder:GetChildren())
        
        -- Inicializar hitboxes
        if HITBOX_ENABLED then
            updateAllHitboxes()
        end
        
        -- Monitorar novos inimigos
        killersFolder.ChildAdded:Connect(function(child)
            if child:IsA("Model") and HITBOX_ENABLED then
                task.wait(0.1)
                expandHitbox(child)
            end
        end)
        
        killersFolder.ChildRemoved:Connect(function(child)
            restoreHitbox(child)
        end)
    else
        print("⚠️ Pasta Killers não encontrada no Workspace!")
        Rayfield:Notify({
            Title = "Aviso",
            Content = "Pasta 'Killers' não encontrada!",
            Duration = 5,
            Image = 4483362458
        })
    end
    
    -- Loop de atualização
    local updateTimer = 0
    RunService.Heartbeat:Connect(function(dt)
        updateTimer = updateTimer + dt
        if updateTimer >= UPDATE_RATE then
            updateTimer = 0
            if HITBOX_ENABLED or HEAD_ENABLED then
                updateAllHitboxes()
            end
        end
    end)
end)

-- ============================================
-- MENSAGEM FINAL
-- ============================================
print("==========================================")
print("SURVIVAL SYSTEM - CARREGADO COM SUCESSO!")
print("==========================================")
print("📁 Categorias: 3 (Armas, Bases, Powers)")
print("🎯 Hitbox Corpo: " .. (HITBOX_ENABLED and "Ativado" or "Desativado") .. " (" .. HITBOX_SIZE .. " studs)")
print("🎯 Hitbox Cabeça: " .. (HEAD_ENABLED and "Ativado" or "Desativado") .. " (" .. HEAD_SIZE .. " studs)")
print("📍 Total de locais: 11")
print("⏱️ Cooldown: " .. cooldownTime .. "s")
print("==========================================")

Rayfield:Notify({
    Title = "Sistema Carregado!",
    Content = "Teleporte + Hitbox (Corpo + Cabeça) prontos!",
    Duration = 6,
    Image = 4483362458
})