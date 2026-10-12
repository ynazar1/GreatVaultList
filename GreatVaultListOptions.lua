local addonName = ...

local GreatVaultList = LibStub("AceAddon-3.0"):GetAddon("GreatVaultList")
local L, _ = GreatVaultList:GetLibs()
local BlizzMoveAPI = _G.BlizzMoveAPI


GreatVaultListOptions = {}



function GreatVaultListOptions:init()
    if self.initialized then return end
    self.initialized = true

    local AddOnInfo = { C_AddOns.GetAddOnInfo(addonName) }
    local category, layout = Settings.RegisterVerticalLayoutCategory(AddOnInfo[2])
    self.category = category
    self.layout = layout
    Settings.RegisterAddOnCategory(category)
    GreatVaultList.OptionsID = category:GetID()


    -- Init columns category
    self:InitColumnCategory()
    -- Init Tabs category
    self:InitTabsCategory()


    local setting = GreatVaultList.Util:RegisterSetting(self.category, "mninimaphide", "hide",
        GreatVaultList.db.global.Options.minimap, "boolean", L["opt_minimap_name"],
        GreatVaultList.db.global.Options.minimap.hide)
    GreatVaultList.Util:OnSettingChanged(setting, function(self)
        if self:GetValue() then
            GreatVaultList.minimapIcon:Hide(addonName)
        else
            GreatVaultList.minimapIcon:Show(addonName)
        end
    end)

    Settings.CreateCheckbox(self.category, setting, L["opt_minimap_desc"])

    -- scale
    if not BlizzMoveAPI then
        local setting = GreatVaultList.Util:RegisterSetting(self.category, "scale", "scale", GreatVaultList.db.global.Options,
            "number", L["opt_scale_name"], 1)
        GreatVaultList.Util:OnSettingChanged(setting, function(self) GreatVaultListFrame:SetScale(self:GetValue()) end)

        local function FormatScaledPercentage(value)
            return FormatPercentage(value);
        end

        local options = Settings.CreateSliderOptions(.4, 2, .01)
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatScaledPercentage);
        Settings.CreateSlider(self.category, setting, options, L["opt_scale_desc"])
    end

    -- lines
    local setting = GreatVaultList.Util:RegisterSetting(category, "lines", "lines", GreatVaultList.db.global.Options, "number",
        L["opt_lines_name"], 12)
    GreatVaultList.Util:OnSettingChanged(setting, function(self)
        GreatVaultListFrame:UpdateSize()
    end)

    local options = Settings.CreateSliderOptions(4, 24, 1)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
    Settings.CreateSlider(self.category, setting, options, L["opt_lines_desc"])




    GreatVaultList.ElvUi:AddOption(self.category)

    do
        local function onButtonClick()
            local keybindsCategory = SettingsPanel:GetCategory(Settings.KEYBINDINGS_CATEGORY_ID);
            local keybindsLayout = SettingsPanel:GetLayout(keybindsCategory);
            for _, initializer in keybindsLayout:EnumerateInitializers() do
                if initializer.data.name == BINDING_HEADER_GreatVaultList then
                    initializer.data.expanded = true;
                    Settings.OpenToCategory(Settings.KEYBINDINGS_CATEGORY_ID, BINDING_HEADER_GreatVaultList);
                    return;
                end
            end
        end

        local addSearchTags = false;
        local initializer = CreateSettingsButtonInitializer("", SETTINGS_KEYBINDINGS_LABEL, onButtonClick, nil,
            addSearchTags);
        layout:AddInitializer(initializer);
    end






    -- Character Delete
    self.layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["opt_CharacterDelete_title"]));

    local deleteOptionsKeys = {};
    local function GetOptions()
        wipe(deleteOptionsKeys)
        local deleteOptions = Settings.CreateControlTextContainer();
        local i = 0
        deleteOptions:Add(0, "");

        _.forEach(GreatVaultList.db.global.characters, function(entry, key)
            if type(entry) ~= "table" or not entry.name then return end
            i = i + 1;

            local name = entry.normalizedRealm and string.format("%s-%s", entry.name, entry.normalizedRealm) or entry.name
            deleteOptions:Add(i, name);
            deleteOptionsKeys[i] = key
        end)

        return deleteOptions:GetData();
    end


    local selectedOption = {}
    local characterDeleteSetting = GreatVaultList.Util:RegisterSetting(self.category, "dummyVar", "dummyVar", selectedOption, "number",  L["opt_CharacterDelete_slider_name"], 0)
    Settings.CreateDropdown(self.category, characterDeleteSetting, GetOptions, L["opt_CharacterDelete_slider_desc"]);


    self.layout:AddInitializer(CreateSettingsButtonInitializer(
        "", 
        L["opt_CharacterDelete_btn_name"],
        function() 
            local selectedIndex = characterDeleteSetting:GetValue()
            if not selectedIndex or selectedIndex == 0 then return end

            StaticPopupDialogs["GreatVaultListOptions_COMFIRM_DELETE_CHARATER"] = {
                text =  L["opt_CharacterDelete_confirm_text"],
                button1 = YES,
                button2 = NO,
                OnAccept = function()
                    local keyToDelete = deleteOptionsKeys[selectedIndex]
                    if not keyToDelete then return end
                    GreatVaultList.db.global.characters[keyToDelete] = nil
                    characterDeleteSetting:SetValue(0)
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
            }
        
            StaticPopup_Show("GreatVaultListOptions_COMFIRM_DELETE_CHARATER")
        end,
        nil,
        false
    ));



    --Settings.OpenToCategory(GreatVaultList.OptionsID)

    
