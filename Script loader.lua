-- SCRIPT LOADER COMPACTO HORIZONTAL
-- Painel pequeno + Aba lateral de scripts
-- By ZanScripts

local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local LOCAL = Players.LocalPlayer

-- ==================== CONFIG ====================

local CONFIG = {
    PASSWORD = "adevailza",
    
    CATEGORIES = {
        {
            name = "🤖 AI",
            scripts = {
                {name = "AI Autopilot", url = "URL1"},
                {name = "ChatGPT", url = "URL2"}
            }
        },
        {
            name = "🎮 Game",
            scripts = {
                {name = "Player Chase", url = "URL3"},
                {name = "ESP", url = "URL4"}
            }
        },
        {
            name = "🔧 Utils",
            scripts = {
                {name = "Key System", url = "URL5"},
                {name = "Server Hop", url = "URL6"}
            }
        }
    }
}

-- ==================== CRIAR GUI ====================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CompactLoader"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game:GetService("CoreGui") end

-- Background
local Blur = Instance.new("Frame")
Blur.Size = UDim2.new(1, 0, 1, 0)
Blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Blur.BackgroundTransparency = 0.5
Blur.BorderSizePixel = 0
Blur.Parent = ScreenGui

-- Container PEQUENO E HORIZONTAL (280x180)
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 0, 0, 0)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
Main.BorderSizePixel = 0
Main.ClipsDescendants = false
Main.Parent = Blur

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(70, 70, 85)
MainStroke.Thickness = 1
MainStroke.Parent = Main

-- Animação
TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 280, 0, 180)
}):Play()

-- ==================== PIXEL ART 32x32 ====================

local FaceFrame = Instance.new("Frame")
FaceFrame.Size = UDim2.new(0, 96, 0, 96)
FaceFrame.Position = UDim2.new(0, 15, 0, 15)
FaceFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
FaceFrame.BorderSizePixel = 0
FaceFrame.Parent = Main

local FaceCorner = Instance.new("UICorner")
FaceCorner.CornerRadius = UDim.new(0, 8)
FaceCorner.Parent = FaceFrame

local pixelSize = 3
local grid = {}

for y = 0, 31 do
    grid[y] = {}
    for x = 0, 31 do
        local px = Instance.new("Frame")
        px.Size = UDim2.new(0, pixelSize, 0, pixelSize)
        px.Position = UDim2.new(0, x * pixelSize, 0, y * pixelSize)
        px.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        px.BorderSizePixel = 0
        px.Parent = FaceFrame
        grid[y][x] = px
    end
end

-- Padrões
local PATTERNS = {
    eyes_closed = {
        {8,10},{9,10},{10,10},{11,10},
        {21,10},{22,10},{23,10},{24,10}
    },
    eyes_open = {
        {9,9},{10,9},{11,9},
        {8,10},{9,10},{10,10},{11,10},{12,10},
        {8,11},{9,11},{10,11},{11,11},{12,11},
        {9,12},{10,12},{11,12},
        {10,10},{10,11},
        {20,9},{21,9},{22,9},
        {19,10},{20,10},{21,10},{22,10},{23,10},
        {19,11},{20,11},{21,11},{22,11},{23,11},
        {20,12},{21,12},{22,12},
        {21,10},{21,11}
    },
    mouth_closed = {
        {12,22},{13,22},{14,22},{15,22},{16,22},{17,22},{18,22},{19,22}
    },
    mouth_o = {
        {13,20},{14,20},{15,20},{16,20},{17,20},{18,20},
        {12,21},{19,21},
        {12,22},{19,22},
        {12,23},{19,23},
        {13,24},{14,24},{15,24},{16,24},{17,24},{18,24}
    },
    mouth_semi = {
        {12,21},{13,21},{14,21},{15,21},{16,21},{17,21},{18,21},{19,21},
        {13,22},{14,22},{15,22},{16,22},{17,22},{18,22}
    }
}

local function clearFace()
    for y = 0, 31 do
        for x = 0, 31 do
            grid[y][x].BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        end
    end
end

local function drawPattern(pattern, color)
    for _, pos in ipairs(pattern) do
        local x, y = pos[1], pos[2]
        if grid[y] and grid[y][x] then
            grid[y][x].BackgroundColor3 = color
        end
    end
end

local WHITE = Color3.fromRGB(255, 255, 255)

local function drawFace(eyes, mouth)
    clearFace()
    drawPattern(eyes, WHITE)
    drawPattern(mouth, WHITE)
end

drawFace(PATTERNS.eyes_closed, PATTERNS.mouth_closed)

-- Áudio
local function playAudio()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://6026984224"
    sound.Volume = 0.5
    sound.Parent = SoundService
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 3)
end

local function animateSpeech()
    spawn(function()
        drawFace(PATTERNS.eyes_open, PATTERNS.mouth_o)
        wait(0.25)
        drawFace(PATTERNS.eyes_open, PATTERNS.mouth_semi)
        wait(0.25)
        drawFace(PATTERNS.eyes_open, PATTERNS.mouth_o)
        wait(0.25)
        drawFace(PATTERNS.eyes_open, PATTERNS.mouth_closed)
    end)
