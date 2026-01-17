-- 脚本中心通用 - 多合一脚本菜单
-- 版本：永久免费 v2.0

-- 加载 WindUI 库
local WindUI do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)
    
    if ok then
        WindUI = result
    else
        WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end
end

-- 创建弹窗
WindUI:Popup({
    Title = "脚本中心通用",
    Icon = "rbxassetid://130346803512317",
    Content = "正在加载脚本中心通用...\n\n其他：\n• 😏",
    Buttons = {
        {
            Title = "取消",
            Callback = function() 
                return
            end,
            Variant = "Tertiary",
        },
        {
            Title = "继续加载",
            Callback = function() 
                createMainWindow()
            end,
            Variant = "Primary",
        }
    }
})

-- 服务
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("StarterGui")
local StatsService = game:GetService("Stats")

-- 变量
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local defaultWalkSpeed = 16
local defaultJumpPower = 50
local defaultMaxZoom = 400
local defaultGravity = 196.2
local defaultFieldOfView = camera.FieldOfView

-- 角色相关
local character, humanoid, rootpart

local function getCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid", 5)
    rootpart = character:WaitForChild("HumanoidRootPart", 5)
    defaultWalkSpeed = humanoid.WalkSpeed
    defaultJumpPower = humanoid.JumpPower
    defaultMaxZoom = player.CameraMaxZoomDistance
    defaultGravity = Workspace.Gravity
end

getCharacter()
player.CharacterAdded:Connect(getCharacter)

-- 飞行功能
local flySpeed = 5
local flying = false
local bodyVelocity, bodyGyro, flyConnection

local function startFlying()
    if not humanoid or not rootpart then return end
    humanoid.PlatformStand = true
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e6,1e6,1e6)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = rootpart
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e6,1e6,1e6)
    bodyGyro.P = 10000
    bodyGyro.D = 500
    bodyGyro.Parent = rootpart
    flyConnection = RunService.Heartbeat:Connect(function()
        if not humanoid or not rootpart then return end
        local cm = require(player.PlayerScripts:WaitForChild("PlayerModule",5):WaitForChild("ControlModule",5))
        if not cm then return end
        local mv = cm:GetMoveVector()
        local dir = camera.CFrame:VectorToWorldSpace(mv)
        bodyVelocity.Velocity = dir * (flySpeed*10)
        bodyGyro.CFrame = camera.CFrame
    end)
end

local function stopFlying()
    if humanoid then humanoid.PlatformStand = false end
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    if flyConnection then flyConnection:Disconnect() end
    bodyVelocity, bodyGyro, flyConnection = nil,nil,nil
end

-- 穿墙功能
local noclipEnabled = false
local noclipConnection

local function enableNoclip()
    if noclipEnabled then return end
    noclipEnabled = true
    noclipConnection = RunService.Stepped:Connect(function()
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    if not noclipEnabled then return end
    noclipEnabled = false
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- 旋转功能
local rotating = false
local rotateSpeed = 50
local rotateConnection

local function startRotating()
    if not rootpart then return end
    rotating = true
    rotateConnection = RunService.Heartbeat:Connect(function()
        if not rootpart then return end
        rootpart.CFrame = rootpart.CFrame * CFrame.Angles(0, math.rad(rotateSpeed) * 0.1, 0)
    end)
end

local function stopRotating()
    rotating = false
    if rotateConnection then
        rotateConnection:Disconnect()
        rotateConnection = nil
    end
end

-- 人物透明功能
local characterTransparency = 0
local originalTransparencies = {}

local function setCharacterTransparency(transparency)
    if not character then return end
    characterTransparency = transparency
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if transparency > 0 then
                if not originalTransparencies[part] then
                    originalTransparencies[part] = part.Transparency
                end
                part.Transparency = transparency
            else
                if originalTransparencies[part] then
                    part.Transparency = originalTransparencies[part]
                end
            end
        end
    end
end

-- 获取所有道具功能
local function getAllTools()
    WindUI:Notify({
        Title = "正在获取道具",
        Content = "尝试获取所有可用道具...",
        Duration = 2
    })
    
    local toolCount = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") then
            local success, err = pcall(function()
                local clone = obj:Clone()
                clone.Parent = player.Backpack
                toolCount = toolCount + 1
            end)
        end
    end
    
    if player:FindFirstChild("Backpack") then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Tool") and obj:IsDescendantOf(Workspace) then
                local success, err = pcall(function()
                    local tool = obj:Clone()
                    tool.Parent = player.Backpack
                    toolCount = toolCount + 1
                end)
            end
        end
    end
    
    WindUI:Notify({
        Title = "获取完成",
        Content = string.format("成功获取 %d 个道具到背包", toolCount),
        Duration = 3
    })
end

-- 装备道具功能
local function equipTool()
    if player and player:FindFirstChild("Backpack") then
        local backpack = player.Backpack
        local tools = backpack:GetChildren()
        
        for _, tool in ipairs(tools) do
            if tool:IsA("Tool") then
                tool.Parent = player.Character
                WindUI:Notify({
                    Title = "道具已装备",
                    Content = string.format("已装备道具: %s", tool.Name),
                    Duration = 3
                })
                return
            end
        end
        
        WindUI:Notify({
            Title = "没有道具",
            Content = "背包中没有找到道具",
            Duration = 3
        })
    else
        WindUI:Notify({
            Title = "错误",
            Content = "找不到背包或角色",
            Duration = 3
        })
    end
end

-- 丢弃道具功能
local function dropTool()
    if player and player.Character then
        local character = player.Character
        local tools = character:GetChildren()
        
        for _, tool in ipairs(tools) do
            if tool:IsA("Tool") then
                tool.Parent = Workspace
                WindUI:Notify({
                    Title = "道具已丢弃",
                    Content = string.format("已丢弃道具: %s", tool.Name),
                    Duration = 3
                })
                return
            end
        end
        
        WindUI:Notify({
            Title = "没有道具",
            Content = "角色身上没有找到道具",
            Duration = 3
        })
    else
        WindUI:Notify({
            Title = "错误",
            Content = "找不到角色",
            Duration = 3
        })
    end
end

-- 自瞄功能（使用UNXHub的自瞄系统）
local AimlockEnabled = false
local AimlockSmoothness = 25
local AimlockKeybind = Enum.UserInputType.MouseButton2
local AimlockFOV = 150
local AimlockTeamCheck = true
local AimlockWallCheck = true
local AimlockConnection = nil
local AimlockMaxDist = 5000
local AimlockType = "Nearest Mouse"
local FOVEnabled = false
local ShowFOV = false
local FOVColor = Color3.fromRGB(255, 255, 255)
local FOVType = "Centered"
local RainbowFOV = false
local RainbowFOVSpeed = 2
local FOVStrokeThickness = 2.5
local AimlockOffsetX = 0
local AimlockOffsetY = 0
local WhitelistPlayers = {}
local PrioritizePlayers = {}

-- 创建FOV圆
local FOVCircle = nil
local function createFOVCircle()
    if FOVCircle then
        FOVCircle:Remove()
        FOVCircle = nil
    end
    
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = ShowFOV
    FOVCircle.Color = FOVColor
    FOVCircle.Transparency = 1
    FOVCircle.Thickness = FOVStrokeThickness
    FOVCircle.NumSides = 100
    FOVCircle.Filled = false
    FOVCircle.Radius = AimlockFOV
    if FOVType == "Centered" then
        FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    else
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    end
end

-- 检查玩家是否有效
local function IsValidTarget(plr)
    if not plr or plr == player then return false end
    if not plr.Character or not plr.Character:FindFirstChild("Head") or not plr.Character:FindFirstChild("Humanoid") then return false end
    if plr.Character.Humanoid.Health <= 0 then return false end
    if AimlockTeamCheck and plr.Team == player.Team then return false end
    
    if WhitelistPlayers then
        for _, whitelistedPlayer in ipairs(WhitelistPlayers) do
            if plr.Name == tostring(whitelistedPlayer) then
                return false
            end
        end
    end
    
    return true
end

-- 视线检查
local function HasLineOfSight(targetHead)
    if not AimlockWallCheck then return true end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character}
    local result = Workspace:Raycast(camera.CFrame.Position, (targetHead.Position - camera.CFrame.Position).Unit * AimlockMaxDist, raycastParams)
    return not result or result.Instance:IsDescendantOf(targetHead.Parent)
end

