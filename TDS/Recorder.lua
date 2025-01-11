local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteFunction = if not GameSpoof then ReplicatedStorage:WaitForChild("RemoteFunction") else SpoofEvent
local RemoteEvent = if not GameSpoof then ReplicatedStorage:WaitForChild("RemoteEvent") else SpoofEvent
local RSTimer = ReplicatedStorage:WaitForChild("State"):WaitForChild("Timer"):WaitForChild("Time") -- Current game's timer
local RSMode = ReplicatedStorage:WaitForChild("State"):WaitForChild("Mode") -- Survival or Hardcore check
local RSDifficulty = ReplicatedStorage:WaitForChild("State"):WaitForChild("Difficulty") -- Survival's gamemodes
local RSMap = ReplicatedStorage:WaitForChild("State"):WaitForChild("Map") --map's Name
local VoteGUI = LocalPlayer.PlayerGui:WaitForChild("ReactOverridesVote"):WaitForChild("Frame"):WaitForChild("votes"):WaitForChild("vote") -- it is what it is
local GameWave = LocalPlayer.PlayerGui:WaitForChild("ReactGameTopGameDisplay"):WaitForChild("Frame"):WaitForChild("wave"):WaitForChild("container"):WaitForChild("value") -- currennt wave you are on

getgenv().WriteFile = function(check,name,location,str)
    if not check then
        return
    end
    if type(name) == "string" then
        if not type(location) == "string" then
            location = ""
        end
        if not isfolder(location) then
            makefolder(location)
        end
        if type(str) ~= "string" then
            error("Argument 4 must be a string got " .. tostring(number))
        end
        writefile(location.."/"..name..".txt",str)
    else
        error("Argument 2 must be a string got " .. tostring(number))
    end
end
getgenv().AppendFile = function(check,name,location,str)
    if not check then
        return
    end
    if type(name) == "string" then
        if not type(location) == "string" then
            location = ""
        end
        if not isfolder(location) then
            WriteFile(check,name,location,str)
        end
        if type(str) ~= "string" then
            error("Argument 4 must be a string got " .. tostring(number))
        end
        if isfile(location.."/"..name..".txt") then
            appendfile(location.."/"..name..".txt",str)
        else
            WriteFile(check,name,location,str)
        end
    else
        error("Argument 2 must be a string got " .. tostring(number))
    end
end
local writestrat = function(...)
    local TableText = {...}
    task.spawn(function()
        if not game:GetService("Players").LocalPlayer then
            repeat task.wait() until game:GetService("Players").LocalPlayer
        end
        for i,v in next, TableText do
            if type(v) ~= "string" then
                TableText[i] = tostring(v)
            end
        end
        local Text = table.concat(TableText, " ")
        print(Text)
        return WriteFile(true,LocalPlayer.Name.."'s strat","StrategiesX/TDS/Recorder",tostring(Text).."\n")
    end)
end
local appendstrat = function(...)
    local TableText = {...}
    task.spawn(function()
        if not game:GetService("Players").LocalPlayer then
            repeat task.wait() until game:GetService("Players").LocalPlayer
        end
        for i,v in next, TableText do
            if type(v) ~= "string" then
                TableText[i] = tostring(v)
            end
        end
        local Text = table.concat(TableText, " ")
        print(Text)
        return AppendFile(true,LocalPlayer.Name.."'s strat","StrategiesX/TDS/Recorder",tostring(Text).."\n")
    end)
end
getgenv().Recorder = {
    Troops = {
        Golden = {},
    },
    TowersList = {},
}
getgenv().TowersList = Recorder.TowersList
local TowerCount = 0
local GetMode = nil

local UILibrary = getgenv().UILibrary or loadstring(game:HttpGet("https://raw.githubusercontent.com/Sigmanic/ROBLOX/main/ModificationWallyUi", true))()
UILibrary.options.toggledisplay = 'Fill'

local mainwindow = UILibrary:CreateWindow('Recorder')
UILibrary.container.Parent.Parent = LocalPlayer.PlayerGui
Recorder.Status = mainwindow:Section("Loading")

