-- ============================================
-- SISTEMA COMPLETO CORRIGIDO
-- ============================================

-- Carregar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Criar janela principal
local Window = Rayfield:CreateWindow({
    Name = "Survival Helper",
    LoadingTitle = "Carregando...",
    LoadingSubtitle = "Versão Corrigida",
    ConfigurationSaving = { Enabled = false }
})

-- ============================================
-- 1. SISTEMA DE TELEPORTE (JÁ FUNCIONANDO)
-- ============================================
local TeleportSystem = {
    teleporting = false,
    cooldowns = {},
    cooldownTime = 10
}

local TeleportLocations = {
    ["Alien Gun"] = Vector3.new(114.22046661376953, 335.4999084472656, 565.9104614257812)
}

local function teleportToLocation(locationName, position)
    if TeleportSystem.teleporting then return end
    
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    TeleportSystem.teleporting = true
    local originalCFrame = humanoidRootPart.CFrame
    
    -- Teleportar
    humanoidRootPart.CFrame = CFrame.new(position)
    
    Rayfield:Notify({
        Title = "Teleportado!",
        Content = locationName .. " (5 segundos)",
        Duration = 3,
        Image = 4483362458
    })
    
    wait(5)
    
    -- Voltar
    humanoidRootPart.CFrame = originalCFrame
    
    Rayfield:Notify({
        Title = "Retornado!",
        Content = "Voltou para posição original",
        Duration = 3,
        Image = 4483362458
    })
    
    TeleportSystem.teleporting = false
end

-- ============================================
-- 2. SISTEMA DE HITBOX EXPANDER CORRIGIDO
-- ============================================
local HitboxSystem = {
    Enabled = false,
    SizeMultiplier = 3.0,
    Transparency = 0.85,
    Color = Color3.fromRGB(255, 50, 50),
    ExpandedMonsters = {},
    KillersFolder = nil
}

-- Função para debug/informação
local function debugPrint(msg)
    print("[HITBOX] " .. msg)
    -- Também mostrar na tela se quiser
end

-- Encontrar a pasta Killers (com letra maiúscula)
local function findKillersFolder()
    debugPrint("Procurando pasta Killers...")
    
    -- Tentar diferentes variações
    local possibleNames = {"Killers", "killers", "Enemies", "Monsters", "Mobs"}
    
    for _, name in pairs(possibleNames) do
        local folder = workspace:FindFirstChild(name)
        if folder then
            debugPrint("✅ Pasta encontrada: " .. name)
            HitboxSystem.KillersFolder = folder
            return folder
        end
    end
    
    debugPrint("❌ Nenhuma pasta de monstros encontrada!")
    return nil
end