-- 获取最近玩家
local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = math.huge
    local mousePos = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y + 36)
    local centerPos = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    local checkPos = AimlockType == "Nearest Mouse" and mousePos or centerPos

    local prioritizedPlayers = {}
    local normalPlayers = {}

    -- 分离优先玩家和普通玩家
    for _, plr in Players:GetPlayers() do
        if IsValidTarget(plr) then
            local isPrioritized = false
            if PrioritizePlayers then
                for _, prioritizedPlayer in ipairs(PrioritizePlayers) do
                    if plr.Name == tostring(prioritizedPlayer) then
                        isPrioritized = true
                        break
                    end
                end
            end
            
            if isPrioritized then
                table.insert(prioritizedPlayers, plr)
            else
                table.insert(normalPlayers, plr)
            end
        end
    end

    local function CheckPlayer(plr)
        local head = plr.Character:FindFirstChild("Head")
        if head then
            local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - checkPos).Magnitude
                local worldDist = (head.Position - camera.CFrame.Position).Magnitude

                if worldDist <= AimlockMaxDist and distance < shortestDistance then
                    if FOVEnabled then
                        local fovCenter = FOVType == "Centered" and centerPos or mousePos
                        if (Vector2.new(screenPos.X, screenPos.Y) - fovCenter).Magnitude <= AimlockFOV then
                            if HasLineOfSight(head) then
                                shortestDistance = distance
                                return plr
                            end
                        end
                    else
                        if HasLineOfSight(head) then
                            shortestDistance = distance
                            return plr
                        end
                    end
                end
            end
        end
        return nil
    end

    -- 先检查优先玩家
    for _, plr in ipairs(prioritizedPlayers) do
        local result = CheckPlayer(plr)
        if result then
            closest = result
        end
    end

    -- 如果没有优先玩家，检查普通玩家
    if not closest then
        for _, plr in ipairs(normalPlayers) do
            local result = CheckPlayer(plr)
            if result then
                closest = result
            end
        end
    end

    return closest
end

-- 投掷功能（使用UNXHub的投掷系统）
local flingTime = 5
local flingForce = 50000

