local GreatVaultList = LibStub("AceAddon-3.0"):GetAddon("GreatVaultList")
local L, _ = GreatVaultList:GetLibs()



local TableCellBaseMixin = CreateFromMixins(TableBuilderCellMixin);
GreatVaultListTableCellBaseMixin = TableCellBaseMixin

function TableCellBaseMixin:Init(owner, dataIndex, columns, columnConfig, width)
    self.columns = columns or {}
    self.columnConfig = columnConfig or {}
    self.width = width
end

function TableCellBaseMixin:PopulateFn(rowData, dataIndex, idx)
    idx = idx or 1
    local text
    local fn = _.get(self.columnConfig, {self.columns[dataIndex], "populate"})
    if fn and type(fn) == "function" then 
        text = fn({rowData = rowData}, rowData[dataIndex], idx)
    else 
        text = rowData[dataIndex]
    end


    if not text then 
        local emptyStr = _.get(self.columnConfig, {self.columns[dataIndex], "emptyStr", idx}, _.get(self.columnConfig, {self.columns[dataIndex], "emptyStr"}, "-"))
        text = GRAY_FONT_COLOR:WrapTextInColorCode(emptyStr)
    end
    return tostring(text)
end

local TableCellTextMixin = CreateFromMixins(TableCellBaseMixin);
GreatVaultListTableCellTextMixin = TableCellTextMixin


function TableCellTextMixin:Populate(rowData, dataIndex)
	if not dataIndex then return end
    if not rowData then return end
    self.Text:SetText(self:PopulateFn(rowData, dataIndex))
end


local TableCellTripleTextMixin = CreateFromMixins(TableCellBaseMixin);
GreatVaultListTableCellTripleTextMixin = TableCellTripleTextMixin

function TableCellTripleTextMixin:Populate(rowData, dataIndex)
    _.forEach({"Text1", "Text2", "Text3"}, function(entry, idx)
        self[entry]:SetWidth(math.floor(self.width/3))
        self[entry].Text:SetJustifyH("CENTER")
        self[entry].Text:SetText(self:PopulateFn(rowData, dataIndex, idx))
    end)
end

local TableCellIconMixin = CreateFromMixins(TableCellBaseMixin);
GreatVaultListTableCellIconMixin = TableCellIconMixin

function TableCellIconMixin:Populate(rowData, dataIndex)
	local fn = _.get(self.columnConfig, {self.columns[dataIndex], "populate"})
	local icon = fn(rowData, rowData[dataIndex])
    self.IconFrame.Icon:SetAtlas(icon)
end








local TableCellVaultStatusMixin = CreateFromMixins(TableCellBaseMixin);
GreatVaultListTableCellVaultStatusMixin = TableCellVaultStatusMixin

function TableCellVaultStatusMixin:Populate(rowData, dataIndex)
	local fn = _.get(self.columnConfig, {self.columns[dataIndex], "populate"})
	local state = fn(rowData, rowData[dataIndex])

    if not state then
        state = "incomplete"
    end

    self.NormalTexture:SetShown(state ~= "incomplete");
	self.handlesTexture:SetShown(state == "incomplete");
	self.centerPlateTexture:SetShown(state == "incomplete");
	self.NormalTexture:SetDesaturated(state ~= "collect");
end


function TableCellVaultStatusMixin:OnClick() 
    self:ShowGreatVault(self.rowData.data)
end

function TableCellVaultStatusMixin:ShowGreatVault(data)
    if not data then return end

    if not WeeklyRewardsFrame and WeeklyRewards_LoadUI then
        WeeklyRewards_LoadUI()
    end
    if not WeeklyRewardsRemoteFrame then
        WeeklyRewardsRemoteFrame  = CreateFrame("Frame","WeeklyRewardsRemoteFrame", UIParent, "WeeklyRewardsRemoteFrameTemplate")
        WeeklyRewardsRemoteFrame:EnableMouse(true)
        GreatVaultList:addWeeklyRewardFrame()
    end

    local sameName = (data.name == WeeklyRewardsRemoteFrame.charName)
    if WeeklyRewardsRemoteFrame:IsVisible() then
        HideUIPanel(WeeklyRewardsRemoteFrame)
        if not sameName then 
            WeeklyRewardsRemoteFrame:show(data)
        end
    else
        WeeklyRewardsRemoteFrame:show(data)
    end


end