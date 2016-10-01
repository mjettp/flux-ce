--[[ 
	Rework © 2016 TeslaCloud Studios
	Do not share, re-distribute or sell.
--]]

local PANEL = {};

local closeDuration = 0.1;
local expandDuration = 0.15;
local clickDuration = 0.4;
local outlineSize = 0.5;
local backDuration = 1;

local colorBlack = Color(0, 0, 0, 255);
local colorWhite = Color(255, 255, 255, 255);
local colorRed = Color(255, 30, 30, 255);
local colorBlue = Color(30, 30, 255, 255);

local menuFont = "menu_thin";

function PANEL:Init()
	RestoreCursorPosition();

	local scrW, scrH = ScrW(), ScrH();

	self.offset = 0;

	self:SetSize(scrW, scrH);
	self:SetPos(0, 0);

	local backURL = rw.settings.GetString("BackgroundURL");
	local backOption = rw.settings.GetString("FitType");

	self:SetBackImage(backURL, backOption);

	self:CreateBackPanel();
	
	self.mainX = scrW * -0.03;

	self.playerLabel = vgui.Create("rwTabPlayerLabel", self);
	self.charPanel = vgui.Create("rwTabCharacter", self);
	self.dateTime = vgui.Create("rwTabDate", self);
	self.dateTime:SetSize(scrW * 0.25, scrH * 0.075);
	self.dateTime:SetPos(self.charPanel.x, scrH * 0.01);

	self.dock = vgui.Create("rwTabDock", self);

	self.category = vgui.Create("rwTabCategory", self)
	self.category:SetPos(self.mainX + scrW * 0.5 - self.category:GetWide() * 0.5, scrH * 0.01);

	self.ph1 = vgui.Create("EditablePanel", self);
	self.ph1:SetSize(self.charPanel:GetWide(), self.charPanel:GetTall());
	self.ph1:SetPos(self.dateTime.x + self.dateTime:GetWide() - self.ph1:GetWide(), self.charPanel.y);

	self.ph1.Paint = function(panel, w, h)
		surface.SetDrawColor(rw.settings.GetColor("MenuBackColor"));
		surface.DrawRect(0, 0, w, h);
	end;

	chatbox.oldW, chatbox.oldH = chatbox.width, chatbox.height;
	chatbox.oldX, chatbox.oldY = chatbox.x, chatbox.y;

	chatbox.width = scrW * 0.6;
	chatbox.height = scrH * 0.25;
	chatbox.x = self.playerLabel.x;
	chatbox.y = scrH * 0.71;

	if (chatbox.panel) then
		chatbox.panel:Remove();
		chatbox.panel = nil;
	end;

	chatbox.Show(self);

	-- We do this to make the text wrap to the new size of the chatbox.
	chatbox.UpdateDisplay();

	chatbox.textEntry:RequestFocus();

	self.ph2 = vgui.Create("EditablePanel", self);
	self.ph2:SetSize(self.dateTime:GetWide(), chatbox.height);
	self.ph2:SetPos(self.dateTime.x, chatbox.y);

	self.ph2.Paint = function(panel, w, h)
		surface.SetDrawColor(rw.settings.GetColor("MenuBackColor"));
		surface.DrawRect(0, 0, w, h);
	end;

	self.ph3 = vgui.Create("EditablePanel", self);
	self.ph3:SetSize(self.dateTime:GetWide(), scrH * 0.25);
	self.ph3:SetPos(self.dateTime.x, scrH * 0.1);

	self.ph3.Paint = function(panel, w, h)
		surface.SetDrawColor(rw.settings.GetColor("MenuBackColor"));
		surface.DrawRect(0, 0, w, h);

		draw.SimpleTextOutlined("Message of the day:", menuFont, w * 0.5, h * 0.5, rw.settings.GetColor("TextColor"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, outlineSize, colorBlack);
	end;

	self.viewPort = vgui.Create("DButton", self);

	self.viewPort:SetSize(scrW, scrH);
	self.viewPort:SetPos(0, 0);

	self.viewPort.Paint = function(viewPort, w, h)
		local x, y = viewPort:GetPos();

		render.RenderView({
			x = x,
			y = y,
			w = w,
			h = h,
			dopostprocess = true
		});

		return true;
	end;

	self.viewPort.DoClick = function(viewPort)
		self:CloseMenu();
	end;

	self.viewPort:MoveTo(self.mainX + scrW * 0.115 + self.offset, scrH * 0.1, expandDuration, nil, nil, function()
		self:SavePositions();
	end);
	self.viewPort:SizeTo(scrW * 0.6, scrH * 0.6, expandDuration);

	if (rw.savedTab) then
		self:OpenChildMenu(rw.savedTab);
		rw.savedTab = nil;
	end;
end;

function PANEL:OnRemove()
	chatbox.width, chatbox.height = chatbox.oldW, chatbox.oldH;
	chatbox.x, chatbox.y = chatbox.oldX, chatbox.oldY;

	-- We do this to make the text wrap to the normal size properly.
	chatbox.UpdateDisplay()

	if (chatbox.panel) then
		chatbox.panel:Remove();
		chatbox.panel = nil;
	end;

	chatbox.CreateDerma();
	chatbox.textEntry:SetAlpha(0);

	if (self.menu) then
		rw.savedTab = util.GetPanelClass(self.menu);
	end;
end;

function PANEL:CreateBackPanel()
	local scrW, scrH = ScrW(), ScrH();

	self.backPanel = vgui.Create("DPanel", self);

	self.backPanel:MoveToBack();

	self.backPanel:SetPos(0, 0);
	self.backPanel:SetSize(scrW, scrH);

	self.backPanel.Paint = function(panel, w, h)
		local backImage = self.backImage;
		local option = self.option;
		local backW, backH = self.backW, self.backH;
		local backX, backY = self.backX, self.backY;
		local tiles = self.tiles;

		if (panel == self.oldPanel) then
			backImage = self.oldImage;
			option = self.oldOption;

			backW, backH = self.oldW, self.oldH;
			backX, backY = self.oldX, self.oldY;
			tiles = self.oldTiles;
		end;

		if (backImage and backImage != "") then
			local backMat = URLMaterial(backImage);

			surface.SetMaterial(backMat);
			surface.SetDrawColor(colorWhite);

			if (option == "center") then
				backW, backH = backMat:Width(), backMat:Height();
				backX, backY = w * 0.5 - backW * 0.5, h * 0.5 - backH * 0.5;
			elseif (option == "fit") then
				backW, backH = util.FitToAspect(backMat:Width(), backMat:Height(), w, h);
				backX, backY = w * 0.5 - backW * 0.5, h * 0.5 - backH * 0.5;
			elseif (option == "tiled") then
				if (!tiles) then
					backW, backH = util.FitToAspect(backMat:Width(), backMat:Height(), w, h);
					tiles = {};

					for k = 0, math.ceil(w / backW) - 1 do
						for i = 0, math.ceil(h / backH) - 1 do
							tiles[#tiles + 1] = {
								x = k * backW,
								y = i * backH
							};
						end;
					end;
				end;

				for k, v in pairs(tiles) do
					surface.DrawTexturedRect(v.x, v.y, backW, backH);
				end;

				return;
			end;

			surface.DrawTexturedRect(backX, backY, backW, backH);
		else
			surface.SetDrawColor(rw.settings.GetColor("BackgroundColor"));
			surface.DrawRect(0, 0, w, h);
		end;
	end;

	self.backPanel.OnMousePressed = function(nKey)
		if (self.menu) then
			self:CloseChildMenu();
		end;
	end;
end;

function PANEL:OnMousePressed()
	if (self.menu) then
		self:CloseChildMenu();
	end;
end;

function PANEL:GetActiveCategory()
	if (IsValid(self.menu) and util.GetPanelClass(self.menu) == "rwScoreboard") then
		return "Scoreboard";
	end;

	return "Home";
end;

function PANEL:SavePositions()
	for k, v in pairs(self:GetChildren()) do
		v.startingPos = {x = v.x, y = v.y};
	end;
end;

function PANEL:CloseMenu(bForce)
	if (bForce) then
		rw.tabMenu:Remove();
		rw.tabMenu = nil;

		if (timer.Exists("rwCloseTabMenu")) then
			timer.Remove("rwCloseTabMenu");
		end;

		return;
	end;

	self.viewPort:MoveToFront();
	self.viewPort:MoveTo(0, 0, closeDuration);
	self.viewPort:SizeTo(ScrW(), ScrH(), closeDuration);

	timer.Create("rwCloseTabMenu", closeDuration, 1, function()
		RememberCursorPosition();

		if (IsValid(self)) then
			self:CloseMenu(true);
		end;
	end);
end;

function PANEL:SetBackImage(url, option)
	if (self.backPanel) then
		self.oldPanel = self.backPanel;
		self.oldImage = self.backImage;
		self.oldOption = self.option;

		self.oldW, self.oldH = self.backW, self.backH;
		self.oldX, self.oldY = self.backX, self.backY;

		self.oldPanel:AlphaTo(0, backDuration, nil, function(data, panel)
			panel:Remove();
		end);

		self:CreateBackPanel();

		self.backPanel:MoveToBack();
		self.oldPanel:MoveToAfter(self.backPanel);
	end;

	self.backImage = url;
	self.option = option;
		
	URLMaterial(url);

	local w, h = self:GetWide(), self:GetTall();

	if (!option or option == "fill") then
		self.backW, self.backH, self.backX, self.backY = w, h, 0, 0;
	elseif (option == "tiled") then
		self.tiles = nil;
	end;
end;

function PANEL:Paint(w, h)
	surface.SetDrawColor(colorBlack);
	surface.DrawRect(0, 0, w, h);

	surface.SetDrawColor(rw.settings.GetColor("BackgroundColor"));
	surface.DrawRect(0, 0, w, h);
end;

function PANEL:OpenChildMenu(menu)
	local class = nil;

	if (IsValid(self.menu)) then
		class = util.GetPanelClass(self.menu);

		self:CloseChildMenu(nil, true);
	end;

	if (!class or (class and class != menu)) then
		local scrW, scrH = ScrW(), ScrH();

		self.menu = vgui.Create(menu, self);

		if (self.menu) then
			self.menu:SetAlpha(0);
			self.menu:SetPos(self.mainX + scrW * 0.115 + self.offset, scrH * 0.1);
			self.menu:AlphaTo(255, expandDuration);

			if (self.backPanel) then
				self.menu:MoveToAfter(self.backPanel);
			end;

			self.menu.startingPos = {x = self.mainX + scrW * 0.115, y = self.menu.y};
		end;
	end;

	if (!class or class == menu) then
		self.dock:ToggleMenuExpand();
	end;
end;

function PANEL:CloseChildMenu(bForce, noExpand)
	if (!IsValid(self.oldMenu)) then
		self.oldMenu = self.menu;
	end;

	if (IsValid(self.oldMenu) and !self.closingMenu) then
		if (bForce) then
			self.oldMenu:Remove();
			self.oldMenu = nil;

			return;
		end;

		-- If we don't do this, then if the client tries to close menu while it is fading, it will break menu.
		self.closingMenu = true;

		local panel = self.oldMenu;

		self.oldMenu:AlphaTo(0, expandDuration, nil, function()
			self.closingMenu = false;

			panel:Remove();
		end);

		if (self.oldMenu.OnFade) then
			self.oldMenu:OnFade();
		end;

		if (!noExpand) then
			self.dock:ToggleMenuExpand();
		end;
	end;
end;

derma.DefineControl("rwTabMenu", "", PANEL, "EditablePanel");

local PANEL = {};

function PANEL:Init()
	local scrW, scrH = ScrW(), ScrH();

	self:SetSize(scrW * 0.3, scrH * 0.075);

	self.home = vgui.Create("rwCategoryButton", self);

	local homeName = L("#TabMenu_Home");
	local scoreName = L("#TabMenu_Scoreboard");
	local adminName = L("#TabMenu_Admin");

	local w = self:GetWide() * 0.3;

	surface.SetFont(menuFont);

	for k, v in ipairs({homeName, scoreName, adminName}) do
		local textW = surface.GetTextSize(v) + (w * 0.15);

		if (textW > w) then
			local diff = textW - w;

			w = textW;

			self:SetSize(self:GetWide() + (diff * 3), self:GetTall());
		end;
	end;

	self.home.text = homeName;
	self.home:SetPos(0, 0);
	self.home:SetSize(w, self:GetTall());
	self.home.category = "Home";

	self.home.DoClick = function()
		self:GetParent():CloseChildMenu();

		self.home.clickStart = CurTime();
		self.home.clickX, self.home.clickY = self.home:ScreenToLocal(input.GetCursorPos());
	end;

	self.scoreboard = vgui.Create("rwCategoryButton", self);

	self.scoreboard.text = scoreName;
	self.scoreboard:SetSize(w, self:GetTall());
	self.scoreboard:SetPos(self:GetWide() - self.scoreboard:GetWide(), 0);
	self.scoreboard.menu = "rwScoreboard";
	self.scoreboard.category = "Scoreboard";

	if (rw.client:IsAdmin()) then
		self.admin = vgui.Create("rwCategoryButton", self);

		self.admin.text = adminName;
		self.admin:SetSize(w, self:GetTall());
		self.admin:SetPos(self:GetWide() * 0.5 - self.admin:GetWide() * 0.5, 0);
		self.admin.category = "Admin";
	else
		self.home:SetPos(self:GetWide() * 0.5 - self.home:GetWide(), self.home.y);
		self.scoreboard:SetPos(self.home.x + self.home:GetWide(), self.scoreboard.y);
	end;
end;

function PANEL:Paint(w, h)
end;

function PANEL:OnMousePressed()
	local parent = self:GetParent();

	if (parent.menu) then
		parent:CloseChildMenu();
	end;
end;

derma.DefineControl("rwTabCategory", "", PANEL, "DPanel");

local PANEL = {};

function PANEL:Init()
	self.textAlpha = colorWhite.a;
	self:SetText("");
end;

function PANEL:DoClick()
	if (self.menu) then
		self:GetParent():GetParent():OpenChildMenu(self.menu);
	end;
end;

function PANEL:Paint(w, h)
	if (self.text) then
		local curTime = CurTime();

		if (self:IsHovered() and !self.hovered) then
			self.lerpTime = CurTime();
			self.hovered = true;
		elseif (!self:IsHovered() and self.hovered) then
			self.lerpTime = CurTime();
			self.hovered = false;
		end;

		if (self.lerpTime) then
			local fraction = (curTime - self.lerpTime) / expandDuration;

			if (self.hovered) then
				self.textAlpha = Lerp(fraction, colorWhite.a, 170);
			else
				self.textAlpha = Lerp(fraction, 170, colorWhite.a);
			end;
		end;

		local alpha = self.textAlpha;

		if (self:GetParent():GetParent():GetActiveCategory() == self.category) then
			alpha = 170;
		end;

		draw.SimpleTextOutlined(self.text, menuFont, w * 0.5, h * 0.5, ColorAlpha(rw.settings.GetColor("TextColor"), alpha), TEXT_ALIGN_CENTER, nil, outlineSize, ColorAlpha(colorBlack, alpha));
	end;
end;

derma.DefineControl("rwCategoryButton", "", PANEL, "DButton");

local PANEL = {};

function PANEL:Init()
	local scrW, scrH = ScrW(), ScrH();
	local parent = self:GetParent();

	self:SetPos(parent.mainX + scrW * -0.2, scrH * 0.1);
	self:SetSize(scrW * 0.31, scrH * 0.6);

	self.alpha = 0;
	self.offset = 0;
	
	local size = scrW * 0.02;
	local x = self:GetWide() - size;
	local y = self:GetTall() * 0.15;

	self.expand = vgui.Create("rwTabDockButton", self);

	self.expand:SetSize(size * 1.1, size* 1.1);
	self.expand:SetPos(x - size * 0.1, 0);
	self.expand.icon = "fa-bars";
	self.expand.size = size;

	self.expand:SetCallback(function(panel)
		self:ToggleExpand();
	end);

	self.menus = {};

	plugin.Call("AdjustTabDockMenus", self.menus);

	for k, v in pairs(self.menus) do
		v.text = L("#TabMenu_"..k);

		local button = vgui.Create("rwTabDockButton", self);
		local textSize = util.GetTextSize(menuFont, v.text) - scrW * 0.04;

		if (textSize > self.offset) then
			self.offset = textSize;
		end;

		button:SetSize(size * 1.1, size * 1.1);
		button:SetPos(x - size * 0.1, y);
		button.size = size;
		button.icon = v.icon;
		button.menu = v.menu;

		button.DoClick = function(panel)
			if (panel.menu) then
				self:GetParent():OpenChildMenu(panel.menu);	
			end;

			panel.clickStart = CurTime();
		end;

		v.button = button;

		y = y + (size * 1.75);
	end;
end;

function PANEL:ToggleExpand()
	local parent = self:GetParent();

	if (self.bExpanded == nil) then
		self.bExpanded = true;
	end;

	if (self.bExpanded) then
		self.target = colorWhite.a;
	else
		self.target = 0;
	end;

	for k, v in pairs(parent:GetChildren()) do
		if (v == parent.backPanel) then
			continue;
		end;

		if (self.bExpanded) then
			v:MoveTo(v.startingPos.x + self.offset, v.startingPos.y, expandDuration);

			parent.offset = self.offset;			
		else
			v:MoveTo(v.startingPos.x, v.startingPos.y, expandDuration);

			parent.offset = 0;
		end;
	end;

	self.bExpanded = !self.bExpanded;
	self.expandStart = CurTime();
	self.origin = self.alpha;
end;

function PANEL:ToggleMenuExpand()
	local scrW, scrH = ScrW(), ScrH();
	local parent = self:GetParent();

	if (self.bMenuExpanded == nil) then
		self.bMenuExpanded = true;
	end;

	parent.viewPort:MoveToFront();

	if (self.bMenuExpanded) then
		parent.viewPort:MoveTo(parent.charPanel.x, parent.menu.y, expandDuration, nil, nil, function()
			parent.viewPort.startingPos = {x = parent.viewPort.x - parent.offset, y = parent.viewPort.y};
		end);

		parent.viewPort:SizeTo(scrW * 0.25, scrH * 0.25, expandDuration);
	else
		parent.viewPort:MoveTo(parent.mainX + scrW * 0.115 + parent.offset, parent.viewPort.y, expandDuration, nil, nil, function()
			parent.viewPort.startingPos = {x = parent.viewPort.x - parent.offset, y = parent.viewPort.y};
		end);

		parent.viewPort:SizeTo(scrW * 0.6, scrH * 0.6, expandDuration);
	end;

	self.bMenuExpanded = !self.bMenuExpanded;
end;

function PANEL:Paint(w, h)
	local curTime = CurTime();

	if (self.expandStart) then
		local fraction = (curTime - self.expandStart) / expandDuration;

		self.alpha = Lerp(fraction, self.origin, self.target);

		if (fraction >= 1) then
			if (!self.bExpanded) then
				self.alpha = colorWhite.a;
			else
				self.alpha = 0;
			end;

			self.origin = nil;
			self.expandStart = nil;
		end;
	end;

	local textColor = rw.settings.GetColor("TextColor");

	if (self.alpha > 0) then
	//	draw.SimpleTextOutlined("#TabMenu_Expand", menuFont, self.expand.x * 0.97, self.expand.y + self.expand:GetTall() * 0.5, ColorAlpha(textColor, self.alpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, outlineSize, ColorAlpha(colorBlack, self.alpha));

		for k, v in pairs(self.menus) do
			draw.SimpleTextOutlined(v.text, menuFont, v.button.x * 0.97, v.button.y + v.button:GetTall() * 0.5, ColorAlpha(textColor, self.alpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, outlineSize, ColorAlpha(colorBlack, self.alpha));
		end;
	end;
end;

function PANEL:OnMousePressed()
	local parent = self:GetParent();

	if (parent.menu) then
		parent:CloseChildMenu();
	end;
end;

derma.DefineControl("rwTabDock", "", PANEL, "DScrollPanel");

local PANEL = {};

function PANEL:Init()
	self:SetText("");
	self.textAlpha = colorWhite.a;
end;

function PANEL:SetCallback(callback)
	function self:DoClick()
		callback(self);
		self.clickStart = CurTime();
	end;
end;

function PANEL:Paint(w, h)
	local color = self.color or colorWhite;
	local curTime = CurTime();

	if (self:IsHovered() and !self.hovered) then
		self.lerpTime = CurTime();
		self.hovered = true;
	elseif (!self:IsHovered() and self.hovered) then
		self.lerpTime = CurTime();
		self.hovered = false;
	end;

	if (self.lerpTime) then
		local fraction = (curTime - self.lerpTime) / expandDuration;

		if (self.hovered) then
			self.textAlpha = Lerp(fraction, color.a, 170);
		else
			self.textAlpha = Lerp(fraction, 170, color.a);
		end;
	end;

	local alpha = self.textAlpha;
	local currentPanel = self:GetParent():GetParent():GetParent().menu;

	if (IsValid(currentPanel) and self.menu == util.GetPanelClass(currentPanel)) then
		alpha = 170;
	end;

	rw.fa:Draw(self.icon or "fa-bars", w * 0.5, h * 0.5, self.size or 16, ColorAlpha(rw.settings.GetColor("TextColor"), alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, outlineSize, colorBlack);

	if (self.clickStart) then
		local fraction = (curTime - self.clickStart) / clickDuration;
		local w2 = w * 0.5;
		local h2 = h * 0.5;

		surface.DisableClipping(true);
			surface.SetDrawColor(ColorAlpha(colorWhite, Lerp(fraction, colorWhite.a, 0)));

			surface.DrawCircle(w2, h2, Lerp(fraction, 1, w2 * 1.25));
			surface.DrawOutlinedCircle(w2, h2, Lerp(fraction, 1, w), w2 * 0.15);
		surface.DisableClipping(false);

		if (fraction >= 1) then
			self.clickStart = nil;
		end;
	end;
end;

derma.DefineControl("rwTabDockButton", "", PANEL, "DButton");

local PANEL = {};

function PANEL:Init()
end;

local days = {
	"Sunday",
	"Monday",
	"Tuesday",
	"Wednesday",
	"Thursday",
	"Friday",
	"Saturday"
};

function PANEL:Paint(w, h)
	local date = os.date("*t", os.time());
	local day = days[date.wday];
	local month = date.month;
	local year = date.year;
	local hour = date.hour;

	local am = "AM";

	if (hour > 12) then
		am = "PM";
		hour = hour - 12;
	elseif (hour == 0) then
		hour = 12;
	end;

	local min = date.min;

	// or else it will look like 7:3 PM for 7:03 PM.
	if (min < 10) then
		min = "0"..min;
	end;

	// 24 Hour String
//	local timeText = hour..":"..date.min;
	local timeText = hour..":"..min.." "..am;
	local dateText = day.." "..date.day.."/"..month.."/"..year;

	local textColor = rw.settings.GetColor("TextColor");

	draw.SimpleTextOutlined(timeText, menuFont, w, h * 0.5, textColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, outlineSize, colorBlack);
	draw.SimpleTextOutlined(dateText, menuFont, 0, h * 0.5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, outlineSize, colorBlack);
end;

function PANEL:OnMousePressed()
	local parent = self:GetParent();

	if (parent.menu) then
		parent:CloseChildMenu();
	end;
end;

derma.DefineControl("rwTabDate", "", PANEL, "DPanel");

local PANEL = {};

do 
	-- How much larger than the avatarimage is the background for it.
	local sizeOffset = 0.15;

	-- Don't edit these.
	local fullOffset = sizeOffset + 1;
	local halfOffset = sizeOffset * 0.5;

	function PANEL:Init()
		local scrW, scrH = ScrW(), ScrH();
		local parent = self:GetParent();

		self:SetSize(scrW * 0.2, scrH * 0.075);
		self:SetPos(parent.mainX + scrW * 0.115, scrH * 0.01);

		local avatarSize = self:GetTall() * 0.8;

		self.avatar = vgui.Create("AvatarImage", self);
		self.avatar:SetSize(avatarSize, avatarSize);
		self.avatar:SetPos(halfOffset * self.avatar:GetWide(), self:GetTall() - self.avatar:GetTall());
		self.avatar:SetPlayer(rw.client, 64);
		self.avatar:SetCursor("hand");

		self.avatar.OnMousePressed = function(self)
			gui.OpenURL("http://steamcommunity.com/profiles/"..rw.client:SteamID64());
		end;
	end;

	function PANEL:Paint(w, h)
		DisableClipping(true);
			draw.RoundedBox(4, self.avatar.x - (self.avatar:GetWide() * halfOffset), self.avatar.y - (self.avatar:GetTall() * halfOffset), self.avatar:GetWide() * fullOffset, self.avatar:GetTall() * fullOffset, rw.settings.GetColor("TextColor"));
		DisableClipping(false);

		draw.SimpleTextOutlined(rw.client:Name(), menuFont, self.avatar.x + self.avatar:GetWide() + w * 0.04, h * 0.5, rw.settings.GetColor("TextColor"), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, outlineSize, colorBlack);
	end;
end;

function PANEL:OnMousePressed()
	local parent = self:GetParent();

	if (parent.menu) then
		parent:CloseChildMenu();
	end;
end;

derma.DefineControl("rwTabPlayerLabel", "", PANEL, "DPanel");

local PANEL = {};

function PANEL:Init()
	local scrW, scrH = ScrW(), ScrH();
	local parent = self:GetParent();

	self:SetSize(scrW * 0.1225, scrH * 0.34);
	self:SetPos(parent.playerLabel.x + scrW * 0.6 + scrW * 0.0055, scrH * 0.6 + scrH * 0.1 - self:GetTall());

	self.barWidth = scrW * 0.01;
	self.optionHeight = self.barWidth * 2;

	self.modelPanel = vgui.Create("DModelPanel", self);
	self.modelPanel:SetSize(self:GetWide(), self:GetTall());
	self.modelPanel:SetPos(0, 0);
	self.modelPanel:SetModel(rw.client:GetModel());
	self.modelPanel:SetCamPos(Vector(25, 25, 60));
	self.modelPanel:SetLookAt(Vector(0, 0, 45));

	self.optionBar = vgui.Create("DButton", self);
	self.optionBar:SetSize(self.optionHeight, self.optionHeight);
	self.optionBar:SetPos(self:GetWide() * 0.005, self:GetTall() - self.optionHeight);
	self.optionBar:SetText("");

	function self.optionBar:PaintOver(w, h)
		rw.fa:Draw("fa-cogs", w * 0.5, h * 0.5, h * 0.8, colorBlack, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
	end;

	self.optionBar.DoClick = function()
		if (IsValid(self.optionMenu)) then
			self.optionMenu:Remove();
			self.optionMenu = nil;

			return;	
		end;

		self.optionMenu = vgui.Create("DMenu", self);

		self.optionMenu:AddOption("Does Nothing", function() end);
		self.optionMenu:AddSubMenu("Descriptions", function() end);
		self.optionMenu:AddOption("Fall Over", function() end);

		local height = self.optionMenu:ChildCount() * self.optionMenu:GetChild(1):GetTall();

		self.optionMenu:SetPos(self.optionHeight * 1.1, self:GetTall() - height);
	end;	

	function self.modelPanel:LayoutEntity(ent)
		self:RunAnimation();
	end;

	function self.modelPanel:Think()
		if (self.bDragging) then
			if (!input.IsMouseDown(MOUSE_LEFT)) then
				self.lastMouseX = nil;
				self.bDragging = false;

				return;
			end;

			local ent = self:GetEntity();

			if (IsValid(ent)) then
				local mouseX, mouseY = input.GetCursorPos();

				if (!self.lastMouseX) then
					self.lastMouseX = mouseX;
				end;

				local mouseXDiff = mouseX - self.lastMouseX;
				local entAngles = ent:GetAngles();

				ent:SetAngles(entAngles + Angle(0, mouseXDiff, 0));

				self.lastMouseX = mouseX;
			end;
		end;
	end;

	function self.modelPanel:OnMousePressed(key)
		if (key == MOUSE_LEFT) then
			self.bDragging = true;
		end;
	end;
end;

function PANEL:Think()
	self:SetAnimation(rw.client:GetSequence());
	self.optionBar:SetPos(self:GetWide() * 0.005, self:GetTall() - self.optionHeight);
end;

function PANEL:SetAnimation(anim)
	if (!anim) then return; end;

	local ent = self.modelPanel:GetEntity();

	if (IsValid(ent)) then
		-- We do this check so our client doesn't crash if we supply an anim the model doesn't have.
		if (isnumber(anim) and anim >= 0) then
			ent:SetSequence(anim);
		end;
	end;
end;

function PANEL:Paint(w, h)
	surface.SetDrawColor(rw.settings.GetColor("MenuBackColor"));
	surface.DrawRect(0, 0, w, h);
end;

derma.DefineControl("rwTabCharacter", "", PANEL, "DPanel");