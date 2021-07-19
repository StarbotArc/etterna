function getPlayerOptionsList(itemSet)
	local Items = {
		["Main"] = "Speed,RateList,NoteSk,PRAC,DownSc,Center,Persp,LC,BG,SF,Background,Judge,Life,Fail,Score",
		["Theme"] = "CG,CBHL,JT,CT,DP,TT,TG,TTM,JC,EB,EBC,PI,FBP,FB,MB,LEADB,NPS",
		["Effect"] = "Persp,App,GHO,SHO,Acc,Hide,Effect1,Effect2,Scroll,Turn,Insert,R1,R2,Holds,Mines"
	}
	return Items[itemSet] .. ",NextScr"
end