local function fling(TargetPlayer, duration)
    local startTime = tick()
    local Character = player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart

    local TCharacter = TargetPlayer.Character
    local THumanoid
    local TRootPart
    local THead
    local Accessory
    local Handle

    if TCharacter:FindFirstChildOfClass("Humanoid") then
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    end
    if THumanoid and THumanoid.RootPart then
        TRootPart = THumanoid.RootPart
    end
    if TCharacter:FindFirstChild("Head") then
        THead = TCharacter.Head
    end
    if TCharacter:FindFirstChildOfClass("Accessory") then
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    end
    if Accessory and Accessory:FindFirstChild("Handle") then
        Handle = Accessory.Handle
    end

    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end
        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif not THead and Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end
        
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(flingForce, flingForce * 10, flingForce)
            RootPart.RotVelocity = Vector3.new(flingForce * 20, flingForce * 20, flingForce * 20)
        end
        
        local SFBasePart = function(BasePart)
            local TimeToWait = duration or 2
            local Time = tick()
            local Angle = 0

            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100

                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5 ,0), CFrame.Angles(math.rad(-90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                else
                    break
                end
            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= Players or not TargetPlayer.Character == TCharacter or THumanoid.Sit or tick() > Time + TimeToWait
        end
        
        local previousDestroyHeight = workspace.FallenPartsDestroyHeight
        workspace.FallenPartsDestroyHeight = 0/0
        
        local BV = Instance.new("BodyVelocity")
        BV.Name = "EpixVel"
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(flingForce, flingForce, flingForce)
        BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
        
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        
        if TRootPart and THead then
            if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
                SFBasePart(THead)
            else
                SFBasePart(TRootPart)
            end
        elseif TRootPart and not THead then
            SFBasePart(TRootPart)
        elseif not TRootPart and THead then
            SFBasePart(THead)
        elseif not TRootPart and not THead and Accessory and Handle then
            SFBasePart(Handle)
        end
        
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid
        
        repeat
            if Character and Humanoid and RootPart and getgenv().OldPos then
                RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                Humanoid:ChangeState("GettingUp")
                table.foreach(Character:GetChildren(), function(_, x)
                    if x:IsA("BasePart") then
                        x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
                    end
                end)
            end
            task.wait()
        until RootPart and getgenv().OldPos and (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
        workspace.FallenPartsDestroyHeight = previousDestroyHeight
    end
end

-- 显示服务器信息
local function showServerInfo()
    local currentPlayers = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    local serverId = game.JobId
    local placeId = game.PlaceId
    local serverTime = os.date("%Y-%m-%d %H:%M:%S")
    
    local infoText = string.format([[
服务器信息:

玩家数量: %d/%d
服务器ID: %s
游戏ID: %d
当前时间: %s

服务器状态: 正常运行
]], currentPlayers, maxPlayers, serverId, placeId, serverTime)
    
    -- 显示服务器信息
    WindUI:Popup({
        Title = "服务器信息",
        Content = infoText,
        Buttons = {
            {
                Title = "关闭",
                Callback = function() end,
                Variant = "Tertiary",
            }
        }
    })
end

-- 越跑越快功能变量
local speedRampEnabled = false
local speedRampConnection = nil
local allTrails = {} -- 存储轨迹特效
local speedRampChar, speedRampHumanoid, speedRampHrp

-- 计时器功能变量
local timerEnabled = false
local timerScreenGui = nil
local timerHeartbeatConnection = nil

-- 踏空行走功能变量
local floatWalkEnabled = false

-- 更改公告栏文本功能
local announceText = "脚本垃圾"

-- 创建主窗口
function createMainWindow()
    -- 创建窗口（七彩颜色边框）
    local Window = WindUI:CreateWindow({
        Title = "脚本中心通用",
        Author = "Script Hub - 永久免费 v2.0",
        Folder = "ScriptCenterUniversal",
        NewElements = true,
        HideSearchBar = false,
        Icon = "rbxassetid://130346803512317",
        BorderColor = Color3.fromRGB(255, 0, 0), -- 红色边框
        Theme = "Light",
        OpenButton = {
            Title = "打开脚本中心",
            CornerRadius = UDim.new(0, 8),
            StrokeThickness = 2,
            Enabled = true,
            Draggable = true,
            OnlyMobile = false,
            Color = ColorSequence.new(
                Color3.fromHex("#FF0000"),
                Color3.fromHex("#FF7F00"),
                Color3.fromHex("#FFFF00"),
                Color3.fromHex("#00FF00"),
                Color3.fromHex("#00FFFF"),
                Color3.fromHex("#0000FF"),
                Color3.fromHex("#7F00FF"),
                Color3.fromHex("#FFFFFF")
            )
        }
    })
    
    -- 添加版本标签 - 蓝色
    Window:Tag({
        Title = "Script Hub",
        Color = Color3.fromHex("#0066ff"), -- 蓝色
        Radius = 0,
    })
    
    -- 添加永久免费版本标签 - 绿色
    Window:Tag({
        Title = "永久免费",
        Color = Color3.fromHex("#30ff6a"), -- 绿色
        Radius = 0,
    })
    
    -- 主功能标签页
    local MainTab = Window:Tab({
        Title = "主功能",
    })
    
    -- 角色控制部分
    local CharacterSection = MainTab:Section({
        Title = "角色控制",
    })
    
    -- 速度控制
    local walkspeedSlider = CharacterSection:Slider({
        Title = "移动速度",
        Step = 1,
        Value = {
            Min = 1,
            Max = 500,
            Default = defaultWalkSpeed,
        },
        Callback = function(value)
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    })
    
    CharacterSection:Space()
    
    -- 跳跃力控制
    local jumppowerSlider = CharacterSection:Slider({
        Title = "跳跃力",
        Step = 1,
        Value = {
            Min = 1,
            Max = 1000,
            Default = defaultJumpPower,
        },
        Callback = function(value)
            if humanoid then
                humanoid.JumpPower = value
            end
        end
    })
    
    CharacterSection:Space()
    
    -- 重力控制
    local gravitySlider = CharacterSection:Slider({
        Title = "重力",
        Step = 1,
        Value = {
            Min = 0,
            Max = 500,
            Default = defaultGravity,
        },
        Callback = function(value)
            Workspace.Gravity = value
        end
    })
    
    CharacterSection:Space()
    
    -- 无限跳跃
    local infiniteJumpToggle
    infiniteJumpToggle = CharacterSection:Toggle({
        Title = "无限跳跃",
        Default = false,
        Callback = function(state)
            if state then
                UserInputService.JumpRequest:Connect(function()
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
                WindUI:Notify({
                    Title = "无限跳跃已启用",
                    Content = "",
                    Duration = 2
                })
            else
                WindUI:Notify({
                    Title = "无限跳跃已禁用",
                    Content = "",
                    Duration = 2
                })
            end
        end
    })
    
    CharacterSection:Space()
    
    -- 穿墙功能
    local noclipToggle
    noclipToggle = CharacterSection:Toggle({
        Title = "穿墙模式",
        Default = false,
        Callback = function(state)
            if state then
                enableNoclip()
                WindUI:Notify({
                    Title = "穿墙已启用",
                    Content = "现在不可以穿过墙壁7891😏",
                    Duration = 2
                })
            else
                disableNoclip()
                WindUI:Notify({
                    Title = "穿墙已禁用",
                    Content = "9178",
                    Duration = 2
                })
            end
        end
    })
    
    CharacterSection:Space()
    
    -- 旋转功能
    local rotateToggle
    rotateToggle = CharacterSection:Toggle({
        Title = "旋转",
        Default = false,
        Callback = function(state)
            if state then
                startRotating()
                WindUI:Notify({
                    Title = "旋转已启用",
                    Content = "",
                    Duration = 2
                })
            else
                stopRotating()
                WindUI:Notify({
                    Title = "旋转已禁用",
                    Content = "",
                    Duration = 2
                })
            end
        end
    })
    
    CharacterSection:Space()
    
    CharacterSection:Slider({
        Title = "旋转速度",
        Step = 1,
        Value = {
            Min = 10,
            Max = 5000, -- 改为最大值5000
            Default = 50,
        },
        Callback = function(value)
            rotateSpeed = value
        end
    })
    
    -- 飞行功能部分
    local FlySection = MainTab:Section({
        Title = "飞行",
    })
    
    -- 飞行开关
    local flyToggle
    flyToggle = FlySection:Toggle({
        Title = "飞行",
        Default = false,
        Callback = function(state)
            flying = state
            if state then
                startFlying()
                WindUI:Notify({
                    Title = "飞行已启用",
                    Content = "",
                    Duration = 2
                })
            else
                stopFlying()
                WindUI:Notify({
                    Title = "飞行已禁用",
                    Content = "",
                    Duration = 2
                })
            end
        end
    })
    
    FlySection:Space()
    
    -- 飞行速度
    FlySection:Slider({
        Title = "飞行速度",
        Step = 1,
        Value = {
            Min = 1,
            Max = 75,
            Default = 5,
        },
        Callback = function(value)
            flySpeed = value
        end
    })
    
    -- 重置按钮
    CharacterSection:Space()
    CharacterSection:Button({
        Title = "重置角色",
        Callback = function()
            if character then
                character:BreakJoints()
                WindUI:Notify({
                    Title = "角色已重置",
                    Content = "正在重置角色...",
                    Duration = 2
                })
            end
        end
    })
    
    -- 视觉标签页
    local VisualsTab = Window:Tab({
        Title = "视觉",
    })
    
    -- 游戏视觉部分
    local GameVisualsSection = VisualsTab:Section({
        Title = "游戏视觉",
    })
    
    -- 视野控制
    GameVisualsSection:Slider({
        Title = "视野范围",
        Step = 1,
        Value = {
            Min = 60,
            Max = 120,
            Default = defaultFieldOfView,
        },
        Callback = function(value)
            camera.FieldOfView = value
        end
    })
    
    GameVisualsSection:Space()
    
    -- 最大缩放距离
    GameVisualsSection:Slider({
        Title = "最大缩放距离",
        Step = 1,
        Value = {
            Min = 1,
            Max = 1000,
            Default = defaultMaxZoom,
        },
        Callback = function(value)
            player.CameraMaxZoomDistance = value
        end
    })
    
    GameVisualsSection:Space()
    
    -- 全亮模式
    local fullbrightToggle
    fullbrightToggle = GameVisualsSection:Toggle({
        Title = "全亮模式",
        Default = false,
        Callback = function(state)
            if state then
                Lighting.Brightness = 2
                Lighting.Ambient = Color3.fromRGB(255,255,255)
                Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
                Lighting.ClockTime = 12
                Lighting.FogEnd = 100000
                WindUI:Notify({
                    Title = "全亮已启用",
                    Content = "游戏现在全亮",
                    Duration = 2
                })
            else
                Lighting.Brightness = 1
                Lighting.Ambient = Color3.fromRGB(0,0,0)
                Lighting.OutdoorAmbient = Color3.fromRGB(0,0,0)
                Lighting.ClockTime = 14
                Lighting.FogEnd = 1000
                WindUI:Notify({
                    Title = "全亮已禁用",
                    Content = "恢复正常亮度",
                    Duration = 2
                })
            end
        end
    })
    
    GameVisualsSection:Space()
    
    -- 无雾模式
    local noFogToggle
    noFogToggle = GameVisualsSection:Toggle({
        Title = "无雾模式",
        Default = false,
        Callback = function(state)
            if state then
                Lighting.FogEnd = 100000000
                WindUI:Notify({
                    Title = "无雾已启用",
                    Content = "雾气已移除",
                    Duration = 2
                })
            else
                Lighting.FogEnd = 1000
                WindUI:Notify({
                    Title = "无雾已禁用",
                    Content = "恢复正常雾气",
                    Duration = 2
                })
            end
        end
    })
    
    GameVisualsSection:Space()
    
    -- 人物透明
    GameVisualsSection:Slider({
        Title = "人物透明度",
        Step = 0.1,
        Value = {
            Min = 0,
            Max = 1,
            Default = 0,
        },
        Callback = function(value)
            setCharacterTransparency(value)
        end
    })
    
    -- X-Ray功能
    local XRaySection = VisualsTab:Section({
        Title = "X透视",
    })
    
    local xrayEnabled = false
    local xrayTransparency = 0.8
    local xrayObjects = {}
    
    local xrayToggle
    xrayToggle = XRaySection:Toggle({
        Title = "X透视",
        Default = false,
        Callback = function(state)
            xrayEnabled = state
            if state then
                xrayObjects = {}
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Parent ~= character then
                        xrayObjects[obj] = obj.Transparency
                        obj.Transparency = xrayTransparency
                    end
                end
                WindUI:Notify({
                    Title = "透视已启用",
                    Content = "可以看到墙壁后的物体",
                    Duration = 2
                })
            else
                for obj, originalTransparency in pairs(xrayObjects) do
                    if obj and obj:IsA("BasePart") then
                        obj.Transparency = originalTransparency
                    end
                end
                xrayObjects = {}
                WindUI:Notify({
                    Title = "透视已禁用",
                    Content = "恢复正常视野",
                    Duration = 2
                })
            end
        end
    })
    
    XRaySection:Space()
    
    XRaySection:Slider({
        Title = "透视透明度",
        Step = 1,
        Value = {
            Min = 0,
            Max = 100,
            Default = 80,
        },
        Callback = function(value)
            xrayTransparency = value/100
            if xrayEnabled then
                for obj, _ in pairs(xrayObjects) do
                    if obj and obj:IsA("BasePart") then
                        obj.Transparency = xrayTransparency
                    end
                end
            end
        end
    })
    
    -- 功能标签页
    local FeaturesTab = Window:Tab({
        Title = "功能",
    })
    
    -- FPS控制
    local FPSSection = FeaturesTab:Section({
        Title = "FPS控制",
    })
    
    local fpsValue = 60
    FPSSection:Slider({
        Title = "FPS限制",
        Step = 1,
        Value = {
            Min = 1,
            Max = 720,
            Default = 60,
        },
        Callback = function(value)
            fpsValue = value
        end
    })
    
    FPSSection:Space()
    
    FPSSection:Button({
        Title = "应用FPS限制",
        Callback = function()
            if setfpscap then
                setfpscap(fpsValue)
                WindUI:Notify({
                    Title = "FPS限制已应用",
                    Content = string.format("FPS限制为: %d", fpsValue),
                    Duration = 2
                })
            else
                WindUI:Notify({
                    Title = "不支持FPS限制",
                    Content = "当前环境不支持FPS限制",
                    Duration = 2
                })
            end
        end
    })
    
    -- 自瞄功能
    local AimSection = FeaturesTab:Section({
        Title = "自瞄",
    })
    
    local aimlockToggle
    aimlockToggle = AimSection:Toggle({
        Title = "自瞄开关",
        Default = false,
        Callback = function(state)
            AimlockEnabled = state
            if state then
                createFOVCircle()
                WindUI:Notify({
                    Title = "自瞄已启用",
                    Content = "按住鼠标右键瞄准",
                    Duration = 2
                })
            else
                if FOVCircle then
                    FOVCircle.Visible = false
                end
                WindUI:Notify({
                    Title = "自瞄已禁用",
                    Content = "自瞄功能已关闭",
                    Duration = 2
                })
            end
        end
    })
    
    AimSection:Space()
    
    AimSection:Toggle({
        Title = "平滑自瞄",
        Default = false,
        Callback = function(state)
            AimlockSmoothness = state and 25 or 100
        end
    })
    
    AimSection:Space()
    
    AimSection:Slider({
        Title = "自瞄平滑度",
        Step = 1,
        Value = {
            Min = 1,
            Max = 100,
            Default = 25,
        },
        Callback = function(value)
            AimlockSmoothness = value
        end
    })
    
    AimSection:Space()
    
    AimSection:Slider({
        Title = "自瞄FOV",
        Step = 1,
        Value = {
            Min = 50,
            Max = 750,
            Default = 150,
        },
        Callback = function(value)
            AimlockFOV = value
            if FOVCircle then
                FOVCircle.Radius = value
            end
        end
    })
    
    AimSection:Space()
    
    AimSection:Toggle({
        Title = "团队检查",
        Default = true,
        Callback = function(state)
            AimlockTeamCheck = state
        end
    })
    
    AimSection:Space()
    
    AimSection:Toggle({
        Title = "墙壁检查",
        Default = true,
        Callback = function(state)
            AimlockWallCheck = state
        end
    })
    
    AimSection:Space()
    
    AimSection:Toggle({
        Title = "显示FOV",
        Default = false,
        Callback = function(state)
            ShowFOV = state
            if FOVCircle then
                FOVCircle.Visible = state
            end
        end
    })
    
    AimSection:Space()
    
    AimSection:Toggle({
        Title = "启用FOV限制",
        Default = false,
        Callback = function(state)
            FOVEnabled = state
        end
    })
    
    AimSection:Space()
    
    AimSection:Dropdown({
        Title = "自瞄类型",
        Items = {"Nearest Character", "Nearest Mouse"},
        Default = "Nearest Mouse",
        Callback = function(value)
            AimlockType = value
        end
    })
    
    AimSection:Space()
    
    AimSection:Slider({
        Title = "自瞄最大距离",
        Step = 100,
        Value = {
            Min = 100,
            Max = 10000,
            Default = 5000,
        },
        Callback = function(value)
            AimlockMaxDist = value
        end
    })
    
    -- 计时器功能
    local TimerSection = FeaturesTab:Section({
        Title = "计时器",
    })
    
    -- 计时器开关
    local timerToggle
    timerToggle = TimerSection:Toggle({
        Title = "计时器开关",
        Default = false,
        Callback = function(state)
            timerEnabled = state
            if state then
                -- 创建计时器UI
                if timerScreenGui then
                    timerScreenGui:Destroy()
                    timerScreenGui = nil
                end
                
                -- 创建计时器GUI
                timerScreenGui = Instance.new("ScreenGui")
                timerScreenGui.Name = "TimerGui"
                timerScreenGui.ResetOnSpawn = false
                timerScreenGui.Parent = player.PlayerGui
                
                local mainFrame = Instance.new("Frame")
                mainFrame.Name = "TimerFrame"
                mainFrame.Size = UDim2.new(0, 120, 0, 40)
                mainFrame.Position = UDim2.new(0, 20, 0.5, -20)
                mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
                mainFrame.BorderSizePixel = 0
                mainFrame.Parent = timerScreenGui
                
                local timerLabel = Instance.new("TextLabel")
                timerLabel.Name = "TimerLabel"
                timerLabel.Size = UDim2.new(1, 0, 1, 0)
                timerLabel.Position = UDim2.new(0, 0, 0, 0)
                timerLabel.BackgroundTransparency = 1
                timerLabel.Text = "0:00"
                timerLabel.TextColor3 = Color3.new(0.5, 1, 0)
                timerLabel.TextScaled = true
                timerLabel.Font = Enum.Font.RobotoMono
                timerLabel.Parent = mainFrame
                
                local textGradient = Instance.new("UIGradient")
                textGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.new(0.5, 1, 0)),
                    ColorSequenceKeypoint.new(1, Color3.new(0, 0.4, 0))
                }
                textGradient.Rotation = 90
                textGradient.Parent = timerLabel
                
                local padding = Instance.new("UIPadding")
                padding.PaddingLeft = UDim.new(0, 8)
                padding.PaddingRight = UDim.new(0, 8)
                padding.PaddingTop = UDim.new(0, 4)
                padding.PaddingBottom = UDim.new(0, 4)
                padding.Parent = mainFrame
                
                local startButton = Instance.new("TextButton")
                startButton.Name = "StartButton"
                startButton.Size = UDim2.new(0, 40, 0, 40)
                startButton.Position = UDim2.new(0, 20, 0.5, 30)
                startButton.BackgroundColor3 = Color3.new(0, 0, 0.5)
                startButton.BorderSizePixel = 0
                startButton.Text = "开始计时"
                startButton.TextColor3 = Color3.new(1, 1, 1)
                startButton.TextScaled = true
                startButton.Font = Enum.Font.RobotoMono
                startButton.Parent = timerScreenGui
                
                -- 计时器变量
                local startTime = nil
                local timerRunning = false
                local heartbeatConnection = nil
                
                local function updateTimer()
                    if not timerRunning or not startTime then return end
                    
                    local currentTime = tick()
                    local elapsed = currentTime - startTime
                    
                    local minutes = math.floor(elapsed / 60)
                    local seconds = math.floor(elapsed % 60)
                    
                    timerLabel.Text = string.format("%d:%02d", minutes, seconds)
                end
                
                -- 开始/停止计时器
                startButton.MouseButton1Click:Connect(function()
                    if not timerRunning then
                        timerRunning = true
                        startTime = tick()
                        startButton.Text = "暂停计时"
                        startButton.BackgroundColor3 = Color3.new(1, 0, 0)
                        
                        textGradient.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.new(0.5, 1, 0)),
                            ColorSequenceKeypoint.new(1, Color3.new(0, 0.4, 0))
                        }
                        
                        heartbeatConnection = RunService.Heartbeat:Connect(updateTimer)
                    else
                        timerRunning = false
                        startButton.Text = "开始计时"
                        startButton.BackgroundColor3 = Color3.new(0, 0, 0.5)
                        
                        textGradient.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.new(0.5, 0.8, 1)),
                            ColorSequenceKeypoint.new(1, Color3.new(0, 0.2, 0.6))
                        }
                        
                        if heartbeatConnection then
                            heartbeatConnection:Disconnect()
                            heartbeatConnection = nil
                        end
                    end
                end)
                
                WindUI:Notify({
                    Title = "计时器已启用",
                    Content = "计时器界面已创建",
                    Duration = 3
                })
            else
                -- 关闭计时器
                if timerScreenGui then
                    timerScreenGui:Destroy()
                    timerScreenGui = nil
                end
                
                if timerHeartbeatConnection then
                    timerHeartbeatConnection:Disconnect()
                    timerHeartbeatConnection = nil
                end
                
                WindUI:Notify({
                    Title = "计时器已禁用",
                    Content = "计时器界面已移除",
                    Duration = 3
                })
            end
        end
    })
    
    TimerSection:Space()
    
    TimerSection:Button({
        Title = "重置计时器",
        Callback = function()
            if timerScreenGui then
                local timerLabel = timerScreenGui:FindFirstChild("TimerFrame") and 
                                 timerScreenGui.TimerFrame:FindFirstChild("TimerLabel")
                if timerLabel then
                    timerLabel.Text = "0:00"
                    WindUI:Notify({
                        Title = "计时器已重置",
                        Content = "计时器已归零",
                        Duration = 2
                    })
                end
            else
                WindUI:Notify({
                    Title = "计时器未启用",
                    Content = "请先启用计时器",
                    Duration = 2
                })
            end
        end
    })
    
    -- 踏空行走功能
    local FloatWalkSection = FeaturesTab:Section({
        Title = "踏空行走",
    })
    
    FloatWalkSection:Button({
        Title = "加载踏空行走",
        Callback = function()
            local success, err = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Float'))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "踏空行走已加载",
                    Content = "踏空行走脚本已成功加载",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "踏空行走脚本加载失败: " .. tostring(err),
                    Duration = 5
                })
            end
        end
    })
    
    -- 投掷功能
    local FlingSection = FeaturesTab:Section({
        Title = "甩飞",
    })
    
    -- 获取玩家列表
    local function getPlayerList()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then 
                table.insert(list, p.Name) 
            end
        end
        return list
    end
    
    FlingSection:Button({
        Title = "甩飞最近玩家",
        Callback = function()
            local closestPlayer = nil
            local shortestDistance = math.huge
            
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (player.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = plr
                    end
                end
            end
            
            if closestPlayer then
                fling(closestPlayer, flingTime)
                WindUI:Notify({
                    Title = "甩飞开始",
                    Content = string.format("正在甩飞 %s", closestPlayer.Name),
                    Duration = 2
                })
            else
                WindUI:Notify({
                    Title = "甩飞失败",
                    Content = "未找到可甩飞的玩家",
                    Duration = 2
                })
            end
        end
    })
    
    FlingSection:Space()
    
    FlingSection:Button({
        Title = "甩飞所有人",
        Callback = function()
            local playerList = {}
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(playerList, plr)
                end
            end
            
            if #playerList > 0 then
                for _, plr in ipairs(playerList) do
                    fling(plr, flingTime)
                    task.wait(flingTime + 1)
                end
                WindUI:Notify({
                    Title = "甩飞完成",
                    Content = string.format("已甩飞 %d 名玩家", #playerList),
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "甩飞失败",
                    Content = "未找到可甩飞的玩家",
                    Duration = 2
                })
            end
        end
    })
    
    FlingSection:Space()
    
    FlingSection:Slider({
        Title = "甩飞时间",
        Step = 0.5,
        Value = {
            Min = 1,
            Max = 25,
            Default = 5,
        },
        Callback = function(value)
            flingTime = value
        end
    })
    
    FlingSection:Space()
    
    FlingSection:Slider({
        Title = "甩飞力度",
        Step = 1000,
        Value = {
            Min = 1000,
            Max = 9999999,
            Default = 50000,
        },
        Callback = function(value)
            flingForce = value
        end
    })
    
    -- 服务器工具
    local ServerToolsSection = FeaturesTab:Section({
        Title = "服务器/游戏",
    })
    
    ServerToolsSection:Button({
        Title = "复制服务器ID",
        Callback = function()
            if setclipboard then
                setclipboard(game.JobId)
                WindUI:Notify({
                    Title = "已复制服务器ID",
                    Content = "服务器ID已复制到剪贴板",
                    Duration = 2
                })
            end
        end
    })
    
    ServerToolsSection:Space()
    
    ServerToolsSection:Button({
        Title = "重新加入服务器",
        Callback = function()
            if game.JobId ~= "" then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
            end
        end
    })
    
    ServerToolsSection:Space()
    
    local targetJobId = ""
    ServerToolsSection:Input({
        Title = "目标服务器ID",
        Default = "",
        Callback = function(value)
            targetJobId = value
        end
    })
    
    ServerToolsSection:Space()
    
    ServerToolsSection:Button({
        Title = "进入目标服务器",
        Callback = function()
            if targetJobId ~= "" then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, targetJobId, player)
            else
                WindUI:Notify({
                    Title = "请输入服务器ID",
                    Content = "请先输入目标服务器ID",
                    Duration = 2
                })
            end
        end
    })
    
    ServerToolsSection:Space()
    
    ServerToolsSection:Button({
        Title = "退出游戏",
        Callback = function()
            game:Shutdown()
        end
    })
    
    -- FE标签页
    local FETab = Window:Tab({
        Title = "FE",
    })
    
    local FESection = FETab:Section({
        Title = "FE动画",
    })
    
    FESection:Button({
        Title = "FE动画(最全动作)",
        Callback = function()
            CoreGui:SetCore("SendNotification", {
                Title = "Script hub",
                Text = "脚本中心动作/动画/表情",
                Icon = "rbxassetid://72708707930817",
                Duration = 6, 
            })
            CoreGui:SetCore("SendNotification", {
                Title = "正在加载",
                Text = "脚本中心动画/动作/，表情",
                Icon = "rbxassetid://72708707930817",
                Duration = 6, 
            })
            
            local success, err = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/maninffg/---/refs/heads/main/%E8%84%9A%E6%9C%AC%E4%B8%AD%E5%BF%83%E5%8A%A8%E7%94%BB%E5%8A%A8%E4%BD%9C'))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "FE动画已加载",
                    Content = "FE动画脚本已成功加载",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "FE动画脚本加载失败: " .. tostring(err),
                    Duration = 5
                })
            end
        end
    })
    
    FESection:Space()
    
    FESection:Button({
        Title = "YI指令",
        Callback = function()
            CoreGui:SetCore("SendNotification", {
                Title = "YI Script",
                Text = "YI-输入最简单的指令fly 空格调节速度",
                Icon = "rbxassetid://72708707930817",
                Duration = 6, 
            })
            CoreGui:SetCore("SendNotification", {
                Title = "正在加载",
                Text = "YI指令",
                Icon = "rbxassetid://72708707930817",
                Duration = 6, 
            })
            
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "YI指令已加载",
                    Content = "无限收益指令已成功加载",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "YI指令加载失败: " .. tostring(err),
                    Duration = 5
                })
            end
        end
    })
    
    FESection:Space()
    
    FESection:Button({
        Title = "撸管R15",
        Callback = function()
            WindUI:Notify({
                Title = "正在加载撸管R15",
                Content = "正在加载R15动画...",
                Duration = 2
            })
            
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "撸管R15已加载",
                    Content = "R15动画已成功加载",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "R15动画加载失败: " .. tostring(err),
                    Duration = 5
                })
            end
        end
    })
    
    FESection:Space()
    
    FESection:Button({
        Title = "撸管R6",
        Callback = function()
            WindUI:Notify({
                Title = "正在加载撸管R6",
                Content = "正在加载R6动画...",
                Duration = 2
            })
            
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "撸管R6已加载",
                    Content = "R6动画已成功加载",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "R6动画加载失败: " .. tostring(err),
                    Duration = 5
                })
            end
        end
    })
    
    -- 通用标签页
    local UniversalTab = Window:Tab({
        Title = "通用",
    })
    
    -- 道具管理部分
    local ToolsSection = UniversalTab:Section({
        Title = "道具管理",
    })
    
    ToolsSection:Button({
        Title = "获取所有道具",
        Callback = function()
            getAllTools()
        end
    })
    
    ToolsSection:Space()
    
    -- 添加装备道具按钮
    ToolsSection:Button({
        Title = "装备道具",
        Callback = function()
            equipTool()
        end
    })
    
    ToolsSection:Space()
    
    -- 添加丢弃道具按钮
    ToolsSection:Button({
        Title = "丢弃道具",
        Callback = function()
            dropTool()
        end
    })
    
    ToolsSection:Space()
    
    -- 服务器信息按钮
    ToolsSection:Button({
        Title = "显示服务器信息",
        Callback = function()
            showServerInfo()
        end
    })
    
    -- 更改公告栏文本功能
    local AnnounceSection = UniversalTab:Section({
        Title = "更改公告栏",
    })
    
    AnnounceSection:Input({
        Title = "新公告文本",
        Default = "脚本垃圾",
        Callback = function(value)
            announceText = value
        end
    })
    
    AnnounceSection:Space()
    
    AnnounceSection:Button({
        Title = "应用新公告",
        Callback = function()
            -- 执行更改公告栏脚本
            local NewText = announceText
            local TargetItemCode = "\231\137\140\229\173\144"

            local function ForceModify(targetPlayer)
                pcall(function()
                    local targetName = targetPlayer.Name
                    local remote = workspace:FindFirstChild(targetName) 
                        and workspace[targetName]:FindFirstChild(TargetItemCode)
                        and workspace[targetName][TargetItemCode]:FindFirstChild("RemoteFunction")

                    if remote then
                        remote:InvokeServer(NewText)
                    else
                        if workspace:FindFirstChild("noobandbond") then
                            workspace.noobandbond[TargetItemCode].RemoteFunction:InvokeServer(NewText)
                        end
                    end
                    
                    if game:GetService("ReplicatedStorage"):FindFirstChild("SetHeadText") then
                        game:GetService("ReplicatedStorage").SetHeadText:FireServer(NewText)
                    end
                end)
            end

            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                task.spawn(ForceModify, p)
            end

            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("TextLabel") or v:IsA("TextBox") then
                    v.Text = NewText
                end
            end
            
            WindUI:Notify({
                Title = "公告已更改",
                Content = string.format("已将所有公告栏文本更改为: %s", NewText),
                Duration = 3
            })
        end
    })
    
    -- 越跑越快功能
    local SpeedRampSection = UniversalTab:Section({
        Title = "越跑越快",
    })
    
    local speedRampToggle
    speedRampToggle = SpeedRampSection:Toggle({
        Title = "越跑越快",
        Default = false,
        Callback = function(state)
            speedRampEnabled = state
            if state then
                -- 加载越跑越快脚本
                local success, err = pcall(function()
                    -- 越跑越快脚本
                    local Players = game:GetService("Players")
                    local RunService = game:GetService("RunService")
                    local TweenService = game:GetService("TweenService")
                    local Debris = game:GetService("Debris")

                    local lp = Players.LocalPlayer

                    --========== CONFIG ==========
                    local INCREMENT = 1
                    local INCREMENT_INTERVAL = 0.15
                    local MAX_SPEED = 9000
                    local RESET_IDLE_TIME = 0.25

                    local TRAIL_COLOR = Color3.fromRGB(80,170,255)
                    local TRAIL_LIFETIME = 0.28
                    local TRAIL_EMISSION = 0.8
                    local TRAIL_WIDTH_START = 0.5
                    local TRAIL_WIDTH_END = 0.0

                    local LIGHTNING_ENABLED = true
                    local LIGHTNING_COLOR = Color3.fromRGB(140,210,255)
                    local LIGHTNING_BASE_RATE = 0.20
                    local LIGHTNING_MIN_RATE = 0.045
                    local LIGHTNING_MAX_RATE = 0.30
                    local LIGHTNING_MAIN_COUNT = 2
                    local LIGHTNING_BRANCH_CHANCE = 0.45
                    local LIGHTNING_SPARKS = true
                    local LIGHTNING_SPARK_COUNT = 6

                    --========== UTIL ==========
                    local function qwait(n) if n and n > 0 then task.wait(n) end end
                    local function ensurePart(char, names)
                        for _, n in ipairs(names) do
                            local p = char:FindFirstChild(n)
                            if p then return p end
                        end
                    end

                    --========== CHARACTER ==========
                    local function getChar()
                        local char = lp.Character or lp.CharacterAdded:Wait()
                        local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
                        local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart")
                        return char, hum, hrp
                    end
                    speedRampChar, speedRampHumanoid, speedRampHrp = getChar()
                    local baseSpeed = speedRampHumanoid.WalkSpeed

                    --========== TRAILS ==========
                    local function clearTrails()
                        for _, t in ipairs(allTrails) do
                            pcall(function()
                                if t.trail then t.trail:Destroy() end
                                if t.att0 then t.att0:Destroy() end
                                if t.att1 then t.att1:Destroy() end
                            end)
                        end
                        table.clear(allTrails)
                    end
                    
                    local function makeTrail(part, id, offA, offB)
                        if not part then return end
                        local att0 = Instance.new("Attachment"); att0.Position = offA; att0.Parent = part
                        local att1 = Instance.new("Attachment"); att1.Position = offB; att1.Parent = part
                        local tr = Instance.new("Trail")
                        tr.Attachment0 = att0; tr.Attachment1 = att1
                        tr.Color = ColorSequence.new(TRAIL_COLOR)
                        tr.Transparency = NumberSequence.new(0.05, 1)
                        tr.WidthScale = NumberSequence.new(TRAIL_WIDTH_START, TRAIL_WIDTH_END)
                        tr.LightEmission = TRAIL_EMISSION
                        tr.Lifetime = TRAIL_LIFETIME
                        tr.Enabled = false
                        tr.Parent = part
                        table.insert(allTrails, {trail=tr, att0=att0, att1=att1})
                    end
                    
                    local function buildTrails()
                        clearTrails()
                        makeTrail(ensurePart(speedRampChar,{"LeftFoot","LeftLowerLeg","Left Leg"}),"LF",Vector3.new(-.05,.05,.05),Vector3.new(.05,-.05,-.05))
                        makeTrail(ensurePart(speedRampChar,{"RightFoot","RightLowerLeg","Right Leg"}),"RF",Vector3.new(.05,.05,.05),Vector3.new(-.05,-.05,-.05))
                        makeTrail(ensurePart(speedRampChar,{"LeftHand","LeftLowerArm","Left Arm"}),"LH",Vector3.new(-.06,0,.08),Vector3.new(.06,0,-.08))
                        makeTrail(ensurePart(speedRampChar,{"RightHand","RightLowerArm","Right Arm"}),"RH",Vector3.new(.06,0,.08),Vector3.new(-.06,0,-.08))
                        local torso = ensurePart(speedRampChar,{"UpperTorso","LowerTorso","Torso"}) or speedRampHrp
                        makeTrail(torso,"T1",Vector3.new(-.08,.1,.02),Vector3.new(.08,-.1,-.02))
                        makeTrail(torso,"T2",Vector3.new(.08,.1,-.02),Vector3.new(-.08,-.1,.02))
                    end
                    
                    local function setTrails(on) 
                        for _, t in ipairs(allTrails) do 
                            if t.trail and t.trail.Parent then
                                t.trail.Enabled = on 
                            end
                        end 
                    end
                    
                    buildTrails()

                    --========== LIGHTNING ==========
                    local function fadeDebris(p,t) TweenService:Create(p,TweenInfo.new(t),{Transparency=1}):Play(); Debris:AddItem(p,t+0.05) end
                    local function seg(a,b,th)
                        local s=Instance.new("Part");s.Anchored=true;s.CanCollide=false;s.Material=Enum.Material.Neon;s.Color=LIGHTNING_COLOR
                        local dir=(b-a);s.Size=Vector3.new(th,th,math.max(0.05,dir.Magnitude))
                        s.CFrame=CFrame.new(a,b)*CFrame.new(0,0,-s.Size.Z/2);s.Parent=workspace;return s
                    end
                    local function sparks(origin)
                        if not LIGHTNING_SPARKS then return end
                        for i=1,LIGHTNING_SPARK_COUNT do
                            local p=Instance.new("Part");p.Anchored=true;p.CanCollide=false;p.Material=Enum.Material.Neon;p.Color=LIGHTNING_COLOR
                            p.Shape=Enum.PartType.Ball;p.Size=Vector3.new(0.08,0.08,0.08)
                            local dir=Vector3.new(math.random()-0.5, math.random()-0.5, math.random()-0.5).Unit
                            p.CFrame=CFrame.new(origin + dir*(math.random()*2.2+0.4))
                            p.Transparency=0.1;p.Parent=workspace;fadeDebris(p,0.12)
                        end
                    end
                    local function spawnBoltSet()
                        if not LIGHTNING_ENABLED then return end
                        local base=speedRampHrp.Position+Vector3.new(0,1.2,0)
                        sparks(speedRampHrp.Position+Vector3.new(0,0.2,0))
                        for m=1,LIGHTNING_MAIN_COUNT do
                            local segments=math.random(3,5)
                            local radius=4+math.random()*5
                            local dir=Vector3.new(math.random()-0.5, math.random()-0.5, math.random()-0.5).Unit*radius
                            local prev=base
                            for i=1,segments do
                                local t=i/segments
                                local nextPos=base+dir*t+Vector3.new((math.random()-0.5)*1.2,(math.random()-0.5)*1.0,(math.random()-0.5)*1.2)
                                fadeDebris(seg(prev,nextPos,0.1),0.08)
                                if math.random()<LIGHTNING_BRANCH_CHANCE then
                                    local branch=Vector3.new(math.random()-0.5, math.random()-0.5, math.random()-0.5).Unit*(1.5+math.random()*1.5)
                                    fadeDebris(seg(nextPos,nextPos+branch,0.08),0.07)
                                end
                                prev=nextPos
                            end
                        end
                    end

                    --========== RESPAWN ==========
                    lp.CharacterAdded:Connect(function() 
                        qwait(0.1); 
                        speedRampChar, speedRampHumanoid, speedRampHrp = getChar(); 
                        baseSpeed = speedRampHumanoid.WalkSpeed; 
                        buildTrails() 
                    end)

                    --========== LOOP ==========
                    local incT, idleT, lastL = 0, 0, 0
                    speedRampConnection = RunService.Heartbeat:Connect(function(dt)
                        if not speedRampHumanoid or speedRampHumanoid.Health <= 0 then 
                            setTrails(false)
                            return 
                        end
                        
                        local moving = speedRampHumanoid.MoveDirection.Magnitude > 0.05
                        if moving then
                            setTrails(true); idleT = 0; incT = incT + dt
                            if incT >= INCREMENT_INTERVAL then 
                                incT = 0; 
                                speedRampHumanoid.WalkSpeed = math.min(speedRampHumanoid.WalkSpeed + INCREMENT, MAX_SPEED) 
                            end
                            lastL = lastL + dt
                            local rate = math.clamp(LIGHTNING_BASE_RATE - math.clamp((speedRampHumanoid.WalkSpeed - baseSpeed)/1200, 0, 1)*(LIGHTNING_BASE_RATE - LIGHTNING_MIN_RATE), LIGHTNING_MIN_RATE, LIGHTNING_MAX_RATE)
                            if lastL >= rate then 
                                lastL = 0; 
                                spawnBoltSet() 
                            end
                        else
                            setTrails(false); incT = 0; lastL = 0; idleT = idleT + dt
                            if idleT >= RESET_IDLE_TIME and speedRampHumanoid.WalkSpeed ~= baseSpeed then 
                                speedRampHumanoid.WalkSpeed = baseSpeed 
                            end
                        end
                    end)
                end)
                
                if success then
                    WindUI:Notify({
                        Title = "越跑越快已启用",
                        Content = "角色移动时会越来越快",
                        Duration = 3
                    })
                else
                    WindUI:Notify({
                        Title = "越跑越快加载失败",
                        Content = "错误: " .. tostring(err),
                        Duration = 5
                    })
                    speedRampToggle:Set(false)
                end
            else
                -- 关闭越跑越快
                if speedRampConnection then
                    speedRampConnection:Disconnect()
                    speedRampConnection = nil
                end
                
                -- 清理轨迹特效
                for _, t in ipairs(allTrails) do
                    pcall(function()
                        if t.trail then t.trail:Destroy() end
                        if t.att0 then t.att0:Destroy() end
                        if t.att1 then t.att1:Destroy() end
                    end)
                end
                table.clear(allTrails)
                
                -- 恢复默认速度
                if humanoid then
                    humanoid.WalkSpeed = defaultWalkSpeed
                end
                
                WindUI:Notify({
                    Title = "越跑越快已禁用",
                    Content = "恢复默认移动速度，特效已清理",
                    Duration = 3
                })
            end
        end
    })
    
    SpeedRampSection:Space()
    
    SpeedRampSection:Slider({
        Title = "基础速度",
        Step = 1,
        Value = {
            Min = 16,
            Max = 100,
            Default = 16,
        },
        Callback = function(value)
            if humanoid then
                defaultWalkSpeed = value
                humanoid.WalkSpeed = value
            end
        end
    })
    
    SpeedRampSection:Space()
    
    SpeedRampSection:Button({
        Title = "重置速度",
        Callback = function()
            if humanoid then
                humanoid.WalkSpeed = defaultWalkSpeed
                WindUI:Notify({
                    Title = "速度已重置",
                    Content = "移动速度已恢复为默认值",
                    Duration = 3
                })
            end
        end
    })
    
    ToolsSection:Space()
    
    -- 重置设置按钮
    ToolsSection:Button({
        Title = "重置所有设置",
        Callback = function()
            -- 重置角色设置
            if humanoid then
                humanoid.WalkSpeed = defaultWalkSpeed
                humanoid.JumpPower = defaultJumpPower
            end
            player.CameraMaxZoomDistance = defaultMaxZoom
            Workspace.Gravity = defaultGravity
            camera.FieldOfView = defaultFieldOfView
            
            -- 重置飞行
            if flying then
                stopFlying()
                if flyToggle then flyToggle:Set(false) end
            end
            
            -- 重置穿墙
            if noclipEnabled then
                disableNoclip()
                if noclipToggle then noclipToggle:Set(false) end
            end
            
            -- 重置旋转
            if rotating then
                stopRotating()
                if rotateToggle then rotateToggle:Set(false) end
            end
            
            -- 重置X-Ray
            if xrayEnabled then
                for obj, originalTransparency in pairs(xrayObjects) do
                    if obj and obj:IsA("BasePart") then
                        obj.Transparency = originalTransparency
                    end
                end
                xrayObjects = {}
                if xrayToggle then xrayToggle:Set(false) end
            end
            
            -- 重置人物透明
            setCharacterTransparency(0)
            
            -- 重置视觉设置
            Lighting.Brightness = 1
            Lighting.Ambient = Color3.fromRGB(0,0,0)
            Lighting.OutdoorAmbient = Color3.fromRGB(0,0,0)
            Lighting.ClockTime = 14
            Lighting.FogEnd = 1000
            if fullbrightToggle then fullbrightToggle:Set(false) end
            if noFogToggle then noFogToggle:Set(false) end
            
            -- 重置自瞄
            AimlockEnabled = false
            if aimlockToggle then aimlockToggle:Set(false) end
            if FOVCircle then
                FOVCircle.Visible = false
            end
            
            -- 重置越跑越快
            if speedRampEnabled then
                if speedRampConnection then
                    speedRampConnection:Disconnect()
                    speedRampConnection = nil
                end
                
                -- 清理轨迹特效
                for _, t in ipairs(allTrails) do
                    pcall(function()
                        if t.trail then t.trail:Destroy() end
                        if t.att0 then t.att0:Destroy() end
                        if t.att1 then t.att1:Destroy() end
                    end)
                end
                table.clear(allTrails)
                
                if speedRampToggle then speedRampToggle:Set(false) end
            end
            
            -- 重置计时器
            if timerEnabled then
                if timerScreenGui then
                    timerScreenGui:Destroy()
                    timerScreenGui = nil
                end
                if timerToggle then timerToggle:Set(false) end
            end
            
            -- 重置滑块
            if walkspeedSlider then walkspeedSlider:Set(defaultWalkSpeed) end
            if jumppowerSlider then jumppowerSlider:Set(defaultJumpPower) end
            if gravitySlider then gravitySlider:Set(defaultGravity) end
            
            WindUI:Notify({
                Title = "设置已重置",
                Content = "所有设置已恢复默认",
                Duration = 3
            })
        end
    })
    
    -- 其他脚本标签页
    local OtherScriptsTab = Window:Tab({
        Title = "其他脚本",
    })
    
    -- 脚本列表
    local scriptsList = {
        {
            name = "KGKG脚本",
            script = function()
                KGKG_SCRIPT = "张硕制作"
                loadstring(game:HttpGet("\104\116\116\112\115\58\47\47\103\105\116\104\117\98\46\99\111\109\47\90\83\45\78\66\47\75\71\47\114\97\119\47\109\97\105\110\47\90\104\97\110\103\45\83\104\117\111\46\108\117\97"))()
            end
        },
        {
            name = "皮脚本",
            script = function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua"))()
            end
        },
        {
            name = "情云脚本中心",
            script = function()
                loadstring(utf8.char((function() return table.unpack({108,111,97,100,115,116,114,105,110,103,40,103,97,109,101,58,72,116,116,112,71,101,116,40,34,104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,67,104,105,110,97,81,89,47,45,47,109,97,105,110,47,37,69,54,37,56,51,37,56,53,37,69,52,37,66,65,37,57,49,34,41,41,40,41})end)()))()
            end
        },
        {
            name = "导管中心",
            script = function()
                loadstring("\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\34\104\116\116\112\115\58\47\47\114\97\119\46\103\105\116\104,117\98\117\115\101\114\99\111,110\116\101\110\116\46\99\111\109\47\117\115\101\114\97\110\101\119\114\102\102\47\114\111\98\108\111\120\45\47\109\97\105\110\47\37\69,54\37\57\68\37\65\49\37\69\54\37\65\67\37\66\69\37\69\53\37\56\68\37\56\70\37\69\56\37\65\69\37\65\69\34\41\41\40\41\10")()
            end
        },
        {
            name = "XK脚本",
            script = function()
                loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-XK-Hub-76803"))()
            end
        },
        {
            name = "黑洞中心",
            script = function()
                loadstring(game:HttpGet("\104\116\116\112\115\58\47\47\103\105\116\101\101\46\99\111\109\47\66\83\95\115\99\114\105\112\116\47\115\99\114\105\112\116\47\114\97\119\47\109\97\115\116\101\114\47\66\83\95\83\99\114\105\112\116\46\76\117\97\117"))()
            end
        },
        {
            name = "WTB脚本",
            script = function()
                getgenv().ADittoKey = "WTB_FREEKEY"
                pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/Potato5466794/GC-WTB/refs/heads/main/Loader/Loader.luau", true))()
                end)
            end
        },
        {
            name = "叶脚本",
            script = function()
                loadstring(game:HttpGet("https://api.junkie-development.de/api/v1/luascripts/public/3387bc2c06c6ab7e0606178d675e0ad46b29427c6a1f81e96a4c9d7a090eb68e/download"))()
            end
        },
        {
            name = "XK脚本2",
            script = function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/BINjiaobzx6/BINjiao/main/XK.lua"))()
            end
        },
        {
            name = "XC脚本",
            script = function()
                loadstring(game:HttpGet("\104\116\116\112\115\58\47\47\112\97\115\116\101\98\105\110\46\99\111\109\47\114\97\119\47\103\101\109\120\72\119\65\49"))()
            end
        }
    }
    
    -- 创建脚本按钮
    for _, scriptInfo in ipairs(scriptsList) do
        OtherScriptsTab:Button({
            Title = scriptInfo.name,
            Callback = function()
                WindUI:Notify({
                    Title = "正在加载脚本",
                    Content = string.format("正在加载 %s...", scriptInfo.name),
                    Duration = 2
                })
                
                -- 尝试加载脚本
                local success, err = pcall(scriptInfo.script)
                if success then
                    WindUI:Notify({
                        Title = "脚本加载成功",
                        Content = string.format("%s 已成功加载", scriptInfo.name),
                        Duration = 3
                    })
                else
                    WindUI:Notify({
                        Title = "脚本加载失败",
                        Content = string.format("加载 %s 时出错: %s", scriptInfo.name, tostring(err)),
                        Duration = 5
                    })
                end
            end
        })
        
        OtherScriptsTab:Space({ Columns = 1 })
    end
    
    -- UI设置标签页
    local UISettingsTab = Window:Tab({
        Title = "UI设置",
    })
    
    local SettingsSection = UISettingsTab:Section({
        Title = "界面设置",
    })
    
    -- 主题选择
    local themeOptions = {"Light", "Dark", "Auto"}
    local currentTheme = "Light"
    
    SettingsSection:Dropdown({
        Title = "主题选择",
        Default = "Light",
        Items = themeOptions,
        Callback = function(value)
            currentTheme = value
            WindUI:SetTheme(value)
            WindUI:Notify({
                Title = "主题已更改",
                Content = string.format("已切换到 %s 主题", value),
                Duration = 2
            })
        end
    })
    
    SettingsSection:Space()
    
    -- 自定义光标
    SettingsSection:Toggle({
        Title = "自定义光标",
        Default = true,
        Callback = function(state)
            WindUI:SetCustomCursor(state)
            WindUI:Notify({
                Title = "光标设置",
                Content = state and "自定义光标已启用" or "自定义光标已禁用",
                Duration = 2
            })
        end
    })
    
    SettingsSection:Space()
    
    -- 界面缩放
    SettingsSection:Slider({
        Title = "界面缩放",
        Step = 0.1,
        Value = {
            Min = 0.5,
            Max = 2,
            Default = 1,
        },
        Callback = function(value)
            WindUI:SetDPIScale(value)
            WindUI:Notify({
                Title = "缩放已更改",
                Content = string.format("界面缩放: %.1fx", value),
                Duration = 2
            })
        end
    })
    
    SettingsSection:Space()
    
    -- 导出配置
    SettingsSection:Button({
        Title = "导出配置",
        Callback = function()
            local config = {
                version = "永久免费 v2.0",
                theme = currentTheme,
                flyEnabled = flying,
                noclipEnabled = noclipEnabled,
                rotating = rotating,
                xrayEnabled = xrayEnabled,
                walkspeed = humanoid and humanoid.WalkSpeed or defaultWalkSpeed,
                jumppower = humanoid and humanoid.JumpPower or defaultJumpPower
            }
            
            if setclipboard then
                setclipboard("脚本中心通用配置: " .. game:GetService("HttpService"):JSONEncode(config))
                WindUI:Notify({
                    Title = "配置已复制",
                    Content = "配置已复制到剪贴板",
                    Duration = 3
                })
            end
        end
    })
    
    SettingsSection:Space()
    
    -- 关闭脚本
    SettingsSection:Button({
        Title = "关闭脚本中心",
        Callback = function()
            -- 清理所有功能
            if flying then stopFlying() end
            if noclipEnabled then disableNoclip() end
            if rotating then stopRotating() end
            if xrayEnabled then
                for obj, originalTransparency in pairs(xrayObjects) do
                    if obj and obj:IsA("BasePart") then
                        obj.Transparency = originalTransparency
                    end
                end
            end
            
            -- 重置设置
            if humanoid then
                humanoid.WalkSpeed = defaultWalkSpeed
                humanoid.JumpPower = defaultJumpPower
            end
            player.CameraMaxZoomDistance = defaultMaxZoom
            Workspace.Gravity = defaultGravity
            camera.FieldOfView = defaultFieldOfView
            
            -- 重置人物透明
            setCharacterTransparency(0)
            
            -- 清理自瞄FOV
            if FOVCircle then
                FOVCircle:Remove()
                FOVCircle = nil
            end
            
            -- 停止自瞄循环
            if aimlockLoop then
                aimlockLoop:Disconnect()
            end
            
            -- 停止越跑越快
            if speedRampConnection then
                speedRampConnection:Disconnect()
                speedRampConnection = nil
            end
            
            -- 清理轨迹特效
            for _, t in ipairs(allTrails) do
                pcall(function()
                    if t.trail then t.trail:Destroy() end
                    if t.att0 then t.att0:Destroy() end
                    if t.att1 then t.att1:Destroy() end
                end)
            end
            table.clear(allTrails)
            
            -- 停止计时器
            if timerHeartbeatConnection then
                timerHeartbeatConnection:Disconnect()
                timerHeartbeatConnection = nil
            end
            
            -- 移除计时器UI
            if timerScreenGui then
                timerScreenGui:Destroy()
                timerScreenGui = nil
            end
            
            -- 关闭窗口
            Window:Destroy()
            
            WindUI:Notify({
                Title = "脚本已关闭",
                Content = "脚本中心已关闭并清理",
                Duration = 3
            })
        end
    })
    
    -- 关于标签页
    local AboutTab = Window:Tab({
        Title = "其他",
    })
    
    local AboutSection = AboutTab:Section({
        Title = "关于脚本中心通用",
    })
    
    AboutSection:Image({
        Image = "rbxassetid://75702897877244",
        AspectRatio = "1:1",
        Radius = 12,
    })
    
    AboutSection:Space({ Columns = 2 })
    
    AboutSection:Section({
        Title = "脚本中心通用",
        TextSize = 20,
        FontWeight = Enum.FontWeight.Bold,
    })
    
    AboutSection:Section({
        Title = "其他: 永久免费",
        TextSize = 14,
        TextTransparency = 0.3,
        FontWeight = Enum.FontWeight.Medium,
    })
    
    AboutSection:Space({ Columns = 3 })
    
    AboutSection:Label({
        Title = "Script Hub",
        Color = ColorSequence.new(Color3.fromRGB(0, 102, 255)), -- 蓝色
    })
    
    AboutSection:Label({
        Title = "永久免费",
        Color = ColorSequence.new(Color3.fromRGB(0, 255, 0)), -- 绿色
    })
    
    AboutSection:Space({ Columns = 1 })
    
    AboutSection:Section({
        Title = "其他:\n• 新年快乐！祝你们身心快乐！长寿百岁！出入平安！",
        TextSize = 12,
        TextTransparency = 0.4,
        FontWeight = Enum.FontWeight.Medium,
    })
    
    AboutSection:Space({ Columns = 4 })
    
    -- 玩家加入/离开通知
    Players.PlayerAdded:Connect(function(player)
        CoreGui:SetCore("SendNotification", {
            Title = "玩家加入",
            Text = player.Name .. " 加入了游戏",
            Icon = "rbxassetid://82031063194606",
            Duration = 6, 
        })
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        CoreGui:SetCore("SendNotification", {
            Title = "玩家离开",
            Text = player.Name .. " 离开了游戏",
            Icon = "rbxassetid://82031063194606",
            Duration = 6, 
        })
    end)
    
    -- 自瞄更新循环
    local aimlockLoop
    aimlockLoop = RunService.RenderStepped:Connect(function()
        -- 更新FOV圆位置
        if FOVCircle then
            if FOVType == "Centered" then
                FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
            else
                local mousePos = UserInputService:GetMouseLocation()
                FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
            end
        end
        
        -- 自瞄逻辑
        if AimlockEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = GetClosestPlayer()
            if target and target.Character then
                local head = target.Character:FindFirstChild("Head")
                if head then
                    local offset = Vector3.new(AimlockOffsetX * 10, AimlockOffsetY * 10, 0)
                    local targetPos = head.Position + offset
                    
                    if AimlockSmoothness < 100 then
                        local smoothness = AimlockSmoothness / 100
                        camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, targetPos), smoothness)
                    else
                        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
                    end
                end
            end
        end
    end)
    
    -- 游戏关闭时清理
    game:BindToClose(function()
        -- 清理所有功能
        if flying then stopFlying() end
        if noclipEnabled then disableNoclip() end
        if rotating then stopRotating() end
        if xrayEnabled then
            for obj, originalTransparency in pairs(xrayObjects) do
                if obj and obj:IsA("BasePart") then
                    obj.Transparency = originalTransparency
                end
            end
        end
        setCharacterTransparency(0)
        
        -- 清理自瞄FOV
        if FOVCircle then
            FOVCircle:Remove()
            FOVCircle = nil
        end
        
        -- 停止自瞄循环
        if aimlockLoop then
            aimlockLoop:Disconnect()
        end
        
        -- 停止越跑越快
        if speedRampConnection then
            speedRampConnection:Disconnect()
            speedRampConnection = nil
        end
        
        -- 清理轨迹特效
        for _, t in ipairs(allTrails) do
            pcall(function()
                if t.trail then t.trail:Destroy() end
                if t.att0 then t.att0:Destroy() end
                if t.att1 then t.att1:Destroy() end
            end)
        end
        table.clear(allTrails)
        
        -- 停止计时器
        if timerHeartbeatConnection then
            timerHeartbeatConnection:Disconnect()
            timerHeartbeatConnection = nil
        end
        
        -- 移除计时器UI
        if timerScreenGui then
            timerScreenGui:Destroy()
            timerScreenGui = nil
        end
    end)
end

print("脚本中心通用 - 永久免费 已加载")
print("Script Hub - 如果你看到这个就表示加载成功脚本")
