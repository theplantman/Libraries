local Important = {
    ["Animations"] = game.HttpService:JSONDecode(game:HttpGet("https://raw.githubusercontent.com/theplantman/Modules/main/Important/Animations.json")),
    ["Audios"] = {},
    ["BindedInputs"] = {},
    ["ModeSettings"] = {
        ["Base"] = true
    },
    ["OnSpawnSettings"] = {
        ["Set"] = false
    },
    ["PlayerSettings"] = {
        ["Active"] = false,
        ["Cooldowns"] = {}
    }
}
function Important:AddCooldown(Lifetime, Name)
    if Name then
        Important["PlayerSettings"]["Cooldowns"][Name] = true
        task.delay(Lifetime or 1, function()
            if Important["PlayerSettings"]["Cooldowns"][Name] then
                Important["PlayerSettings"]["Cooldowns"][Name] = nil
            end
        end)
    end
end
function Important:AddPassive(Arguments, Type)
    if Important:CharacterLoaded() and not Important["DodgeSettings"] and (Type or "Dodge") == "Dodge" then
        Important["DodgeSettings"] = {
            ["Active"] = true
        }
        game.ReplicatedStorage.RTZ:FireServer(true)
        game.ReplicatedStorage.RTZClient.OnClientEvent:Connect(function(Player)
            if math.random(1, 2) == 1 then
                Important:LoadAnimation(5633583111):Play()
            else
                Important:LoadAnimation(5633584586):Play()
            end
        end)
    elseif not Important["GodSettings"] and Type == "God" then
        Important["GodSettings"] = {
            ["AntiAnchor"] = true,
            ["AntiFling"] = true
        }
    elseif not Important["SpeedAndJumpSettings"] and Type == "SpeedAndJump" then
        Important["SpeedAndJumpSettings"] = Arguments or {
            ["Base"] = {}
        }
    end
end
function Important:BindInput(Input, Function, Type)
    if Input and Function then
        if not Important[Input] then
            Important["BindedInputs"][Input] = {}
        end
        Important["BindedInputs"][Input][Type or "Began"] = Function
    end
end
function Important:CharacterLoaded(Character)
    Character = Character or game.Players.LocalPlayer.Character
    if Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health ~= 0 and Character:FindFirstChild("HumanoidRootPart") then
        return Character
    end
end
function Important:ClearCooldowns(Blacklist)
    Important["ClearCooldownBlacklistSettings"] = Blacklist or {}
    for Index, Cooldown in pairs(Important["PlayerSettings"]["Cooldowns"]) do
        if not table.find(Blacklist or {}, Index) then
            Cooldown = nil
        end
    end
end
function Important:DodgeToggle(Toggle)
    if Important:CharacterLoaded() and Important["DodgeSettings"] then
        Important["DodgeSettings"]["Active"] = Toggle or false
        game.ReplicatedStorage.RTZ:FireServer(Toggle or false)
    end
end
function Important:FireInput(GameProcessed, Input, Type)
    if Input then
        local StringInput
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            StringInput = "LMB"
        elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
            StringInput = "RMB"
        else
            StringInput = Input.KeyCode.Name
        end
        if not GameProcessed and StringInput and Important["BindedInputs"][StringInput] and Important["BindedInputs"][StringInput][Type or "Began"] and Important:CharacterLoaded() then
            task.spawn(Important["BindedInputs"][StringInput][Type or "Began"])
        end
    end
end
function Important:GetAbilityScript()
    if Important:CharacterLoaded() then
        local WhitelistedLocalScripts = {
            "Clean&Misc.",
            "MrPresidentAnimation",
            "clientTS",
            "DimensionLighting",
            "QualityScript",
            "Animate",
            "UnStun",
            "DismAnimation",
            "SP3_Effect",
        }
        local function GetAbilityName(Name)
            for Index, LocalScript in pairs(game.Lighting:GetChildren()) do
                if LocalScript:IsA("LocalScript") and LocalScript.Name == Name then
                    return LocalScript.Name
                end
            end
        end
        for Index, LocalScript in pairs(Important:CharacterLoaded():GetChildren()) do
            if LocalScript:IsA("LocalScript") and not table.find(WhitelistedLocalScripts, LocalScript.Name) and GetAbilityName(LocalScript.Name) then
                return Important:CharacterLoaded()[GetAbilityName(LocalScript.Name)]
            end
        end
    end
end
function Important:LoadAnimation(IdOrName)
    if Important:CharacterLoaded() and IdOrName then
        local Animation = Instance.new("Animation")
        if Important["Animations"][IdOrName] then
            Animation.AnimationId = Important["Animations"][IdOrName]
        else
            Animation.AnimationId = "rbxassetid://" .. IdOrName
        end 
        return Important:CharacterLoaded().Humanoid:LoadAnimation(Animation)
    end
