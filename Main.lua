-- Carregar Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Criar janela
local Window = Rayfield:CreateWindow({
    Name = "Teleport System v2.0",
    LoadingTitle = "Carregando...",
    LoadingSubtitle = "Sistema de Teleporte por Categorias",
    ConfigurationSaving = {
        Enabled = false
    }
})

-- Coordenadas dos teleportes organizadas por categoria
local TeleportLocations = {
    -- CATEGORIA: ARMAS
    ["Alien Gun"] = Vector3.new(114.22046661376953, 335.4999084472656, 565.9104614257812),
    
    -- CATEGORIA: BASES/LOCAIS
    ["Base Segura"] = Vector3.new(-51.438236236572266, 313.5002746582031, 292.1361999511719),
    ["Energia"] = Vector3.new(126.81755828857422, 323.4999694824219, 600.4284057617188),
    ["Roleta"] = Vector3.new(111.14323425292969, 313.4999694824219, 350.11810302734375),
    ["Upgrade"] = Vector3.new(111.16646575927734, 335.4999694824219, 66.77725982666016),
    
    -- CATEGORIA: POWERS
    ["2X dano"] = Vector3.new(98.72466278076172, 271.7002258300781, 176.35610961914062),
    ["Revive"] = Vector3.new(183.5561981201172, 313.4999694824219, 434.4063720703125),
    ["Cura Bala"] = Vector3.new(-130.79737854003906, 293.4999694824219, 354.90643310546875),
    ["Colete"] = Vector3.new(-169.19932556152344, 293.5002746582031, 317.37908935546875),
    ["Speed Cola"] = Vector3.new(106.36351013183594, 323.4999694824219, 698.6314697265625),
    ["Eletric Cherry"] = Vector3.new(-48.826568603515625, 293.49969482421875, 337.36962890625)
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

-- Variáveis de estado
local teleporting = false
local teleportCooldowns = {}
local cooldownTime = 10 -- 10 segundos de recarga
local buttonReferences = {} -- Para gerenciar todos os botões

-- Função principal de teleporte
local function teleportToLocation(locationName, position)
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
    local Players = game:GetService("Players")
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
    humanoidRootPart.CFrame = CFrame.new(position)
    
    Rayfield:Notify({
        Title = "Teleportado!",
        Content = "Você foi teleportado para " .. locationName .. " por 5 segundos",
        Duration = 5,
        Image = 4483362458
    })
    
    -- Atualizar botão
    if buttonReferences[locationName] then
        buttonReferences[locationName]:Set("⏳ Teleportando...")
    end
    
    -- Esperar 5 segundos
    wait(5)
    
    -- Voltar
    humanoidRootPart.CFrame = originalCFrame
    
    Rayfield:Notify({
        Title = "Retornado!",
        Content = "Você voltou para sua posição original",
        Duration = 3,
        Image = 4483362458
    })
    
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
local function createTeleportButton(tab, locationName, position, emoji)
    local button = tab:CreateButton({
        Name = emoji .. " " .. locationName,
        Callback = function()
            teleportToLocation(locationName, position)
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
    Tab:CreateLabel("Cada teleporte dura 5 segundos")
    Tab:CreateLabel("Cooldown: " .. cooldownTime .. " segundos entre usos")
    
    -- Seção de locais
    Tab:CreateSection("📍 Locais Disponíveis")
    
    -- Criar botões para cada local
    for locationName, position in pairs(locations) do
        local emoji = LocationEmojis[locationName] or "📍"
        createTeleportButton(Tab, locationName, position, emoji)
    end
    
    -- Status
    Tab:CreateSection("📊 Status")
    Tab:CreateLabel("✅ Categoria " .. categoryTitle .. " pronta!")
    
    return Tab
end

-- ============================================
-- CRIAR CATEGORIAS
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
createCategory("Armas", 7733765391, "Armas", ArmasCategory) -- Ícone de arma
createCategory("Bases", 4483362458, "Bases e Locais", BasesCategory) -- Ícone de casa
createCategory("Powers", 9753762469, "Poderes e Buffs", PowersCategory) -- Ícone de raio

-- ============================================
-- ABA DE INFORMAÇÕES GERAIS
-- ============================================
local InfoTab = Window:CreateTab("Informações", 6031068421)

InfoTab:CreateSection("📋 Sistema de Teleporte")
InfoTab:CreateLabel("Versão: 2.0 - Com Categorias")
InfoTab:CreateLabel("Total de locais: " .. #TeleportLocations)
InfoTab:CreateLabel("Duração do teleporte: 5 segundos")
InfoTab:CreateLabel("Tempo de recarga: " .. cooldownTime .. " segundos")

InfoTab:CreateSection("🎮 Como Usar")
InfoTab:CreateLabel("1. Escolha uma categoria")
InfoTab:CreateLabel("2. Clique no local desejado")
InfoTab:CreateLabel("3. Aguarde 5 segundos no local")
InfoTab:CreateLabel("4. Volte automaticamente")

InfoTab:CreateSection("⚙️ Estatísticas")
local totalLocations = 0
for _ in pairs(TeleportLocations) do totalLocations = totalLocations + 1 end
InfoTab:CreateLabel("Armas: 1 local")
InfoTab:CreateLabel("Bases: 4 locais")
InfoTab:CreateLabel("Powers: 6 locais")
InfoTab:CreateLabel("Total: " .. totalLocations .. " locais")

-- ============================================
-- INICIALIZAÇÃO
-- ============================================

print("==========================================")
print("TELEPORT SYSTEM v2.0 - CATEGORIZADO")
print("==========================================")
print("Categorias criadas: 3")
print("Armas: 1 local")
print("Bases: 4 locais")
print("Powers: 6 locais")
print("Total: " .. totalLocations .. " locais")
print("Cooldown: " .. cooldownTime .. "s")
print("==========================================")

Rayfield:Notify({
    Title = "Sistema Carregado!",
    Content = totalLocations .. " locais disponíveis em 3 categorias",
    Duration = 5,
    Image = 4483362458
})