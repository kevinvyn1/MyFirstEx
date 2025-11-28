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

local VehicleStealerEnabled = false
local StealDistance = 10
local TargetVehicle = nil
local EjectDelay = 1

--// Functions //--

local function FindNearestVehicle()
    local nearestVehicle = nil
    local nearestDistance = StealDistance
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

local function StealVehicle()
    if not VehicleStealerEnabled or not TargetVehicle then return end

    if Humanoid.SeatPart then
        if Humanoid.SeatPart:IsDescendantOf(TargetVehicle) then
            wait(EjectDelay)
            EjectDriver(TargetVehicle)

            _G.WindUI:Notify({ -- Menggunakan _G.WindUI karena WindUI didefinisikan di script utama
                Title = "Vehicle Stolen!",
                Content = "Attempting to take control of the vehicle!",
                Icon = "check",
            })
        end
    end
end

--// Main Loop //--
RunService.Stepped:Connect(StealVehicle)

--// UI Elements (dipindahkan ke script utama) //--
--// Variabel UI dipindahkan ke script utama dan diakses melalui _G //--

_G.VehicleStealer = {
    FindNearestVehicle = FindNearestVehicle,
    TargetVehicle = nil,
    VehicleStealerEnabled = false
}
