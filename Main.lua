-- Ped V1 Script
-- Wind UI
local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

-- Serviços
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ==================== WINDOW ====================
local Window = WindUI:CreateWindow({
    Title = "Ped V1",
    Subtitle = "by yPedroX",
    Icon = "tv-minimal",
    Author = "yPedroX",
    Folder = "PedV1Config",
    Size = UDim2.fromOffset(580, 460),
    KeySystem = false,
    Transparent = true,
})

Window:Tag({
    Title = "v1.0",
    Icon = "github",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 0,
})

-- ==================== ABA COMBATE ====================
local CombatTab = Window:Tab({
    Title = "Combate",
    Icon = "crosshair"
})

local CombatSection = CombatTab:Section({
    Title = "Assistência",
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

-- ==================== SKILL CHECK ====================
local skillCheckEnabled = false
local oldNamecall
local mt = getrawmetatable(game)

CombatSection:Toggle({
    Title = "Auto Skill Check (Nunca Errar)",
    Description = "Sempre acerta o skill check do Generator",
    Default = false,
    Callback = function(v)
        skillCheckEnabled = v

        if v then
            setreadonly(mt, false)
            oldNamecall = mt.__namecall

            mt.__namecall = newcclosure(function(self, ...)
                local args = {...}
                local method = getnamecallmethod()

                if skillCheckEnabled
                    and method == "FireServer"
                    and tostring(self) == "SkillCheckResultEvent" then
                    args[1] = true
                    return oldNamecall(self, unpack(args))
                end

                return oldNamecall(self, ...)
            end)

            setreadonly(mt, true)
        else
            if oldNamecall then
                setreadonly(mt, false)
                mt.__namecall = oldNamecall
                setreadonly(mt, true)
            end
        end
    end
})

-- ==================== ABA ESP ====================
local EspTab = Window:Tab({
    Title = "ESP",
    Icon = "brush"
})

local EspSection = EspTab:Section({
    Title = "ESP Config",
    Closed = false
})

-- ==================== VARIÁVEIS ====================
local espGenerator = false
local generatorESP = {}

-- ==================== FUNÇÃO % ====================
local function getGeneratorPercent(model)
    local value = model:GetAttribute("RepairProgress")
    if typeof(value) ~= "number" then return "0%" end

    if value <= 1 then
        return math.floor(value * 100) .. "%"
    else
        return math.floor(value) .. "%"
    end
end

-- ==================== ESP GENERATOR ====================
local function applyGeneratorESP(model)
    if generatorESP[model] then return end

    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0.4
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    highlight.Adornee = model
    highlight.Parent = model

    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = part
    billboard.Size = UDim2.fromOffset(120, 22)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = part

    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1,1)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(255,255,0)
    text.TextSize = 14
    text.Font = Enum.Font.Gotham
    text.TextStrokeTransparency = 0.7
    text.Parent = billboard

    generatorESP[model] = {
        highlight = highlight,
        text = text
    }
end

-- ==================== SCAN ====================
local function scanGenerators()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Generator" then
            applyGeneratorESP(obj)
        end
    end
end

-- ==================== TOGGLE ====================
EspSection:Toggle({
    Title = "ESP Generator (Amarelo + %)",
    Default = false,
    Callback = function(v)
        espGenerator = v

        if v then
            scanGenerators()
        else
            for _, data in pairs(generatorESP) do
                if data.highlight then data.highlight:Destroy() end
                if data.text and data.text.Parent then
                    data.text.Parent:Destroy()
                end
            end
            generatorESP = {}
        end
    end
})

-- ==================== UPDATE % TEMPO REAL ====================
RunService.RenderStepped:Connect(function()
    if not espGenerator then return end

    for model, data in pairs(generatorESP) do
        if model and model.Parent and data.text then
            data.text.Text = "Generator [" .. getGeneratorPercent(model) .. "]"
        end
    end
end)

Workspace.DescendantAdded:Connect(function(obj)
    if espGenerator and obj:IsA("Model") and obj.Name == "Generator" then
        task.wait(0.3)
        applyGeneratorESP(obj)
    end
end)

-- ==================== FINAL ====================
WindUI:Notify({
    Title = "Ped V1 Carregado!",
    Content = "ESP Generator com porcentagem ativo!",
    Duration = 6
})

print("Ped V1 carregado com sucesso")