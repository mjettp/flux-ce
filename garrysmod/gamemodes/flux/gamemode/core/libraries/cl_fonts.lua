--[[
	Flux © 2016-2017 TeslaCloud Studios
	Do not share or re-distribute before
	the framework is publicly released.
--]]

library.New("fonts", fl)

-- We want the fonts to recreate on refresh.
local stored = {}

do
	local aspect = ScrW() / ScrH()

	local function ScreenIsRatio(w, h)
		return (aspect == w / h)
	end

	function fl.fonts:ScaleSize(size)
		if (ScreenIsRatio(16, 10)) then
			return math.floor(size * (ScrH() / 1200))
		elseif (ScreenIsRatio(4, 3)) then
			return math.floor(size * (ScrH() / 1024))
		end

		return math.floor(size * (ScrH() / 1080))
	end
end

function fl.fonts:CreateFont(name, fontData)
	if (name == nil or !istable(fontData)) then return end
	if (stored[name]) then return end

	-- Force UTF-8 range by default.
	fontData.extended = true

	surface.CreateFont(name, fontData)
	stored[name] = fontData
end

function fl.fonts:GetSize(name, size)
	if (!size) then return name end

	local newName = name..":"..size

	if (!stored[newName]) then
		local fontData = table.Copy(stored[name])

		if (fontData) then
			fontData.size = size

			self:CreateFont(newName, fontData)
		end
	end

	return newName
end

function fl.fonts:ClearTable()
	stored = {}
end

function fl.fonts:ClearSizes()
	for k, v in pairs(stored) do
		if (k:find("\\")) then
			stored[k] = nil
		end
	end
end

function fl.fonts:GetTable(name)
	return stored[name]
end

function fl.fonts:CreateFonts()
	self:ClearTable()

	self:CreateFont("menu_thin", {
		font = "Roboto Lt",
		extended = true,
		weight = 400,
		size = self:ScaleSize(34)
	})

	self:CreateFont("menu_thin_large", {
		font = "Roboto Lt",
		extended = true,
		weight = 400,
		size = self:ScaleSize(42)
	})

	self:CreateFont("menu_thin_small", {
		font = "Roboto Lt",
		extended = true,
		weight = 300,
		size = self:ScaleSize(28)
	})

	self:CreateFont("menu_thin_smaller", {
		font = "Roboto Lt",
		extended = true,
		size = self:ScaleSize(22),
		weight = 200
	})

	self:CreateFont("menu_light", {
		font = "Roboto Lt",
		extended = true,
		size = self:ScaleSize(34)
	})

	self:CreateFont("menu_light_tiny", {
		font = "Roboto Lt",
		extended = true,
		size = self:ScaleSize(16)
	})

	self:CreateFont("menu_light_small", {
		font = "Roboto Lt",
		extended = true,
		size = self:ScaleSize(20)
	})

	self:CreateFont("hud_small", {
		font = "Roboto Condensed",
		extended = true,
		size = self:ScaleSize(20),
		weight = 200
	})

	self:CreateFont("bar_text", {
		font = "Roboto Condensed",
		extended = true,
		size = 14,
		weight = 600
	})

	self:CreateFont("tooltip_large", {
		font = "Roboto Condensed",
		extended = true,
		size = 26,
		weight = 500
	})

	self:CreateFont("tooltip_small", {
		font = "Roboto Condensed",
		extended = true,
		size = 16,
		weight = 500
	})

	self:CreateFont("fl_frame_title", {
		font = "Roboto",
		size = 14,
		weight = 500
	})

	self:CreateFont("fl_menuitem", {
		font = "Roboto Condensed",
		extended = true,
		size = 24,
		weight = 500
	})

	self:CreateFont("fl_menuitem_large", {
		font = "Roboto Condensed",
		extended = true,
		size = 30,
		weight = 500
	})

	self:CreateFont("flMainFont", {
		font = "Roboto Condensed",
		extended = true,
		size = 16,
		weight = 500
	})

	theme.Call("CreateFonts", self)
	hook.Run("CreateFonts", self)
end