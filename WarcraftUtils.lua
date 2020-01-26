local addonName, NS = ...


local UILFGFrame
NS.Commands:AddCommand("lfg", "opens the lfg window", function()
	if UILFGFrame and UILFGFrame:IsShown() then
		UILFGFrame:Release()
	else
		UILFGFrame = NS.UI:CreateMenu("LFG")
		UILFGFrame:Show()
	end
end)

local UILFMFrame
NS.Commands:AddCommand("lfm", "opens the lfm window", function()
	if UILFMFrame and UILFMFrame:IsShown() then
		UILFMFrame:Release()
	else
		UILFMFrame = NS.UI:CreateMenu("LFM")
		UILFMFrame:Show()
	end
end)

local UITargetFrame
NS.Commands:AddCommand("tar", "opens the target window", function()
	if UITargetFrame and UITargetFrame:IsShown() then
		UITargetFrame:Release()
	else
		UITargetFrame = NS.UI:CreateTargetFrame()
		UITargetFrame:Show()
	end
end)


----------------------------------
-- Events
----------------------------------
local eventFrame, events = CreateFrame("Frame"), {}

function events:ADDON_LOADED(name)
	if name ~= addonName then return end
	
	-- Register Slash Commands
	NS.Commands:Register(addonName, "/ras")
	
    print(string.format("|cff0090ff[%s]|r loaded sucessfully", addonName))
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
	events[event](self, ...)
end)
for k, _ in pairs(events) do
	eventFrame:RegisterEvent(k)
end