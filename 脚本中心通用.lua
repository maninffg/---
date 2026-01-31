local RandomMessage = `[{math.random()}]`
local Passed = false

game:GetService("LogService").MessageOut:Connect(function(Message, MessageType)
	if Message == RandomMessage and MessageType == Enum.MessageType.MessageOutput then
		Passed = true
	end
end)

print(RandomMessage)

repeat
	task.wait()
until Passed
-- 反混淆 放入你的脚本
loadstring(game:HttpGet("https://raw.githubusercontent.com/maninffg/---/refs/heads/main/真正的脚本中心通用.lua"))()