-- Expandir UM monstro específico
local function expandSingleMonster(monster)
    if not monster or not monster.Parent then return false end
    
    debugPrint("Expandindo monstro: " .. monster.Name)
    
    -- Verificar se é um monstro válido
    if not monster:IsA("Model") then 
        debugPrint("❌ Não é um Model")
        return false 
    end
    
    -- Listar todas as partes do monstro
    debugPrint("Partes encontradas em " .. monster.Name .. ":")
    for _, part in pairs(monster:GetChildren()) do
        if part:IsA("BasePart") then
            debugPrint("  - " .. part.Name .. " (Tamanho: " .. tostring(part.Size) .. ")")
        end
    end
    
    -- Partes prioritárias para expandir
    local expandedParts = {}
    local partsToExpand = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}
    
    for _, partName in pairs(partsToExpand) do
        local originalPart = monster:FindFirstChild(partName)
        if originalPart and originalPart:IsA("BasePart") then
            debugPrint("✅ Expandindo parte: " .. partName)
            
            -- Criar parte expandida
            local expandedPart = Instance.new("Part")
            expandedPart.Name = "ExpandedHitbox_" .. partName
            expandedPart.Size = originalPart.Size * HitboxSystem.SizeMultiplier
            expandedPart.CFrame = originalPart.CFrame
            expandedPart.Anchored = false
            expandedPart.CanCollide = false
            expandedPart.Transparency = HitboxSystem.Transparency
            expandedPart.Color = HitboxSystem.Color
            expandedPart.Material = Enum.Material.Neon
            
            -- Usar WeldConstraint para seguir o monstro
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = originalPart
            weld.Part1 = expandedPart
            weld.Parent = expandedPart
            
            -- Adicionar para ser visível mas não interferir
            local selection = Instance.new("SelectionBox")
            selection.Adornee = expandedPart
            selection.Transparency = 1
            selection.Visible = false
            selection.Parent = expandedPart
            
            expandedPart.Parent = monster
            expandedParts[originalPart] = expandedPart
            
            debugPrint("  Criada hitbox: " .. expandedPart.Name .. " (Tamanho: " .. tostring(expandedPart.Size) .. ")")
        end
    end
    
    -- Se não expandiu partes prioritárias, expandir qualquer BasePart
    if next(expandedParts) == nil then
        debugPrint("⚠️ Nenhuma parte prioritária encontrada, expandindo todas as BaseParts...")
        
        for _, originalPart in pairs(monster:GetChildren()) do
            if originalPart:IsA("BasePart") and not string.find(originalPart.Name, "ExpandedHitbox") then
                debugPrint("✅ Expandindo: " .. originalPart.Name)
                
                local expandedPart = Instance.new("Part")
                expandedPart.Name = "ExpandedHitbox_" .. originalPart.Name
                expandedPart.Size = originalPart.Size * HitboxSystem.SizeMultiplier
                expandedPart.CFrame = originalPart.CFrame
                expandedPart.Anchored = false
                expandedPart.CanCollide = false
                expandedPart.Transparency = HitboxSystem.Transparency
                expandedPart.Color = HitboxSystem.Color
                expandedPart.Material = Enum.Material.Neon
                
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = originalPart
                weld.Part1 = expandedPart
                weld.Parent = expandedPart
                
                expandedPart.Parent = monster
                expandedParts[originalPart] = expandedPart
            end
        end
    end
    
    if next(expandedParts) ~= nil then
        HitboxSystem.ExpandedMonsters[monster] = expandedParts
        debugPrint("🎯 MONSTRO EXPANDIDO COM SUCESSO: " .. monster.Name)
        return true
    else
        debugPrint("❌ FALHA: Não foi possível expandir nenhuma parte do monstro")
        return false
    end
end

