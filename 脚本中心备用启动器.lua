--已停用 已经启动器所有bug修复完成
--[[ AS Script hub = "AS启动器"
loadstring(game:HttpGet("https://raw.githubusercontent.com/maninffg/---/refs/heads/main/脚本中心启动器.lua"))() ]]
local CoreGui = game:GetService("StarterGui")
CoreGui:SetCore("SendNotification", {
    Title = "AS Script",
    Text = "备用启动器已停用",
    Icon = "rbxassetid://118056805704151",
    Duration = 6, 
})
wait(1.5)
CoreGui:SetCore("SendNotification", {
    Title = "正在为您加载启动器",
    Text = "AS脚本中心启动器",
    Icon = "rbxassetid://118056805704151",
    Duration = 6, 
})
wait(0.5)
AS Script hub = "AS启动器"
loadstring(game:HttpGet("https://raw.githubusercontent.com/maninffg/---/refs/heads/main/脚本中心启动器.lua"))()
