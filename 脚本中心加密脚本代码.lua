-- 脚本加密工具 UI库版
-- 版本: 2.0

local Players = game:GetService("Players")
local CoreGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- UI库类
local UILibrary = {}
UILibrary.__index = UILibrary

function UILibrary.new()
    local self = setmetatable({}, UILibrary)
    
    -- 创建主界面
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "ScriptEncryptorUILibrary"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- 主窗口
    self.MainWindow = self:CreateWindow({
        Title = "脚本加密工具",
        Size = UDim2.new(0, 350, 0, 450),
        Position = UDim2.new(0.5, -175, 0.5, -225)
    })
    
    -- 标签页系统
    self.Tabs = {}
    self.ActiveTab = nil
    
    -- 初始化标签页
    self:InitializeTabs()
    
    self.ScreenGui.Parent = playerGui
    
    return self
end

-- 创建窗口
function UILibrary:CreateWindow(options)
    local window = {}
    
    -- 主窗口框架
    window.Frame = Instance.new("Frame")
    window.Frame.Name = "Window"
    window.Frame.Size = options.Size or UDim2.new(0, 300, 0, 400)
    window.Frame.Position = options.Position or UDim2.new(0.5, -150, 0.5, -200)
    window.Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    window.Frame.BorderSizePixel = 0
    window.Frame.ClipsDescendants = true
    
    -- 圆角
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = window.Frame
    
    -- 阴影
    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Name = "DropShadow"
    DropShadow.Size = UDim2.new(1, 10, 1, 10)
    DropShadow.Position = UDim2.new(0, -5, 0, -5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.Image = "rbxassetid://6014261993"
    DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow.ImageTransparency = 0.5
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.Parent = window.Frame
    
    -- 标题栏
    window.TitleBar = Instance.new("Frame")
    window.TitleBar.Name = "TitleBar"
    window.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    window.TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    window.TitleBar.BorderSizePixel = 0
    
    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 8)
    TitleBarCorner.Parent = window.TitleBar
    
    window.Title = Instance.new("TextLabel")
    window.Title.Name = "Title"
    window.Title.Size = UDim2.new(0, 120, 1, 0)
    window.Title.Position = UDim2.new(0, 15, 0, 0)
    window.Title.BackgroundTransparency = 1
    window.Title.Text = options.Title or "窗口"
    window.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    window.Title.TextSize = 18
    window.Title.Font = Enum.Font.GothamSemibold
    window.Title.TextXAlignment = Enum.TextXAlignment.Left
    
    window.MinimizeButton = Instance.new("TextButton")
    window.MinimizeButton.Name = "MinimizeButton"
    window.MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    window.MinimizeButton.Position = UDim2.new(1, -70, 0.5, -15)
    window.MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    window.MinimizeButton.Text = "_"
    window.MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    window.MinimizeButton.TextSize = 20
    window.MinimizeButton.Font = Enum.Font.GothamBold
    
    local MinimizeButtonCorner = Instance.new("UICorner")
    MinimizeButtonCorner.CornerRadius = UDim.new(0, 4)
    MinimizeButtonCorner.Parent = window.MinimizeButton
    
    window.CloseButton = Instance.new("TextButton")
    window.CloseButton.Name = "CloseButton"
    window.CloseButton.Size = UDim2.new(0, 30, 0, 30)
    window.CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
    window.CloseButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    window.CloseButton.Text = "X"
    window.CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    window.CloseButton.TextSize = 16
    window.CloseButton.Font = Enum.Font.GothamBold
    
    local CloseButtonCorner = Instance.new("UICorner")
    CloseButtonCorner.CornerRadius = UDim.new(0, 4)
    CloseButtonCorner.Parent = window.CloseButton
    
    -- 内容区域
    window.Content = Instance.new("Frame")
    window.Content.Name = "Content"
    window.Content.Size = UDim2.new(1, -20, 1, -60)
    window.Content.Position = UDim2.new(0, 10, 0, 50)
    window.Content.BackgroundTransparency = 1
    
    -- 标签页容器
    window.TabContainer = Instance.new("Frame")
    window.TabContainer.Name = "TabContainer"
    window.TabContainer.Size = UDim2.new(1, 0, 0, 30)
    window.TabContainer.BackgroundTransparency = 1
    
    window.TabContent = Instance.new("Frame")
    window.TabContent.Name = "TabContent"
    window.TabContent.Size = UDim2.new(1, 0, 1, -35)
    window.TabContent.Position = UDim2.new(0, 0, 0, 35)
    window.TabContent.BackgroundTransparency = 1
    
    -- 组装
    window.TitleBar.Parent = window.Frame
    window.Title.Parent = window.TitleBar
    window.MinimizeButton.Parent = window.TitleBar
    window.CloseButton.Parent = window.TitleBar
    window.Content.Parent = window.Frame
    window.TabContainer.Parent = window.Content
    window.TabContent.Parent = window.Content
    
    -- 拖拽功能
    self:AddDragFunctionality(window)
    
    -- 按钮悬停效果
    self:AddButtonHover(window.MinimizeButton)
    self:AddButtonHover(window.CloseButton)
    
    return window