-- Expandir TODOS os monstros
local function expandAllMonsters()
    debugPrint("=== EXPANDINDO TODOS OS MONSTROS ===")
    
    local folder = HitboxSystem.KillersFolder or findKillersFolder()
    if not folder then
        debugPrint("❌ ERRO: Pasta Killers não encontrada!")
        return 0
    end
    
    debugPrint("Monstros na pasta " .. folder.Name .. ": " .. #folder:GetChildren())
    
    local expandedCount = 0
    for _, monster in pairs(folder:GetChildren()) do
        if monster:IsA("Model") then
            debugPrint("--- Processando: " .. monster.Name .. " ---")
            
            -- Verificar se tem Humanoid (é um monstro/npc)
            local humanoid = monster:FindFirstChild("Humanoid")
            if humanoid then
                debugPrint("✅ É um NPC com Humanoid (Vida: " .. humanoid.Health .. ")")
                
                if expandSingleMonster(monster) then
                    expandedCount = expandedCount + 1
                end
            else
                debugPrint("⚠️ Não tem Humanoid, mas vou tentar expandir mesmo assim")
                if expandSingleMonster(monster) then
                    expandedCount = expandedCount + 1
                end
            end
            
            debugPrint("--- Fim: " .. monster.Name .. " ---")
        end
    end
    
    debugPrint("=== EXPANSÃO CONCLUÍDA ===")
    debugPrint("Total expandido: " .. expandedCount .. " monstros")
    return expandedCount
end

-- Restaurar monstros ao normal
local function restoreAllMonsters()
    debugPrint("=== RESTAURANDO MONSTROS ===")
    
    local restoredCount = 0
    for monster, expandedParts in pairs(HitboxSystem.ExpandedMonsters) do
        if monster and monster.Parent then
            debugPrint("Restaurando: " .. monster.Name)
            
            for _, expandedPart in pairs(expandedParts) do
                if expandedPart and expandedPart.Parent then
                    expandedPart:Destroy()
                end
            end
            restoredCount = restoredCount + 1
        end
    end
    
    HitboxSystem.ExpandedMonsters = {}
    debugPrint("✅ Restaurados: " .. restoredCount .. " monstros")
    return restoredCount
end

-- Alternar sistema
local function toggleHitboxSystem()
    HitboxSystem.Enabled = not HitboxSystem.Enabled
    
    if HitboxSystem.Enabled then
        debugPrint("🎯 ATIVANDO SISTEMA DE HITBOX")
        
        -- Primeiro, tentar encontrar a pasta
        findKillersFolder()
        
        -- Expandir monstros
        local count = expandAllMonsters()
        
        if count > 0 then
            Rayfield:Notify({
                Title = "Hitbox Expander",
                Content = "Ativado! " .. count .. " monstros expandidos.",
                Duration = 5,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Aviso",
                Content = "Nenhum monstro encontrado na pasta Killers!",
                Duration = 5,
                Image = 4483362458
            })
        end
        
    else
        debugPrint("🚫 DESATIVANDO SISTEMA DE HITBOX")
        
        local count = restoreAllMonsters()
        
        Rayfield:Notify({
            Title = "Hitbox Expander",
            Content = "Desativado! " .. count .. " monstros restaurados.",
            Duration = 5,
            Image = 4483362458
        })
    end
end

-- ============================================
-- 3. INTERFACE RAYFIELD
-- ============================================

-- Aba de Teleportes
local TeleportTab = Window:CreateTab("Teleportes", 4483362458)
TeleportTab:CreateSection("Teleportes Temporários")

TeleportTab:CreateButton({
    Name = "🚀 Alien Gun (5 segundos)",
    Callback = function()
        teleportToLocation("Alien Gun", TeleportLocations["Alien Gun"])
    end,
})

-- Aba de Combate
local CombatTab = Window:CreateTab("Combate", 7733765391)
CombatTab:CreateSection("Expansor de Hitbox - CORRIGIDO")

-- Botão de diagnóstico primeiro
CombatTab:CreateButton({
    Name = "🔍 DIAGNÓSTICO",
    Callback = function()
        debugPrint("=== EXECUTANDO DIAGNÓSTICO ===")
        
        local folder = findKillersFolder()
        if folder then
            Rayfield:Notify({
                Title = "Diagnóstico",
                Content = "Pasta encontrada: " .. folder.Name .. " (" .. #folder:GetChildren() .. " itens)",
                Duration = 5,
                Image = 4483362458
            })
            
            -- Mostrar alguns monstros
            for i = 1, math.min(3, #folder:GetChildren()) do
                local monster = folder:GetChildren()[i]
                if monster then
                    debugPrint("Monstro " .. i .. ": " .. monster.Name)
                end
            end
        else
            Rayfield:Notify({
                Title = "Erro",
                Content = "Pasta Killers não encontrada!",
                Duration = 5,
                Image = 4483362458
            })
        end
    end,
})

-- Toggle principal
local HitboxToggle = CombatTab:CreateToggle({
    Name = "Ativar Hitbox Expander",
    CurrentValue = false,
    Callback = toggleHitboxSystem
})

-- Controles
CombatTab:CreateSlider({
    Name = "Tamanho (recomendado: 3x)",
    Range = {2, 5},
    Increment = 0.5,
    Suffix = "x",
    CurrentValue = HitboxSystem.SizeMultiplier,
    Callback = function(value)
        HitboxSystem.SizeMultiplier = value
        if HitboxSystem.Enabled then
            -- Recarregar com novo tamanho
            restoreAllMonsters()
            expandAllMonsters()
        end
    end,
})

CombatTab:CreateSlider({
    Name = "Transparência",
    Range = {0.5, 1},
    Increment = 0.1,
    CurrentValue = HitboxSystem.Transparency,
    Callback = function(value)
        HitboxSystem.Transparency = value
        if HitboxSystem.Enabled then
            for _, expandedParts in pairs(HitboxSystem.ExpandedMonsters) do
                for _, part in pairs(expandedParts) do
                    if part then part.Transparency = value end
                end
            end
        end
    end,
})

-- Botão para testar em Jeff específico
CombatTab:CreateButton({
    Name = "🧪 TESTAR NO JEFF",
    Callback = function()
        debugPrint("=== TESTANDO NO JEFF ESPECÍFICO ===")
        
        local jeff = workspace:FindFirstChild("Killers"):FindFirstChild("Jeff")
        if jeff then
            debugPrint("Jeff encontrado!")
            
            if expandSingleMonster(jeff) then
                Rayfield:Notify({
                    Title = "Teste Jeff",
                    Content = "Hitbox expandida com sucesso!",
                    Duration = 5,
                    Image = 4483362458
                })
            else
                Rayfield:Notify({
                    Title = "Erro Jeff",
                    Content = "Falha ao expandir Jeff",
                    Duration = 5,
                    Image = 4483362458
                })
            end
        else
            Rayfield:Notify({
                Title = "Jeff não encontrado",
                Content = "Verifique se Jeff está em workspace.Killers",
                Duration = 5,
                Image = 4483362458
            })
        end
    end,
})

-- ============================================
-- 4. INICIALIZAÇÃO E DEBUG
-- ============================================

print("==========================================")
print(" SURVIVAL HELPER - VERSÃO CORRIGIDA")
print("==========================================")
print("✅ Interface Rayfield carregada")
print("✅ Sistema de Teleporte pronto")
print("✅ Hitbox Expander corrigido")
print("==========================================")

-- Verificar se a pasta existe ao iniciar
spawn(function()
    wait(2)
    local folder = findKillersFolder()
    if folder then
        print("📁 Pasta de monstros: " .. folder.Name)
        print("📊 Total de itens: " .. #folder:GetChildren())
    end
end)

Rayfield:Notify({
    Title = "Sistema Pronto!",
    Content = "Use a aba Combate para Hitbox Expander",
    Duration = 5,
    Image = 4483362458
})
```

Teste RÁPIDO - Execute este primeiro:

```lua
-- TESTE IMEDIATO DE HITBOX
print("=== TESTE IMEDIATO ===")

-- 1. Verificar se Jeff existe
local jeff = workspace.Killers.Jeff
if jeff then
    print("✅ Jeff encontrado em workspace.Killers.Jeff")
    
    -- 2. Verificar partes do Jeff
    print("Partes do Jeff:")
    for _, part in pairs(jeff:GetChildren()) do
        if part:IsA("BasePart") then
            print("  - " .. part.Name .. " | Tamanho: " .. tostring(part.Size))
        end
    end
    
    -- 3. Expandir APENAS a cabeça (teste simples)
    local head = jeff:FindFirstChild("Head")
    if head then
        print("✅ Cabeça encontrada! Expandindo...")
        
        -- Criar hitbox expandida
        local expandedHead = Instance.new("Part")
        expandedHead.Name = "ExpandedHitbox_Test"
        expandedHead.Size = head.Size * 3
        expandedHead.CFrame = head.CFrame
        expandedHead.Transparency = 0.7
        expandedHead.Color = Color3.fromRGB(255, 0, 0)
        expandedHead.Material = Enum.Material.Neon
        expandedHead.CanCollide = false
        
        -- Fixar na cabeça
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = head
        weld.Part1 = expandedHead
        weld.Parent = expandedHead
        
        expandedHead.Parent = jeff
        
        print("🎯 TESTE CONCLUÍDO!")
        print("A cabeça do Jeff agora deve estar 3x maior e vermelha!")
    else
        print("❌ Jeff não tem 'Head'")
        
        -- Mostrar o que ele tem
        for _, part in pairs(jeff:GetChildren()) do
            print("Tem: " .. part.Name .. " (" .. part.ClassName .. ")")
        end
    end
else
    print("❌ Jeff não encontrado!")
    print("Verifique: workspace.Killers existe?")
    
    if workspace:FindFirstChild("Killers") then
        print("✅ Killers existe! Itens:")
        for _, item in pairs(workspace.Killers:GetChildren()) do
            print("  - " .. item.Name)
        end
    else
        print("❌ Killers não existe no workspace")
    end
end