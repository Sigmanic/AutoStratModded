if getgenv().StratXLibrary and getgenv().StratXLibrary.Executed then
	if StratXLibrary.Strat[#StratXLibrary.Strat].Active then
		return Strat.new()
	else
		return StratXLibrary.Strat[#StratXLibrary.Strat]
	end
end

if not game:IsLoaded() then
	game["Loaded"]:Wait()
end

local Version = "Version: 0.3.22 [Alpha]"
local Items = {
	Enabled = true,
	Name = {"Bell", "Lorebook"}
}

local LoadLocal = false
local MainLink = LoadLocal and "" or "https://raw.githubusercontent.com/Sigmanic/Strategies-X/refs/heads/main/TDS/"

local OldTime = os.clock()

-- // Folder Stuffs

local function CheckFolderExists(folder_path)
    if not isfolder(folder_path) then
		makefolder(folder_path)
    end
end

local LocalFolder = "StrategiesX/TDS/"
CheckFolderExists("StrategiesX")
CheckFolderExists(LocalFolder)
CheckFolderExists(LocalFolder.."UserConfig")
CheckFolderExists(LocalFolder.."UserLogs")
CheckFolderExists(LocalFolder.."Recorder")

local StratXLibrary = {Functions = {}}
getgenv().StratXLibrary = StratXLibrary

--getgenv().StratXLibrary.ExecutedCount = 0
getgenv().Functions = StratXLibrary.Functions
StratXLibrary["TowersContained"] = {}
StratXLibrary["TowersContained"].Index = 0
getgenv().TowersContained = StratXLibrary["TowersContained"]
StratXLibrary["ActionInfo"] = {
	["Place"] = {0,0},
	["Upgrade"] = {0,0},
	["Sell"] = {0,0},
	["Skip"] = {0,0},
	["Ability"] = {0,0},
	["Target"] = {0,0},
	["Option"] = {0,0},
	["LeaveOn"] = {0,0},
	["AutoChain"] = {0,0},
	["SellAllFarms"] = {0,0},
}
StratXLibrary.UI = {}
StratXLibrary.RestartCount = 0
StratXLibrary.CurrentCount = StratXLibrary.RestartCount
--StratXLibrary.MultiStratEnabled = getgenv().IsMultiStrat or false
--[[StratXLibrary.MultiStratEnabled = true
getgenv().GameSpoof = "Lobby"]]

StratXLibrary.UtilitiesConfig = {
	Camera = (getgenv().DefaultCam and tonumber(getgenv().DefaultCam)) or 2,
	LowGraphics = getgenv().PotatoPC or false,
	BypassGroup = getgenv().GroupBypass or false,
	AutoBuyMissing = getgenv().BuyMissingTowers or false,
	AutoPickups = getgenv().BattlePass or false,
	RestartMatch = getgenv().AutoRestart or false,
	TowersPreview = getgenv().Debug or false,
	AutoSkip = getgenv().AutoSkip or false,
	UseTimeScale = getgenv().UseTimeScale or false,
	PreferMatchmaking = getgenv().PreferMatchmaking or getgenv().Matchmaking or false,
	Webhook = {
		WebhookEnabled = true,
		Link = (getgenv().WebhookLink and tostring(getgenv().WebhookLink)) or "",
		HideUser = false,
		UseNewFormat = false,
		PlayerInfo = true,
		GameInfo = true,
		TroopsInfo = true,
		DisableCustomLog = true,
	},
}

local SpoofEvent = {}
if GameSpoof then
	function SpoofEvent:InvokeServer(...)
		print("InvokeServer",...)
	end
	function SpoofEvent:FireServer(...)
		print("FireServer",...)
	end
end

--[[function ggc(arg)
    for i, v in pairs(getgc(true)) do
        if type(v) == 'table' then
            if rawget(v, arg) then
                if arg == "IsPrivateServer" then
                    if v[arg] ~= 0 then
                        return true
                    else
                        return false
                    end
                end
                if arg == "Enabled" then
                    -- Check if any 'v[arg]' equals true
                    if v[arg] == true then
                        return true
                    else
                        return false
                    end
                end
                -- For other arguments, return the value directly
                return v[arg]
            end
        end
    end
    return nil  -- Return nil if no valid value was found
end]]

local SpecialMaps = {
	"Pizza Party",
	"Badlands II",
	"Polluted Wasteland II",
	--Current Special Maps ^^^^^^
	"Failed Gateway",
	"The Nightmare Realm",
	"Containment",
	--Halloween 2024 Maps ^^^^^^
	"Pls Donate",
	--Pls Donate Collaboration Map
	"Outpost 32",
	--Frost Invasion 2024 Map
	"Classic Candy Cane Lane",
	"Classic Winter",
	"Classic Forest Camp",
	"Classic Island Chaos",
	"Classic Castle",
	--The Classic Roblox Event Special Maps ^^^^^^
	"Huevous Hunt",
	--The Hunt Roblox Event Special Maps ^^^^^^
}

local SpecialGameMode = {
    ["Pizza Party"] = {mode = "halloween", challenge = "PizzaParty"},
    ["Badlands II"] = {mode = "badlands", challenge = "Badlands"},
    ["Polluted Wasteland II"] = {mode = "polluted", challenge = "PollutedWasteland"},
    --Current Special Maps ^^^^^^
    ["Failed Gateway"] = {mode = "halloween2024", difficulty = "Act1", night = 1},
    ["The Nightmare Realm"] = {mode = "halloween2024", difficulty = "Act2", night = 2},
    ["Containment"] = {mode = "halloween2024", difficulty = "Act3", night = 3},
    ["Pls Donate"] = {mode = "plsDonate", difficulty = "PlsDonateHard"},
    ["Outpost 32"] = {mode = "frostInvasion", difficulty = "Hard" },
    --Temporary Special Maps ^^^^^^
    ["Classic Candy Cane Lane"] = {mode = "Event", part = "ClassicRobloxPart1"},
    ["Classic Winter"] = {mode = "Event", part = "ClassicRobloxPart2"},
    ["Classic Forest Camp"] = {mode = "Event", part = "ClassicRobloxPart3"},
    ["Classic Island Chaos"] = {mode = "Event", part = "ClassicRobloxPart4"},
    ["Classic Castle"] = {mode = "Event", part = "ClassicRobloxPart5"},
    --The Classic Event Maps ^^^^^^ [STILL EXIST IN GAME FILES]
    ["Huevous Hunt"] = {""},
    --The Hunt Event Maps [NO LONGER EXIST IN GAME FILES]
}

local WeeklyChallenge = {
    "BackToBasics",
    --[["JailedTowers",
    "Juggernaut",
    "Legion",
    "OopsAllSlimes",
    "Vanguard"]]
}

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteFunction = if not GameSpoof then ReplicatedStorage:WaitForChild("RemoteFunction") else SpoofEvent
local RemoteEvent = if not GameSpoof then ReplicatedStorage:WaitForChild("RemoteEvent") else SpoofEvent
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local Mouse = LocalPlayer:GetMouse()
local CurrentCamera = Workspace.CurrentCamera
local OldCameraOcclusionMode = LocalPlayer.DevCameraOcclusionMode
local VirtualUser = game:GetService("VirtualUser")
local UILibrary = getgenv().UILibrary or loadstring(game:HttpGet("https://raw.githubusercontent.com/Sigmanic/ROBLOX/main/WallyUI.lua", true))()
UILibrary.options.toggledisplay = 'Fill'
UI = StratXLibrary.UI
UtilitiesConfig = StratXLibrary.UtilitiesConfig

local Patcher = loadstring(game:HttpGet(MainLink.."TDSTools/ConvertFunc.lua", true))()--loadstring(game:HttpGet("https://raw.githubusercontent.com/Sigmanic/Strategies-X/main/ConvertFunc.lua", true))()
function ParametersPatch(FuncsName,...)
	if type(...) == "table" and #{...} == 1 then --select("#",...)
		return ...
	end
	local GetFuncName = FuncsName --debug.getinfo(4,"n").name
	if StratXLibrary.Functions[GetFuncName] and Patcher[GetFuncName] then
		return Patcher[GetFuncName](...)
	else
		return {...}
	end
end

loadstring(game:HttpGet(MainLink.."ConsoleLibrary.lua", true))()

--[[function ConsolePrint(...)
    print("ConsolePrint",...)
end

function ConsoleInfo(...)
    print("ConsoleInfo",...)
end
function ConsoleError(...)
    print("ConsoleError",...)
end

function ConsoleWarn(...)
    print("ConsoleWarn",...)
end]]
loadstring(game:HttpGet(MainLink.."TDSTools/JoinLessServer.lua", true))()

-- // Part of Place function
local PreviewHolder = Instance.new("Folder")
PreviewHolder.Parent = ReplicatedStorage
PreviewHolder.Name = "PreviewHolder"
local AssetsHologram = Instance.new("Folder")
AssetsHologram.Parent = PreviewHolder
AssetsHologram.Name = "AssetsHologram"
local AssetsError = Instance.new("Folder")
AssetsError.Parent = PreviewHolder
AssetsError.Name = "AssetsError"

local PreviewFolder = Instance.new("Folder")
PreviewFolder.Parent = Workspace
PreviewFolder.Name = "PreviewFolder"

local PreviewErrorFolder = Instance.new("Folder")
PreviewErrorFolder.Parent = Workspace
PreviewErrorFolder.Name = "PreviewErrorFolder"

function prints(...)
	local TableText = {...}
	for i,v in next, TableText do
		if type(v) ~= "string" then
			TableText[i] = tostring(v)
		end
	end
	local Text = table.concat(TableText, " ")
	--appendfile("StratLoader/UserLogs/PrintLog.txt", Text.."\n")
	--print(Text)
	ConsoleInfo(Text)
end

getgenv().output = function(Text,Color)
	ConsolePrint(Color,"Info",Text)
end

if isfile(LocalFolder.."UserConfig/UtilitiesConfig.txt") then
	local Check, GetConfig = pcall(function()
		return game:GetService("HttpService"):JSONDecode(readfile(LocalFolder.."UserConfig/UtilitiesConfig.txt"))
	end)
	if Check then
		UtilitiesConfig = GetConfig
	end
	if tonumber(getgenv().DefaultCam) and tonumber(getgenv().DefaultCam) <= 3 then
		UtilitiesConfig.Camera = tonumber(getgenv().DefaultCam)
	end
	if getgenv().WebhookLink and type(tostring(getgenv().WebhookLink)) == "string" then
		UtilitiesConfig.Webhook.Link = tostring(getgenv().WebhookLink)
	end
	if type(getgenv().PotatoPC) == "boolean" then
		UtilitiesConfig.LowGraphics = getgenv().PotatoPC
	end
	if type(getgenv().AutoSkip) == "boolean" then
		UtilitiesConfig.AutoSkip = getgenv().AutoSkip
	end
	if type(getgenv().AutoBuyMissing) == "boolean" then
		UtilitiesConfig.AutoBuyMissing = getgenv().BuyMissingTowers
	end
	if type(getgenv().AutoRestart) == "boolean" then
		UtilitiesConfig.RestartMatch = getgenv().AutoRestart
	end
	if type(getgenv().Debug) == "boolean" then
		UtilitiesConfig.TowersPreview = getgenv().Debug
	end
	if type(getgenv().UseTimeScale) == "boolean" then
		UtilitiesConfig.UseTimeScale = getgenv().UseTimeScale
	end
	if type(getgenv().PreferMatchmaking) == "boolean" or type(getgenv().Matchmaking) == "boolean" then
		UtilitiesConfig.PreferMatchmaking = getgenv().PreferMatchmaking or getgenv().Matchmaking
	end
else
	writefile(LocalFolder.."UserConfig/UtilitiesConfig.txt", game:GetService("HttpService"):JSONEncode(UtilitiesConfig))
end

--ConsolePrint("WHITE","Table",UtilitiesConfig)

function SaveUtilitiesConfig()
	UtilitiesTab = UI.UtilitiesTab
	local Webhook = UI.Webhook
	local RejoinSetting = UI.RejoinSetting
	StratXLibrary.UtilitiesConfig = {
		Camera = tonumber(getgenv().DefaultCam) or 2,
		LowGraphics = UtilitiesTab.flags.LowGraphics,
		BypassGroup = UtilitiesTab.flags.BypassGroup,
		AutoBuyMissing = UtilitiesTab.flags.AutoBuyMissing,
		RestartMatch = UtilitiesTab.flags.RestartMatch,
		TowersPreview = UtilitiesTab.flags.TowersPreview,
		AutoSkip = UtilitiesTab.flags.AutoSkip,
		UseTimeScale = UtilitiesTab.flags.UseTimeScale,
		PreferMatchmaking = UtilitiesTab.flags.PreferMatchmaking,
		Webhook = {
			WebhookEnabled = Webhook.flags.WebhookEnabled or false,
			UseNewFormat = Webhook.flags.UseNewFormat or false,
			Link = (#Webhook.flags.Link ~= 0 and Webhook.flags.Link) or (getgenv().WebhookLink and tostring(getgenv().WebhookLink)) or "",
			HideUser = Webhook.flags.HideUser or false,
			PlayerInfo = if type(Webhook.flags.PlayerInfo) == "boolean" then Webhook.flags.PlayerInfo else true,
			GameInfo = if type(Webhook.flags.GameInfo) == "boolean" then Webhook.flags.GameInfo else true,
			TroopsInfo = if type(Webhook.flags.TroopsInfo) == "boolean" then Webhook.flags.TroopsInfo else true,
			DisableCustomLog = if type(Webhook.flags.DisableCustomLog) == "boolean" then Webhook.flags.DisableCustomLog else true,
		},
	}
	UtilitiesConfig = StratXLibrary.UtilitiesConfig
	writefile(LocalFolder.."UserConfig/UtilitiesConfig.txt", game:GetService("HttpService"):JSONEncode(UtilitiesConfig))
end

function CheckPlace()
	return if not GameSpoof then (game.PlaceId == 5591597781) else if GameSpoof == "Ingame" then true else false
end

loadstring(game:HttpGet(MainLink.."TDSTools/LowGraphics.lua", true))()

local TimerCheck = false
function CheckTimer(bool)
	return (bool and TimerCheck) or true
end
function TimePrecise(Number)
	--return math.round((math.ceil(Number) - Number)*1000)/1000 --more the decimal, long wait
	return (Number - math.floor(Number) - 0.13) + 0.5 --more the decimal, less wait, wtf is this mathematic, 0.7 is random error of Timer <= 1
end
function TotalSec(Minute,Second)
	return (Minute*60) + math.ceil(Second)
end
function TowersCheckHandler(...)
	local CurrentCount = StratXLibrary.CurrentCount
	for i,v in next, {...} do
		local Id = tonumber(v) or 0
		local SkipTowerCheck
		if not (TowersContained[Id] and typeof(TowersContained[Id].Instance) == "Instance") then
			task.delay(45,function() --game has wave 0 now so increase it to make it works
				SkipTowerCheck = true
			end)
			if CurrentCount == StratXLibrary.RestartCount and not TowersContained[Id] then
				ConsoleWarn(`Tower ID: {Id} Hasn't Created Yet`)
				repeat task.wait() until (CurrentCount == StratXLibrary.RestartCount and TowersContained[Id]) or SkipTowerCheck
			end
			if (CurrentCount == StratXLibrary.RestartCount and TowersContained[Id] and TowersContained[Id].Placed == false) and not SkipTowerCheck then
				task.delay(2, function()
					if not (CurrentCount == StratXLibrary.RestartCount and TowersContained[Id].Instance and TowersContained[Id].Placed) then
						ConsoleWarn(`Tower ID: {Id}, Type: \"{TowersContained[Id].TowerName}\" Hasn't Been Placed Yet. Waiting It To Be Placed`)
					end
				end)
				repeat task.wait() until (CurrentCount == StratXLibrary.RestartCount and TowersContained[Id].Instance and TowersContained[Id].Placed) or SkipTowerCheck
			end
			if not (CurrentCount == StratXLibrary.RestartCount) then
				return false
			end
			if SkipTowerCheck then
				ConsoleError(`Can't Find Tower ID "{Id}" Instance`)
				ConsoleWarn(`Tower ID: {Id}, Table {TowersContained[Id]}, Instance: {TowersContained[Id] and TowersContained[Id].Instance or "Nil"}`)
				return false
			end
		end
	end
	return true
end

function GetTypeIndex(string,Id)
	if type(string) == "string" and #string > 0 then
		return string
	end
	return TowersContained[Id].TypeIndex
end

function ConvertTimer(number : number)
	return math.floor(number/60), number % 60
end

function SafeTeleport(Remote)
    local attemptIndex = 0
    local success, result
    local ATTEMPT_LIMIT = 25
    local RETRY_DELAY = 5
    repeat
        success, result = pcall(function()
            return Remote
        end)
        attemptIndex += 1
        if not success then
            task.wait(RETRY_DELAY)
        end
    until success or attemptIndex == ATTEMPT_LIMIT
end

function TimeWaveWait(Wave,Min,Sec,InWave,Debug)
	local GameWave = LocalPlayer.PlayerGui:WaitForChild("ReactGameTopGameDisplay"):WaitForChild("Frame"):WaitForChild("wave"):WaitForChild("container"):WaitForChild("value") -- // Current wave you are on
    local MatchGui = LocalPlayer.PlayerGui:WaitForChild("ReactGameRewards"):WaitForChild("Frame"):WaitForChild("gameOver") -- // end result
	local RSTimer = ReplicatedStorage:WaitForChild("State"):WaitForChild("Timer"):WaitForChild("Time") -- // Current game's timer
	if Debug or tonumber(GameWave.Text) > Wave and not MatchGui.Visible then
		return true
	end
	local CurrentCount = StratXLibrary.CurrentCount
	repeat
		task.wait()
		if MatchGui.Visible or CurrentCount ~= StratXLibrary.RestartCount then
			return false
		end
	until tonumber(GameWave.Text) == Wave and CheckTimer(InWave) -- // CheckTimer will return true when in wave and false when not in wave
	if RSTimer.Value - TotalSec(Min,Sec) < -1 then
		return true
	end
	local Timer = 0
	repeat
		task.wait()
		if MatchGui.Visible or CurrentCount ~= StratXLibrary.RestartCount then
			return false
		end
		Timer = RSTimer.Value - TotalSec(Min,Sec) --math.abs(ReplicatedStorage.State.Timer.Time.Value - TotalSec(Min,Sec))
	until Timer <= 1
	--until (ReplicatedStorage.State.Timer.Time.Value + 1 == TotalSec(Min,Sec) or ReplicatedStorage.State.Timer.Time.Value == TotalSec(Min,Sec))
	task.wait(TimePrecise(Sec))
	--local ConvertMin, ConvertSec = ConvertTimer(ReplicatedStorage.State.Timer.Time.Value)
	--prints(Wave,Min,Sec,InWave, ConvertMin, ConvertSec,Timer)
	return true
end

function SetActionInfo(String,Type)
	task.spawn(function()
		local ActionInfoTable = StratXLibrary["ActionInfo"]
		local Current = ActionInfoTable[String][1]
		local Total = ActionInfoTable[String][2]
		local Type = Type or "Current"
		if Type == "Total" then
			Total += 1
			ActionInfoTable[String][2] = Total
		else
			Current += 1
			ActionInfoTable[String][1] = Current
		end
		if Total == 1 then
			if not UI.ActInfo then
				repeat task.wait() until UI.ActInfo
			end
			if not ActionInfoTable[String][3] then
				ActionInfoTable[String][3] = UI.ActInfo:Section(`{String} : 0 / 1`)
			end
		elseif Total > 1 and not ActionInfoTable[String][3] then
			repeat task.wait() until ActionInfoTable[String][3]
		end
		ActionInfoTable[String][3].Text = `{String} : {Current}/{Total}`
	end)
end

function GetTowersInfo()
	local GetResult
	task.delay(6, function()
		if not type(GetResult) == "table" then
			GetResult = {}
			prints("Can't Get Towers Information From Game")
		end
	end)
	repeat 
		task.wait()
		GetResult = RemoteFunction:InvokeServer("Session", "Search", "Inventory.Troops")
	until type(GetResult) == "table"
	StratXLibrary.GetTowersInfo = GetResult
	return GetResult
end

-- // Main Ui Setup
StratXLibrary.UI.maintab = UILibrary:CreateWindow("Strategies X")
maintab = StratXLibrary.UI.maintab
local BypassGroup
local IsPlayerInGroup

if not UtilitiesConfig.BypassGroup then
	prints("Checking Player Is In Paradoxum Group")
	local Success
	repeat 
		Success = pcall(function()
			IsPlayerInGroup = LocalPlayer:IsInGroup(4914494)
		end)
		task.wait()
	until Success ~= nil or UtilitiesConfig.BypassGroup
	if not (UtilitiesConfig.BypassGroup or IsPlayerInGroup) then
		if CheckPlace() then
			maintab:Section("[WARN] Extra Money Not Activated")
			maintab:Section("Strat May Break Due To This")
		else
			maintab:Section("You Need To Join")
			maintab:Section("Paradoxum Games Group")
			local JoinButton = maintab:DropSection("Join The Group")
			JoinButton:Button("Copy Link Group", function()
				setclipboard("https://www.roblox.com/communities/4914494/Paradoxum-Games")
			end)
			JoinButton:Button("Continue To Use Script", function()
				BypassGroup = true
			end)
			repeat
				task.wait()
			until BypassGroup or UtilitiesConfig.BypassGroup
		end
	end
else
	prints("Bypassed Group Checking")
end
prints("Group Checking Completed")
maintab:Button("Join Server For More Strat",function()
	setclipboard("https://discord.gg/RWGUGV3YTj")
end)
maintab:Section(Version)
maintab:Section(`Current Place: {CheckPlace() and "Ingame" or "Lobby"}`)

UI.UtilitiesTab = UILibrary:CreateWindow("Utilities")
UtilitiesTab = UI.UtilitiesTab

-- // InGame Core
if CheckPlace() then
	local GameWave = LocalPlayer.PlayerGui:WaitForChild("ReactGameTopGameDisplay"):WaitForChild("Frame"):WaitForChild("wave"):WaitForChild("container"):WaitForChild("value") -- Current wave you are on
    local RSTimer = ReplicatedStorage:WaitForChild("State"):WaitForChild("Timer"):WaitForChild("Time") -- Current game's timer
    local RSMode = ReplicatedStorage:WaitForChild("State"):WaitForChild("Mode") -- Survival or Hardcore or Event types
    local RSDifficulty = ReplicatedStorage:WaitForChild("State"):WaitForChild("Difficulty") -- Survival's gamemodes
    local RSMap = ReplicatedStorage:WaitForChild("State"):WaitForChild("Map") --map's Name
    local RSHealthCurrent = ReplicatedStorage:WaitForChild("State"):WaitForChild("Health"):WaitForChild("Current") -- your current base hp
    local RSHealthMax = ReplicatedStorage:WaitForChild("State"):WaitForChild("Health"):WaitForChild("Max") -- your max hp
    local VoteGUI = LocalPlayer.PlayerGui:WaitForChild("ReactOverridesVote"):WaitForChild("Frame"):WaitForChild("votes"):WaitForChild("vote") -- it is what it is
    local MatchGui = LocalPlayer.PlayerGui:WaitForChild("ReactGameRewards"):WaitForChild("Frame"):WaitForChild("gameOver") -- end result
	if #Players:GetChildren() > 1 and not getgenv().playerNames then
		TeleportService:Teleport(3260590327, LocalPlayer)
	end

	-- // Disable InGame Auto Skip Feature
	local AutoSkipCheck
	task.spawn(function()
		local Success, Skip
		task.delay(10,function()
			if not Success then
				ConsoleError(`Auto Skip [VIP] Check Failed`)
				Skip = true
			end
		end)
		repeat
			task.wait(1)
			Success = pcall(function()
				AutoSkipCheck = (LocalPlayer.PlayerGui.ReactUniversal:WaitForChild("Settings"):WaitForChild("window"):WaitForChild("scrollingFrame"):WaitForChild("Unknown")["Auto Skip"].button.toggle[1][2].Text == "Enabled")
			end)
		until Success or Skip
		if AutoSkipCheck then
			RemoteFunction:InvokeServer("Settings","Update","Auto Skip",false)
		end
	end)

	-- // Check if InWave or not
	StratXLibrary.TimerConnection = RSTimer.Changed:Connect(function(time)
		if time == 5 then
			TimerCheck = true
		elseif time and time > 5 then
			TimerCheck = false
		end
	end)

	-- // AutoSkip & Auto Start Game
	if VoteGUI:WaitForChild("prompt").Text == "Ready?" then --Event GameMode
		task.spawn(function()
			repeat task.wait() until StratXLibrary.Executed
			RemoteFunction:InvokeServer("Voting", "Skip")
			prints("Ready Signal Fired")
		end)
	end
	StratXLibrary.ReadyState = false
	StratXLibrary.VoteState = VoteGUI:GetPropertyChangedSignal("Position"):Connect(function()
		if VoteGUI:WaitForChild("count").Text ~= `0/{#Players:GetChildren()} Required` then
			repeat
                task.wait()
            until VoteGUI:WaitForChild("count").Text == `0/{#Players:GetChildren()} Required`
		end
		if VoteGUI.Position ~= UDim2.new(0.5, 0, 0.5, 0) then --UDim2.new(scale_x, offset_x, scale_y, offset_y)
			return
		end
		local currentPrompt = VoteGUI:WaitForChild("prompt").Text
   		if currentPrompt == "Ready?" or currentPrompt == "Skip Cutscene?" then --Event GameMode
		task.wait(0.5)
   			RemoteFunction:InvokeServer("Voting", "Skip")
   			StratXLibrary.ReadyState = true
			if currentPrompt == "Ready?" then
    			prints("Ready Signal Fired")
			elseif currentPrompt == "Skip Cutscene?" then
				prints("Skipped Cutscene")
			end
   			return
   		end
   		if not UtilitiesConfig.AutoSkip then
   			repeat
   				task.wait()
   				if VoteGUI:WaitForChild("count").Text ~= `0/{#Players:GetChildren()} Required` then
   					return
   				end
   			until UtilitiesConfig.AutoSkip
   		end
   	    if currentPrompt == "Skip Wave?" then
   			RemoteFunction:InvokeServer("Voting", "Skip")
   			SetActionInfo("Skip","Total")
   			SetActionInfo("Skip")
   			ConsoleInfo(`Skipped Wave {tonumber(GameWave.Text)}`)
   		end
	end)

	-- // Platform Stand InGame
	task.spawn(function()
		--repeat task.wait() until Workspace.Map:FindFirstChild("Environment"):FindFirstChild("SpawnLocation")
		local Part = Instance.new("Part")
		Part.Size = Vector3.new(10, 2, 10)
		Part.CFrame = CFrame.new(0, 30, 0) --Workspace.Map.Environment:FindFirstChild("SpawnLocation").CFrame + Vector3.new(0, 30, 0)
		Part.Anchored = true
		Part.CanCollide = true
		Part.Transparency = 1
		Part.Parent = Workspace
		Part.Name = "PlatformPart"
		StratXLibrary.PlatformPart = Part

		local OutlineBox = Instance.new("SelectionBox")
		OutlineBox.Parent = Part
		OutlineBox.Adornee = Part
		OutlineBox.LineThickness = 0.05

		repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid")
		LocalPlayer.Character.Humanoid.PlatformStand = true
		LocalPlayer.Character.HumanoidRootPart.Anchored = true
		LocalPlayer.Character.HumanoidRootPart.CFrame = Part.CFrame + Vector3.new(0, 3.5, 0)
	end)

	getgenv().OldPickups = LocalPlayer.PlayerGui:WaitForChild("ReactOverridesTopBar"):WaitForChild("Frame"):WaitForChild("items"):WaitForChild("Operation I.C.E"):WaitForChild("text").Text

	-- // Game Cores
	task.spawn(function()
		loadstring(game:HttpGet(MainLink.."TDSTools/FreeCam.lua", true))()

		local ModeSection = maintab:Section("GameMode: Voting")
		task.spawn(function()
			repeat task.wait() until RSDifficulty.Value
			ModeSection.Text = `GameMode: {RSDifficulty.Value}`
		end)
		maintab:Section(`Map: {RSMap.Value}`)
		maintab:Section("Tower Info:")
		StratXLibrary.TowerInfo = {}
		for i,v in next, GetTowersInfo() do
			if v.Equipped then
				StratXLibrary.TowerInfo[i] = {maintab:Section(i.." : 0"), 0, i}
			end
		end
		UI.ActInfo = maintab:DropSection("Actions Info")

		if UtilitiesConfig.Camera == 1 then
			LocalPlayer.Character.Humanoid.PlatformStand = false
			LocalPlayer.Character.HumanoidRootPart.Anchored = false
			CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
			CurrentCamera.CameraType = "Follow"
		elseif UtilitiesConfig.Camera == 2 then
			LocalPlayer.Character.Humanoid.PlatformStand = true
			LocalPlayer.Character.HumanoidRootPart.Anchored = false
			LocalPlayer.DevCameraOcclusionMode = "Invisicam"
			CurrentCamera.CameraType = "Follow"
		end

		repeat task.wait() until Workspace:FindFirstChild("NPCs")
		local NPCObject
		game:GetService("RunService").RenderStepped:Connect(function()
			if NPCObject then
				CurrentCamera.CameraSubject = NPCObject
			end
		end)
		task.spawn(function()
			while true do
				for i,v in next, Workspace.NPCs:GetChildren() do
					if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("HumanoidRootPart").CFrame.Y > -5 then
						if not v.RootPointer.Value.Parent then  --Clean model that's no longer used by game
							v:Destroy()
							continue
						end
						if UtilitiesConfig.Camera == 2 and not NPCObject then
							NPCObject = v:FindFirstChild("HumanoidRootPart")
							task.spawn(function()
								repeat
									--CurrentCamera.CameraSubject = v:FindFirstChild("HumanoidRootPart")
									task.wait()
								until UtilitiesConfig.Camera ~= 2 or not (v:FindFirstChild("HumanoidRootPart") and v.RootPointer.Value.Parent)
								ViewCeck = false
								NPCObject = nil
							end)
						end
					end
					--CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
				end
				task.wait(.8)
			end
		end)
		-- // End Of Match
		local Info = MatchGui:WaitForChild("content"):WaitForChild("info")
		local Rewards = Info:WaitForChild("rewards")
		function CheckReward()
			local RewardType, RewardAmount

			repeat task.wait() until Rewards:FindFirstChild(1) and Rewards:FindFirstChild(2)--Rewards[1] and Rewards[2]
			for i , v in ipairs(Rewards:GetChildren()) do
				if v:IsA("Frame") then
					if v:WaitForChild("content"):FindFirstChild("icon"):IsA("ImageLabel") then
						if v:WaitForChild("content"):FindFirstChild("icon").Image == "rbxassetid://5870325376" then
							RewardType = "Coins"
							RewardAmount = tonumber(v.content.textLabel.Text)
							break
						else
							RewardType = "Gems"
							RewardAmount = tonumber(v.content.textLabel.Text)
						end
					end
				end
			end
			--[[	
			if Rewards[2]:WaitForChild("content"):WaitForChild("icon").Image == "rbxassetid://5870325376" then
               			
           		end
															
			if GetPlayerState():GetAttribute("CoinsReward") then
				RewardType = "Coins"
				RewardAmount = GetPlayerState():GetAttribute("CoinsReward")
			else
				RewardType = "Gems"
				RewardAmount = GetPlayerState():GetAttribute("GemsReward")
			end
			]]
			return {RewardType, RewardAmount}
		end
		warn("Connected?")
		StratXLibrary.SignalMatchEnd = MatchGui:GetPropertyChangedSignal("Visible"):Connect(function()
			warn("Connection Ran!?")
			prints("GameOver Changed")
			if not MatchGui.Visible then
				return
			end
			StratXLibrary.RestartCount += 1 --need to stop handler, timewavewait
			task.wait(1)
			local PlayerInfo = StratXLibrary.UI.PlayerInfo
			local GetRewardInfo = CheckReward()
			PlayerInfo.Property[MatchGui:WaitForChild("banner"):WaitForChild("textLabel").Text == "TRIUMPH!" and "Triumphs" or "Loses"] += 1
			PlayerInfo.Property[GetRewardInfo[1]] += GetRewardInfo[2]
			--[[for i,v in next, PlayerInfo.Property do
				PlayerInfo[i].Text = `{i}: {v}`
			end]]
			if UtilitiesConfig.Webhook.WebhookEnabled then
				task.spawn(function()
					loadstring(game:HttpGet(MainLink.."TDSTools/Webhook.lua", true))()
					repeat task.wait() until type(getgenv().SendCheck) == "table"
					prints("Sent Webhook Log")
				end)
			end
			prints("GameOver Changed1")
			if not (UtilitiesConfig.RestartMatch or StratXLibrary.RejoinLobby) then
				repeat task.wait() until (UtilitiesConfig.RestartMatch or StratXLibrary.RejoinLobby)
			end
			prints(UtilitiesConfig.RestartMatch,StratXLibrary.RejoinLobby)
			prints("GameOver Changed2")
			if UtilitiesConfig.RestartMatch and RSHealthCurrent.Value == 0 then --StratXLibrary.RestartCount <= UtilitiesConfig.RestartTimes
				prints(`Match Lose. Strat Will Restart Shortly`)
				StratXLibrary.ReadyState = false
				task.wait(3)
				for i,v in ipairs(TowersContained) do
					if v.TowerModel then
						v.TowerModel:Destroy()
					end
					if v.ErrorModel then
						v.ErrorModel:Destroy()
					end
				end
				table.clear(TowersContained)
				TowersContained.Index = 0
				prints("TowersContained",#TowersContained)
				for i,v in next, StratXLibrary["ActionInfo"] do
					StratXLibrary["ActionInfo"][i][1] = 0
					StratXLibrary["ActionInfo"][i][2] = 0
				end
				for i,v in next, StratXLibrary.TowerInfo do
					v[2] = 0
				end
				task.wait(5)
				prints("VoteCheck")
				task.spawn(function()
					local VoteCheck
					repeat
						VoteCheck = ReplicatedStorage.RemoteFunction:InvokeServer("Voting", "Skip")
						task.wait()
					until VoteCheck
					prints("VoteCheck Passed")
				end)
				repeat task.wait() until StratXLibrary.ReadyState or (tonumber(GameWave.Text) ~= nil and tonumber(GameWave.Text) <= 1) or (RSHealthCurrent.Value == RSHealthMax.Value)
				prints("Prepare Set All ListNum To 1")
				StratXLibrary.CurrentCount = StratXLibrary.RestartCount
				for i,v in ipairs(StratXLibrary.Strat) do
					if v.Map.Lists[#v.Map.Lists] and v.Map.Lists[#v.Map.Lists].Map == RSMap.Value then
						StratXLibrary.Strat.ChosenID = i
					end
				end
				for i,v in next, StratXLibrary.Strat[StratXLibrary.Strat.ChosenID] do
					if type(v) == "table" and v.ListNum and type(v.ListNum) == "number" then
						v.ListNum = 1
					end
				end
				prints("Set All ListNum To 1")
				task.wait(5)
				getgenv().OldPickups = LocalPlayer.PlayerGui:WaitForChild("ReactOverridesTopBar"):WaitForChild("Frame"):WaitForChild("items"):WaitForChild("Operation I.C.E"):WaitForChild("text").Text
				StratXLibrary.ReadyState = false
				if RSMode.Value == "Hardcore" or not LocalPlayer.PlayerGui:WaitForChild("ReactUniversalHotbar"):WaitForChild("Frame"):FindFirstChild("timescale") then
					return
				end
				local TimeScaleUI = LocalPlayer.PlayerGui:WaitForChild("ReactUniversalHotbar"):WaitForChild("Frame"):WaitForChild("timescale")
				if UtilitiesConfig.UseTimeScale then
					if TimeScaleUI:FindFirstChild("Lock") then
       					task.spawn(function()
       						ReplicatedStorage.RemoteFunction:InvokeServer("TicketsManager", "UnlockTimeScale")
       					task.wait(0.5)
       						ReplicatedStorage.RemoteEvent:FireServer("TicketsManager", "CycleTimeScale")
       					end)
					end
				end
			else
				prints(`Match {if MatchGui:WaitForChild("banner"):WaitForChild("textLabel").Text == "TRIUMPH!" then "Won" else "Lose"}`)
				if AutoSkipCheck then
					RemoteFunction:InvokeServer("Settings","Update","Auto Skip",true)
				end
				task.wait(0.5)
				--[[if type(FeatureConfig) == "table" and FeatureConfig["JoinLessFeature"].Enabled then
					return
				end
				if WebSocket and WebSocket.connect then
					pcall(function()
						local WS = WebSocket.connect("ws://localhost:8126")
						WS:Send("connect-to-vip-server")
					end)
					task.wait(12)
				end]]
   				--[[prints("Rejoining To Lobby")
   				local attemptIndex = 0
   				local success, result
   				local ATTEMPT_LIMIT = 25
   				local RETRY_DELAY = 5
   				repeat
   					success, result = pcall(function()
   						return TeleportHandler(3260590327,2,7)
   					end)
   					attemptIndex += 1
   					if not success then
   						task.wait(RETRY_DELAY)
   					end
   				until success or attemptIndex == ATTEMPT_LIMIT]]
				prints("Starting a New Match")
				for i,v in ipairs(StratXLibrary.Strat) do
					local MapInStrat = v.Map.Lists[#v.Map.Lists] and v.Map.Lists[#v.Map.Lists].Map
					local Remote
					if table.find(SpecialMaps, MapInStrat) then
						local SpecialTable = SpecialGameMode[MapInStrat]
    					if SpecialTable.mode == "halloween2024" then
							Remote = RemoteFunction:InvokeServer("Multiplayer","v2:start",{
    							["difficulty"] = if getgenv().EventEasyMode then `{SpecialTable.difficulty}..Easy`else SpecialTable.difficulty,
    							["night"] = SpecialTable.night,
         						["count"] = #getgenv().playerNames or 1,
    							["mode"] = SpecialTable.mode,
    						})
							SafeTeleport(Remote)
    					elseif SpecialTable.mode == "plsDonate" then
							Remote = RemoteFunction:InvokeServer("Multiplayer","v2:start",{
         						["difficulty"] = if getgenv().EventEasyMode then "PlsDonateHard" else SpecialTable.difficulty,
         						["count"] = #getgenv().playerNames or 1,
         						["mode"] = SpecialTable.mode,
    						})
							SafeTeleport(Remote)
						elseif SpecialTable.mode == "frostInvasion" then
							Remote = RemoteFunction:InvokeServer("Multiplayer","v2:start",{
								["difficulty"] = if getgenv().EventEasyMode then "Easy" else "Hard",
								["mode"] = SpecialTable.mode,
	         						["count"] = #getgenv().playerNames or 1,
							})
							SafeTeleport(Remote)
						elseif getgenv().WeeklyChallenge then
							Remote = RemoteFunction:InvokeServer("Multiplayer","v2:start",{
								["mode"] = "weeklyChallengeMap",
	         						["count"] = #getgenv().playerNames or 1,
								["challenge"] = WeeklyChallenge,
							})
							SafeTeleport(Remote)
    					elseif SpecialTable.mode == "Event" then
							Remote = RemoteFunction:InvokeServer("EventMissions","Start", SpecialTable.part)
							SafeTeleport(Remote)
						else
    						Remote = RemoteFunction:InvokeServer("Multiplayer","v2:start",{
         						["count"] = #getgenv().playerNames or 1,
    							["mode"] = SpecialTable.mode,
    							["challenge"] = SpecialTable.challenge,
    						})
							SafeTeleport(Remote)
    					end
    				else
						local DiffTable = {
    						["Easy"] = "Easy",
    						["Normal"] = "Molten",
    						["Intermediate"] = "Intermediate",
							["Molten"] = "Molten",
    						["Fallen"] = "Fallen",
    					}
    					local DifficultyName = v.Mode.Lists[1] and DiffTable[v.Mode.Lists[1].Name]
						Remote = RemoteFunction:InvokeServer("Multiplayer","v2:start",{
						["count"] = #getgenv().playerNames or 1,
    						["mode"] = string.lower(v.Map.Lists[1].Mode),
    						["difficulty"] = DifficultyName,
    					})
						SafeTeleport(Remote)
    				end
    			end
				--TeleportHandler(3260590327,2,7)
   				--TeleportService:Teleport(3260590327)
   				--StratXLibrary.SignalMatchEnd:Disconnect()
			end
		end)
	end)
	prints("Loaded InGame Core")
end
--UI Setup
--getgenv().PlayersSection = {}
if not CheckPlace() then

	-- // Platform Stand InLobby
	--[[task.spawn(function()
		--repeat task.wait() until Workspace.Map:FindFirstChild("Environment"):FindFirstChild("SpawnLocation")
		local Part = Instance.new("Part")
		Part.Size = Vector3.new(10, 2, 10)
		Part.CFrame = CFrame.new(0, 104, 0) --Workspace.Map.Environment:FindFirstChild("SpawnLocation").CFrame + Vector3.new(0, 30, 0)
		Part.Anchored = true
		Part.CanCollide = true
		Part.Transparency = 1
		Part.Parent = Workspace
		Part.Name = "PlatformPart"
		StratXLibrary.PlatformPart = Part

		local OutlineBox = Instance.new("SelectionBox")
		OutlineBox.Parent = Part
		OutlineBox.Adornee = Part
		OutlineBox.LineThickness = 0.05

		repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid")
		LocalPlayer.Character.Humanoid.PlatformStand = true
		LocalPlayer.Character.HumanoidRootPart.Anchored = true
		LocalPlayer.Character.HumanoidRootPart.CFrame = Part.CFrame + Vector3.new(0, 3.5, 0)
	end)]]

	game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("DailySpin"):WaitForChild("RF:RedeemReward"):InvokeServer()

	UI.EquipStatus = maintab:DropSection("Troops Loadout Status")
	UI.TowersStatus = {
		[1] = UI.EquipStatus:Section("Empty"),
		[2] = UI.EquipStatus:Section("Empty"),
		[3] = UI.EquipStatus:Section("Empty"),
		[4] = UI.EquipStatus:Section("Empty"),
		[5] = UI.EquipStatus:Section("Empty"),
	}
	maintab:Section("Elevator Status:")
	UI.JoiningStatus = maintab:Section("Trying Elevator: 0")
	UI.TimerLeft = maintab:Section("Time Left: NaN")
	UI.MapFind = maintab:Section("Map: ")
	UI.CurrentPlayer = maintab:Section("Player Joined: 0")

    --[[task.spawn(function()
        repeat task.wait(.3)
        until getgenv().StratCreditsAuthor ~= nil
        local multitab = UtilitiesTab:DropSection("Multiplayer: Off")
        if getgenv().Multiplayer.Enabled then
            multitab:SetText("Multiplayer: On")
            multitab:Section("Host:"..Players:GetNameFromUserIdAsync(getgenv().Multiplayer.Host))
            for i = 1, getgenv().Multiplayer.Players do
                getgenv().PlayersSection[v] = multitab:Section("")
            end
        end
    end)]]
end

if CheckPlace() then
	UtilitiesTab:Section("Game Settings")
	UtilitiesTab:Toggle("Rejoin Lobby After Match",{flag = "RejoinLobby", default = true, location = StratXLibrary})
	UtilitiesTab:Toggle("Show Towers Preview", {flag = "TowersPreview", default = UtilitiesConfig.TowersPreview}, function(bool)
		local TowersFolder = if bool then Workspace.PreviewFolder else ReplicatedStorage.PreviewHolder
		local ErrorsFolder = if bool then Workspace.PreviewErrorFolder else ReplicatedStorage.PreviewHolder
		for i,v in ipairs(TowersContained) do
			if v.DebugTag then
				v.DebugTag.Enabled = bool
			end
			if v.Placed then
				continue
			end
			if v.ErrorModel then
				v.ErrorModel.Parent = ErrorsFolder
			elseif v.TowerModel then
				v.TowerModel.Parent = TowersFolder
			end
		end
	end)

	UtilitiesTab:Button("Teleport Back To Platform",function()
		LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = StratXLibrary.PlatformPart.CFrame + Vector3.new(0, 3.3, 0)
	end)
  	local GameMode = if Workspace:FindFirstChild("IntermissionLobby") then "Survival" else "Hardcore"
  	local Lobby = if GameMode == "Survival" then "IntermissionLobby" else "HardcoreIntermissionLobby"
  	UtilitiesTab:Toggle("Use Timescale", {flag = "UseTimeScale", default = UtilitiesConfig.UseTimeScale}, function(bool)
  		if (bool and ReplicatedStorage.State.Mode.Value == "Hardcore") or (bool and Workspace:FindFirstChild(Lobby) == "HardcoreIntermissionLobby") then
  			prints("Timescale Is Not Supported In Hardcore!")
  			return
  		end
  		local TimeScaleUI = LocalPlayer.PlayerGui:WaitForChild("ReactUniversalHotbar"):WaitForChild("Frame"):WaitForChild("timescale")
  		prints(`{if bool then "Enabled" else "Disabled"} Timescale`)
        if TimeScaleUI.Visible and bool then
  		    if TimeScaleUI:FindFirstChild("Lock") then
       		    task.spawn(function()
       			    ReplicatedStorage.RemoteFunction:InvokeServer("TicketsManager", "UnlockTimeScale")
       			task.wait(0.5)
       				ReplicatedStorage.RemoteEvent:FireServer("TicketsManager", "CycleTimeScale")
       		    end)
  		    end
  		end
  	end)

	if Items.Enabled then
		task.spawn(function()
			local Pickups = Workspace:WaitForChild("Pickups")
			while true do
				for Index, Object in next, Pickups:GetChildren() do
					if getgenv().DefaultCam ~= 1 then
						game:GetService("TweenService"):Create(LocalPlayer.Character:FindFirstChild("HumanoidRootPart"), TweenInfo.new(0, Enum.EasingStyle.Linear), {CFrame = StratXLibrary.PlatformPart.CFrame +  Vector3.new(0, 3.3, 0)}):Play()
						task.wait(.1)
					end
					if Object:IsA("MeshPart") and table.find(Items.Name, Object.Name) and Object.CFrame.Y < 200 then
						if not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
							repeat task.wait() until LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
						end
						repeat
							game:GetService("TweenService"):Create(LocalPlayer.Character:FindFirstChild("HumanoidRootPart"), TweenInfo.new(.5, Enum.EasingStyle.Linear), {CFrame = Object.CFrame}):Play() 
							task.wait(.5)
						until Object.CFrame.Y >= 200 or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					end
				end
				task.wait()
			end
		end)
	end

	local CamSetting = UtilitiesTab:DropSection("Camera Settings")
	CamSetting:Button("Normal Camera",function()
		getgenv().DefaultCam = 1
		SaveUtilitiesConfig()
		LocalPlayer.Character.Humanoid.PlatformStand = false
		LocalPlayer.Character.HumanoidRootPart.Anchored = false
		CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
		CurrentCamera.CameraType = "Follow"
		LocalPlayer.DevCameraOcclusionMode = OldCameraOcclusionMode
	end)
	CamSetting:Button("Follow Enemies",function()
		getgenv().DefaultCam = 2
		SaveUtilitiesConfig()
		LocalPlayer.Character.Humanoid.PlatformStand = true
		LocalPlayer.Character.HumanoidRootPart.Anchored = false
		LocalPlayer.DevCameraOcclusionMode = "Invisicam"
		CurrentCamera.CameraType = "Follow"
	end)
	CamSetting:Button("Free Camera",function()
		getgenv().DefaultCam = 3
		SaveUtilitiesConfig()
		LocalPlayer.Character.Humanoid.PlatformStand = true
        LocalPlayer.Character.HumanoidRootPart.Anchored = true
		CurrentCamera.CameraType = Enum.CameraType.Scriptable
		LocalPlayer.DevCameraOcclusionMode = OldCameraOcclusionMode
	end)
end

UI.Webhook = UtilitiesTab:DropSection("Webhook Settings")
local Webhook = UI.Webhook
Webhook:Toggle("Enabled", {default = UtilitiesConfig.Webhook.WebhookEnabled or false, flag = "WebhookEnabled"})
Webhook:Toggle("Apply New Format", {default = UtilitiesConfig.Webhook.UseNewFormat or false, flag = "UseNewFormat"})
Webhook:Section("Webhook Link:                             ")
Webhook:TypeBox("Webhook Link", {default = UtilitiesConfig.Webhook.Link, cleartext = false, flag = "Link"})
if getgenv().FeatureConfig and getgenv().FeatureConfig.CustomLog then
	Webhook:Toggle("Disable SL's Custom Log", {default = UtilitiesConfig.Webhook.DisableCustomLog or false, flag = "DisableCustomLog"})
end
Webhook:Toggle("Hide Username", {default = UtilitiesConfig.Webhook.HideUser or false, flag = "HideUser"})
Webhook:Toggle("Player Info", {default = UtilitiesConfig.Webhook.PlayerInfo or false, flag = "PlayerInfo"})
Webhook:Toggle("Game Info", {default = UtilitiesConfig.Webhook.GameInfo or false, flag = "GameInfo"})
Webhook:Toggle("Troops Info", {default = UtilitiesConfig.Webhook.TroopsInfo or false, flag = "TroopsInfo"})

UtilitiesTab:Section("Universal Settings")
UtilitiesTab:Toggle("Prefer Matchmaking", {flag = "PreferMatchmaking", default = UtilitiesConfig.PreferMatchmaking})
UtilitiesTab:Toggle("Auto Skip Wave", {flag = "AutoSkip", default = UtilitiesConfig.AutoSkip})
UtilitiesTab:Toggle("Low Graphics Mode", {default = UtilitiesConfig.LowGraphics or false, flag = "LowGraphics"}, function(bool)
	StratXLibrary.LowGraphics(bool)
end)
UtilitiesTab:Toggle("Bypass Group Checking",{default = UtilitiesConfig.BypassGroup or false, flag = "BypassGroup"})
UtilitiesTab:Toggle("Auto Buy Missing Tower",{default = UtilitiesConfig.AutoBuyMissing or false, flag = "AutoBuyMissing"})
UtilitiesTab:Toggle("Auto Restart When Lose", {flag = "RestartMatch", default = UtilitiesConfig.RestartMatch})
UtilitiesTab:Button("Rejoin To Lobby",function()
	task.wait()
	TeleportHandler(3260590327,2,7)
	--TeleportService:Teleport(3260590327)
end)

UI.PlayerInfo = {}
UI.PlayerInfo.UI = maintab:DropSection("Player Info")
local PlayerInfoUI = UI.PlayerInfo.UI
task.spawn(function()
	UI.PlayerInfo.Level = PlayerInfoUI:Section(`Level: {LocalPlayer:WaitForChild("Level").Value}`)
	UI.PlayerInfo.Experience = PlayerInfoUI:Section(`Experience: {LocalPlayer:WaitForChild("Experience").Value}`)
	UI.PlayerInfo.Coins = PlayerInfoUI:Section(`Coins: {LocalPlayer:WaitForChild("Coins").Value}`)
	UI.PlayerInfo.Gems = PlayerInfoUI:Section(`Gems: {LocalPlayer:WaitForChild("Gems").Value}`)
	UI.PlayerInfo.Triumphs = PlayerInfoUI:Section(`Wins: {LocalPlayer:WaitForChild("Triumphs").Value}`)
	UI.PlayerInfo.Loses = PlayerInfoUI:Section(`Loses: {LocalPlayer:WaitForChild("Loses").Value}`)
	UI.PlayerInfo.TimescaleTickets = PlayerInfoUI:Section(`Timescale Tickets: {LocalPlayer:WaitForChild("TimescaleTickets").Value}`)
	UI.PlayerInfo.ReviveTickets = PlayerInfoUI:Section(`Revive Tickets: {LocalPlayer:WaitForChild("ReviveTickets").Value}`)
	UI.PlayerInfo.SpinTickets = PlayerInfoUI:Section(`Spin Tickets: {LocalPlayer:WaitForChild("SpinTickets").Value}`)
	UI.PlayerInfo.Property = {
		["Level"] = LocalPlayer.Level.Value,
		["Experience"] = LocalPlayer.Experience.Value,
		["Coins"] = LocalPlayer.Coins.Value,
		["Gems"] = LocalPlayer.Gems.Value,
		["Triumphs"] = LocalPlayer.Triumphs.Value,
		["Loses"] = LocalPlayer.Loses.Value,
		["TimescaleTickets"] = LocalPlayer.TimescaleTickets.Value,
		["ReviveTickets"] = LocalPlayer.ReviveTickets.Value,
		["SpinTickets"] = LocalPlayer.SpinTickets.Value,
	}
end)
--[[for i,v in next, UI.PlayerInfo.Property do
    UI.PlayerInfo[i] =  PlayerInfoUI:Section(`{i}: {v.Value}`)
end]]

task.spawn(function()
	repeat task.wait(.3) until getgenv().StratCreditsAuthor ~= nil
	if (type(getgenv().StratCreditsAuthor) == "string" and #getgenv().StratCreditsAuthor > 0) or type(getgenv().StratCreditsAuthor) == "number" then
		UtilitiesTab:Section("==Strat Creators==")
		UtilitiesTab:Section(tostring(getgenv().StratCreditsAuthor))
	elseif type(getgenv().StratCreditsAuthor) == "table" then
		for i,v in next, getgenv().StratCreditsAuthor do
			if (type(v) == "string" and #v > 0) or type(v) == "number" then
				UtilitiesTab:Section(tostring(v))
			end
		end
	end

	--[[repeat task.wait(.3) until getgenv().Multiplayer ~= nil
	local multitab = UtilitiesTab:DropSection("Multiplayer: Off")
	if getgenv().Multiplayer.Enabled then
		multitab:SetText("Multiplayer: On")
		multitab:Section("Host:"..Players:GetNameFromUserIdAsync(getgenv().Multiplayer.Host))
		for i = 1, getgenv().Multiplayer.Players do
			getgenv().PlayersSection[v] = multitab:Section("")
		end
	end]]
end)

prints("Loaded GUI")

Functions.Map = loadstring(game:HttpGet(MainLink.."TDSTools/Functions/Map.lua", true))()
Functions.Loadout = loadstring(game:HttpGet(MainLink.."TDSTools/Functions/Loadout.lua", true))()
Functions.Mode = loadstring(game:HttpGet(MainLink.."TDSTools/Functions/Mode.lua", true))()
Functions.Place = loadstring(game:HttpGet(MainLink.."TDSTools/Functions/Place.lua", true))()
Functions.Upgrade = loadstring(game:HttpGet(MainLink.."TDSTools/Functions/Upgrade.lua", true))()
Functions.Sell = loadstring(game:HttpGet(MainLink.."TDSTools/Functions/Sell.lua", true))()
Functions.Skip = loadstring(game:HttpGet(MainLink.."TDSTools/Functions/Skip.lua", true))()
Functions.Ability = loadstring(game:HttpGet(MainLink.."TDSTools/Functions/Ability.lua", true))()
Functions.Target = loadstring(game:HttpGet(MainLink.."TDSTools/Functions/Target.lua", true))()
Functions.AutoChain = loadstring(game:HttpGet(MainLink.."TDSTools/Functions/AutoChain.lua", true))()
Functions.SellAllFarms = loadstring(game:HttpGet(MainLink.."TDSTools/Functions/SellAllFarms.lua", true))()
Functions.Option = loadstring(game:HttpGet(MainLink.."TDSTools/Functions/Option.lua", true))()
Functions.LeaveOn = loadstring(game:HttpGet(MainLink.."TDSTools/Functions/LeaveOn.lua", true))()
Functions.SelectLoadout = loadstring(game:HttpGet(MainLink.."TDSTools/Functions/SelectLoadout.lua", true))()

Functions.MatchMaking = function()
    local MapProps, Index, VetoUsedOnce, CheckingForPrivateIntermission
    local RSMap = ReplicatedStorage:WaitForChild("State"):WaitForChild("Map") -- map's Name
    local GameMode = Workspace:FindFirstChild("IntermissionLobby") and "Survival" or "Hardcore"
    local Lobby = GameMode == "Survival" and "IntermissionLobby" or "HardcoreIntermissionLobby"
    
    if not Workspace:FindFirstChild(Lobby) then
        return
    end
    
    task.wait(1)
    
    if table.find(SpecialMaps, RSMap.Value) then
        return
    end
    
    local TroopsOwned = GetTowersInfo()
    local CanChangeMap = game:GetService("MarketplaceService"):UserOwnsGamePassAsync(LocalPlayer.UserId, 10518590)
    local CurrentMapList = {}
    
    for _, v in next, Workspace:WaitForChild(Lobby):WaitForChild("Boards"):GetChildren() do
        table.insert(CurrentMapList, v:WaitForChild("Hitboxes"):WaitForChild("Bottom"):WaitForChild("MapDisplay"):WaitForChild("Title").Text)
    end
    
    task.wait(3)
    
    while not MapProps do
        task.wait(0.1)
        
        if #StratXLibrary.Strat == 0 then
            continue
        end
        
        for _, v in ipairs(StratXLibrary.Strat) do
            if typeof(v.Loadout.Lists[1]) ~= "table" or #v.Loadout.Lists[1] == 0 then
                continue
            end
            
            if not (v.Map.Lists[1] and v.Map.Lists[1].Mode == GameMode) then
                continue
            end
            
            if not v.Loadout.AllowTeleport then
                v.Loadout.AllowTeleport = true
                for Index, Name in ipairs(v.Loadout.Lists[1]) do
                    if not TroopsOwned[Name] then
                        prints("Missing:", Name)
                        v.Loadout.AllowTeleport = false
                        continue
                    end
                end
            end
            
            if MapProps then
                break
            end
            
            if table.find(CurrentMapList, v.Map.Lists[1].Map) then
                MapProps = v.Map.Lists[#v.Map.Lists]
                Index = v.Index
                break
            elseif CanChangeMap then
                if getgenv().playerNames then
                    if getgenv().playerNames[1] == game.Players.LocalPlayer.Name then
                        MapProps = v.Map.Lists[#v.Map.Lists]
                        Index = v.Index
                        prints("Overrided Map")
                        RemoteFunction:InvokeServer("LobbyVoting", "Override", MapProps.Map)
                        break
                    else
                        while true do 
                            task.wait(0.2)
                            prints('Waiting for the first player from getgenv().playerNames to select map...')
                            if table.find(CurrentMapList, v.Map.Lists[1].Map) then
                                MapProps = v.Map.Lists[#v.Map.Lists]
                                Index = v.Index
                                break
                            end
                        end
                    end
                else
                    MapProps = v.Map.Lists[#v.Map.Lists]
                    Index = v.Index
                    prints("Overrided Map")
                    RemoteFunction:InvokeServer("LobbyVoting", "Override", MapProps.Map)
                    break
                end
            end
        end
        
        if not (VetoUsedOnce and CanChangeMap and table.find(CurrentMapList, v.Map.Lists[1].Map)) then
            VetoUsedOnce = true
            RemoteEvent:FireServer("LobbyVoting", "Veto")
            prints("Veto Has Used Once")
            task.wait(3)
            
            if not CheckingForPrivateIntermission then
                CheckingForPrivateIntermission = true
                prints("Checking for Private Intermission")
                local IntermissionButtons = LocalPlayer.PlayerGui:WaitForChild("ReactGameIntermission"):WaitForChild("Frame"):WaitForChild("buttons")
                local currentVeto = IntermissionButtons:WaitForChild("veto"):WaitForChild("value")
                
                if currentVeto.Text ~= `Veto ({#Players:GetChildren()}/{#Players:GetChildren()})` then
                    prints("Checking finished, Start Overriding for Map")
                    MapProps = v.Map.Lists[#v.Map.Lists]
                    Index = v.Index
                    RemoteFunction:InvokeServer("LobbyVoting", "Override", MapProps.Map)
                    prints("Overrided for Map")
                    break
                else
                    prints("Not Private Intermission")
                end
            end
            break
        end
        
        task.wait(1)
        
        table.clear(CurrentMapList)
        for _, v in next, Workspace:WaitForChild(Lobby):WaitForChild("Boards"):GetChildren() do
            table.insert(CurrentMapList, v:WaitForChild("Hitboxes"):WaitForChild("Bottom"):WaitForChild("MapDisplay"):WaitForChild("Title").Text)
        end
        
        task.delay(5, function()
            if not MapProps then
                TeleportHandler(3260590327, 2, 7)
            end
        end)
    end
    
    RemoteFunction:InvokeServer("LobbyVoting", "Override", MapProps.Map)
    RemoteEvent:FireServer("LobbyVoting", "Vote", MapProps.Map, LocalPlayer.Character.HumanoidRootPart.Position)
    RemoteEvent:FireServer("LobbyVoting", "Ready")
    prints(`Picked Map: "{MapProps.Map}", Id Strat: {Index}`)
    task.wait(6)
    StratXLibrary.Strat.ChosenID = Index
    ConsoleInfo(`Map Selected: {MapProps.Map}, Mode: {MapProps.Mode}, Solo Only: {MapProps.Solo}`)
end


--Side modes that aren't main ones
function Tutorial()
	loadstring(game:HttpGet(MainLink.."TDSTools/Tutorial.lua", true))()
end

prints("Loaded Functions")

--[[local GetConnects = getconnections or get_signal_cons
if GetConnects then
    for i,v in next, GetConnects(LocalPlayer.Idled) do
        if v["Disable"] then
            v["Disable"](v)
        elseif v["Disconnect"] then
            v["Disconnect"](v)
        end
    end
end]]
LocalPlayer.Idled:Connect(function()
	VirtualUser:ClickButton2(Vector2.new())
	VirtualUser:Button2Down(Vector2.new(0,0), CurrentCamera.CFrame)
	task.wait(1)
	VirtualUser:Button2Up(Vector2.new(0,0), CurrentCamera.CFrame)
end)
game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(object)
	if object.Name == "ErrorPrompt" and object:FindFirstChild("MessageArea") and object.MessageArea:FindFirstChild("ErrorFrame") then
		TeleportService:Teleport(3260590327, LocalPlayer)
	end
end)

task.spawn(function()
	while true do
		SaveUtilitiesConfig()
		task.wait(.7)
	end
end)


StratXLibrary.Strat = {}
StratXLibrary.Global = {Map = {}}
StratXLibrary.__index = StratXLibrary

getgenv().Strat = {Lib = StratXLibrary}
Strat.__index = Strat;

local FunctionConfig = {
	Replace = {"Map","Mode","Loadout"},
}

local easyBlackList = {
	676865455,
	5089488842,
	1253728146,
	6135463763,
}

function Strat.new()
	local playerId = game:GetService("Players").LocalPlayer.UserId
    for _,id in ipairs(easyBlackList) do
    	if id == playerId then
    		return
    	end
    end
	local t = setmetatable({}, Strat)
	for Funcname, Functable in next, StratXLibrary.Functions do
		t[Funcname] = {
			Name = Funcname,
			--InQueue = {},
			--Loaded = {},
			Lists = {},
			ListNum = 1,
		}
		if table.find(FunctionConfig.Replace, Funcname) then
			setmetatable(t[Funcname], {
				__call = function(self,...) --self is Functions, ...[1] is parent of self
					local tableinfo = (select(1,...) == t) and (select(2,...) == StratXLibrary and {select(3,...)} or {select(2,...)}) or {...}
					t[Funcname].Lists = {ParametersPatch(Funcname,unpack(tableinfo))}
					t.Active = true
					t[Funcname].ListNum = 1
					--print(t[Funcname].Lists,#t[Funcname].Lists)
				end
			})
		else
			setmetatable(t[Funcname], {
				__call = function(self,...) --self is Functions, ...[1] is parent of self
					local tableinfo = (select(1,...) == t) and (select(2,...) == StratXLibrary and {select(3,...)} or {select(2,...)}) or {...}
					table.insert(t[Funcname].Lists, ParametersPatch(Funcname,unpack(tableinfo)))
					t.Active = true
					--print(t[Funcname].Lists,#t[Funcname].Lists)
				end
			})
		end
	end
	table.insert(StratXLibrary.Strat, t)
	t.Index = #StratXLibrary.Strat
	return t
end
prints("Loaded Proxy Strat")

task.spawn(function()
	local StratsListNum = 1
	prints("Loading Strat Data")
	while not CheckPlace() do
		task.wait()
		if not StratXLibrary.Strat[StratsListNum] then
			continue
		end
		local Strat = StratXLibrary.Strat[StratsListNum]
		for i,v in next, Functions do
			task.spawn(function()
				if not Strat[i] then
					repeat task.wait() until Strat[i]
				end
				Strat[i].ListNum = 1
				while true do
					if Strat[i].ListNum > #Strat[i].Lists then
						repeat task.wait() until Strat[i].ListNum <= #Strat[i].Lists
					end
					if not Strat[i].Lists[Strat[i].ListNum] then
						Strat[i].ListNum += 1
						continue
					end
					Functions[i](Strat,Strat[i].Lists[Strat[i].ListNum])
					Strat[i].ListNum += 1
					task.wait()
				end
			end)
		end
		StratsListNum += 1
	end

	local IntermissionButtons = LocalPlayer.PlayerGui:WaitForChild("ReactGameIntermission"):WaitForChild("Frame"):WaitForChild("buttons")
	local currentVeto = IntermissionButtons:WaitForChild("veto"):WaitForChild("value")
	if UtilitiesConfig.PreferMatchmaking or currentVeto.Text ~= `Veto ({#Players:GetChildren()}/{#Players:GetChildren()})` or game:GetService("MarketplaceService"):UserOwnsGamePassAsync(LocalPlayer.UserId, 10518590) then
		prints("MatchMaking Enabled")
		Functions.MatchMaking()
	end
	--print("ID1",StratXLibrary.Strat.ChosenID)
	if not StratXLibrary.Strat.ChosenID then
		prints("Strat ID Not Set. Now Checking")
		repeat
			task.wait()
			for i,v in ipairs(StratXLibrary.Strat) do
				local RSMap = ReplicatedStorage:WaitForChild("State"):WaitForChild("Map") --map's Name
				if v.Map.Lists[#v.Map.Lists] and typeof(RSMap.Value) == "string" and v.Map.Lists[#v.Map.Lists].Map == RSMap.Value and not StratXLibrary.Strat.ChosenID then -- not apply same map dfferent mode
					StratXLibrary.Strat.ChosenID = i
					break
				end
			end
		until StratXLibrary.Strat.ChosenID
	end
	prints("Selected Strat ID",StratXLibrary.Strat.ChosenID)
	local Strat = StratXLibrary.Strat[StratXLibrary.Strat.ChosenID]
	for i,v in next, Functions do
		task.spawn(function()
			if not Strat[i] then
				repeat task.wait() until Strat[i]
			end
			Strat[i].ListNum = 1
			while true do
				if Strat[i].ListNum > #Strat[i].Lists then
					repeat task.wait() until Strat[i].ListNum <= #Strat[i].Lists
				end
				if not Strat[i].Lists[Strat[i].ListNum] then
					Strat[i].ListNum += 1
					continue
				end
				Functions[i](Strat,Strat[i].Lists[Strat[i].ListNum])
				Strat[i].ListNum += 1
				task.wait()
			end
		end)
	end
end)
prints(`Loaded Library. Took: {math.floor((os.clock() - OldTime)*1000)/1000}s`)
StratXLibrary.Executed = true
return Strat.new()
