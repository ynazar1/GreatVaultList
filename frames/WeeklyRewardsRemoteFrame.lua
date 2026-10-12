local GreatVaultList = LibStub("AceAddon-3.0"):GetAddon("GreatVaultList")
local L, _ = GreatVaultList:GetLibs()
local LibGearData = LibStub("LibGearData-1.0")

local RemoteMixin = {};
GreatVaultListWeeklyRewardsRemoteMixin = RemoteMixin


local WEEKLY_REWARDS_EVENTS = {
	"WEEKLY_REWARDS_UPDATE",
	"CHALLENGE_MODE_COMPLETED",
	"CHALLENGE_MODE_MAPS_UPDATE",
};


local function getUnitColor(playerClass)
    return (type(_G.CUSTOM_CLASS_COLORS) == "table") and _G.CUSTOM_CLASS_COLORS[playerClass] or _G.RAID_CLASS_COLORS[playerClass]
end

function RemoteMixin:show(data)
    if not data.activitiesData then 
        PlaySound(1203);
        UIErrorsFrame:AddMessage("Data missing.Log in on that character.", RED_FONT_COLOR:GetRGBA());
        return
    end

    self.charName =  data.name
    if GreatVaultList.db.global.Options.columns.character.useClassColors and data.class then
        self.charName =  getUnitColor(data.class):WrapTextInColorCode(data.name)
    end
    self.ActivitiesData =  data.activitiesData
    self.hasAvailableRewards = (data.vaultstatus == "collect")
    self.canClaimRewards = (not data.vaultstatus == "collect")

    ShowUIPanel(WeeklyRewardsRemoteFrame) 
end


function RemoteMixin:OnLoad()
    self.Activities =  C_WeeklyRewards.GetActivities();


    self.Activities = _.map(self.Activities, function(entry)
        entry.id = nil
        entry.type = nil
    end)

    WeeklyRewardsFrame.SetUpActivity(self, self.RaidFrame, RAIDS, "evergreen-weeklyrewards-category-raids", Enum.WeeklyRewardChestThresholdType.Raid);
	WeeklyRewardsFrame.SetUpActivity(self, self.MythicFrame, DUNGEONS, "evergreen-weeklyrewards-category-dungeons", Enum.WeeklyRewardChestThresholdType.Activities);
	WeeklyRewardsFrame.SetUpActivity(self, self.WorldFrame, WORLD, "evergreen-weeklyrewards-category-world", Enum.WeeklyRewardChestThresholdType.World);
  
    local attributes =
	{
        area = "center",
		pushable = 0,
		allowOtherPanels = 1,
		checkFit = 0,
	};
    
	RegisterUIPanel(WeeklyRewardsRemoteFrame, attributes);
end



function RemoteMixin:OnShow()
    PlaySound(SOUNDKIT.UI_WEEKLY_REWARD_OPEN_WINDOW);
    FrameUtil.RegisterFrameForEvents(self, WEEKLY_REWARDS_EVENTS);
    self:FullRefresh();
end

function RemoteMixin:OnHide()
    PlaySound(SOUNDKIT.UI_WEEKLY_REWARD_CLOSE_WINDOW);
    FrameUtil.UnregisterFrameForEvents(self, WEEKLY_REWARDS_EVENTS);
end

function RemoteMixin:OnEvent()
    HideUIPanel(WeeklyRewardsRemoteFrame)
end


function RemoteMixin:FullRefresh()
	self:Refresh();
end

function RemoteMixin:Refresh()
    self.HeaderFrame.Text:SetText(self.charName);
	local canClaimRewards = self.canClaimRewards;


	local activities = self.ActivitiesData;
	for i, activityInfo in ipairs(activities) do
		local frame = self:GetActivityFrame(activityInfo.type, activityInfo.index);
		if frame then
			-- hide current progress for current week if rewards are present
			if canClaimRewards and #activityInfo.rewards == 0 then
				activityInfo.progress = 0;
			end

            frame.UnselectedFrame:Hide()
            frame.SelectedTexture:Hide();

            function frame:ShowPreviewItemTooltip()
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -7, -11);
                GameTooltip_SetTitle(GameTooltip, WEEKLY_REWARDS_CURRENT_REWARD);
                
                if _.size(self.info.tooltip) > 0 then 
                    _.forEach(self.info.tooltip, function(entry)
                        local color = nil
                        if entry.color then
                            color = CreateColorFromHexString(entry.color)
                        end
                       _G[entry.type](GameTooltip, entry.value, color)
                    end)
                end
                GameTooltip:Show();
            end
            frame:Refresh(activityInfo);
		end
	end


end






function RemoteMixin:SelectActivity(activityFrame)
end


function RemoteMixin:GetActivityFrame(activityType, index)
    return WeeklyRewardsFrame.GetActivityFrame(self, activityType, index)
end
