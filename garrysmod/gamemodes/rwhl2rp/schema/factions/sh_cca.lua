--[[ 
	Rework © 2016-2017 TeslaCloud Studios
	Do not share or re-distribute before 
	the framework is publicly released.
--]]

FACTION.Name = "Combine Civil Authority";
FACTION.Description = "Combine police forces.";
FACTION.PhysDesc = "Wearing shiny metropolice unit uniform with brand new stunstick on his belt."
FACTION.Color = Color(225, 185, 135);
FACTION.DefaultClass = "recruit";
FACTION.NameTemplate = "CCA.{data:Squad}.{rank}.{callback:GenerateID}";
FACTION:SetData("Squad", "UNION");
FACTION.Models.universal = {
	"models/police.mdl"
};

FACTION:AddRank("RCT");
FACTION:AddRank("GU");
FACTION:AddRank("S-GU");
FACTION:AddRank("OfC");
FACTION:AddRank("GHOST");
FACTION:AddRank("CmD");
FACTION:AddRank("SeC");

FACTION:AddClass("recruit", "Metropolice Recruit", "Metropolice Unit that is yet to pass their basic training.", FACTION.Color, function(player)
	return true;
end);

FACTION:AddClass("unit", "Metropolice Unit", "A regular Metropolice Force unit.", FACTION.Color, function(player)
	return player:IsRank("GU");
end);

FACTION:AddClass("elite_mpf", "Elite Metropolice", "Metropolice high command.", FACTION.Color, function(player)
	return player:IsRank("OfC");
end);

function FACTION:GenerateID(player)
	return math.random(100, 999);
end;