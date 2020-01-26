-- ----------------------------------------------------------------------------
-- AddOn namespace
-- ----------------------------------------------------------------------------
local addonName, WU = ...

WU.UI = {}
local UI = WU.UI

local AceGUI = LibStub("AceGUI-3.0")


UI.dungeons = {
    { name="Ragefireabgrund", short="RFA" },
    { name="Die Höhlen des Wehklagens", short="HdW" },
    { name="Die Todesminen", short="Todesminen" },
    { name="Burg Schattenfang", short="BSF" },
    { name="Tiefschwarze Grotte", short="BFD" },
    { name="Das Verlies", short="Verlies" },
    { name="Gnomeregan", short="Gnome" },
    { name="Der Kral von Razorfen", short="Kral" },
    { name="Das scharlachrote Kloster - Friedhof", short="Kloster FH" },
    { name="Das scharlachrote Kloster - Bibliothek", short="Kloster Bib" },
    { name="Das scharlachrote Kloster - Waffenkammer", short="Kloster WK" },
    { name="Das scharlachrote Kloster - Kathedrale", short="Kloster Kath" },
    { name="Die Hügel von Razorfen", short="Hügel" },
    { name="Uldaman", short="Ulda" },
    { name="Zul'Farrak", short="ZF" },
    { name="Maraudon", short="Mara" },
    { name="Der Tempel von Atal'Hakkar", short="Tempel" },
    { name="Blackrocktiefen", short="BRD" },
    { name="Untere Schwarzfelsspitze", short="LBRS" },
    { name="Obere Schwarzfelsspitze", short="UBRS" },
    { name="Düsterbruch - Ost", short="DM Ost" },
    { name="Düsterbruch - West", short="DM West" },
    { name="Düsterbruch - Nord", short="DM Nord" },
    { name="Scholomance", short="Scholo" },
    { name="Stratholme - Living", short="Strat Liv" },
    { name="Stratholme - Undead", short="Strat UD" }
}


local function GetJoinedChannels()
    local channels = {}
    local channelList = { GetChannelList() }
    for i=1, #channelList, 3 do
		-- we don't want to add "blocked" channels
		if not channelList[i+2] then
			channels[channelList[i]] = channelList[i+1]
		end
    end
    return channels
end


-- Centered Layout, Children are stacked on top of each other centered vertically
AceGUI:RegisterLayout("HCenterList", function(content, children)
	local height = 0
	local width = content.width or content:GetWidth() or 0
	for i = 1, #children do
		local child = children[i]

		local frame = child.frame
		frame:ClearAllPoints()
		frame:Show()
		if i == 1 then
			frame:SetPoint("TOP", content)
		else
			frame:SetPoint("TOP", children[i-1].frame, "BOTTOM")
		end

		if child.width == "fill" then
			child:SetWidth(width)

			if child.DoLayout then
				child:DoLayout()
			end
		elseif child.width == "relative" then
			child:SetWidth(width * child.relWidth)

			if child.DoLayout then
				child:DoLayout()
			end
		end

		height = height + (frame.height or frame:GetHeight() or 0)
	end
end)


