--[[ 
	Rework © 2016 Mr. Meow and NightAngel
	Do not share, re-distribute or sell.
--]]

local playerMeta = FindMetaTable("Player");

function playerMeta:HasPermission(perm)
	return rw.admin:HasPermission(self, perm);
end;

function playerMeta:GetPermissions()
	return self:GetNetVar("rePermissions", {});
end;

function playerMeta:IsOwner()
	return (rw.config:Get("owner_steamid") == self:SteamID());
end;

function playerMeta:GetUserGroup()
	return self:GetNetVar("rwUserGroup", "user");
end;

function playerMeta:GetSecondaryGroups()
	return self:GetNetVar("rwSecondaryGroups", {});
end;

function playerMeta:GetCustomPermissions()
	return self:GetNetVar("rwCustomPermissions", {});
end;

if (SERVER) then
	function playerMeta:SetPermissions(permTable)
		return self:SetNetVar("rePermissions", permTable);
	end;

	function playerMeta:SetUserGroup(group)
		group = group or "user";

		self:SetNetVar("rwUserGroup", group);
	end;
end;