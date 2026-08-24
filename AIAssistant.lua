--[[\
    Real Gemini AI Assistant for Delta
]]--

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local PathfindingService = game:GetService("PathfindingService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Очистка старого интерфейса
if CoreGui:FindFirstChild("TrueAIChat") then
    CoreGui.TrueAIChat:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrueAIChat"
ScreenGui.ResetOnSpawn = false

pcall(function()
    if gethui then ScreenGui.Parent = gethui()
    else ScreenGui.Parent = CoreGui end
end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Круглая кнопка
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(1, -65, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
ToggleBtn.Text = "🧠"
ToggleBtn.TextSize = 24
ToggleBtn.ZIndex = 100
ToggleBtn.Parent = ScreenGui

local BtnCorner = Instance.new("UICorner") BtnCorner.CornerRadius = UDim.new(1, 0) BtnCorner.Parent = ToggleBtn
local BtnStroke = Instance.new("UIStroke") BtnStroke.Color = Color3.fromRGB(0, 180, 255) BtnStroke.Thickness = 2 BtnStroke.Parent = ToggleBtn

-- Главное меню
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 310)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
MainFrame.Visible = false
MainFrame.ZIndex = 90
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner") FrameCorner.CornerRadius = UDim.new(0, 10) FrameCorner.Parent = MainFrame
local FrameStroke = Instance.new("UIStroke") FrameStroke.Color = Color3.fromRGB(0, 180, 255) FrameStroke.Thickness = 1.5 FrameStroke.Parent = MainFrame

-- Шапка
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 34)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
TopBar.ZIndex = 91
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "  🤖 GEMINI AI ASSISTANT"
Title.Size = UDim2.new(1, -35, 1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 92
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -30, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 12
CloseBtn.ZIndex = 93
CloseBtn.Parent = TopBar
local CloseCorner = Instance.new("UICorner") CloseCorner.CornerRadius = UDim.new(0, 6) CloseCorner.Parent = CloseBtn

-- Чат
local ChatScroll = Instance.new("ScrollingFrame")
ChatScroll.Size = UDim2.new(1, -10, 1, -85)
ChatScroll.Position = UDim2.new(0, 5, 0, 38)
ChatScroll.BackgroundTransparency = 1
ChatScroll.ScrollBarThickness = 3
ChatScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
ChatScroll.ZIndex = 91
ChatScroll.Parent = MainFrame

local ChatLayout = Instance.new("UIListLayout")
ChatLayout.SortOrder = Enum.SortOrder.LayoutOrder
ChatLayout.Padding = UDim.new(0, 4)
ChatLayout.Parent = ChatScroll

-- Ввод
local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(1, -44, 0, 32)
InputBox.Position = UDim2.new(0, 5, 1, -37)
InputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.PlaceholderText = "Спроси Gemini или 'подойди к [ник]'..."
InputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
InputBox.Font = Enum.Font.SourceSans
InputBox.TextSize = 12
InputBox.ClearTextOnFocus = false
InputBox.ZIndex = 92
InputBox.Parent = MainFrame

local InputCorner = Instance.new("UICorner") InputCorner.CornerRadius = UDim.new(0, 6) InputCorner.Parent = InputBox

local SendBtn = Instance.new("TextButton")
SendBtn.Text = "➤"
SendBtn.Size = UDim2.new(0, 32, 0, 32)
SendBtn.Position = UDim2.new(1, -37, 1, -37)
SendBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SendBtn.Font = Enum.Font.SourceSansBold
SendBtn.TextSize = 13
SendBtn.ZIndex = 92
SendBtn.Parent = MainFrame

local SendCorner = Instance.new("UICorner") SendCorner.CornerRadius = UDim.new(0, 6) SendCorner.Parent = SendBtn

-- Перетаскивание кнопки
local dragging, dragStart, startPos, moved = false, nil, nil, false
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true moved = false dragStart = input.Position startPos = ToggleBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        if delta.Magnitude > 4 then moved = true end
        ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

ToggleBtn.Activated:Connect(function() if not moved then MainFrame.Visible = not MainFrame.Visible end end)
CloseBtn.Activated:Connect(function() MainFrame.Visible = false end)

-- Вывод сообщений в чат
local totalH = 0
local function AddMsg(sender, text)
    local msgFrame = Instance.new("Frame")
    msgFrame.Size = UDim2.new(1, 0, 0, 0)
    msgFrame.BackgroundTransparency = 1
    msgFrame.ZIndex = 92
    msgFrame.Parent = ChatScroll

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Text = (sender == "ai" and "[Gemini]: " or "[Вы]: ") .. text
    msgLabel.Size = UDim2.new(1, 0, 1, 0)
    msgLabel.BackgroundTransparency = 1
    msgLabel.TextColor3 = sender == "ai" and Color3.fromRGB(0, 220, 255) or Color3.fromRGB(240, 240, 240)
    msgLabel.Font = Enum.Font.SourceSans
    msgLabel.TextSize = 12
    msgLabel.TextWrapped = true
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.ZIndex = 93
    msgLabel.Parent = msgFrame

    local bounds = TextService:GetTextSize(msgLabel.Text, 12, Enum.Font.SourceSans, Vector2.new(230, 2000))
    local h = math.max(bounds.Y + 4, 18)
    msgFrame.Size = UDim2.new(1, 0, 0, h)
    totalH = totalH + h + 4
    ChatScroll.CanvasSize = UDim2.new(0, 0, 0, totalH)
    ChatScroll.CanvasPosition = Vector2.new(0, totalH)
end

task.spawn(function()
    task.wait(0.3)
    AddMsg("ai", "Привет! Я Gemini. Спроси меня о чем угодно или напиши 'подойди к [ник]'.")
end)

-- Функция управления персонажем
local function ApproachPlayer(targetName)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return "Нет персонажа!" end
    
    local targetPlayer = nil
    local lowerTarget = targetName:lower():gsub("^%s+", ""):gsub("%s+$", "")
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if p.Name:lower():find(lowerTarget) or p.DisplayName:lower():find(lowerTarget) then
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    targetPlayer = p
                    break
                end
            end
        end
    end
    
    if not targetPlayer then return "Игрок не найден на сервере!" end
    local targetPos = targetPlayer.Character.HumanoidRootPart.Position
    
    task.spawn(function()
        AddMsg("ai", "Иду к игроку " .. targetPlayer.Name .. "...")
        local path = PathfindingService:CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true })
        local success = pcall(function() path:ComputeAsync(char.HumanoidRootPart.Position, targetPos) end)
        
        if success and path.Status == Enum.PathStatus.Success then
            for _, wp in ipairs(path:GetWaypoints()) do
                if not char:FindFirstChild("Humanoid") then break end
                char.Humanoid:MoveTo(wp.Position)
                if wp.Action == Enum.PathWaypointAction.Jump then char.Humanoid.Jump = true end
                task.wait(0.25)
            end
            AddMsg("ai", "Я дошел до игрока " .. targetPlayer.Name .. "!")
        else
            char.Humanoid:MoveTo(targetPos)
            AddMsg("ai", "Иду к игроку напрямую!")
        end
    end)
    
    return "Строю путь к " .. targetPlayer.Name .. "..."
