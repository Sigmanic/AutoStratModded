local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteFunction = if not GameSpoof then ReplicatedStorage:WaitForChild("RemoteFunction") else SpoofEvent
local RemoteEvent = if not GameSpoof then ReplicatedStorage:WaitForChild("RemoteEvent") else SpoofEvent
local TeleportService = game:GetService("TeleportService")

--[[local SpecialGameMode = {
    ["Pizza Party"] = "halloween",
    ["Badlands II"] = "badlands",
    ["Polluted Wastelands II"] = "polluted", 
    ["Huevous Hunt"] = "egg_hunt",
}]]
local SpecialGameMode = {
    ["Pizza Party"] = {mode = "halloween", challenge = "PizzaParty"},
    ["Badlands II"] = {mode = "badlands", challenge = "Badlands"},
    ["Polluted Wastelands II"] = {mode = "polluted", challenge = "PollutedWasteland"}, 
}
local ElevatorSettings = {
    ["Survival"] = {Enabled = false, ReMap = true, JoinMap = true, WaitTimeRe = .1, WaitTimeJoin = .25},
    ["Hardcore"] = {Enabled = false, ReMap = true, JoinMap = true, WaitTimeRe = 4.2, WaitTimeJoin = 1.7},
    ["Tutorial"] = {Enabled = false,},
}