end

-- 添加拖拽功能
function UILibrary:AddDragFunctionality(window)
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        window.Frame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
    
    window.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    window.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateInput(input)
        end
    end)
end

-- 添加按钮悬停效果
function UILibrary:AddButtonHover(button)
    local originalColor = button.BackgroundColor3
    
    button.MouseEnter:Connect(function()
        local tween = TweenService:Create(
            button,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(
                math.min(originalColor.R * 255 + 30, 255),
                math.min(originalColor.G * 255 + 30, 255),
                math.min(originalColor.B * 255 + 30, 255)
            )}
        )
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local tween = TweenService:Create(
            button,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = originalColor}
        )
        tween:Play()
    end)
end

-- 创建按钮
function UILibrary:CreateButton(parent, options)
    local button = Instance.new("TextButton")
    button.Name = options.Name or "Button"
    button.Size = options.Size or UDim2.new(1, 0, 0, 40)
    button.Position = options.Position or UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = options.BackgroundColor3 or Color3.fromRGB(80, 120, 200)
    button.Text = options.Text or "按钮"
    button.TextColor3 = options.TextColor3 or Color3.fromRGB(255, 255, 255)
    button.TextSize = options.TextSize or 16
    button.Font = options.Font or Enum.Font.GothamSemibold
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    if parent then
        button.Parent = parent
    end
    
    -- 添加悬停效果
    self:AddButtonHover(button)
    
    return button
end

-- 创建输入框
function UILibrary:CreateTextBox(parent, options)
    local textBox = Instance.new("TextBox")
    textBox.Name = options.Name or "TextBox"
    textBox.Size = options.Size or UDim2.new(1, 0, 0, 100)
    textBox.Position = options.Position or UDim2.new(0, 0, 0, 0)
    textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    textBox.TextColor3 = options.TextColor3 or Color3.fromRGB(255, 255, 255)
    textBox.TextSize = options.TextSize or 14
    textBox.Font = options.Font or Enum.Font.RobotoMono
    textBox.Text = options.Text or ""
    textBox.PlaceholderText = options.PlaceholderText or ""
    textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    textBox.ClearTextOnFocus = options.ClearTextOnFocus or false
    textBox.MultiLine = options.MultiLine or false
    textBox.TextXAlignment = options.TextXAlignment or Enum.TextXAlignment.Left
    textBox.TextYAlignment = options.TextYAlignment or Enum.TextYAlignment.Top
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = textBox
    
    if parent then
        textBox.Parent = parent
    end
    
    return textBox
end

-- 创建标签
function UILibrary:CreateLabel(parent, options)
    local label = Instance.new("TextLabel")
    label.Name = options.Name or "Label"
    label.Size = options.Size or UDim2.new(1, 0, 0, 20)
    label.Position = options.Position or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = options.Text or "标签"
    label.TextColor3 = options.TextColor3 or Color3.fromRGB(200, 200, 200)
    label.TextSize = options.TextSize or 14
    label.Font = options.Font or Enum.Font.Gotham
    label.TextXAlignment = options.TextXAlignment or Enum.TextXAlignment.Left
    
    if parent then
        label.Parent = parent
    end
    
    return label
end