end
function Important:Magnitude(DetectSpeed, Function, HitOnce, LifeTime, Position, Range, Visualize, Weld)
    if Function and Important:CharacterLoaded() then
        local Hitbox = Instance.new("Part")
        if Weld then
            local WeldConstraint = Instance.new("WeldConstraint")
            WeldConstraint.Parent = Hitbox
            WeldConstraint.Part0 = Hitbox
            WeldConstraint.Part1 = Weld
        else
            Hitbox.Anchored = true
        end
        Hitbox.CanCollide = false
        Hitbox.CastShadow = false
        Hitbox.Massless = true
        Hitbox.Parent = game.Workspace
        Hitbox.Position = Position or Important:CharacterLoaded().HumanoidRootPart.Position
        Hitbox.BrickColor = BrickColor.new("Really red")
        Hitbox.Material = Enum.Material.ForceField
        Hitbox.Shape = Enum.PartType.Ball
        Hitbox.Size = Vector3.new(Range or 15, Range or 15, Range or 15)
        if not Visualize then
            Hitbox.Transparency = 1
        end
        game.Debris:AddItem(Hitbox, LifeTime or 0.5)
        task.spawn(function()
            local Hit = {}
            repeat
                for Index, Character in pairs(game.Workspace.Entities:GetChildren()) do
                    if Character ~= Important:CharacterLoaded() and table.insert(Hit, Important:CharacterLoaded(Character)) and Important:CharacterLoaded(Character) and (Hitbox.Position - Important:CharacterLoaded(Character).HumanoidRootPart.Position).Magnitude <= ((Range or 7.5) / 2) then
                        task.spawn(function()
                            if HitOnce then
                                table.insert(Hit, Important:CharacterLoaded(Character))
                            end
                            Function(Important:CharacterLoaded(Character))
                        end)
                    end
                end
                task.wait(DetectSpeed or 0)
            until not Hitbox or not Hitbox.Parent
        end)
    end
end
function Important:OnSpawn(DisableStand, Function, GodMode)
    if Important:CharacterLoaded() then
        game.Workspace.Entities:WaitForChild(game.Players.LocalPlayer.Name)
        if DisableStand and Important:GetAbilityScript() then
            Important:GetAbilityScript().Disabled = true
        end
        if Function then
            task.spawn(Function)
        end
        if GodMode then
            game.ReplicatedStorage.BurnDamage:FireServer(Important:CharacterLoaded().Humanoid, CFrame.new(), 0 * math.huge, 0, Vector3.zero, "rbxassetid://241837157", 0, Color3.new(), "", 0, 0)
        end
        if not Important["OnSpawnSettings"]["Set"] then
            Important["OnSpawnSettings"]["DisableStand"] = DisableStand
            Important["OnSpawnSettings"]["Function"] = Function
            Important["OnSpawnSettings"]["GodMode"] = GodMode
            Important["OnSpawnSettings"]["Set"] = true
        end
    end
end
function Important:PlayAudio(CFrame, Id, Loop, Pitch)
    if Id then
        task.spawn(function()
            local Audio = Instance.new("Sound")
            Audio.Parent = game.ReplicatedStorage
            Audio.SoundId = "rbxassetid://" .. Id
            game.ContentProvider:PreloadAsync({
                Audio
            })
            repeat
                game.RunService.RenderStepped:Wait()
            until Audio.TimeLength and Audio.TimeLength > 0
            local TimeLength = Audio.TimeLength
            Audio:Destroy()
            for Index, AudioSystem in pairs(Important["Audios"]) do
                if AudioSystem["Id"] == Id then
                    Important["Audios"][Index] = nil
                end
            end
            local function FireRemote()
                if Important:CharacterLoaded() and CFrame then
                    game.ReplicatedStorage.Damage11Sans:FireServer(Important:CharacterLoaded().Humanoid, CFrame, 0, 0, Vector3.new(), math.huge, "rbxassetid://" .. Id, Pitch or 1, math.huge)
                elseif Important:CharacterLoaded() and not CFrame then
                    game.ReplicatedStorage.Damage11Sans:FireServer(Important:CharacterLoaded().Humanoid, Important:CharacterLoaded().HumanoidRootPart.CFrame, 0, 0, Vector3.new(), math.huge, "rbxassetid://" .. Id, Pitch or 1, math.huge)
                end
            end
            if TimeLength <= 0.69625 then
                FireRemote()
            elseif TimeLength > 0.69625 then
                Important["Audios"]["rbxassetid://" .. Id] = {
                    ["Loop"] = Loop or false,
                }
                task.spawn(function()
                    local function Play()
                        Important["Audios"]["rbxassetid://" .. Id]["Time"] = tick()
                        for Index = 1, math.ceil((TimeLength / 0.69625) / (Pitch or 1)) do
                            if not Important["Audios"]["rbxassetid://" .. Id] then
                                break
                            end
                            FireRemote()
                            task.wait(0.69625)
                        end
                        if Important["Audios"]["rbxassetid://" .. Id] and Loop then
                            Play()
                        else
                            Important["Audios"]["rbxassetid://" .. Id] = nil
                        end 
                    end
                    Play()
                end)
            end
        end)
    end
