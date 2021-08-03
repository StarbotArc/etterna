local defaultGameplayCoordinates = {
	JudgeX = 0,
	JudgeY = 0,
	ComboX = 30,
	ComboY = -20,
	ErrorBarX = SCREEN_CENTER_X,
	ErrorBarY = SCREEN_CENTER_Y + 53,
	TargetTrackerX = SCREEN_CENTER_X + 26,
	TargetTrackerY = SCREEN_CENTER_Y + 25,
	MiniProgressBarX = SCREEN_CENTER_X + 44,
	MiniProgressBarY = SCREEN_CENTER_Y + 34,
	FullProgressBarX = SCREEN_CENTER_X,
	FullProgressBarY = 20,
	JudgeCounterX = SCREEN_CENTER_X / 2,
	JudgeCounterY = SCREEN_CENTER_Y,
	DisplayPercentX = SCREEN_CENTER_X / 2 + 60/2, -- above the judge counter, middle of it
	DisplayPercentY = SCREEN_CENTER_Y - 60,
	DisplayMeanX = SCREEN_CENTER_X / 2 + 60/2, -- below the judge counter, middle of it
	DisplayMeanY = SCREEN_CENTER_Y + 50,
	NPSDisplayX = 5,
	NPSDisplayY = SCREEN_BOTTOM - 170,
	NPSGraphX = 0,
	NPSGraphY = SCREEN_BOTTOM - 160,
	NotefieldX = 0,
	NotefieldY = 0,
	ProgressBarPos = 1,
	LeaderboardX = 0,
	LeaderboardY = SCREEN_HEIGHT / 10,
	ReplayButtonsX = SCREEN_WIDTH - 45,
	ReplayButtonsY = SCREEN_HEIGHT / 2 - 100,
	LifeP1X = 178,
	LifeP1Y = 10,
	LifeP1Rotation = 0,
	PracticeCDGraphX = 10,
	PracticeCDGraphY = 85,
	BPMTextX = SCREEN_CENTER_X,
	BPMTextY = SCREEN_BOTTOM - 20,
	MusicRateX = SCREEN_CENTER_X,
	MusicRateY = SCREEN_BOTTOM - 10
}

local defaultGameplaySizes = {
	JudgeZoom = 1.0,
	ComboZoom = 0.6,
	ErrorBarWidth = 240,
	ErrorBarHeight = 10,
	TargetTrackerZoom = 0.4,
	FullProgressBarWidth = 1.0,
	FullProgressBarHeight = 1.0,
	DisplayPercentZoom = 1,
	DisplayMeanZoom = 1,
	NPSDisplayZoom = 0.5,
	NPSGraphWidth = 1.0,
	NPSGraphHeight = 1.0,
	NotefieldWidth = 1.0,
	NotefieldHeight = 1.0,
	NotefieldSpacing = 0.0,
	LeaderboardWidth = 1.0,
	LeaderboardHeight = 1.0,
	LeaderboardSpacing = 0.0,
	ReplayButtonsZoom = 1.0,
	ReplayButtonsSpacing = 0.0,
	LifeP1Width = 1.0,
	LifeP1Height = 1.0,
	PracticeCDGraphWidth = 0.8,
	PracticeCDGraphHeight = 1,
	MusicRateZoom = 1.0,
	BPMTextZoom = 1.0
}

local defaultConfig = {
	BPMDisplay = true,
	DisplayPercent = true,
	ErrorBar = 1,
	FullProgressBar = true,
	JudgeCounter = true,
	LaneCover = 0, -- soon to be changed to: 0=off, 1=sudden, 2=hidden
	-- leaderboard
	DisplayMean = true,
	MeasureCounter = true,
	MiniProgressBar = true,
	NPSDisplay = true,
	NPSGraph = true,
	PlayerInfo = true,
	RateDisplay = true,
	TargetTracker = true,

	JudgmentText = true,
	ComboText = true,
	CBHighlight = true,

	ConvertedAspectRatio = false, -- defaults false so that we can load and convert element positions, then set true
	CurrentHeight = SCREEN_HEIGHT,
	CurrentWidth = SCREEN_WIDTH,

	ScreenFilter = 1,
	JudgeType = 1,
	AvgScoreType = 0,
	GhostScoreType = 1,
	TargetGoal = 93,
	TargetTrackerMode = 0,
	leaderboardEnabled = false,
	LaneCoverHeight = 10,
	ReceptorSize = 100,
	ErrorBarCount = 30,
	BackgroundType = 1,
	UserName = "",
	PasswordToken = "",
	CustomizeGameplay = false,
	PracticeMode = false,
	GameplayXYCoordinates = {
		["3K"] = DeepCopy(defaultGameplayCoordinates),
		["4K"] = DeepCopy(defaultGameplayCoordinates),
		["5K"] = DeepCopy(defaultGameplayCoordinates),
		["6K"] = DeepCopy(defaultGameplayCoordinates),
		["7K"] = DeepCopy(defaultGameplayCoordinates),
		["8K"] = DeepCopy(defaultGameplayCoordinates),
		["9K"] = DeepCopy(defaultGameplayCoordinates),
		["10K"] = DeepCopy(defaultGameplayCoordinates),
		["12K"] = DeepCopy(defaultGameplayCoordinates),
		["16K"] = DeepCopy(defaultGameplayCoordinates)
	},
	GameplaySizes = {
		["3K"] = DeepCopy(defaultGameplaySizes),
		["4K"] = DeepCopy(defaultGameplaySizes),
		["5K"] = DeepCopy(defaultGameplaySizes),
		["6K"] = DeepCopy(defaultGameplaySizes),
		["7K"] = DeepCopy(defaultGameplaySizes),
		["8K"] = DeepCopy(defaultGameplaySizes),
		["9K"] = DeepCopy(defaultGameplaySizes),
		["10K"] = DeepCopy(defaultGameplaySizes),
		["12K"] = DeepCopy(defaultGameplaySizes),
		["16K"] = DeepCopy(defaultGameplaySizes)
	}
}