-- 创建标签页
function UILibrary:CreateTab(tabName, tabText)
    local tab = {}
    tab.Name = tabName
    
    -- 标签按钮
    tab.Button = Instance.new("TextButton")
    tab.Button.Name = tabName .. "TabButton"
    tab.Button.Size = UDim2.new(0, 80, 1, 0)
    tab.Button.Position = UDim2.new(0, (#self.Tabs * 85), 0, 0)
    tab.Button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    tab.Button.Text = tabText or tabName
    tab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    tab.Button.TextSize = 14
    tab.Button.Font = Enum.Font.Gotham
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = tab.Button
    
    -- 标签内容
    tab.Content = Instance.new("Frame")
    tab.Content.Name = tabName .. "Content"
    tab.Content.Size = UDim2.new(1, 0, 1, 0)
    tab.Content.BackgroundTransparency = 1
    tab.Content.Visible = false
    
    -- 添加到UI
    tab.Button.Parent = self.MainWindow.TabContainer
    tab.Content.Parent = self.MainWindow.TabContent
    
    -- 悬停效果
    self:AddButtonHover(tab.Button)
    
    -- 点击事件
    tab.Button.MouseButton1Click:Connect(function()
        self:SwitchTab(tabName)
    end)
    
    self.Tabs[tabName] = tab
    
    -- 如果是第一个标签，设为活动标签
    if #self.Tabs == 1 then
        self:SwitchTab(tabName)
    end
    
    return tab
end

-- 切换标签页
function UILibrary:SwitchTab(tabName)
    if self.ActiveTab then
        -- 重置上一个活动标签的按钮颜色
        self.ActiveTab.Button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        self.ActiveTab.Content.Visible = false
    end
    
    -- 设置新活动标签
    self.ActiveTab = self.Tabs[tabName]
    if self.ActiveTab then
        self.ActiveTab.Button.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
        self.ActiveTab.Content.Visible = true
    end
end

-- 初始化标签页
function UILibrary:InitializeTabs()
    -- 加密标签页
    local encryptTab = self:CreateTab("Encrypt", "加密")
    
    -- 加密标签页内容
    local encryptContent = encryptTab.Content
    
    -- 输入标签
    self:CreateLabel(encryptContent, {
        Name = "InputLabel",
        Text = "输入要加密的脚本:",
        Position = UDim2.new(0, 0, 0, 0)
    })
    
    -- 脚本输入框
    self.ScriptInput = self:CreateTextBox(encryptContent, {
        Name = "ScriptInput",
        Size = UDim2.new(1, 0, 0, 100),
        Position = UDim2.new(0, 0, 0, 25),
        Text = "print('Hello from Script Hub!')\nfor i = 1, 5 do\n    print('Count:', i)\nend",
        MultiLine = true
    })
    
    -- 混淆标签
    self:CreateLabel(encryptContent, {
        Name = "ObfuscateLabel",
        Text = "混淆文本 (可选):",
        Position = UDim2.new(0, 0, 0, 135)
    })
    
    -- 混淆输入框
    self.ObfuscateInput = self:CreateTextBox(encryptContent, {
        Name = "ObfuscateInput",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 160),
        Text = "RandomObfuscationString123",
        MultiLine = false
    })
    
    -- 加密按钮
    self.EncryptButton = self:CreateButton(encryptContent, {
        Name = "EncryptButton",
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 200),
        Text = "加密脚本",
        BackgroundColor3 = Color3.fromRGB(80, 120, 200)
    })
    
    -- 输出标签
    self:CreateLabel(encryptContent, {
        Name = "OutputLabel",
        Text = "加密结果:",
        Position = UDim2.new(0, 0, 0, 250)
    })
    
    -- 输出框
    self.OutputBox = self:CreateTextBox(encryptContent, {
        Name = "OutputBox",
        Size = UDim2.new(1, 0, 0, 80),
        Position = UDim2.new(0, 0, 0, 275),
        Text = "加密结果将显示在这里...",
        MultiLine = true,
        TextEditable = false
    })
    
    -- 复制按钮
    self.CopyButton = self:CreateButton(encryptContent, {
        Name = "CopyButton",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 365),
        Text = "复制到剪贴板",
        BackgroundColor3 = Color3.fromRGB(60, 150, 100),
        TextSize = 14
    })
    
    -- 设置标签页
    self:SwitchTab("Encrypt")
end

-- 发送通知
function UILibrary:SendNotification(title, text)
    CoreGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Icon = "rbxassetid://130346803512317",
        Duration = 6,
    })
end

-- 加密函数 (八进制编码)
function UILibrary:EncryptToOctal(scriptText)
    -- 先转义字符串中的特殊字符
    local escaped = string.gsub(scriptText, "\\", "\\\\")
    escaped = string.gsub(escaped, "\"", "\\\"")
    escaped = string.gsub(escaped, "'", "\\'")
    escaped = string.gsub(escaped, "\n", "\\n")
    escaped = string.gsub(escaped, "\r", "\\r")
    escaped = string.gsub(escaped, "\t", "\\t")
    
    local result = ""
    for i = 1, #escaped do
        local charCode = string.byte(escaped, i)
        -- 转换为八进制
        local octal = string.format("%o", charCode)
        -- 确保是3位八进制数
        while #octal < 3 do
            octal = "0" .. octal
        end
        result = result .. "\\" .. octal
    end
    return result
end