local timeSection = mainwindow:Section("Time Passed: ")
task.spawn(function()
    function TimeConverter(v)
        if v <= 9 then
            local conv = "0" .. v
            return conv
        else
            return v
        end
    end
    local startTime = os.time()

    while task.wait(0.1) do
        local t = os.time() - startTime
        local seconds = t % 60
        local minutes = math.floor(t / 60) % 60
        timeSection.Text = "Time Passed: " .. TimeConverter(minutes) .. ":" .. TimeConverter(seconds)
    end
end)

mainwindow:Toggle('Auto Skip', {flag = "autoskip"})
mainwindow:Section("\\/ LAST WAVE \\/")
mainwindow:Toggle('Auto Sell Farms', {default = true, flag = "autosellfarms"})

function SetStatus(string)
    Recorder.Status.Text = string
end

--[[local GameInfo
getgenv().GetGameInfo = function()
    if GameInfo then
        return GameInfo
    end
    repeat
        for i,v in next, ReplicatedStorage.StateReplicators:GetChildren() do
            if v:GetAttribute("TimeScale") then
                GameInfo = v
                return v
            end
        end
        task.wait()
    until GameInfo
end
local VoteState
getgenv().GetVoteState = function()
    if VoteState then
        return VoteState
    end
    repeat
        for i,v in next, ReplicatedStorage.StateReplicators:GetChildren() do
            if v:GetAttribute("MaxVotes") then
                VoteState = v
                return v
            end
        end
        task.wait()
    until VoteState
end]]

function ConvertTimer(number : number)
   return math.floor(number/60), number % 60
end

local TimerCheck = false
function CheckTimer(bool)
    return (bool and TimerCheck) or true
end
RSTimer.Changed:Connect(function(time)
    if time == 5 then
        TimerCheck = true
    elseif time and time > 5 then
        TimerCheck = false
    end
end)

function GetTimer()
    local Min, Sec = ConvertTimer(RSTimer.Value)
    return {tonumber(GameWave.Text), Min, Sec + Recorder.SecondMili, tostring(TimerCheck)}
end

Recorder.SecondMili = 0
RSTimer.Changed:Connect(function()
    Recorder.SecondMili = 0
    for i = 1,9 do
        task.wait(0.09)
        Recorder.SecondMili += 0.1
    end
end)

local FarmsID = {}

