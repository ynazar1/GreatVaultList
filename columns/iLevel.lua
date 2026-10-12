local ColumKey = "ilevel"
local Column = GreatVaultList:NewModule(ColumKey, GREATVAULTLIST_COLUMNS)
local L, _ = GreatVaultList:GetLibs()

Column.key = ColumKey
Column.DBkey = "averageItemLevel"

Column.Option = {}
function Column:AddOptions(category, optionTable)
    Column.Option = optionTable

    if type(optionTable["floatNumber"]) ~= "number" then optionTable["floatNumber"] = 2 end


	local setting = GreatVaultList.Util:RegisterSetting(category, "floatNumber", "floatNumber", optionTable, "number", L["opt_columns_ilevel_floatNumber_name"], 2)

    local options = Settings.CreateSliderOptions(0, 5, 1)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(num) return num end);
	Settings.CreateSlider(category, setting, options, L["opt_columns_ilevel_floatNumber_desc"])
end


Column.config = {
    ["defaultIndex"] = 5,
    ["width"] = 40,
    ["autoWidth"] = true,
    ["header"] = {key = ColumKey, text = L[ColumKey], canSort = true},
    ["demo"] = function(idx)
        return math.random(50000, 60000)/100
    end,
    ["store"] = function(characterInfo)
        local _, ilvl = GetAverageItemLevel();
        characterInfo.averageItemLevel = ilvl
        return characterInfo
    end,
    ["populate"] = function(self, number)
       if type(number) ~= "number" then return number end

       local format = Column.Option.floatNumber and "%.".. Column.Option.floatNumber .."f"or "%.2f"
       return string.format(format, number)
    end
}