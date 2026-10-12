local ColumKey = "keystone"
local Column = GreatVaultList:NewModule(ColumKey, GREATVAULTLIST_COLUMNS)
local L, _ = GreatVaultList:GetLibs()

Column.key = ColumKey
Column.config = {
    ["defaultIndex"] = 9,
    ["width"] = 180,
    ["autoWidth"] = true,
    ["header"] =  { key = ColumKey, text = L[ColumKey], canSort = true},
    ["sortFn"] = function(a, b, comp)
        if type(a) ~= "table" then a = {keystoneLevel = 1} end
        if type(b) ~= "table" then b = {keystoneLevel = 1} end
        return comp(a.keystoneLevel, b.keystoneLevel)
    end,
    ['emptyStr'] = "-",
    ["demo"] = function(idx)
        local mapChallengeModeIDs = {}
        _.foreach(C_ChallengeMode.GetMapTable(), function(k, id)
            tinsert(mapChallengeModeIDs, id)
        end)
        
        return {
            activityID = mapChallengeModeIDs[math.random(#mapChallengeModeIDs)],
            keystoneLevel = math.random(5, 15)
        }
    end,
    event = {
        "CHALLENGE_MODE_COMPLETED",
        function(self)
            GreatVaultList.Data:store(self.config, true)
            if GreatVaultListFrame:IsShown() then  -- refresh view if window is open
                GreatVaultListFrame:RefreshScrollFrame()
            end
        end
    },
    ["store"] = function(characterInfo)
        local activityID, groupID, keystoneLevel = C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel()

        if activityID then 
            characterInfo.keystone = {}
            characterInfo.keystone.activityID = activityID
            characterInfo.keystone.groupID = groupID
            characterInfo.keystone.keystoneLevel = keystoneLevel
        else
            characterInfo.keystone = ""
        end

        return characterInfo
    end,
    ["populate"] = function(self, keystone)
        if not keystone then return keystone end
        if type(keystone) ~= "table" then return nil end
        if not keystone.keystoneLevel then return nil end
        if not keystone.groupID then return nil end

        local name = C_LFGList.GetActivityGroupInfo(keystone.groupID) or ""
        local level = keystone.keystoneLevel or 0
        return string.format("%s %s", name, level)
    end
}