--// Services //--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--// Variables //--
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local VehiclesFolder = workspace:WaitForChild("Vehicles")

-- Reference ke UI Button
local StealButton

--// Functions //--

local function FindNearestVehicle()
    local nearestVehicle = nil
    local nearestDistance = 10
    for _, vehicle in pairs(VehiclesFolder:GetChildren()) do
        if vehicle:IsA("Model") then
            local primaryPart = vehicle:FindFirstChild("PrimaryPart")
            if primaryPart then
                local distance = (HumanoidRootPart.Position - primaryPart.Position).Magnitude
                if distance <= nearestDistance then
                    nearestDistance = distance
                    nearestVehicle = vehicle
                end
            end
        end
    end
    return nearestVehicle
end

local function EjectDriver(vehicle)
    local driverSeat = vehicle:FindFirstChild("DriverSeat") or vehicle:FindFirstChild("Seat")
    if driverSeat and driverSeat:IsA("VehicleSeat") and driverSeat.Occupant then
        local occupant = driverSeat.Occupant
        local humanoid = occupant.Parent:FindFirstChild("Humanoid")
        if humanoid then
            local tweenInfo = TweenInfo.new(
                0.5,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.Out,
                0,
                false,
                0
            )

            local tween = TweenService:Create(humanoid, tweenInfo, { Sit = false })
            tween:Play()
        end
    end
end

-- Fungsi utama untuk mencuri kendaraan
local function StealVehicle()
    -- Pastikan player berada di dalam kendaraan target
    if not _G.VehicleStealer.TargetVehicle then
        _G.WindUI:Notify({
            Title = "Vehicle Stealer",
            Content = "No target vehicle selected!",
            Icon = "error",
        })
        return
    end

    if Humanoid.SeatPart then
        if Humanoid.SeatPart:IsDescendantOf(_G.VehicleStealer.TargetVehicle) then
            EjectDriver(_G.VehicleStealer.TargetVehicle)

            _G.WindUI:Notify({
                Title = "Vehicle Stealer",
                Content = "Attempting to take control of the vehicle!",
                Icon = "check",
            })
        else
            _G.WindUI:Notify({
                Title = "Vehicle Stealer",
                Content = "You are not in the target vehicle!",
                Icon = "error",
            })
        end
    else
        _G.WindUI:Notify({
            Title = "Vehicle Stealer",
            Content = "You are not in a vehicle!",
            Icon = "error",
        })
    end
end

-- Tambahkan button "Steal Vehicle" ke UI
StealButton = _G.Tabs.Main:Button({
    Title = "Steal Vehicle (Must Be In Car)",
    Desc = "Click to attempt to steal the vehicle you are currently in.",
    Callback = function()
        if _G.VehicleStealer.VehicleStealerEnabled then
            StealVehicle()
        else
            _G.WindUI:Notify({
                Title = "Vehicle Stealer",
                Content = "Vehicle Stealer is not enabled!",
                Icon = "error",
            })
        end
    end
})

-- Fungsi untuk memperbarui status button StealVehicle
local function UpdateStealButton()
    if _G.VehicleStealer.TargetVehicle and Humanoid.SeatPart and Humanoid.SeatPart:IsDescendantOf(_G.VehicleStealer.TargetVehicle) then
        StealButton:SetEnabled(true)
    else
        StealButton:SetEnabled(false)
    end
end

--// Setup
_G.VehicleStealer = {
    FindNearestVehicle = FindNearestVehicle,
    TargetVehicle = nil,
    VehicleStealerEnabled = false,
}

-- Loop untuk memperbarui status button StealVehicle
RunService.Stepped:Connect(UpdateStealButton)
