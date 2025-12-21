-- Ped V1 Script
-- Carregando Wind UI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Criar janela
local Window = WindUI:CreateWindow({
    Title = "Ped V1",
    Subtitle = "by yPedroX",
    Icon = "home",
    Author = "yPedroX",
    Folder = "PedV1Config",
    Size = UDim2.fromOffset(580, 460),
    KeySystem = false,
    Transparent = true,
})

local Window:Tag({
    Title = "v1.6.6",
    Icon = "github",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 0, -- from 0 to 13
})

-- ==================== ABA PERFORMANCE ====================
local PerformanceTab = Window:Tab({
    Title = "Principal",
    Icon = "activity"
})

local PerformanceSection = PerformanceTab:Section({
    Title = "Otimização",
    Closed = false
})

-- Anti Lag TSB
PerformanceSection:Button({
    Title = "Anti Lag TSB",
    Description = "Remove lag do The Strongest Battlegrounds",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/The-Strongest-Battlegrounds-Antilag-TSB-18306"))()
        WindUI:Notify({
            Title = "Anti Lag Ativado!",
            Content = "Otimização aplicada ao jogo",
            Duration = 3
        })
    end
})

-- ==================== ABA COMBATE ====================
local CombatTab = Window:Tab({
    Title = "Combate",
    Icon = "crosshair"
})

local CombatSection = CombatTab:Section({
    Title = "Assistência de Mira",
    Closed = false
})

-- Aimlock
CombatSection:Button({
    Title = "Aimlock",
    Description = "Gruda a câmera no inimigo mais próximo",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Aepione/Prensado/refs/heads/main/Prensado%20camlock"))()
        WindUI:Notify({
            Title = "Aimlock Carregado!",
            Content = "Sistema de mira ativado",
            Duration = 3
        })
    end
})

-- ==================== ABA UTILIDADES ====================
local UtilTab = Window:Tab({
    Title = "Utilidades",
    Icon = "tool"
})

local UtilSection = UtilTab:Section({
    Title = "Auto Reset",
    Closed = false
})

-- Variável para controlar o auto reset
local autoResetEnabled = false
local autoResetLoop = nil

-- Toggle Auto Reset
UtilSection:Toggle({
    Title = "Auto Reset a cada 4 minutos",
    Description = "Mata o personagem automaticamente a cada 4 minutos",
    Default = false,
    Callback = function(value)
        autoResetEnabled = value
        
        if value then
            WindUI:Notify({
                Title = "Auto Reset Ativado!",
                Content = "Personagem será resetado a cada 4 minutos",
                Duration = 3
            })
            
            -- Iniciar loop de reset
            autoResetLoop = task.spawn(function()
                while autoResetEnabled do
                    wait(240) -- 4 minutos = 240 segundos
                    
                    if autoResetEnabled then
                        local player = game.Players.LocalPlayer
                        if player.Character and player.Character:FindFirstChild("Humanoid") then
                            player.Character.Humanoid.Health = 0
                            WindUI:Notify({
                                Title = "Auto Reset",
                                Content = "Personagem resetado!",
                                Duration = 2
                            })
                        end
                    end
                end
            end)
        else
            autoResetEnabled = false
            WindUI:Notify({
                Title = "Auto Reset Desativado!",
                Content = "Reset automático cancelado",
                Duration = 3
            })
        end
    end
})

-- Botão de Reset Manual
UtilSection:Button({
    Title = "Reset Manual",
    Description = "Reseta o personagem imediatamente",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = 0
            WindUI:Notify({
                Title = "Reset Manual",
                Content = "Personagem resetado!",
                Duration = 2
            })
        end
    end
})

-- Notificação inicial
WindUI:Notify({
    Title = "Ped V1 Carregado!",
    Content = "Script desenvolvido por yPedroX",
    Duration = 7
})

print("==========================================")
print("Ped V1 - Carregado com Sucesso!")
print("Desenvolvido por: yPedroX")
print("==========================================")