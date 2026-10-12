local addonName = ...
local L, _ = GreatVaultList:GetLibs()




local ListMixin = {};
GreatVaultListListMixin = ListMixin

function ListMixin:GetBrowseListLayout(owner, itemList, useFill)
	owner.headers = {}
	owner.sort = 1
	owner.reverseSort = false
	owner.sortHeaders = {}
    local function LayoutBrowseListTableBuilder(tableBuilder)
        tableBuilder:SetColumnHeaderOverlap(2);
        tableBuilder:SetHeaderContainer(itemList:GetHeaderContainer());

        _.forEach(self.columns, function(colName, idx)
            local width = _.get(self.columnConfig, {colName, "width"})
            local headerText = _.get(self.columnConfig, {colName, "header", "text"})
            local padding = _.get(self.columnConfig, {colName, "padding"}, GreatVaultList.config.defaultCellPadding)
            local template = _.get(self.columnConfig, {colName, "template"}, "GreatVaultListTableCellTextTemplate")
			local tooltip =  _.get(self.columnConfig, {colName, "tooltip"}, nil)
			local canSort = _.get(self.columnConfig, {colName, "header", "canSort"}, false)

			local headerHidden = _.get(self.columnConfig, {colName, "header", "hidden"})

			if canSort then 
				table.insert(self.sortHeaders, idx);
			end

			local col
			if useFill then
				col = tableBuilder:AddFillColumn(owner, 0, width, padding, padding, idx, template, tooltip, idx, self.columns, self.columnConfig, width);
			else
				col = tableBuilder:AddFixedWidthColumn(owner, 0, width, padding, padding, idx, template, tooltip, idx, self.columns, self.columnConfig, width);
			end

			if not headerHidden then
				col:GetHeaderFrame():SetText(headerText);
			end
			
			if colName ~= "character" then  return end		
        end)
    end

    return LayoutBrowseListTableBuilder;
end

function ListMixin:OnLoad()

	self.tframe = self.tframe or CreateFrame("Frame", nil, self, "GreatVaultListTableCellTextTemplate")
	self.tframe:Hide()

	self.sortHeaders = {}
	self.sort = -1
	self.reverseSort = false
	self.headers = {}

end


function ListMixin:OnShow()
	if not self.columns then return end
	
	local width = 15 + (_.size(self.columnConfig) * 1)
    _.forEach(self.columnConfig, function(entry)
        width = width + (entry.width or 0)
    end)

    self:GetParent():UpdateSize(width);
	self:SetSortOrder(GreatVaultList.db.global.sort, GreatVaultList.db.global.sortReverse)
end



function ListMixin:GetHelpConfig()

	local width = self:GetWidth()-10
	local height = self:GetHeight() + 50

	local helpConfig = {
		FramePos = { x = 0, y = 0 },
		FrameSize = { width = width, height = height },
		[1] = { ButtonPos = { position = "CENTER" },  HighLightBox = { x = width - 12, y = -9, width = 24, height = 24 },	ToolTipDir = "DOWN",  ToolTipText = L["HELP_list_1"] },
		[2] = { ButtonPos = { position = "CENTER"  },  HighLightBox = { x = width - 37, y = -9, width = 24, height = 24 }, ToolTipDir = "DOWN",  ToolTipText = L["HELP_list_2"] },
		[3] = { ButtonPos = { position = "CENTER"},  HighLightBox = { x = width - 141, y = -9, width = 100, height = 24 }, ToolTipDir = "DOWN",  ToolTipText = L["HELP_list_3"] },
		[4] = { ButtonPos = { position = "CENTER" }, HighLightBox = { x = 60, y = -9, width = width - 143 - 60, height = 24 },  ToolTipDir = "DOWN",   ToolTipText = L["HELP_list_4"] },
		[5] = { ButtonPos = { position = "CENTER" }, HighLightBox = { x = 5, y = -40, width = width + 10 , height = height - 40 - 5 - 50 },  ToolTipDir = "DOWN",   ToolTipText = L["HELP_list_5"] }
	}

	return helpConfig
end



function ListMixin:RegisterHeader(header)
	local find = _.find(self.sortHeaders, function(entry) return entry == header.sortOrder; end)
	if find and  find > 0 then 
		table.insert(self.headers, header);
	end
end


function ListMixin:SetSortOrder(sortOrder, reverseSort)
	local asserttext = "variable \"%s\" size is 0"
	GreatVaultList:assert(_.size(self.columns) > 0, "ListMixin:SetSortOrder", asserttext, "self.columns")
	GreatVaultList:assert(_.size(self.columnConfig) > 0, "ListMixin:SetSortOrder", asserttext, "self.columnConfig")

	self.sortOrder = sortOrder

	if reverseSort ~= nil then 
		self.reverseSort = reverseSort
	else
		self.reverseSort =  (self.sort == sortOrder) and not self.reverseSort
	end

	self.sort = type(sortOrder) == "number" and  sortOrder > 0 and sortOrder or "name"
		
	for i, header in ipairs(self.headers) do
		header:UpdateArrow(self.reverseSort);
	end

	local comp = (self.reverseSort) and _.gt or _.lt
	if type(self.sort) == "number" then
		local defaultSortFn = function(a, b, comp)
			a = type(a) == "number" and a or 0
			b = type(b) == "number" and b or 0
			return comp(a, b)
		end
		local sortFn = _.get(self.columnConfig, {self.columns[self.sort], "sortFn"}, defaultSortFn)
		sort(self.ItemList.data, function(a, b) return sortFn(a[self.sort], b[self.sort], comp) end)
	else
		sort(self.ItemList.data, function(a, b)
			if not a[self.sort] then return false end
			if not b[self.sort] then return false end
			return comp(strcmputf8i(a[self.sort], a[self.sort]), 0)
		end)
	end

    if sortOrder then
        GreatVaultList.db.global.sort = self.sort
        GreatVaultList.db.global.sortReverse= self.reverseSort
    end

	self.ItemList:RefreshScrollFrame();