-- 生成可执行的loadstring代码
function UILibrary:GenerateExecutableCode(encryptedScript)
    local header = "-- [[ Script Hub = \"脚本中心加密脚本代码\" ]]\n"
    
    -- 修复：创建一个可以直接执行的loadstring
    local loadstringCode = string.format(
        "local encoded = \"%s\"\n" ..
        "local decoded = \"\"\n" ..
        "for code in string.gmatch(encoded, \"\\\\(%d%d%d)\") do\n" ..
        "    decoded = decoded .. string.char(tonumber(code, 8))\n" ..
        "end\n" ..
        "loadstring(decoded)()",
        encryptedScript
    )
    
    return header .. loadstringCode
end

-- 最小化功能
function UILibrary:SetupMinimize()
    local isMinimized = false
    local originalSize = self.MainWindow.Frame.Size
    local minimizedSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 40)
    
    self.MainWindow.MinimizeButton.MouseButton1Click:Connect(function()
        if isMinimized then
            -- 恢复
            local tween = TweenService:Create(
                self.MainWindow.Frame,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = originalSize}
            )
            tween:Play()
            self.MainWindow.Content.Visible = true
        else
            -- 最小化
            local tween = TweenService:Create(
                self.MainWindow.Frame,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = minimizedSize}
            )
            tween:Play()
            self.MainWindow.Content.Visible = false
        end
        isMinimized = not isMinimized
    end)
end

-- 关闭功能
function UILibrary:SetupClose()
    self.MainWindow.CloseButton.MouseButton1Click:Connect(function()
        self.ScreenGui:Destroy()
    end)
end

-- 设置按钮事件
function UILibrary:SetupEvents()
    -- 加密按钮
    self.EncryptButton.MouseButton1Click:Connect(function()
        local scriptText = self.ScriptInput.Text
        if scriptText == "" or scriptText == "在这里粘贴你的脚本..." then
            self:SendNotification("错误", "请输入要加密的脚本")
            return
        end
        
        -- 加密脚本
        local encrypted = self:EncryptToOctal(scriptText)
        local finalCode = self:GenerateExecutableCode(encrypted)
        
        -- 显示结果
        self.OutputBox.Text = finalCode
        
        -- 发送成功通知
        self:SendNotification("脚本加密", "加密成功！")
        
        -- 添加混淆文本效果
        if self.ObfuscateInput.Text ~= "" and self.ObfuscateInput.Text ~= "一些混淆文本" then
            wait(0.5)
            self:SendNotification("混淆", "混淆文本已应用: " .. self.ObfuscateInput.Text)
        end
    end)
    
    -- 复制按钮
    self.CopyButton.MouseButton1Click:Connect(function()
        if self.OutputBox.Text ~= "加密结果将显示在这里..." then
            -- 尝试复制到剪贴板
            pcall(function()
                -- 检查是否有可用的剪贴板函数
                local clipboardFunc = setclipboard or writeclipboard or toclipboard
                if clipboardFunc then
                    clipboardFunc(self.OutputBox.Text)
                    self:SendNotification("复制成功", "加密脚本已复制到剪贴板")
                    
                    -- 测试运行加密后的代码
                    wait(1)
                    self:SendNotification("测试运行", "尝试执行加密脚本...")
                    
                    -- 安全地测试代码
                    pcall(function()
                        local success, result = pcall(loadstring(self.OutputBox.Text))
                        if success then
                            self:SendNotification("执行成功", "加密脚本执行成功")
                        else
                            self:SendNotification("执行错误", "错误: " .. tostring(result))
                        end
                    end)
                else
                    -- 如果没有复制函数，让用户手动选择文本
                    self.OutputBox.TextEditable = true
                    self.OutputBox:CaptureFocus()
                    self.OutputBox.SelectionStart = 1
                    self.OutputBox.CursorPosition = #self.OutputBox.Text + 1
                    self:SendNotification("复制提示", "请使用 Ctrl+A 全选，然后 Ctrl+C 复制")
                    wait(1)
                    self.OutputBox.TextEditable = false
                end
            end)
        else
            self:SendNotification("错误", "请先加密脚本")
        end
    end)
end

-- 初始化
function UILibrary:Initialize()
    -- 设置最小化和关闭功能
    self:SetupMinimize()
    self:SetupClose()
    
    -- 设置按钮事件
    self:SetupEvents()
    
    -- 发送欢迎通知
    wait(1)
    self:SendNotification("脚本加密工具 UI库版", "欢迎使用脚本加密工具 v2.0")
    wait(1)
    CoreGui:SetCore("SendNotification", {
        Title = "测试",
        Text = "测试",
        Icon = "rbxassetid://130346803512317",
        Duration = 6,
    })
end

-- 创建并初始化UI库
local UI = UILibrary.new()
UI:Initialize()