function UI:CreateMenu(menuType)
	local frame = AceGUI:Create("Window")
	frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetWidth(224)
	frame:SetHeight(242)
	frame:EnableResize(false)
	frame:SetPoint("CENTER")
	frame:SetTitle(menuType)
	frame:SetLayout("HCenterList")

	-- dungeon dropdown
	local dropdownDungeon = AceGUI:Create("Dropdown")
	dropdownDungeon:SetWidth(200)
	dropdownDungeon:SetText("Select Dungeon")
	dropdownDungeon:SetList({})
	for i, dungeon in ipairs(UI.dungeons) do
		dropdownDungeon:AddItem(i, dungeon.name)
	end
	dropdownDungeon:SetCallback("OnValueChanged", function(self, _, key)
		frame.selectedDungeon = key
	end)

	frame:AddChild(dropdownDungeon)

	-- chat channel dropdown
	frame.selectedChannels = {}
	local dropdownChat = AceGUI:Create("Dropdown")
	dropdownChat:SetWidth(200)
	dropdownChat:SetText("Channels")
	dropdownChat:SetMultiselect(true)
	dropdownChat:SetList(GetJoinedChannels())
	dropdownChat:SetCallback("OnValueChanged", function(self, _, key, checked)
		frame.selectedChannels[key] = checked or None
	end)
	frame:AddChild(dropdownChat)

	-- roles
	frame.dd = AceGUI:Create("CheckBox")
	frame.dd:SetLabel("DD")
	frame:AddChild(frame.dd)
    
	frame.heal = AceGUI:Create("CheckBox")
	frame.heal:SetLabel("Heal")
	frame:AddChild(frame.heal)
    
	frame.tank = AceGUI:Create("CheckBox")
	frame.tank:SetLabel("Tank")
	frame:AddChild(frame.tank)
	
	-- extra
	frame.extra = AceGUI:Create("EditBox")
    frame.extra:SetWidth(200)
	frame.extra:DisableButton(true)
	frame:AddChild(frame.extra)

	-- spacer
	frame:AddChild(AceGUI:Create("Spacer"))

	-- confirm button
    local confirm = AceGUI:Create("Button")
    confirm:SetWidth(200)
    confirm:SetText("Go!")
    confirm:SetCallback("OnClick", function(self)
		frame.extra:ClearFocus()

		-- no dungeon selected
        if not frame.selectedDungeon then
            print("Kein Dungeon ausgewählt!")
            return
        end
		
		-- check channel selection
		local nChannels = 0
		for id, name in pairs(frame.selectedChannels) do
			nChannels = nChannels + 1
		end

		if nChannels == 0 then
			print("Keine Channel ausgewählt!")
			return
		end

		-- roles
		local roles = {}
        if frame.dd:GetValue() then table.insert(roles, "DD") end
        if frame.heal:GetValue() then table.insert(roles, "Heal") end
        if frame.tank:GetValue() then table.insert(roles, "Tank") end
        -- no role selected
        if #roles == 0 then
            print("Keine Rolle(n) ausgewählt")
            return
        end

		local res
		if menuType == "LFM" then
			res = "LFM " .. table.concat(roles, ", ") .. " für"
		else
			res = table.concat(roles, "/") .. " LFG für"
		end

		res = res .. " " .. UI.dungeons[frame.selectedDungeon].short
		res = res .. " " .. frame.extra:GetText()

		for id, name in pairs(frame.selectedChannels) do
			SendChatMessage(res, "CHANNEL", nil, id)
		end
    end)
	frame:AddChild(confirm)
		
	return frame
end


function UI:CreateTargetFrame()
	local frame = AceGUI:Create("Window")

	frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetWidth(224)
	frame:SetHeight(120)
	frame:EnableResize(false)
	frame:SetPoint("CENTER")
	frame:SetTitle("Target")
	frame:SetLayout("HCenterList")

	-- target name editbox
    local nameEdit = AceGUI:Create("EditBox")
    nameEdit:SetWidth(200)
	nameEdit:SetLabel("Unit Name:")
	nameEdit:DisableButton(true)
	frame:AddChild(nameEdit)

	-- target button
    frame.confirm = CreateFrame("Button", nil, frame.content, "WUSecureActionButtonTemplate")
    frame.confirm:SetWidth(200)
    frame.confirm:SetPoint("TOP", frame.content, "TOP", 0, -50)
    frame.confirm:SetText("Go!")
	
	frame.confirm:SetAttribute("type1", "macro")
	frame.confirm:SetAttribute("macrotext", "/target nil")
    frame.confirm:SetScript("PreClick", function(self)
		nameEdit:ClearFocus()

		local unitName = nameEdit:GetText()
		self:SetAttribute("macrotext", "/cleartarget\n/target "..unitName.."\n/stopmacro [noexists][dead]\n/tm 8")
	end)

    return frame
end