end

-- Запрос к Gemini API
local function GetAIResponse(prompt)
    local lower = prompt:lower()
    
    local targetName = lower:match("подойди%s+к%s+(.+)") or lower:match("иди%s+к%s+(.+)")
    if targetName then
        return ApproachPlayer(targetName)
    end
    
    if lower == "/help" then
        return "Команды:\n- Любой вопрос (ответит Gemini)\n- 'подойди к [ник]' (идти к игроку)"
    end

    local apiKey = "AQ.Ab8RN6Llx4HhrHNeBp6x7F6tk6eVWd5XvDVw-VVHHJymAgqz1A"
    local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" .. apiKey
    
    local requestData = {
        contents = {
            {
                parts = {
                    { text = "Ты игровой помощник в Roblox. Отвечай кратко, по делу и на русском языке: " .. prompt }
                }
            }
        }
    }
    
    local success, response = pcall(function()
        local req = (http_request or request or HttpService.RequestAsync)
        return req({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(requestData)
        })
    end)
    
    if success and response then
        local bodyText = response.Body or response.Data
        if bodyText then
            local successDecode, data = pcall(function()
                return HttpService:JSONDecode(bodyText)
            end)
            if successDecode and data and data.candidates and data.candidates[1] then
                local parts = data.candidates[1].content.parts
                if parts and parts[1] then
                    return parts[1].text
                end
            end
        end
    end
    
    return "Не удалось связаться с Gemini. Проверь правильность ключа."
end

local function OnSubmit()
    local text = InputBox.Text
    if text == "" then return end
    AddMsg("user", text)
    InputBox.Text = ""
    
    task.spawn(function()
        local reply = GetAIResponse(text)
        AddMsg("ai", reply)
    end)
end

SendBtn.Activated:Connect(OnSubmit)
InputBox.FocusLost:Connect(function(enter) if enter then OnSubmit() end end)

print("Gemini AI Assistant успешно запущен!")