end

-- ==================== INFO DO LADO ====================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 150, 0, 25)
Title.Position = UDim2.new(0, 120, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "SCRIPT LOADER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0, 150, 0, 16)
Subtitle.Position = UDim2.new(0, 120, 0, 50)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "by ZanScripts"
Subtitle.TextColor3 = Color3.fromRGB(120, 120, 140)
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 10
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Main

-- Botão para abrir scripts
local OpenScriptsBtn = Instance.new("TextButton")
OpenScriptsBtn.Size = UDim2.new(0, 145, 0, 35)
OpenScriptsBtn.Position = UDim2.new(0, 120, 0, 85)
OpenScriptsBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
OpenScriptsBtn.Text = "📂 Scripts >"
OpenScriptsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenScriptsBtn.Font = Enum.Font.GothamBold
OpenScriptsBtn.TextSize = 12
OpenScriptsBtn.BorderSizePixel = 0
OpenScriptsBtn.Parent = Main

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = OpenScriptsBtn

-- Botão fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(0, 120, 0, 130)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Main

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    wait(0.4)
    ScreenGui:Destroy()
end)

-- ==================== ABA LATERAL DE SCRIPTS ====================

local ScriptSidebar = Instance.new("Frame")
ScriptSidebar.Size = UDim2.new(0, 0, 0, 180)
ScriptSidebar.Position = UDim2.new(1, 0, 0, 0)
ScriptSidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ScriptSidebar.BorderSizePixel = 0
ScriptSidebar.ClipsDescendants = true
ScriptSidebar.Parent = Main

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 12)
SideCorner.Parent = ScriptSidebar

local SideStroke = Instance.new("UIStroke")
SideStroke.Color = Color3.fromRGB(70, 70, 85)
SideStroke.Thickness = 1
SideStroke.Parent = ScriptSidebar

local sidebarOpen = false

-- Header da sidebar
local SideHeader = Instance.new("Frame")
SideHeader.Size = UDim2.new(1, 0, 0, 40)
SideHeader.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
SideHeader.BorderSizePixel = 0
SideHeader.Parent = ScriptSidebar

local SideHeaderCorner = Instance.new("UICorner")
SideHeaderCorner.CornerRadius = UDim.new(0, 12)
SideHeaderCorner.Parent = SideHeader

local SideTitle = Instance.new("TextLabel")
SideTitle.Size = UDim2.new(1, -50, 1, 0)
SideTitle.Position = UDim2.new(0, 10, 0, 0)
SideTitle.BackgroundTransparency = 1
SideTitle.Text = "Selecione o Script"
SideTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SideTitle.Font = Enum.Font.GothamBold
SideTitle.TextSize = 12
SideTitle.TextXAlignment = Enum.TextXAlignment.Left
SideTitle.Parent = SideHeader

local CloseSideBtn = Instance.new("TextButton")
CloseSideBtn.Size = UDim2.new(0, 30, 0, 30)
CloseSideBtn.Position = UDim2.new(1, -35, 0, 5)
CloseSideBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
CloseSideBtn.Text = "✕"
CloseSideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseSideBtn.Font = Enum.Font.GothamBold
CloseSideBtn.TextSize = 14
CloseSideBtn.BorderSizePixel = 0
CloseSideBtn.Parent = SideHeader

local CloseSideCorner = Instance.new("UICorner")
CloseSideCorner.CornerRadius = UDim.new(0, 6)
CloseSideCorner.Parent = CloseSideBtn

-- Tabs
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -10, 0, 30)
TabBar.Position = UDim2.new(0, 5, 0, 45)
TabBar.BackgroundTransparency = 1
TabBar.Parent = ScriptSidebar

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 4)
TabLayout.Parent = TabBar

-- Content
local SideContent = Instance.new("Frame")
SideContent.Size = UDim2.new(1, -10, 1, -85)
SideContent.Position = UDim2.new(0, 5, 0, 80)
SideContent.BackgroundTransparency = 1
SideContent.ClipsDescendants = true
SideContent.Parent = ScriptSidebar

local tabs = {}
local contents = {}

