local YES,NO,yes,no = true,false,true,false
return {
	enable = YES,
	buff = {
		show = YES,
		left = 10,
		top  = 22,
		maxFPS = 30,
		size = 70, -- ignored by vanilla style
		gap = 10,
		align = 1, -- 1:left 2:center 3:right
		style = 2, -- 1:PocoHud style 2:Vanilla style
	},
	popup = {
		show = YES,
		size = 20,
		damageDecay = 10,
		myDamage = YES,
		crewDamage = YES,
		AIDamage = YES,
		handsUp = YES,
		dominated = YES,
	},
	float = {
		show = YES,
		border = NO,
		size = 15,
		margin = 3,
		keepOnScreen = YES,
		keepOnScreenMargin = {2,15}, -- Margin Percent
		maxOpacity = 0.9,
		unit = YES,
		drills = YES,
	},
	info = {
		size = 14,
		clock = YES,
	},
	minion = {
		show = YES
	},
	chat = {
		readThreshold = 2,
		serverSendThreshold = 3,
		clientSendThreshold = 5,
		midgameAnnounce = 50,
		index = {
			midStat = 3,
			endStat = 4,
			dominated = 4,
			converted = 4,
			minionLost = 4,
			minionShot = 4,
			hostageChanged = 1,
			outofAmmo = 4,
			custody = 5,
			downed = 2,
			downedWarning = 5,
			replenished = 5,
		}
	},
}