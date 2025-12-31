-- Carregar Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Criar janela
local Window = Rayfield:CreateWindow({
    Name = "Survival System v2.0",
    LoadingTitle = "Carregando utilitários...",
    LoadingSubtitle = "Teleporte + Hitbox Expander Avançado",
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
    ["Base Segura"] = {pos = Vector3.new(-51.438236236572266, 313.5002746582031, 292.1361999511719), returnToOrigin = false},
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
-- SISTEMA HITBOX EXPANDER AVANÇADO (2 SLIDERS)
-- ============================================

-- Configurações do Hitbox Expander
local HITBOX_SIZE = 15 -- Tamanho da hitbox do corpo
local HEAD_SIZE = 8    -- Tamanho da hitbox da cabeça
local UPDATE_RATE = 1
local HITBOX_ENABLED = true
local HEAD_ENABLED = true -- Expandir cabeça para headshots
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

local function setHitboxSize(size)
    HITBOX_SIZE = size
    updateAllHitboxes()
end

local function setHeadSize(size)
    HEAD_SIZE = size
    updateAllHitboxes()
end

local function toggleHead(enabled)
    HEAD_ENABLED = enabled
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
-- ABA DO HITBOX EXPANDER AVANÇADO (RAYFIELD)
-- ============================================
local HitboxTab = Window:CreateTab("🎯 Hitbox Expander", 6031300884)

HitboxTab:CreateSection("🎯 Expansor de Hitbox Avançado")
HitboxTab:CreateLabel("Aumenta hitbox do CORPO e CABEÇA dos inimigos")

-- Toggle do Hitbox Expander (Corpo)
local HitboxToggle = HitboxTab:CreateToggle({
    Name = "Ativar Expansão do CORPO",
    CurrentValue = HITBOX_ENABLED,
    Callback = function(value)
        HITBOX_ENABLED = value
        toggleHitboxes(value)
        
        if value then
            Rayfield:Notify({
                Title = "Hitbox Expander",
                Content = "Corpo dos inimigos expandido!",
                Duration = 3,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Hitbox Expander",
                Content = "Corpo dos inimigos restaurado!",
                Duration = 3,
                Image = 4483362458
            })
        end
    end,
})

-- Toggle da Cabeça
local HeadToggle = HitboxTab:CreateToggle({
    Name = "Ativar Expansão da CABEÇA",
    CurrentValue = HEAD_ENABLED,
    Callback = function(value)
        HEAD_ENABLED = value
        toggleHead(value)
        
        if value then
            Rayfield:Notify({
                Title = "Headshot Expander",
                Content = "Cabeça dos inimigos expandida!",
                Duration = 3,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Headshot Expander",
                Content = "Cabeça dos inimigos restaurada!",
                Duration = 3,
                Image = 4483362458
            })
        end
    end,
})

-- Slider para tamanho da hitbox do CORPO
HitboxTab:CreateSection("📏 Tamanho do CORPO")
HitboxTab:CreateSlider({
    Name = "Tamanho do Corpo",
    Range = {5, 50},
    Increment = 1,
    Suffix = " unidades",
    CurrentValue = HITBOX_SIZE,
    Callback = function(value)
        setHitboxSize(value)
        Rayfield:Notify({
            Title = "Tamanho Atualizado",
            Content = "Corpo: " .. value .. " unidades",
            Duration = 2,
            Image = 4483362458
        })
    end,
})

-- Slider para tamanho da hitbox da CABEÇA
HitboxTab:CreateSection("🎯 Tamanho da CABEÇA")
HitboxTab:CreateSlider({
    Name = "Tamanho da Cabeça",
    Range = {3, 20},
    Increment = 1,
    Suffix = " unidades",
    CurrentValue = HEAD_SIZE,
    Callback = function(value)
        setHeadSize(value)
        Rayfield:Notify({
            Title = "Tamanho Atualizado",
            Content = "Cabeça: " .. value .. " unidades",
            Duration = 2,
            Image = 4483362458
        })
    end,
})

-- Botão para atualizar hitboxes
HitboxTab:CreateSection("⚙️ Controles")
HitboxTab:CreateButton({
    Name = "🔄 Atualizar Todas as Hitboxes",
    Callback = function()
        updateAllHitboxes()
        Rayfield:Notify({
            Title = "Hitboxes Atualizadas",
            Content = "Todas as hitboxes foram atualizadas!",
            Duration = 3,
            Image = 4483362458
        })
    end,
})

-- Botão para restaurar tudo
HitboxTab:CreateButton({
    Name = "🗑️ Restaurar Todas as Hitboxes",
    Callback = function()
        for killer, _ in pairs(expandedHitboxes) do
            restoreHitbox(killer)
        end
        expandedHitboxes = {}
        Rayfield:Notify({
            Title = "Hitboxes Restauradas",
            Content = "Todas as hitboxes foram restauradas ao normal!",
            Duration = 3,
            Image = 4483362458
        })
    end,
})

-- Informações
HitboxTab:CreateSection("📊 Informações Atuais")
local BodySizeLabel = HitboxTab:CreateLabel("Tamanho do Corpo: " .. HITBOX_SIZE)
local HeadSizeLabel = HitboxTab:CreateLabel("Tamanho da Cabeça: " .. HEAD_SIZE)
local StatusLabel = HitboxTab:CreateLabel("Status: Aguardando inimigos...")

-- ============================================
-- ABA DE INFORMAÇÕES
-- ============================================
local InfoTab = Window:CreateTab("📋 Informações", 6031068421)

InfoTab:CreateSection("🎮 Sistema Completo")
InfoTab:CreateLabel("Teleport System + Hitbox Expander Avançado")
InfoTab:CreateLabel("Total de locais: 11")
InfoTab:CreateLabel("Cooldown teleporte: " .. cooldownTime .. "s")

InfoTab:CreateSection("⚙️ Configurações do Teleporte")
InfoTab:CreateLabel("• Base Segura: Teleporte PERMANENTE")
InfoTab:CreateLabel("• Outros locais: Teleporte TEMPORÁRIO (5s)")
InfoTab:CreateLabel("• Recarga: " .. cooldownTime .. " segundos entre usos")

InfoTab:CreateSection("🎯 Configurações do Hitbox Expander")
InfoTab:CreateLabel("• Corpo: Ajustável (5-50 unidades)")
InfoTab:CreateLabel("• Cabeça: Ajustável (3-20 unidades)")
InfoTab:CreateLabel("• Headshots: Causam mais dano!")
InfoTab:CreateLabel("• Atualiza automaticamente a cada 1s")

InfoTab:CreateSection("📁 Estrutura do Jogo")
InfoTab:CreateLabel("• Inimigos: workspace.Killers")
InfoTab:CreateLabel("• Monitora novos inimigos automaticamente")
InfoTab:CreateLabel("• Restaura ao normal quando desativado")

-- ============================================
-- INICIALIZAÇÃO DO HITBOX EXPANDER
-- ============================================
spawn(function()
    wait(2) -- Esperar carregar
    
    -- Verificar se existe pasta Killers
    local killersFolder = Workspace:FindFirstChild("Killers")
    if killersFolder then
        print("✅ Pasta Killers encontrada!")
        print("📊 Inimigos detectados: " .. #killersFolder:GetChildren())
        
        -- Atualizar labels
        if StatusLabel then
            StatusLabel:Set("Inimigos: " .. #killersFolder:GetChildren())
        end
        
        -- Inicializar hitboxes
        if HITBOX_ENABLED then
            updateAllHitboxes()
        end
        
        -- Monitorar novos inimigos
        killersFolder.ChildAdded:Connect(function(child)
            if child:IsA("Model") and HITBOX_ENABLED then
                task.wait(0.1)
                expandHitbox(child)
                
                -- Atualizar contador
                if StatusLabel then
                    StatusLabel:Set("Inimigos: " .. #killersFolder:GetChildren())
                end
            end
        end)
        
        killersFolder.ChildRemoved:Connect(function(child)
            restoreHitbox(child)
            
            -- Atualizar contador
            if StatusLabel then
                StatusLabel:Set("Inimigos: " .. #killersFolder:GetChildren())
            end
        end)
    else
        print("⚠️ Pasta Killers não encontrada no Workspace!")
        if StatusLabel then
            StatusLabel:Set("ERRO: Pasta Killers não encontrada!")
        end
        
        Rayfield:Notify({
            Title = "Aviso",
            Content = "Pasta 'Killers' não encontrada no Workspace!",
            Duration = 5,
            Image = 4483362458
        })
    end
    
    -- Loop de atualização automática
    local updateTimer = 0
    RunService.Heartbeat:Connect(function(dt)
        updateTimer = updateTimer + dt
        if updateTimer >= UPDATE_RATE then
            updateTimer = 0
            if HITBOX_ENABLED then
                updateAllHitboxes()
            end
        end
    end)
end)

-- Função para atualizar labels dinamicamente
local function updateHitboxLabels()
    if BodySizeLabel then
        BodySizeLabel:Set("Tamanho do Corpo: " .. HITBOX_SIZE)
    end
    if HeadSizeLabel then
        HeadSizeLabel:Set("Tamanho da Cabeça: " .. HEAD_SIZE)
    end
end

-- Atualizar labels quando mudar os valores
HitboxTab:CreateSection("📈 Monitoramento")
HitboxTab:CreateButton({
    Name = "🔄 Atualizar Informações",
    Callback = function()
        updateHitboxLabels()
        Rayfield:Notify({
            Title = "Informações Atualizadas",
            Content = "Valores atualizados na tela!",
            Duration = 2,
            Image = 4483362458
        })
    end,
})

-- ============================================
-- MENSAGEM FINAL
-- ============================================
print("==========================================")
print("SURVIVAL SYSTEM v2.0 - CARREGADO!")
print("==========================================")
print("📁 Categorias: 3 (Armas, Bases, Powers)")
print("🎯 Hitbox Expander: " .. (HITBOX_ENABLED and "ATIVADO" or "DESATIVADO"))
print("🎯 Headshot Expander: " .. (HEAD_ENABLED and "ATIVADO" : "DESATIVADO"))
print("📏 Tamanho Corpo: " .. HITBOX_SIZE .. " unidades")
print("🎯 Tamanho Cabeça: " .. HEAD_SIZE .. " unidades")
print("📍 Total de locais: 11")
print("⏱️ Cooldown: " .. cooldownTime .. "s")
print("==========================================")

Rayfield:Notify({
    Title = "Sistema Carregado!",
    Content = "Teleporte + Hitbox Expander Avançado prontos!",
    Duration = 5,
    Image = 4483362458
})

-- Inicializar labels
updateHitboxLabels()