return function(self, p1)
    local tableinfo = p1
    local MapName = tableinfo["Map"]
    local Solo = tableinfo["Solo"]
    local Mode = tableinfo["Mode"]
    local Difficulty = tableinfo["Difficulty"]
    --local MapProps = self.Map
    local MapGlobal = StratXLibrary.Global.Map --Not use self.Map since this function acts like global so if using self in each strat, it will duplicate the value and conflicts
    tableinfo.Index = self.Index
    local NameTable = MapName..":"..Mode
    ElevatorSettings[Mode].Enabled = true
    MapGlobal[NameTable] = tableinfo
    if MapGlobal.Active then
        print("Execute One Actived")
        return
    end
    MapGlobal.Active = true
    for i,v in next, MapGlobal do
        if string.find(typeof(v):lower(),"thread") then
            task.cancel(v)
        elseif string.find(typeof(v):lower(),"rbxscript") then
            v:Disconnect()
            RemoteFunction:InvokeServer("Elevators", "Leave")
        end
    end
    MapGlobal.JoiningCheck = false
    MapGlobal.ChangeCheck = false
    task.spawn(function()
        if CheckPlace() then
            repeat task.wait() until GetGameState():GetAttribute("MapName") and typeof(GetGameState():GetAttribute("MapName")) == "string" and GetGameState():GetAttribute("GameMode") --#ReplicatedStorage.State.Map.Value > 1
            local GameMapName = GetGameState():GetAttribute("MapName")
            local GameMode = GetGameState():GetAttribute("GameMode")
            local MapTable = MapGlobal[GameMapName..":"..GameMode]
            if not MapTable then --or not StratXLibrary.Strat[MapTable.Index].Loadout.AllowTeleport then
                print(MapGlobal[GameMapName..":"..GameMode],GameMode)
                ConsoleError("Wrong Map Selected: "..GameMapName..", ".."Mode: "..GameMode)
                task.wait(3)
                TeleportHandler(3260590327,2,7)
                --TeleportService:Teleport(3260590327, LocalPlayer)
                return
            end
            ConsoleInfo("Map Selected: "..GameMapName..", ".."Mode: "..Mode..", ".."Solo Only: "..tostring(Solo))
            return
        end
        local Elevators = {
            ["Survival"] = {},
            ["Hardcore"] = {},
        }
        if MapName == "Tutorial" then
            prints("Teleporting To Tutorial Mode ")
            RemoteEvent:FireServer("Tutorial", "Start")
            return
        end
        for i,v in next,Workspace.Elevators:GetChildren() do
            if SpecialGameMode[MapName] then
                local SpecialTable = SpecialGameMode[MapName]
                UI.JoiningStatus.Text = `Special Gamemode Found. Checking Loadout`
                local Strat = StratXLibrary.Strat[self.Index]
                if Strat.Loadout and not Strat.Loadout.AllowTeleport then
                    prints("Waiting Loadout Allowed")
                    repeat task.wait() until Strat.Loadout.AllowTeleport
                end
                local LoadoutInfo = Strat.Loadout.Lists[#Strat.Loadout.Lists]
                LoadoutInfo.AllowEquip = true
                LoadoutInfo.SkipCheck = true
                prints("Loadout Selecting")
                Functions.Loadout(Strat,LoadoutInfo)
                task.wait(2)
                UI.JoiningStatus.Text = `Teleporting to Special Gamemode`
                RemoteFunction:InvokeServer("Multiplayer","single_create")
                RemoteFunction:InvokeServer("Multiplayer","v2:start",{
                    ["count"] = 1,
                    ["mode"] = SpecialTable.mode,
                    ["challenge"] = SpecialTable.challenge,
                })
                --[[RemoteFunction:InvokeServer("Multiplayer","single_start",{
                    ["count"] = 1,
                    ["mode"] = if SpecialTable then SpecialTable else string.lower(Mode),
                    ["difficulty"] = Difficulty,
                })]] --Still working but i still upadted to the new tds format 
                prints(`Using MatchMaking To Teleport To Special GameMode: {SpecialTable.mode}`)
                return
            elseif v.State.Difficulty.Value == "Private Server" or UtilitiesConfig.PreferMatchmaking then
                local PrivateCheck = v.State.Difficulty.Value == "Private Server"
                UI.JoiningStatus.Text = `{if PrivateCheck then "Private Server Elevator Found" else "Matchmaking Enabled"}. Checking Loadout`
                prints("Waiting Loadout Allowed")
                local Strat = StratXLibrary.Strat
                local MapProps
                repeat
                    task.wait()
                    for i,v in next, Strat do
                        if v.Loadout and v.Loadout.AllowTeleport then
                            MapProps = v.Map.Lists[1]
                            break
                        end
                    end
                until MapProps
                local DiffTable = {
                    ["Easy"] = "Easy",
                    ["Normal"] = "Molten",
                    ["Intermediate"] = "Intermediate",
                    ["Fallen"] = "Fallen",
                }
                local Strat = Strat[MapProps.Index]
                local DifficultyName = Strat.Mode.Lists[1] and DiffTable[Strat.Mode.Lists[1].Name]
                local LoadoutInfo = Strat.Loadout.Lists[1]
                LoadoutInfo.AllowEquip = true
                LoadoutInfo.SkipCheck = true
                prints("Loadout Selecting")
                Functions.Loadout(Strat,LoadoutInfo)
                task.wait(2)
                UI.JoiningStatus.Text = `Teleporting to Matchmaking Place`
                RemoteFunction:InvokeServer("Multiplayer","single_create")
                RemoteFunction:InvokeServer("Multiplayer","v2:start",{
                    ["count"] = 1,
                    ["mode"] = string.lower(MapProps.Mode),
                    ["difficulty"] = DifficultyName,
                })
                prints("Teleporting To Matchmaking Place")
                return
            end
            local Passed, ElevatorType = pcall(function()
                return require(v.Settings).Type
            end)
            if not Passed then
                ElevatorType = if v.Lift["Main part"].BrickColor == BrickColor.new("Lilac") then "Hardcore" else "Survival"
            end
            if not Elevators[ElevatorType] then
                Elevators[ElevatorType] = {}
            end
            table.insert(Elevators[ElevatorType],{
                ["Object"] = v,
                ["MapName"] = v.State.Map.Title,
                ["Time"] = v.State.Timer,
                ["Playing"] = v.State.Players,
                ["Mode"] = ElevatorType,
            })
        end
        --prints("Found",#Elevators,"Elevators")
        for i,v in next, Elevators do
            prints("Found",#v, i.." Elevators")
        end
        while true do
            task.wait(.3)
            for Name, Check in next, ElevatorSettings do
                if not Check.Enabled then
                    continue
                end
                if Check.ReMap then
                    ElevatorSettings[Name].ReMap = false
                    task.wait()
                    task.spawn(function()
                        for i,v in ipairs(Elevators[Name]) do
                            task.wait(ElevatorSettings[Name].WaitTimeRe)
                            if MapGlobal.JoiningCheck then
                                repeat task.wait() until MapGlobal.JoiningCheck == false
                            end
                            local MapTableName = v["MapName"].Value..":"..v["Mode"]
                            if not MapGlobal[MapTableName] and v["Playing"].Value == 0 and not MapGlobal.JoiningCheck then
                                MapGlobal.ChangeCheck = true
                                prints("Changing Elevator",i)
                                RemoteFunction:InvokeServer("Elevators", "Enter", v["Object"])
                                task.wait(.8)
                                RemoteFunction:InvokeServer("Elevators", "Leave")
                                task.wait(.1)
                                MapGlobal.ChangeCheck = false
                            end
                        end
                        task.wait()
                        ElevatorSettings[Name].ReMap = true
                    end)
                end
                if Check.JoinMap then
                    ElevatorSettings[Name].JoinMap = false
                    task.wait()
                    task.spawn(function()
                        for i,v in ipairs(Elevators[Name]) do
                            task.wait(ElevatorSettings[Name].WaitTimeJoin)
                            UI.JoiningStatus.Text = "Trying Elevator: " ..tostring(i)
                            UI.MapFind.Text = "Map: "..v["MapName"].Value
                            UI.CurrentPlayer.Text = "Player Joined: "..v["Playing"].Value
                            prints("Trying elevator",i,"Map:","\""..v["MapName"].Value.."\"",", Player Joined:",v["Playing"].Value)
                            local MapTableName = v["MapName"].Value..":"..v["Mode"]
                            local MapTable = MapGlobal[MapTableName]
                            if MapTable and v["Time"].Value > 5 and v["Playing"].Value < 4 then
                                if MapTable.Solo and v["Playing"].Value ~= 0 then
                                    continue
                                end
                                local MapIndex = MapTable.Index
                                if StratXLibrary.Strat[MapIndex].Loadout and not StratXLibrary.Strat[MapIndex].Loadout.AllowTeleport then
                                    prints("Waiting Loadout Allowed")
                                    repeat task.wait() until StratXLibrary.Strat[MapIndex].Loadout.AllowTeleport
                                end
                                if MapGlobal.JoiningCheck or MapGlobal.ChangeCheck then -- or not self.Loadout.AllowTeleport then
                                    repeat task.wait() 
                                    until MapGlobal.JoiningCheck == false and MapGlobal.ChangeCheck == false --and self.Loadout.AllowTeleport
                                end
                                MapGlobal.JoiningCheck = true

                                RemoteFunction:InvokeServer("Elevators", "Enter", v["Object"])
                                UI.JoiningStatus.Text = "Joined Elevator: " ..tostring(i)
                                prints("Joined Elevator",i)

                                local LoadoutInfo = StratXLibrary.Strat[MapIndex].Loadout.Lists[#StratXLibrary.Strat[MapIndex].Loadout.Lists]
                                LoadoutInfo.AllowEquip = true
                                LoadoutInfo.SkipCheck = true
                                print("Loadout Selecting")
                                Functions.Loadout(StratXLibrary.Strat[MapIndex],LoadoutInfo)

                                MapGlobal.ConnectionEvent = v["Time"].Changed:Connect(function(numbertime)
                                    local MapTableName = v["MapName"].Value..":"..v["Mode"]
                                    UI.MapFind.Text = "Map: "..v["MapName"].Value
                                    UI.CurrentPlayer.Text = "Player Joined: "..v["Playing"].Value
                                    UI.TimerLeft.Text = "Time Left: "..tostring(numbertime)
                                    prints("Time Left: ",numbertime)
                                    --Scenario: Player Died
                                    if not (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid")) then
                                        print("Event Disconnected 3")
                                        MapGlobal.ConnectionEvent:Disconnect()
                                        UI.JoiningStatus.Text = "Player Died. Rejoining Elevator"
                                        prints("Player Died. Rejoining Elevator")
                                        RemoteFunction:InvokeServer("Elevators", "Leave")
                                        UI.TimerLeft.Text = "Time Left: NaN"
                                        repeat task.wait() until LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid")
                                        MapGlobal.JoiningCheck = false
                                        return
                                    end
                                    if numbertime > 0 and (not MapGlobal[MapTableName] or (MapGlobal[MapTableName].Solo and v["Playing"].Value > 1)) then
                                        print("Event Disconnected 1")
                                        MapGlobal.ConnectionEvent:Disconnect()
                                        local Text = (not MapGlobal[MapTableName] and "Map Has Been Changed") or ((MapGlobal[MapTableName].Solo and v["Playing"].Value > 1) and "Someone Has Joined") or "Error"
                                        RemoteFunction:InvokeServer("Elevators", "Leave")
                                        UI.JoiningStatus.Text = Text..", Leaving Elevator "..tostring(i)
                                        prints(Text..", Leaving Elevator",i,"Map:","\""..v["MapName"].Value.."\"",", Player Joined:",v["Playing"].Value)
                                        UI.TimerLeft.Text = "Time Left: NaN"
                                        MapGlobal.JoiningCheck = false
                                        return
                                    end
                                    if numbertime == 0 then
                                        print("Event Disconnected 2")
                                        MapGlobal.ConnectionEvent:Disconnect()
                                        UI.JoiningStatus.Text = "Teleporting To Match"
                                        task.wait(60)
                                        UI.JoiningStatus.Text = "Rejoining Elevator"
                                        prints("Rejoining Elevator")
                                        RemoteFunction:InvokeServer("Elevators", "Leave")
                                        UI.TimerLeft.Text = "Time Left: NaN"
                                        MapGlobal.JoiningCheck = false
                                        return
                                    end
                                    RemoteFunction:InvokeServer("Elevators", "Enter", v["Object"])
                                end)
                                repeat task.wait() until MapGlobal.JoiningCheck == false
                            end
                            task.wait(.2)
                        end
                        ElevatorSettings[Name].JoinMap = true
                    end)
                end
                task.wait()
            end
        end
    end)
end
