--[[-----------------------------------------------------------------------------
Spacer Widget
-------------------------------------------------------------------------------]]
local Type, Version = "Spacer", 1
local AceGUI = LibStub("AceGUI-3.0", true)

-- Lua APIs
local max, select, pairs = math.max, select, pairs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		-- set the flag to stop constant size updates
		self.resizing = true
		-- height is set dynamically by the text and image size
		self:SetWidth(200)
		self:SetHeight(20)

		-- reset the flag
		self.resizing = nil
	end,

	-- ["OnRelease"] = nil,

	["OnWidthSet"] = function(self, width)
	end,

	["SetFont"] = function(self, font, height, flags)
		self.label:SetFont(font, height, flags)
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()

	-- create widget
	local widget = {
		frame = frame,
		type  = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
