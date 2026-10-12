local GreatVaultList = LibStub("AceAddon-3.0"):GetAddon("GreatVaultList")
local BlizzMoveAPI = _G.BlizzMoveAPI

function GreatVaultList:BlizzMove()
    if BlizzMoveAPI then 
		GreatVaultListFrame.Drag:Hide()
		BlizzMoveAPI:RegisterAddOnFrames({
			["GreatVaultList"] = { 
				["GreatVaultListFrame"] = {}
			},
		});
	else
		GreatVaultListFrame:SetScale(GreatVaultList.db.global.Options.scale)
	end
end


function GreatVaultList:addWeeklyRewardFrame()
	if BlizzMoveAPI then 
		BlizzMoveAPI:RegisterAddOnFrames({
			["GreatVaultList"] = { 
				["GreatVaultListFrame"] = {},
				["WeeklyRewardsRemoteFrame"] = {}
			},
		});
	else
		WeeklyRewardsRemoteFrameTemplate:SetScale(GreatVaultList.db.global.Options.scale)
	end

end
