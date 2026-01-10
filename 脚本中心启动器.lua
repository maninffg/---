 -- 不不不不不不
 -- 这怎么是源代码
print("如果你看到这个表示加载成功")
print([[ ███████╗██████╗ ██████╗ ██████╗ ██████╗ ███████╗███████╗██████╗ ██╗ ██╗███████╗██████╗ 
██╔════╝██╔══██╗██╔══██╗██╔═══██╗██╔══██╗ ██╔════╝██╔════╝██╔══██╗██║ ██║██╔════╝██╔══██╗
█████╗ ██████╔╝██████╔╝██║ ██║██████╔╝ ███████╗█████╗ ██████╔╝██║ ██║█████╗ ██║ ██║
██╔══╝ ██╔══██╗██╔══██╗██║ ██║██╔══██╗ ╚════██║██╔══╝ ██╔══██╗██║ ██║██╔══╝ ██║ ██║
███████╗██║ ██║██║ ██║╚██████╔╝██║ ██║ ███████║███████╗██║ ██║╚██████╔╝███████╗██████╔╝
╚══════╝╚═╝ ╚═╝╚═╝ ╚═╝ ╚═════╝ ╚═╝ ╚═╝ ╚══════╝╚══════╝╚═╝ ╚═╝ ╚═════╝ ╚══════╝╚═════╝ 
░█▀▄░█▀▀░█▀▀░█▀█░█▀▄░█▀▀░█▀▀░█▀█░█▀▀░█▀▀░█▀█
░█░█░█▀▀░█▀▀░█▀█░█▀▄░▀▀█░█▀▀░█▀▀░█▀▀░█▀▀░█▀▄
░▀▀░░▀▀▀░▀▀▀░▀░▀░▀░▀░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀░▀]])
print("")
print("脚本中心启动器 | 以下内容可能是相关错误信息！")
print("")
print("脚本中心启动器 | Script hub")
if not isfolder("ErrorServerhub") then
    makefolder("unxhub")
end
if not isfolder("ErrorServerhub/themes") then
    makefolder("unxhub/themes")
end
if not isfile("ErrorServerhub/themes/default.txt") then
    writefile("unxhub/themes/default.txt", "UNXIsh")
end
if not isfile("ErrorServerhub/themes/UNXIsh.json") then
    writefile("unxhub/themes/UNXIsh.json", '{"MainColor":"131218","FontFace":"Code","AccentColor":"a970ff","OutlineColor":"262434","BackgroundColor":"0b0b0d","FontColor":"e8e6f2"}')
end
loadstring(game:HttpGet("https://apigetunx.vercel.app/Modules/v2/Inv.lua",true))()
if not isfile("UsedOneTime.unx") then
    writefile("UsedOneTime.unx","1")
elseif not isfile("AlreadyRated.unx") then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/not-gato/UNX/refs/heads/main/Modules/v2/Rating.lua"))()
    writefile("AlreadyRated.unx","1")
end
if getgenv().unxshared and getgenv().unxshared.isloaded == true then
    warn("脚本中心启动器已加载。跳过初始化。")
    return
end
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Config = {
    Colors = {
        Background = Color3.fromHex("8B0000"),
        Outline = Color3.fromHex("0000FF"),
        Text = Color3.fromHex("FFFF00"),
        TextDim = Color3.fromHex("8a8a9e"),
        BarEmpty = Color3.fromHex("131218"),
        BarFilled = Color3.fromHex("a970ff"),
        Success = Color3.fromRGB(40, 201, 64),
        Error = Color3.fromRGB(255, 80, 80)
    },
    Assets = {
        Logo = "rbxassetid://72708707930817",
        Checkmark = "rbxassetid://11604833061",
        ErrorX = "rbxassetid://3944676352"
    },
    Timings = {
        Intro = 0.8,
        Loop = 2.5,
        SuccessMorph = 0.8,
        Checkmark = 0.5
    }
}
if CoreGui:FindFirstChild("ErrorServerLoader") then
    CoreGui.UNXLoader:Destroy()