end


function ListMixin:calcAutoWidthColumns(data, columnConfig, columns)
	
	return _.forEach(columnConfig, function(column, key)
		if not column.autoWidth then return column end

		local index = _.findIndex(columns, function(v) return v == key end)
		local addSpace = column.header.canSort and 12 or 0
		self.tframe.Text:SetText(column.header.text)
		local maxWidth = math.ceil(self.tframe.Text:GetStringWidth()) + addSpace -- addSpace for arrow 

		_.forEach(data, function(rowData)			
			self.tframe:Init(self, index, columns, columnConfig)
			self.tframe:Populate(rowData, index)
			local w = math.ceil(self.tframe.Text:GetStringWidth())
			maxWidth = math.max(w, maxWidth)
		end)

		
		column.width = maxWidth + ( (column.padding or GreatVaultList.config.defaultCellPadding ) * 2)
		return column
	end)
end


function ListMixin:UpdateFilteredData(str)
	str = str and strtrim(string.lower(str)) or nil
	if str then 
		self.ItemList.data = _.filter(self.data, function(entry) 
			return 	entry.enabled 
					and 
					(
						string.find(string.lower(entry.data.name), str, 0, true)
						or 
						string.find(string.lower(entry.data.realm), str, 0, true)
					)
		end)
	else
		self.ItemList.data = _.filter(self.data, function(entry) return entry.enabled end)
	end
end

function ListMixin:init(columns, data, columnConfig, refresh)
	local asserttext = "variable \"%s\" size is 0"
	GreatVaultList:assert(_.size(columns) > 0, "ListMixin:init", asserttext, "columns")
	GreatVaultList:assert(_.size(data) > 0, "ListMixin:init", asserttext, "data")
	GreatVaultList:assert(_.size(columnConfig) > 0, "ListMixin:init", asserttext, "columnConfig")

    self.columns = columns
	self.data = data
	self:UpdateFilteredData()
    self.columnConfig = columnConfig

	self.columnConfig = self:calcAutoWidthColumns(self.ItemList.data, self.columnConfig, self.columns)

    local width = 15 + (_.size(self.columnConfig) * 1)
    _.forEach(self.columnConfig, function(entry)
        width = width + (entry.width or 0)
    end)

    self:GetParent():UpdateSize(width);

    self.ItemList:SetTableBuilderLayout(self:GetBrowseListLayout(self, self.ItemList, false), self.columnConfig);
	if refresh then 
		self.ItemList:RefreshScrollFrame();
	end
end





















GreatVaultListListOpenVaultMixin = {}

function GreatVaultListListOpenVaultMixin:OnShow()
	local state = GreatVaultList:GetVaultState()

	self.NormalTexture:SetShown(state ~= "incomplete");
	self.handlesTexture:SetShown(state == "incomplete");
	self.centerPlateTexture:SetShown(state == "incomplete");
	self.NormalTexture:SetDesaturated(state ~= "collect");
end

function GreatVaultListListOpenVaultMixin:OnClick()
	SetUIPanelShown(WeeklyRewardsFrame, not WeeklyRewardsFrame:IsShown());
end




GreatVaultListListSearchBoxMixin = {}


function GreatVaultListListSearchBoxMixin:OnLoad()
	SearchBoxTemplate_OnLoad(self);
	self.clearButton:SetScript("OnClick", function(btn)
		self:Reset()
		SearchBoxTemplateClearButton_OnClick(btn);
	end)
end

function GreatVaultListListSearchBoxMixin:OnEnterPressed()
	self:GetParent():UpdateFilteredData(self:GetText())
	self:GetParent().ItemList:RefreshScrollFrame();
end

function GreatVaultListListSearchBoxMixin:Reset()
	self:SetText("");
	self:GetParent():UpdateFilteredData()
	self:GetParent().ItemList:RefreshScrollFrame();
end




GreatVaultListListFilterMixin = {}

function GreatVaultListListFilterMixin:OnLoad()
	WowStyle1FilterDropdownMixin.OnLoad(self);
	self.init = false
end

function GreatVaultListListFilterMixin:OnShow()
	if self.init then return end
	self.init = true

	local function IsSelected(filter)
		return GreatVaultList.db.global.characters[filter].enabled
	end
	
	local function SetSelected(filter)
		local character = GreatVaultList.db.global.characters[filter]
		if not character then return end
		character.enabled = not character.enabled
		
		local findItemList = _.find(self:GetParent().data, function(entry) return entry.name == filter end)
		findItemList.enabled = character.enabled

		self:GetParent():UpdateFilteredData()
		self:GetParent().Search:Reset();

		local sortOrder = self:GetParent().sortOrder
		local reverseSort = self:GetParent().reverseSort
		self:GetParent():SetSortOrder(sortOrder,reverseSort)
	end

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_GREATVAULTLIST_FILTER");
		_.forEach(GreatVaultList.db.global.characters, function(char, key)
			rootDescription:CreateCheckbox(char.name, IsSelected, SetSelected, key);
		end)
	end);
end