local GenerateFunction = {
    Place = function(Args, Timer, RemoteCheck)
        if typeof(RemoteCheck) ~= "Instance" then
            return
        end
        local TowerName = Args[3]
        local Position = Args[4].Position
        local Rotation = Args[4].Rotation
        local RotateX,RotateY,RotateZ = Rotation:ToEulerAnglesYXZ()
        TowerCount += 1
        RemoteCheck.Name = TowerCount
        TowersList[TowerCount] = {
            ["TowerName"] = Args[3],
            ["Instance"] = RemoteCheck,
            ["Position"] = Position,
            ["Rotation"] = Rotation,
        }
        local upgradeHandler = require(ReplicatedStorage.Client.Modules.Game.Interface.Elements.Upgrade.upgradeHandler)
        upgradeHandler:selectTroop(RemoteCheck)
        SetStatus(`Placed {TowerName}`)
        if TowerName == "Farm" then
            table.insert(FarmsID, RemoteCheck.Name)
        end
        local TimerStr = table.concat(Timer, ", ")
        appendstrat(`TDS:Place("{TowerName}", {Position.X}, {Position.Y}, {Position.Z}, {TimerStr}, {RotateX}, {RotateY}, {RotateZ})`)
    end,
    Upgrade = function(Args, Timer, RemoteCheck)
        local TowerIndex = Args[4].Troop.Name;
        local PathTarget = Args[4].Path
        if RemoteCheck ~= true then
            SetStatus(`Upgraded Failed ID: {TowerIndex}`)
            print(`Upgraded Failed ID: {TowerIndex}`, RemoteCheck)
            return
        end
        SetStatus(`Upgraded ID: {TowerIndex}`)
        local TimerStr = table.concat(Timer, ", ")
        appendstrat(`TDS:Upgrade({TowerIndex}, {TimerStr}, {PathTarget})`)
    end,
    Sell = function(Args, Timer, RemoteCheck)
        local TowerIndex = Args[3].Troop.Name;
        if not RemoteCheck or TowersList[tonumber(TowerIndex)].Instance:FindFirstChild("HumanoidRootPart") then
            SetStatus(`Sell Failed ID: {TowerIndex}`)
            print(`Sell Failed ID: {TowerIndex}`, RemoteCheck)
            return
        end
        SetStatus(`Sold TowerIndex {TowerIndex}`)
        local TimerStr = table.concat(Timer, ", ")
        appendstrat(`TDS:Sell({TowerIndex}, {TimerStr})`)
    end,
    Target = function(Args, Timer, RemoteCheck)
        local TowerIndex = Args[4].Troop.Name
        local Target = Args[4].Target
        if RemoteCheck ~= true then
            SetStatus(`Target Failed ID: {TowerIndex}`)
            print(`Target Failed ID: {TowerIndex}`, RemoteCheck)
        end
        SetStatus(`Changed Target ID: {TowerIndex}`)
        local TimerStr = table.concat(Timer, ", ")
        appendstrat(`TDS:Target({TowerIndex}, "{Target}", {TimerStr})`)
    end,
    Abilities = function(Args, Timer, RemoteCheck)
        local TowerIndex = Args[4].Troop.Name
        local AbilityName = Args[4].Name
        local Data = Args[4].Data
        if RemoteCheck ~= true then
            SetStatus(`Ability Failed ID: {TowerIndex}`)
            print(`Ability Failed ID: {TowerIndex}`, RemoteCheck)
            return
        end
        local function formatData(Data)
            local formattedData = {}
            for key, value in pairs(Data) do
                if key == "directionCFrame" then
                    table.insert(formattedData, string.format('["%s"] = CFrame.new(%s)', key, tostring(value)))
                elseif key == "position" then
                    table.insert(formattedData, string.format('["%s"] = Vector3.new(%s)', key, tostring(value)))
                else
                    table.insert(formattedData, string.format('["%s"] = %s', key, tostring(value)))
                end
            end
            return "{" .. table.concat(formattedData, ", ") .. "}"
        end
        local formattedData = formatData(Data)
        SetStatus(`Used Ability On TowerIndex {TowerIndex}`)
        local TimerStr = table.concat(Timer, ", ")
        appendstrat(`TDS:Ability({TowerIndex}, "{AbilityName}", {TimerStr}, {formattedData})`)
    end,
    Option = function(Args, Timer, RemoteCheck)
        local TowerIndex = Args[4].Troop.Name;
        local OptionName = Args[4].Name
        local Value = Args[4].Value
        if RemoteCheck ~= true then
            SetStatus(`Option Failed ID; {TowerIndex}`)
            print(`Option Failed ID: {TowerIndex}`, RemoteCheck)
            return
        end
        SetStatus(`Used Option On TowerIndex {TowerIndex}`)
        local TimerStr = table.concat(Timer, ", ")
        appendstrat(`TDS:Option({TowerIndex}, "{OptionName}", "{Value}", {TimerStr})`)
    end,
    Skip = function(Args, Timer, RemoteCheck)
        if tonumber(GameWave.Text) == 0 then
            return
        end
        SetStatus(`Skipped Wave`)
        local TimerStr = table.concat(Timer, ", ")
        appendstrat(`TDS:Skip({TimerStr})`)
    end,
    Vote = function(Args, Timer, RemoteCheck)
        local Difficulty = Args[3]
        local DiffTable = {
            ["Easy"] = "Easy",
            ["Casual"] = "Casual",
            ["Intermediate"] = "Intermediate",
            ["Molten"] = "Molten",
            ["Fallen"] = "Fallen"
        }
        GetMode = DiffTable[Difficulty] or Difficulty
        SetStatus(`Vote {GetMode}`)
    end,
    SelectLoadout = function(Args, Timer, RemoteCheck)
        local LoadoutName = Args[1]
        SetStatus(`Loadout Selected`)
        appendstrat(`TDS:SelectLoadout("{LoadoutName}")`)
    end,
}

