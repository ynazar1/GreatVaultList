local GreatVaultList = LibStub("AceAddon-3.0"):GetAddon("GreatVaultList")
local L, _ = GreatVaultList:GetLibs()

GreatVaultList.Util = {}

-- baseilvl number - base itemlevel
-- ilvl number - itemlevel for output
-- addMod number - gradient offset
-- diffMod number - gradient size
function GreatVaultList.Util:colorItemLvl(baseilvl, ilvl, addMod, diffMod)

    local function ColorGradient(perc, r1, g1, b1, r2, g2, b2)
        if perc >= 1 then
            local r, g, b = r2, g2, b2
            return r, g, b
        elseif perc <= 0 then
            local r, g, b = r1, g1, b1
            return r, g, b
        end
        return r1 + (r2 - r1) * perc, g1 + (g2 - g1) * perc, b1 + (b2 - b1) * perc
    end


    local function ColorDiff(a, b)
        local diff = a - b
        local perc = (diff + addMod) / diffMod
    
        local r, g, b
        if perc < 0 then
            perc = perc * -1
            r, g, b = ColorGradient(perc, 1, 1, 0, 0, 1, 0)
        else
            r, g, b = ColorGradient(perc, 1, 1, 0, 1, 0, 0)
        end
        return r, g, b
    end

    local r1, g1, b1 = ColorDiff(baseilvl, ilvl)

    return CreateColor(r1, g1, b1):WrapTextInColorCode(ilvl)
end

-- 12.0+ settings variables are global. Prefix them so we don't collide with other addons
-- (e.g. ColorTools already registers "useClassColors").
function GreatVaultList.Util:RegisterSetting(category, variable, key, tbl, varType, name, default)
    local unique = "GreatVaultList_" .. tostring(variable)
    return Settings.RegisterAddOnSetting(category, unique, key, tbl, varType, name, default)
end

-- 12.0 renamed SettingMixin:SetValueChangedCallback -> SetOnValueChangedCallback
function GreatVaultList.Util:OnSettingChanged(setting, callback)
    if type(setting) ~= "table" then return end
    local wrapped = function(self, value)
        if callback then callback(self, value) end
    end
    if setting.SetOnValueChangedCallback then
        setting:SetOnValueChangedCallback(wrapped)
    elseif setting.SetValueChangedCallback then
        setting:SetValueChangedCallback(wrapped)
    elseif Settings.SetOnValueChangedCallback and setting.GetVariable then
        Settings.SetOnValueChangedCallback(setting:GetVariable(), function(_, s, v) wrapped(s, v) end)
    end
end