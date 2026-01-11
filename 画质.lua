-- [[ 源码 可以二创 ]] 
-- //画质脚本
local Lighting = game:GetService("Lighting")
local Terrain = workspace.Terrain
local RunService = game:GetService("RunService")

for _, child in ipairs(Lighting:GetChildren()) do
    if child:IsA("PostEffect") or child:IsA("Sky") then
        child:Destroy()
    end
end

local colorCorrection = Instance.new("ColorCorrectionEffect")
local bloom = Instance.new("BloomEffect")
local sunRays = Instance.new("SunRaysEffect")
local atmosphere = Instance.new("Atmosphere")

colorCorrection.Parent = Lighting
bloom.Parent = Lighting
sunRays.Parent = Lighting
atmosphere.Parent = Lighting

local sky = Instance.new("Sky")
sky.Parent = Lighting

sky.SkyboxBk = "rbxassetid://6444337006" 
sky.SkyboxDn = "rbxassetid://6444336728"
sky.SkyboxFt = "rbxassetid://6444337006"
sky.SkyboxLf = "rbxassetid://6444337006"
sky.SkyboxRt = "rbxassetid://6444337006"
sky.SkyboxUp = "rbxassetid://6444336728"

sky.StarCount = 3000 

colorCorrection.Contrast = 0.18 
colorCorrection.Brightness = 0.05
colorCorrection.Saturation = 0.3 
colorCorrection.TintColor = Color3.fromRGB(255, 242, 230) 

bloom.Intensity = 0.25 
bloom.Size = 48 
bloom.Threshold = 0.85 

sunRays.Intensity = 0.25 
sunRays.Spread = 1.0

Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.05 
Lighting.Brightness = 2.8 
Lighting.ExposureCompensation = 0.7 
Lighting.FogColor = Color3.fromRGB(140, 158, 178) 
Lighting.FogEnd = 3000 

atmosphere.Density = 0.4 
atmosphere.Offset = 0.25
atmosphere.Color = Color3.fromRGB(220, 220, 255)
atmosphere.Decay = Color3.fromRGB(20, 25, 45)
atmosphere.Glare = 0.15 
atmosphere.Haze = 0.25 

Terrain.WaterReflectance = 0.35 
Terrain.WaterTransparency = 0.88
Terrain.WaterWaveSize = 0.15 
Terrain.WaterWaveSpeed = 25 
Terrain.WaterColor = Color3.fromRGB(72, 141, 202) 

local function updateTime()
    Lighting.ClockTime = Lighting.ClockTime + 0.0005 
    
    local timeFactor = math.sin(Lighting.ClockTime * math.pi / 12)
    bloom.Intensity = 0.2 + timeFactor * 0.1
    sunRays.Intensity = 0.2 + timeFactor * 0.1
end

RunService.RenderStepped:Connect(updateTime)

print("0")
print("1")
print("2")
print("3")
print("5")
print("......")
print("加载成功")