end
function Important:SwitchModes(Function, Type)
    if Type and Important["ModeSettings"][Type] ~= nil then
        for Index, Mode in pairs(Important["ModeSettings"]) do
            if Index ~= Type then
                Mode =  false
            end
        end
        if Function then
            Function()
        end
        Important["ModeSettings"][Type] = true
    end
end
game.Players.LocalPlayer.CharacterAdded:Connect(function(Character)
    Important:ClearCooldowns(Important["ClearCooldownBlacklistSettings"])
    task.wait(2)
    if Important["DodgeSettings"] and Important["DodgeSettings"]["Active"] then
        task.spawn(function()
            game.Workspace.Entities:WaitForChild(game.Players.LocalPlayer.Name)
            Character:WaitForChild("RTZ")
            game.ReplicatedStorage.RTZ:FireServer(true)
        end)
    end
    if Important["OnSpawnSettings"]["Set"] then
        Important:OnSpawn(Important["OnSpawnSettings"]["DisableStand"], Important["OnSpawnSettings"]["Function"], Important["OnSpawnSettings"]["GodMode"])
    end
end)
game.RunService.Stepped:Connect(function()
    for Index, Character in pairs(game.Workspace.Entities:GetChildren()) do
        if Character:FindFirstChild("Head") and Character.Head:FindFirstChild("BillboardGui") then
            Character.Head.BillboardGui:Destroy()
        end
    end
    if Important:CharacterLoaded() then
        if Important["GodSettings"] then
            if Important["GodSettings"]["AntiAnchor"] then
                for Index, Part in pairs(Important:CharacterLoaded():GetChildren()) do
                    if Part:IsA("Part") and Part.Anchored == true then
                        game.ReplicatedStorage.Anchor:FireServer(Part, false)
                    end
                end
            end
            if Important["GodSettings"]["AntiFling"] then
                for Index, BodyMover in pairs(Important:CharacterLoaded().HumanoidRootPart:GetChildren()) do
                    if BodyMover.ClassName:match("Body") then
                        BodyMover:Destroy()
                    end
                end
            end
            if Important:CharacterLoaded().HumanoidRootPart.Velocity.Magnitude >= 150 and (Important:CharacterLoaded().HumanoidRootPart.Position - Important["GodSettings"]["OldCFrame"].Position).Magnitude >= 600 then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Important["OldCFrame"]
                game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.zero
            else
                Important["GodSettings"]["OldCFrame"] = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            end
            if Important:CharacterLoaded().Humanoid.PlatformStand == true then
                game.ReplicatedStorage.GetUp:FireServer()
                Important:CharacterLoaded().Humanoid:SetStateEnabled(2, true)
                Important:CharacterLoaded().Humanoid.AutoRotate = true
                Important:CharacterLoaded().Humanoid.PlatformStand = false
            end
        elseif Important["Active"] and Important["SpeedAndJumpSettings"] then
            for Index, Mode in pairs(Important["ModeSettings"]) do
                if Important["SpeedAndJumpSettings"][Index] and Mode then
                    Important:CharacterLoaded().Humanoid.JumpPower = Important["SpeedAndJumpSettings"][Index]["JumpPower"] or 100
                    Important:CharacterLoaded().Humanoid.WalkSpeed = Important["SpeedAndJumpSettings"][Index]["WalkSpeed"] or 32
                end
            end
        end
    end
end)
game.UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    Important:FireInput(GameProcessed, Input)
end)
game.UserInputService.InputEnded:Connect(function(Input, GameProcessed)
    Important:FireInput(GameProcessed, Input, "Ended")
end)
game.Workspace.Effects.DescendantAdded:Connect(function(Sound)
    if Sound:IsA("Sound") and Important["Audios"][Sound.SoundId] and Important["Audios"][Sound.SoundId]["Time"] then
        task.wait(0.01)
        if Important["Audios"][Sound.SoundId] and Important["Audios"][Sound.SoundId]["Time"] then
            Sound.TimePosition = tick() - Important["Audios"][Sound.SoundId]["Time"]
        end
    end
end)
return Important