local Skipped = false
VoteGUI:GetPropertyChangedSignal("Position"):Connect(function()
    repeat task.wait() until mainwindow.flags.autoskip
    if Skipped or VoteGUI:WaitForChild("count").Text ~= "0/1 Required" then
        return
    end
    local currentPrompt = VoteGUI:WaitForChild("prompt").Text
    if currentPrompt == "Skip Wave?" and tonumber(GameWave.Text) ~= 0 then
        Skipped = true
        local Timer = GetTimer()
        task.spawn(GenerateFunction["Skip"], true, Timer)
        ReplicatedStorage.RemoteFunction:InvokeServer("Voting", "Skip")
        task.wait(2.5)
        Skipped = false
    end
end)

task.spawn(function()
    GameWave:GetPropertyChangedSignal("Text"):Wait()
    local FinalWaveAtDifferentMode = {
        ["Easy"] = 25,
        ["Casual"] = 30,
        ["Intermediate"] = 30,
        ["Molten"] = 35,
        ["Fallen"] = 40,
        ["Hardcore"] = 50
    }
    local FinalWave = FinalWaveAtDifferentMode[RSDifficulty.Value]
    GameWave:GetPropertyChangedSignal("Text"):Connect(function()
        if tonumber(GameWave.Text) == FinalWave then
            repeat task.wait() until mainwindow.flags.autosellfarms
            for i,v in ipairs(game.Workspace.Towers:GetChildren()) do
                if v.Owner.Value == LocalPlayer.UserId and table.find(FarmsID, v.Name) then
                    ReplicatedStorage.RemoteFunction:InvokeServer("Troops", "Sell", {["Troop"] = v})
                end
            end
            SetStatus(`Sold All Farms`)
        end
    end)
end)

for TowerName, Tower in next, ReplicatedStorage.RemoteFunction:InvokeServer("Session", "Search", "Inventory.Troops") do
    if (Tower.Equipped) then
        table.insert(Recorder.Troops, TowerName)
        if (Tower.GoldenPerks) then
            table.insert(Recorder.Troops.Golden, TowerName)
        end
    end
end
writestrat("getgenv().StratCreditsAuthor = \"Optional\"")
appendstrat("local TDS = loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Sigmanic/Strategies-X/refs/heads/main/TDS/MainSource.lua\", true))()\nTDS:Map(\""..
RSMap.Value.."\", true, \""..RSMode.Value.."\")\nTDS:Loadout({\""..
    table.concat(Recorder.Troops, `", "`) .. if #Recorder.Troops.Golden ~= 0 then "\", [\"Golden\"] = {\""..
    table.concat(Recorder.Troops.Golden, `", "`).."\"}})" else "\"})"
)
task.spawn(function()
    local DiffTable = {
        ["Easy"] = "Easy",
        ["Casual"] = "Casual",
        ["Intermediate"] = "Intermediate",
        ["Molten"] = "Molten",
        ["Fallen"] = "Fallen"
    }
    repeat task.wait() until GetMode ~= nil or RSDifficulty.Value ~= ""
    if GetMode then
        repeat task.wait() until GetMode == RSDifficulty.Value
        appendstrat(`TDS:Mode("{GetMode}")`)
    elseif DiffTable[RSDifficulty.Value] then
        appendstrat(`TDS:Mode("{DiffTable[RSDifficulty.Value]}")`)
    end
end)

local OldNamecall
OldNamecall = hookmetamethod(game, '__namecall', function(...)
    local Self, Args = (...), ({select(2, ...)})
    if getnamecallmethod() == "InvokeServer" and Self.name == "RemoteFunction" then
        local thread = coroutine.running()
        coroutine.wrap(function(Args)
            local Timer = GetTimer()
            local RemoteFired = Self.InvokeServer(Self, unpack(Args))
            if GenerateFunction[Args[2]] then
                GenerateFunction[Args[2]](Args, Timer, RemoteFired)
            end
            coroutine.resume(thread, RemoteFired)
        end)(Args)
        return coroutine.yield()
    elseif getnamecallmethod() == "FireServer" and GenerateFunction[Self.name] then
        GenerateFunction[Self.name](Args)
    end
    return OldNamecall(...,unpack(Args))
end)