function getDefaultGameplaySize(obj)
	return defaultGameplaySizes[obj]
end

function getDefaultGameplayCoordinate(obj)
	return defaultGameplayCoordinates[obj]
end

playerConfig = create_setting("playerConfig", "playerConfig.lua", defaultConfig, -1)
local convertXPosRatio = 1
local convertYPosRatio = 1
local tmp2 = playerConfig.load
playerConfig.load = function(self, slot)
	local tmp = force_table_elements_to_match_type
	force_table_elements_to_match_type = function()
	end
	local x = create_setting("playerConfig", "playerConfig.lua", {}, -1)
	x = x:load(slot)

	-- aspect ratio is not the same. we must account for this
	if x.GameplayXYCoordinates ~= nil and (not x.ConvertedAspectRatio or x.CurrentHeight ~= defaultConfig.CurrentHeight or x.CurrentWidth ~= defaultConfig.CurrentWidth) then
		x.ConvertedAspectRatio = true
		defaultConfig.ConvertedAspectRatio = true

		-- set up a default 16:9 480p (all themes that use playerConfig use this, Til' Death and spawncamping-wallhack)
		-- i realize this is not 16:9 but promise, this is correct according to how the game works
		-- no further explanation
		if not x.CurrentHeight then
			x.CurrentHeight = 480
		end
		if not x.CurrentWidth then
			x.CurrentWidth = 854
		end

		--[[
			OTHER VALUES FOR THE WEIRDOS THAT USE THEM: IM NOT GONNA BOTHER ACCOMODATING YOU ANY FURTHER THAN THIS
			(all HEIGHT values are 480)
			(if your height value is not 480, you know how to generate these numbers - stop looking at them, they are not correct for you)
				4:3 - WIDTH: 640
				16:10 - WIDTH: 768
				21:9 - WIDTH: 1120
				8:3 - WIDTH: 1280
				5:4 - WIDTH: 600
				1:1 - WIDTH: 480
				3:4 - WIDTH: 360
			USE A CUSTOM DisplayAspectRatio PREFERENCE? FIGURE IT OUT YOURSELF
			HINT: IT ISN'T 480 x DisplayAspectRatio (look in ScreenDimensions.cpp)
			ms.ok(SCREEN_WIDTH .. " " .. SCREEN_HEIGHT)
		]]

		convertXPosRatio = x.CurrentWidth / defaultConfig.CurrentWidth
		convertYPosRatio = x.CurrentHeight / defaultConfig.CurrentHeight
	end

	--------
	-- converts single 4k setup to the multi keymode setup (compatibility with very old customize gameplay versions)
	local coords = x.GameplayXYCoordinates
	local sizes = x.GameplaySizes
	if sizes and not sizes["4K"] then
		defaultConfig.GameplaySizes["3K"] = sizes
		defaultConfig.GameplaySizes["4K"] = sizes
		defaultConfig.GameplaySizes["5K"] = sizes
		defaultConfig.GameplaySizes["6K"] = sizes
		defaultConfig.GameplaySizes["7K"] = sizes
		defaultConfig.GameplaySizes["8K"] = sizes
		defaultConfig.GameplaySizes["9K"] = sizes
		defaultConfig.GameplaySizes["10K"] = sizes
		defaultConfig.GameplaySizes["12K"] = sizes
		defaultConfig.GameplaySizes["16K"] = sizes
	end
	if coords and not coords["4K"] then
		defaultConfig.GameplayXYCoordinates["3K"] = coords
		defaultConfig.GameplayXYCoordinates["4K"] = coords
		defaultConfig.GameplayXYCoordinates["5K"] = coords
		defaultConfig.GameplayXYCoordinates["6K"] = coords
		defaultConfig.GameplayXYCoordinates["7K"] = coords
		defaultConfig.GameplayXYCoordinates["8K"] = coords
		defaultConfig.GameplayXYCoordinates["9K"] = coords
		defaultConfig.GameplayXYCoordinates["10K"] = coords
		defaultConfig.GameplayXYCoordinates["12K"] = coords
		defaultConfig.GameplayXYCoordinates["16K"] = coords
	end
	--
	--------
	force_table_elements_to_match_type = tmp
	return tmp2(self, slot)
end
playerConfig:load()

-- converting coordinates if aspect ratio changes across loads
local coords = playerConfig:get_data().GameplayXYCoordinates
if coords and coords["4K"] then
	-- converting all categories individually
	for cat, t in pairs(playerConfig:get_data().GameplayXYCoordinates) do
		for e, v in pairs(t) do
			-- dont scale defaulted coordinates
			if defaultGameplayCoordinates[e] ~= nil and v ~= defaultGameplayCoordinates[e] then
				if e:sub(-1) == "Y" then
					-- convert y pos
					t[e] = v / convertYPosRatio
				elseif e:sub(-1) == "X" then
					-- convert x pos
					t[e] = v / convertXPosRatio
				end
			end
		end
	end
	playerConfig:get_data().ConvertedAspectRatio = true
end