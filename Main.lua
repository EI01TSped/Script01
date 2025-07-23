-- Carrega o Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Cria a janela do Hub
local Window = Rayfield:CreateWindow({
    Name = "ESP Hub",
    LoadingTitle = "ESP Rayfield",
    LoadingSubtitle = "by SeuNome",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "RayfieldESP", -- Nome da pasta no workspace
        FileName = "espconfig"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- Função para desenhar ESP (Highlight básico)
local function EnableESP()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not player.Character:FindFirstChild("ESPHighlight") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESPHighlight"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Adornee = player.Character
                highlight.Parent = player.Character
            end
        end
    end
end

-- Remove o ESP
local function DisableESP()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("ESPHighlight") then
            player.Character.ESPHighlight:Destroy()
        end
    end
end

-- Cria a aba e toggle na interface
local MainTab = Window:CreateTab("ESP", 4483362458) -- Ícone opcional

local ESPToggle = MainTab:CreateToggle({
    Name = "Ativar ESP",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            EnableESP()
            -- Atualiza sempre que um novo jogador aparecer
            game.Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function()
                    wait(1)
                    EnableESP()
                end)
            end)
        else
            DisableESP()
        end
    end,
})

Rayfield:LoadConfiguration()