for i, category in ipairs(CONFIG.CATEGORIES) do
    -- Tab
    local Tab = Instance.new("TextButton")
    Tab.Size = UDim2.new(0, 70, 1, 0)
    Tab.BackgroundColor3 = i == 1 and Color3.fromRGB(50, 50, 65) or Color3.fromRGB(25, 25, 32)
    Tab.Text = category.name
    Tab.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tab.Font = Enum.Font.GothamBold
    Tab.TextSize = 10
    Tab.BorderSizePixel = 0
    Tab.Parent = TabBar
    
    local TabCor = Instance.new("UICorner")
    TabCor.CornerRadius = UDim.new(0, 5)
    TabCor.Parent = Tab
    
    table.insert(tabs, Tab)
    
    -- Content
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, 0, 1, 0)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 3
    Content.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 85)
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Content.Visible = (i == 1)
    Content.Parent = SideContent
    
    local CLayout = Instance.new("UIListLayout")
    CLayout.Padding = UDim.new(0, 5)
    CLayout.Parent = Content
    
    table.insert(contents, Content)
    
    -- Scripts
    for _, script in ipairs(category.scripts) do
        local SBtn = Instance.new("TextButton")
        SBtn.Size = UDim2.new(1, -6, 0, 38)
        SBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
        SBtn.Text = script.name
        SBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        SBtn.Font = Enum.Font.Gotham
        SBtn.TextSize = 10
        SBtn.BorderSizePixel = 0
        SBtn.Parent = Content
        
        local SCor = Instance.new("UICorner")
        SCor.CornerRadius = UDim.new(0, 6)
        SCor.Parent = SBtn
        
        SBtn.MouseEnter:Connect(function()
            TweenService:Create(SBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 38)}):Play()
        end)
        
        SBtn.MouseLeave:Connect(function()
            TweenService:Create(SBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 26)}):Play()
        end)
        
        SBtn.MouseButton1Click:Connect(function()
            showPassword(script)
        end)
    end
    
    Tab.MouseButton1Click:Connect(function()
        for j = 1, #tabs do
            tabs[j].BackgroundColor3 = Color3.fromRGB(25, 25, 32)
            contents[j].Visible = false
        end
        Tab.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        Content.Visible = true
    end)
end

-- Abrir/Fechar Sidebar
OpenScriptsBtn.MouseButton1Click:Connect(function()
    sidebarOpen = not sidebarOpen
    
    TweenService:Create(ScriptSidebar, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = sidebarOpen and UDim2.new(0, 250, 0, 180) or UDim2.new(0, 0, 0, 180)
    }):Play()
end)

CloseSideBtn.MouseButton1Click:Connect(function()
    sidebarOpen = false
    TweenService:Create(ScriptSidebar, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 0, 0, 180)
    }):Play()
end)

-- ==================== SENHA ====================

local PassPrompt = Instance.new("Frame")
PassPrompt.Size = UDim2.new(1, 0, 1, 0)
PassPrompt.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
PassPrompt.BackgroundTransparency = 0.7
PassPrompt.BorderSizePixel = 0
PassPrompt.Visible = false
PassPrompt.Parent = Blur

local PassBox = Instance.new("Frame")
PassBox.Size = UDim2.new(0, 260, 0, 130)
PassBox.Position = UDim2.new(0.5, -130, 0.5, -65)
PassBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
PassBox.BorderSizePixel = 0
PassBox.Parent = PassPrompt

local PCorner = Instance.new("UICorner")
PCorner.CornerRadius = UDim.new(0, 10)
PCorner.Parent = PassBox

local PTitle = Instance.new("TextLabel")
PTitle.Size = UDim2.new(1, 0, 0, 30)
PTitle.BackgroundTransparency = 1
PTitle.Text = "🔐 Senha"
PTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
PTitle.Font = Enum.Font.GothamBold
PTitle.TextSize = 13
PTitle.Parent = PassBox

local PassInput = Instance.new("TextBox")
PassInput.Size = UDim2.new(1, -30, 0, 35)
PassInput.Position = UDim2.new(0, 15, 0, 45)
PassInput.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
PassInput.PlaceholderText = "Digite a senha..."
PassInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
PassInput.Text = ""
PassInput.TextColor3 = Color3.fromRGB(255, 255, 255)
PassInput.Font = Enum.Font.Gotham
PassInput.TextSize = 11
PassInput.BorderSizePixel = 0
PassInput.Parent = PassBox

local PICor = Instance.new("UICorner")
PICor.CornerRadius = UDim.new(0, 6)
PICor.Parent = PassInput

local ConfirmBtn = Instance.new("TextButton")
ConfirmBtn.Size = UDim2.new(0, 100, 0, 30)
ConfirmBtn.Position = UDim2.new(0.5, -50, 1, -40)
ConfirmBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
ConfirmBtn.Text = "OK"
ConfirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfirmBtn.Font = Enum.Font.GothamBold
ConfirmBtn.TextSize = 12
ConfirmBtn.BorderSizePixel = 0
ConfirmBtn.Parent = PassBox

local CCor = Instance.new("UICorner")
CCor.CornerRadius = UDim.new(0, 6)
CCor.Parent = ConfirmBtn

local selectedScript = nil

function showPassword(script)
    selectedScript = script
    PassPrompt.Visible = true
    PassInput.Text = ""
    PassInput:CaptureFocus()
end

function checkPass()
    if PassInput.Text == CONFIG.PASSWORD then
        PassPrompt.Visible = false
        playAudio()
        animateSpeech()
        wait(1)
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        wait(0.5)
        ScreenGui:Destroy()
        loadstring(game:HttpGet(selectedScript.url))()
    else
        for i = 1, 2 do
            MainStroke.Color = Color3.fromRGB(255, 50, 50)
            wait(0.1)
            MainStroke.Color = Color3.fromRGB(70, 70, 85)
            wait(0.1)
        end
        PassInput.Text = ""
    end
end

ConfirmBtn.MouseButton1Click:Connect(checkPass)
PassInput.FocusLost:Connect(function(e) if e then checkPass() end end)

wait(0.6)
playAudio()
animateSpeech()

print("✅ Compact Loader | by ZanScripts")