end

function GreatVaultListOptions:InitTabsCategory()
    self.TabsSubcategory = Settings.RegisterVerticalLayoutSubcategory(self.category, L["Tabs"]);
    self.tabsSubcategories = {}

    _.forEach(GreatVaultList.Tabs.registeredTabs, function(entry, id)
        local name = entry.name

        local checkboxName = string.format(L["opt_tab_actve_name"], name, id)
        local checkboxTooltip = string.format(L["opt_tab_actve_desc"], name, id)

        local setting = GreatVaultList.Util:RegisterSetting(self.TabsSubcategory, id .. "active", "active",
            GreatVaultList.db.global.Options.tabs[id], "boolean", checkboxName, true)
        GreatVaultList.Util:OnSettingChanged(setting, function(self)
            local value = self:GetValue()
            if value then
                entry:Enable()
            else
                entry:Disable()
            end
        end)

        Settings.CreateCheckbox(self.TabsSubcategory, setting, checkboxTooltip)

        -- add tab spezific optionsTable
        local tabFrame = _G["GreatVaultList_TabFrame_" .. id]
        if not tabFrame then return end
        if tabFrame.AddOptions then
            local category = Settings.RegisterVerticalLayoutSubcategory(self.TabsSubcategory, name);
            Settings.RegisterAddOnCategory(category);
            self.tabsSubcategories[id] = category

            tabFrame:AddOptions(self.tabsSubcategories[id])
        end
    end)
end

function GreatVaultListOptions:InitColumnCategory()
    self.ColumnsSubcategory = Settings.RegisterVerticalLayoutSubcategory(self.category, L["opt_category_columns"]);
    self.columnsSubcategories = {}

    local default = {}
    local options = {}
    _.forEach(GreatVaultList.RegisterdModules, function(entry, key)
        default[key] = {
            active = entry.active,
            index = entry.index,
            id = entry.id
        }

        options[key] = {
            id = entry.id,
            name = entry.name
        }

        self:AddColumnCategory(entry)
    end)


    local changesModules = CopyTable(GreatVaultList.db.global.Options.modules)


    local setting = GreatVaultList.Util:RegisterSetting(self.ColumnsSubcategory, "modules", "modules",
        GreatVaultList.db.global.Options, "table", L["opt_column_order_name"], default)


    GreatVaultList.Util:OnSettingChanged(setting, function(self)
        local value = self:GetValue()
        if not value then return end

        _.forEach(GreatVaultList.RegisterdModules, function(entry, name)
            local module = entry.module
            local mode = value[name].active

            if changesModules[name].active ~= mode then
                if mode then
                    module:Enable()
                else
                    module:Disable()
                end
            end
        end)

        GreatVaultList:updateData(true)
        changesModules = CopyTable(GreatVaultList.db.global.Options.modules)
    end)

    Settings.CreateColumnOrder(self.ColumnsSubcategory, setting, options, L["opt_column_order_desc"])
end

function GreatVaultListOptions:AddColumnCategory(entry)
    local module = entry.module
    if not module.AddOptions then return end
    local name = entry.name

    local category = Settings.RegisterVerticalLayoutSubcategory(self.ColumnsSubcategory, name);
    Settings.RegisterAddOnCategory(category);
    self.columnsSubcategories[entry.id] = category

    if not GreatVaultList.db.global.Options.columns[module.key] or type(GreatVaultList.db.global.Options.columns[module.key]) ~= "table" then
        GreatVaultList.db.global.Options.columns[module.key] = {}
    end
    module:AddOptions(category, GreatVaultList.db.global.Options.columns[module.key])
end
