-- CONFIG
local headshotOnly = true        -- true = ยิงเฉพาะหัว
local hitChance = 1.0            -- โอกาสยิงโดน (0.0 - 1.0)
local minDelay, maxDelay = 0.005, 0.01 -- เวลาระหว่างยิง (สุ่มเพื่อหลีกเลี่ยงโดนตรวจจับ)

-- หาเป้าหมายที่ใกล้ที่สุด (ไม่สนว่ามองเห็นหรือไม่)
local function getClosestPlayer()
    local closest, dist = nil, math.huge
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer 
            and plr.Character 
            and plr.Character:FindFirstChild("HumanoidRootPart") 
            and plr.Character:FindFirstChild("Head") 
            and not plr.Character:FindFirstChildOfClass("ForceField")
            and not table.find(
                table.map(plr.Character:GetChildren(), function(child)
                    return string.lower(child.Name):find("fire") and true or nil
                end),
                true
            ) then

            local d = (plr.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                closest = plr
            end
        end
    end
    return closest
end

-- ยิงแบบเงียบ
local function fireSilent()
    if math.random() > hitChance then return end

    local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end

    local target = getClosestPlayer()
    if not target then return end

    local targetPart = headshotOnly and target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
    if not targetPart then return end

    local origin = game.Players.LocalPlayer.Character.Head.Position
    local dir = (targetPart.Position - origin).Unit

    -- ยิงกระสุน
    local args1 = {
        [1] = tool,
        [2] = {
            id = 1,
            charge = 0,
            dir = dir,
            origin = origin
        }
    }
    game.ReplicatedStorage.WeaponsSystem.Network.WeaponFired:FireServer(unpack(args1))

    -- กระทบเป้า
    local args2 = {
        [1] = tool,
        [2] = {
            p = targetPart.Position,
            pid = 1,
            part = targetPart,
            d = 100,
            maxDist = 100,
            h = targetPart,
            m = Enum.Material.Plastic,
            sid = 1,
            t = tick(),
            n = Vector3.new(0, 1, 0)
        }
    }
    game.ReplicatedStorage.WeaponsSystem.Network.WeaponHit:FireServer(unpack(args2))
end

-- ยิงวนไปเรื่อย ๆ
while true do
    fireSilent()
    task.wait(math.random() * (maxDelay - minDelay) + minDelay)
end
