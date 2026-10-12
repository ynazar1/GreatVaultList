local ColumKey = "character"
local Column = GreatVaultList:NewModule(ColumKey, GREATVAULTLIST_COLUMNS)
local L, _ = GreatVaultList:GetLibs()

Column.key = ColumKey
Column.DBkey = "name"

Column.Option = {}
function Column:AddOptions(category, optionTable)
    Column.Option = optionTable

    local function SetValueChangedCallback(setting, cb)
        GreatVaultList.Util:OnSettingChanged(setting, function(self)
            if cb and type(cb) == "function" then cb(self) end

            if GreatVaultListFrame:IsShown() then  -- refresh view if window is open
                GreatVaultListFrame:RefreshScrollFrame()
            end
        end)
    end
    
    -- showRealmName
	local setting = GreatVaultList.Util:RegisterSetting(category, "useClassColors", "useClassColors", optionTable, "boolean", L["opt_columns_character_useClassColors_name"], false)
    SetValueChangedCallback(setting)
	Settings.CreateCheckbox(category, setting, L["opt_columns_character_useClassColors_desc"])


    -- showRealmName
    local setting = GreatVaultList.Util:RegisterSetting(category, "showRealmName", "showRealmName", optionTable, "boolean", L["opt_columns_character_showRealmName_name"], false)
    SetValueChangedCallback(setting)
	Settings.CreateCheckbox(category, setting, L["opt_columns_character_showRealmName_desc"])
end

local function getUnitColor(playerClass)
    return (type(_G.CUSTOM_CLASS_COLORS) == "table") and _G.CUSTOM_CLASS_COLORS[playerClass] or _G.RAID_CLASS_COLORS[playerClass]
end


Column.config = {
    ["defaultIndex"] = 2,
    ["width"] = 100,
    ["autoWidth"] = true,
    ["header"] = {key = ColumKey, text = L[ColumKey], canSort = true},
    ["sortFn"] = function(a, b, comp)
        if type(a) ~= "string" then a = "" end
        if type(b) ~= "string" then b = "" end
        return comp(a, b)
    end,
    ["demo"] = function(idx)
        local names = {"Jesternar", "Mishenani", "Martiners", "Mydraciea", "Monzorust", "Ysedbelly", "Connerrig", "Trauddled", "Groldrold", "Shillenton", "Ravenf", "Reginotta", "Groldrold"};
        return names[idx]
    end,
    ["store"] = function(characterInfo)
        local _, className = UnitClass("player")
        characterInfo.name = UnitName("player")
        characterInfo.class = className
        characterInfo.realm = GetRealmName()
        characterInfo.normalizedRealm = GetNormalizedRealmName()
        characterInfo.level = UnitLevel("player")

        return characterInfo
    end,
    ["populate"] = function(self, name)
        if not name or type(name) ~= "string" then return end
        if not self.rowData then return name end
        if not self.rowData.data then return name end
        
          -- showRealmName
        if Column.Option.showRealmName and self.rowData.data.normalizedRealm then
            name = string.format("%s-%s", name, self.rowData.data.normalizedRealm)
        end

        -- useClassColors
        if Column.Option.useClassColors and self.rowData.data.class then
            return getUnitColor(self.rowData.data.class):WrapTextInColorCode(name)
        end

        return name
    end

}