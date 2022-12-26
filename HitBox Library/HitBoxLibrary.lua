local HitBoxLibrary = {}
function HitBoxLibrary:CheckCharacter(Character)
    Character = Character or game.Players.LocalPlayer.Character
    if Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health ~= 0 and Character:FindFirstChild("HumanoidRootPart") then
        return "Exist"
    end
end
function HitBoxLibrary:CreateHitBoxPart(Size, Visualize)
    local HitBox = Instance.new("Part")
    HitBox.Parent = game.Workspace
    HitBox.Size = Size or Vector3.new(15, 15, 15)
    HitBox.CanCollide = false
    HitBox.CastShadow = false
    HitBox.BrickColor = BrickColor.new("Really red")
    HitBox.Material = Enum.Material.ForceField
    if not Visualize then
        HitBox.Transparency = 1
    end
    return HitBox
end
function HitBoxLibrary:GetTouchingParts(Filters, FilterType, CFrame, HitBoxType, LifeTime, Size, Visualize, Weld)
    local Characters = {}
    if HitBoxLibrary:CheckCharacter() == "Exist" then
        task.spawn(function()
            local HitBox = HitBoxLibrary:CreateHitBoxPart(Size, Visualize)
            HitBox.CFrame = CFrame or game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            if HitBoxType == "Dynamic" then
                HitBoxLibrary:Weld(HitBox, Weld)
            end
            game.Debris:AddItem(HitBox, LifeTime or 1)
            local Connection = HitBox.Touched:Connect(function()
            end)
            task.delay(LifeTime or 1, function()
                Connection:Disconnect()
            end)
            local function GetTouching()
                if Filters then
                    Characters = {}
                    for Index, Filter in pairs(Filters) do
                        for Index, Part in pairs(HitBox:GetTouchingParts()) do
                            if Part.Parent.ClassName == "Model" and not Characters[Part.Parent] and Part.Parent ~= game.Players.LocalPlayer.Character and HitBoxLibrary:CheckCharacter(Part.Parent) == "Exist" then
                                if (FilterType or "WhiteList") == "WhiteList" and Part.Parent.Parent.Name == Filter.Name then
                                    Characters[Part.Parent] = Part.Parent
                                end
                            end
                        end
                    end
                elseif not Filters then
                    Characters = {}
                    for Index, Part in pairs(HitBox:GetTouchingParts()) do
                        if Part.Parent.ClassName == "Model" and not Characters[Part.Parent] and Part.Parent ~= game.Players.LocalPlayer.Character and HitBoxLibrary:CheckCharacter(Part.Parent) == "Exist" then
                            Characters[Part.Parent] = Part.Parent
                        end
                    end
                end 
            end
            if (HitBoxType or "Static") == "Static" then
                GetTouching()
            elseif HitBoxType == "Dynamic" then
                local Timer = tick()
                repeat
                    GetTouching()
                    task.wait()
                until not HitBox or (tick() - Timer) >= (LifeTime or 1)
            end
        end)
    end
    return Characters
end
function HitBoxLibrary:Magnitude(HitBoxType, Filters, FilterType, LifeTime, Position, Size, Visualize, Weld)
    local Characters = {}
    if HitBoxLibrary:CheckCharacter() == "Exist" then
        task.spawn(function()
            local HitBox = HitBoxLibrary:CreateHitBoxPart(Vector3.new(Size or 15, Size or 15, Size or 15), Visualize)
            HitBox.Position = Position or game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            HitBox.Shape = Enum.PartType.Ball
            if HitBoxType == "Dynamic" then
                HitBoxLibrary:Weld(HitBox, Weld)
            end
            game.Debris:AddItem(HitBox, LifeTime or 1)
            local function GetNear()
                if Filters then
                    Characters = {}
                    for Index, Filter in pairs(Filters) do
                        for Index, Model in pairs(Filter:GetChildren()) do
                            if Model.ClassName == "Model" and not Characters[Model] and Model ~= game.Players.LocalPlayer.Character and HitBoxLibrary:CheckCharacter(Model) == "Exist" and (HitBox.Position - Model.HumanoidRootPart.Position).Magnitude <= (Size or 15) / 2 then
                                if (FilterType or "WhiteList") == "WhiteList" then
                                    Characters[Model] = Model
                                end
                            end
                        end
                    end
                elseif not Filters then
                    Characters = {}
                    for Index, Model in pairs(game.Workspace:GetChildren()) do
                        if Model.ClassName == "Model" and not Characters[Model] and Model ~= game.Players.LocalPlayer.Character and HitBoxLibrary:CheckCharacter(Model) == "Exist" and (HitBox.Position - Model.HumanoidRootPart.Position).Magnitude <= (Size or 15) / 2 then
                            Characters[Model] = Model
                        end
                    end
                end 
            end
            if (HitBoxType or "Static") == "Static" then
                GetNear()
            elseif HitBoxType == "Dynamic" then
                local Timer = tick()
                repeat
                    GetNear()
                    task.wait()
                until not HitBox or (tick() - Timer) >= (LifeTime or 1)
            end
        end)
    end
    return Characters
end
function HitBoxLibrary:Weld(Part0, Part1)
    if not Part1 then
        Part0.Anchored = true
    elseif Part1 then
        Part0.Anchored = false
        local WeldConstraint = Instance.new("WeldConstraint")
        WeldConstraint.Parent = Part0
        WeldConstraint.Part0 = Part0
        WeldConstraint.Part1 = Part1
    end
end
return HitBoxLibrary