local GreatVaultList = LibStub("AceAddon-3.0"):GetAddon("GreatVaultList")
local L, _ = GreatVaultList:GetLibs()


-- support for all the ELVUI fanbois out therez
GreatVaultList.ElvUi = {}

GreatVaultList.ElvUi.init = false


function GreatVaultList.ElvUi:isActive()
	if not C_AddOns.IsAddOnLoaded("ElvUI") then return false end
	self.E = self.E or unpack(ElvUI)
	if not self.E.private.skins.blizzard.enable then return false end
	if not GreatVaultList.db.global.Options.ElvUiSkin then return false end
	self.S = self.S or self.E:GetModule("Skins")

	return true
end

function GreatVaultList.ElvUi:Init()
    if not GreatVaultList.ElvUi:isActive() then return end
	if GreatVaultList.ElvUi.init then return end	
	GreatVaultList.ElvUi.init = true

	GreatVaultListFrame:StripTextures()
	GreatVaultListFrame:SetTemplate("Transparent")

	self.S:HandleCloseButton(GreatVaultListFrameCloseButton)
	

	for _, tab in next, {GreatVaultListFrame.TabSystem:GetChildren() } do
		self.S:HandleTab(tab)
	end

	GreatVaultListFrame.TabSystem:ClearAllPoints()
	GreatVaultListFrame.TabSystem:Point('TOPLEFT', PlayerSpellsFrame, 'BOTTOMLEFT', -3, 0)


	self.S:HandleEditBox(GreatVaultListFrame.ListFrame.Search)
	self.S:HandleButton(GreatVaultListFrame.ListFrame.Filter)

	self:HandleSellList(GreatVaultListFrame.ListFrame.ItemList)
end

function GreatVaultList.ElvUi:HandleSellList(frame)

	local function HandleHeaders(frame)
		local maxHeaders = frame.HeaderContainer:GetNumChildren()
		for i, header in next, { frame.HeaderContainer:GetChildren() } do
			if not header.IsSkinned then
				header:DisableDrawLayer('BACKGROUND')

				if not header.backdrop then
					header:CreateBackdrop('Transparent')
				end

				header.IsSkinned = true
			end

			if header.backdrop then
				header.backdrop:Point('BOTTOMRIGHT', i < maxHeaders and -5 or 0, -2)
			end
		end
	end

	frame:StripTextures()
	frame:SetTemplate('Transparent')

	self.S:HandleTrimScrollBar(frame.ScrollBar)
	frame.ScrollBar:ClearAllPoints()
	frame.ScrollBar:Point('TOPRIGHT', frame, -10, -16)
	frame.ScrollBar:Point('BOTTOMRIGHT', frame, -10, 16)

	hooksecurefunc(frame, 'RefreshScrollFrame', HandleHeaders)
end


function GreatVaultList.ElvUi:AddTab(tab)
	if not GreatVaultList.ElvUi:isActive() then return end
	if not tab then return end
	self:Init()
	self:HandleSellList(tab.ItemList)
    for widget in GreatVaultListFrame.TabSystem.tabPool:EnumerateActive() do
		self.S:HandleTab(widget)
    end
end



function GreatVaultList.ElvUi:AddOption(category)
	if not C_AddOns.IsAddOnLoaded("ElvUI") then return false end
	
	local setting = GreatVaultList.Util:RegisterSetting(category, "ElvUiSkin", "ElvUiSkin", GreatVaultList.db.global.Options, "boolean", L["opt_ElvUiSkin_name"], GreatVaultList.db.global.Options.ElvUiSkin)
    Settings.CreateCheckbox(category, setting, L["opt_ElvUiSkin_desc"])
end