end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ErrorServerLoader"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Config.Colors.Background
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui
local MainImage = Instance.new("ImageLabel")
MainImage.Name = "BackgroundImage"
MainImage.Size = UDim2.new(1, 0, 1, 0)
MainImage.Position = UDim2.new(0, 0, 0, 0)
MainImage.BackgroundTransparency = 1
MainImage.Image = "rbxassetid://130346803512317"
MainImage.ScaleType = Enum.ScaleType.Crop
MainImage.Parent = MainFrame
local dragging
local dragInput
local dragStart
local startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Config.Colors.Outline
MainStroke.Thickness = 1.5
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame
local LogoImage = Instance.new("ImageLabel")
LogoImage.Name = "Logo"
LogoImage.Size = UDim2.new(0, 85, 0, 85)
LogoImage.Position = UDim2.new(0.5, 0, 0.1, 0)
LogoImage.AnchorPoint = Vector2.new(0.5, 0)
LogoImage.BackgroundTransparency = 1
LogoImage.Image = Config.Assets.Logo
LogoImage.ImageColor3 = Config.Colors.Text
LogoImage.ImageTransparency = 1
LogoImage.Parent = MainFrame
local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 12)
LogoCorner.Parent = LogoImage
local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = Config.Colors.Outline
LogoStroke.Thickness = 1
LogoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
LogoStroke.Transparency = 1
LogoStroke.Parent = LogoImage
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, 0, 0, 22)
TitleLabel.Position = UDim2.new(0, 0, 0.52, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "脚本中心启动器"
TitleLabel.TextColor3 = Config.Colors.Text
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 20
TitleLabel.TextTransparency = 1
TitleLabel.Parent = MainFrame
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Size = UDim2.new(1, 0, 0, 14)
StatusLabel.Position = UDim2.new(0, 0, 0.63, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "正在初始化..."
StatusLabel.TextColor3 = Config.Colors.TextDim
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextTransparency = 1
StatusLabel.Parent = MainFrame
local LoaderContainer = Instance.new("Frame")
LoaderContainer.Name = "LoaderContainer"
LoaderContainer.Size = UDim2.new(0.75, 0, 0, 5)
LoaderContainer.Position = UDim2.new(0.5, 0, 0.85, 0)
LoaderContainer.AnchorPoint = Vector2.new(0.5, 0.5)
LoaderContainer.BackgroundColor3 = Config.Colors.BarEmpty
LoaderContainer.BackgroundTransparency = 1
LoaderContainer.ClipsDescendants = true
LoaderContainer.Parent = MainFrame
local LoaderCorner = Instance.new("UICorner")
LoaderCorner.CornerRadius = UDim.new(1, 0)
LoaderCorner.Parent = LoaderContainer
local LoaderStroke = Instance.new("UIStroke")
LoaderStroke.Color = Config.Colors.Outline
LoaderStroke.Thickness = 1
LoaderStroke.Transparency = 1
LoaderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
LoaderStroke.Parent = LoaderContainer
local BarFill = Instance.new("Frame")
BarFill.Name = "BarFill"
BarFill.Size = UDim2.new(0.3, 0, 1, 0)
BarFill.Position = UDim2.new(-0.3, 0, 0, 0)
BarFill.BackgroundColor3 = Config.Colors.BarFilled
BarFill.BorderSizePixel = 0
BarFill.Parent = LoaderContainer
local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = BarFill
local Checkmark = Instance.new("ImageLabel")
Checkmark.Name = "Checkmark"
Checkmark.Size = UDim2.new(0.6, 0, 0.6, 0)
Checkmark.Position = UDim2.new(0.5, 0, 0.5, 0)
Checkmark.AnchorPoint = Vector2.new(0.5, 0.5)
Checkmark.BackgroundTransparency = 1
Checkmark.Image = Config.Assets.Checkmark
Checkmark.ImageColor3 = Color3.fromRGB(255, 255, 255)
Checkmark.ImageTransparency = 1
Checkmark.Parent = LoaderContainer
local ErrorIcon = Instance.new("ImageLabel")
ErrorIcon.Name = "ErrorIcon"
ErrorIcon.Size = UDim2.new(0.5, 0, 0.5, 0)
ErrorIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
ErrorIcon.AnchorPoint = Vector2.new(0.5, 0.5)
ErrorIcon.BackgroundTransparency = 1
ErrorIcon.Image = Config.Assets.ErrorX
ErrorIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
ErrorIcon.ImageTransparency = 1
ErrorIcon.Parent = LoaderContainer
local Controller = {}
local InfiniteTween
function Controller:Start()
    local OpenTween = TweenService:Create(MainFrame, TweenInfo.new(Config.Timings.Intro, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 200, 0, 250) })
    OpenTween:Play()
    OpenTween.Completed:Wait()
    local FadeInfo = TweenInfo.new(0.8)
    TweenService:Create(LogoImage, FadeInfo, {ImageTransparency = 0}):Play()
    TweenService:Create(LogoStroke, FadeInfo, {Transparency = 0}):Play()
    TweenService:Create(TitleLabel, FadeInfo, {TextTransparency = 0}):Play()
    TweenService:Create(StatusLabel, FadeInfo, {TextTransparency = 0}):Play()
    TweenService:Create(LoaderContainer, FadeInfo, {BackgroundTransparency = 0}):Play()
    TweenService:Create(LoaderStroke, FadeInfo, {Transparency = 0}):Play()
    local LoopInfo = TweenInfo.new(Config.Timings.Loop, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1)
    BarFill.Position = UDim2.new(-0.35, 0, 0, 0)
    InfiniteTween = TweenService:Create(BarFill, LoopInfo, {Position = UDim2.new(1.35, 0, 0, 0)})
    InfiniteTween:Play()
end
function Controller:SetStatus(text)
    StatusLabel.Text = text
end
function Controller:Success()
    if InfiniteTween then
        InfiniteTween:Cancel()
    end
    TweenService:Create(BarFill, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    local MorphInfo = TweenInfo.new(Config.Timings.SuccessMorph, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(LoaderContainer, MorphInfo, { Size = UDim2.new(0, 40, 0, 40), BackgroundColor3 = Config.Colors.Success }):Play()
    TweenService:Create(LoaderStroke, TweenInfo.new(0.5), { Color = Config.Colors.Success }):Play()
    task.wait(0.3)
    local CheckTween = TweenService:Create(Checkmark, TweenInfo.new(Config.Timings.Checkmark, Enum.EasingStyle.Linear), { ImageTransparency = 0 })
    CheckTween:Play()
    Controller:SetStatus("加载成功！")
end
function Controller:Fail()
    if InfiniteTween then
        InfiniteTween:Cancel()
    end
    TweenService:Create(BarFill, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    local MorphInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(LoaderContainer, MorphInfo, { Size = UDim2.new(0, 40, 0, 40), BackgroundColor3 = Config.Colors.Error }):Play()
    TweenService:Create(LoaderStroke, TweenInfo.new(0.5), { Color = Config.Colors.Error }):Play()
    task.wait(0.3)
    TweenService:Create(ErrorIcon, TweenInfo.new(0.5, Enum.EasingStyle.Linear), { ImageTransparency = 0 }):Play()
    Controller:SetStatus("加载失败！")
end
local function s(text)
    Controller:SetStatus(text)
    task.wait(0.2)
end
Controller:Start()
s("脚本中心启动器 v2.1.0 已初始化")
s("正在检查API状态...")
loadstring(game:HttpGet("https://raw.githubusercontent.com/not-gato/UNX/refs/heads/main/Modules/v2/API.lua",true))()
task.wait(0.1)
s("正在创建全局变量...")
task.wait(0.05)
getgenv().unxshared={
    version="2.4.0",
    gamename=MarketplaceService:GetProductInfo(game.PlaceId).Name,
    issupported=false,
    playername=LocalPlayer.Name,
    playerid=LocalPlayer.UserId,
    isloaded=false,
    devnote="由脚本中心用💖制作"
}
s("玩家: "..LocalPlayer.Name.." (ID: "..LocalPlayer.UserId..")")
task.wait(0.05)
s("游戏: "..getgenv().unxshared.gamename)
task.wait(0.14)
s("正在检查游戏兼容性...")
task.wait(0.02)
local bc=game.PlaceId
s("游戏ID: "..tostring(bc))
s("开发者提示: "..getgenv().unxshared.devnote)
task.wait(0.12)
s("正在加载脚本中心...")
task.wait(0.1)
local be,bf=pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/maninffg/---/refs/heads/main/Script%20Hub.lua"))()
end)
if be then
    s("正在发送信息...")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/not-gato/UNX/refs/heads/main/Modules/v2/Log.lua"))()
    getgenv().unxshared.isloaded=true
    s("脚本加载成功")
    task.wait(0.05)
    s("初始化完成！")
    Controller:Success()
    task.wait(1.5)
    local FadeOutInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(MainFrame, FadeOutInfo, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }):Play()
    if LoaderStroke then
        LoaderStroke.Enabled = false
        TweenService:Create(LoaderStroke, FadeOutInfo, {Transparency = 1}):Play()
    end
    pcall(function()
        for _,v in pairs(MainFrame:GetDescendants()) do
            if v:IsA("GuiObject") then
                TweenService:Create(v, FadeOutInfo, {BackgroundTransparency=1, ImageTransparency=1, TextTransparency=1}):Play()
            elseif v:IsA("UIStroke") then
                TweenService:Create(v, FadeOutInfo, {Transparency=1}):Play()
            end
        end
    end)
    task.wait(0.6)
    pcall(function()
        MainFrame:ClearAllChildren()
    end)
    pcall(function()
        MainFrame:Destroy()
    end)
    pcall(function()
        ScreenGui:Destroy()
    end)
else
    getgenv().unxshared.isloaded=false
    Controller:Fail()
    local errorMsg=tostring(bf):gsub("`","")
    local kickTitle="脚本中心启动器"
    local kickBody= "<font color='rgb(255,100,100)'>发生错误，脚本中心必须关闭。</font>\n\n"..
                    "<font color='rgb(220,220,220)'>错误: </font><font color='rgb(255,150,150)'>"..errorMsg.."</font>\n\n"..
                    "<font color='rgb(100,200,255)'>请在我们的哔哩哔哩上报告此问题:</font>\n"..
                    "<font color='rgb(0,170,255)'>https://discord.gg/zpaMS8qUfB</font>"
    local success,cKickModule=pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/not-gato/gatostuff/refs/heads/main/raw/scripts/uKick.lua"))()
    end)
    if success and cKickModule and cKickModule.cKick then
        pcall(cKickModule.cKick,kickTitle,kickBody)
    else
        warn("脚本中心启动器错误 (cKick失败):",bf)
    end
end
