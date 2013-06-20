local function formatNumber(n)
	if not n then return "" end
	if n >= 1e14 then return tostring(n) end
    n = tostring(n)
    local sep = sep or ","
    local dp = string.find(n, "%.") or #n+1
	for i=dp-4, 1, -3 do
		n = n:sub(1, i) .. sep .. n:sub(i+1)
    end
    return n
end

if not FAdmin or not FAdmin.StartHooks then return end
FAdmin.StartHooks["DarkRP"] = function()
	-- DarkRP information:
	FAdmin.ScoreBoard.Player:AddInformation("Steam name", function(ply) return ply:SteamName() end, true)
	FAdmin.ScoreBoard.Player:AddInformation("Money", function(ply) if LocalPlayer():IsAdmin() and ply.DarkRPVars and ply:getDarkRPVar("money") then return "$"..formatNumber(ply:getDarkRPVar("money")) end end)
	FAdmin.ScoreBoard.Player:AddInformation("Wanted", function(ply) if ply.DarkRPVars and ply:getDarkRPVar("wanted") then return tostring(ply.DarkRPVars["wantedReason"] or "N/A") end end)
	FAdmin.ScoreBoard.Player:AddInformation("Community link", function(ply) return FAdmin.SteamToProfile(ply:SteamID()) end)
	FAdmin.ScoreBoard.Player:AddInformation("Rank", function(ply) return ply:GetNWString("usergroup") end)

	-- Warrant
	FAdmin.ScoreBoard.Player:AddActionButton("Warrant", "FAdmin/icons/Message",	Color(0, 0, 200, 255),
		function(ply) return LocalPlayer():IsCP() end,
		function(ply, button)
			Derma_StringRequest("Warrant reason", "Enter the reason for the warrant", "", function(Reason)
				LocalPlayer():ConCommand("darkrp /warrant \"".. ply:SteamID().."\" ".. Reason)
			end)
		end)

	--wanted
	FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
			return ((ply:getDarkRPVar("wanted") and "Unw") or "W") .. "anted"
		end,
		function(ply) return "FAdmin/icons/jail", ply:getDarkRPVar("wanted") and "FAdmin/icons/disable" end,
		Color(0, 0, 200, 255),
		function(ply) local t = LocalPlayer():Team() return t == TEAM_POLICE or t == TEAM_MAYOR or t == TEAM_CHIEF end,
		function(ply, button)
			if not ply:getDarkRPVar("wanted")  then
				Derma_StringRequest("wanted reason", "Enter the reason to arrest this player", "", function(Reason)
					LocalPlayer():ConCommand("darkrp /wanted \"".. ply:SteamID().."\" ".. Reason)
				end)
			else
				LocalPlayer():ConCommand("darkrp /unwanted \"".. ply:UserID() .. "\"")
			end
		end)

	--Teamban
	local function teamban(ply, button)
		local menu = DermaMenu()
		local Title = vgui.Create("DLabel")
		Title:SetText("  Jobs:\n")
		Title:SetFont("UiBold")
		Title:SizeToContents()
		Title:SetTextColor(color_black)
		local command = "rp_teamban"

		menu:AddPanel(Title)
		for k,v in SortedPairsByMemberValue(RPExtraTeams, "name") do
			local submenu = menu:AddSubMenu(v.name)
			submenu:AddOption("2 minutes", function() RunConsoleCommand(command, ply:UserID(), k, 120) end)
			submenu:AddOption("Half an hour", function() RunConsoleCommand(command, ply:UserID(), k, 1800) end)
			submenu:AddOption("An hour", function() RunConsoleCommand(command, ply:UserID(), k, 3600) end)
			submenu:AddOption("Until restart", function() RunConsoleCommand(command, ply:UserID(), k, 0) end)
		end
		menu:Open()
	end
	FAdmin.ScoreBoard.Player:AddActionButton("Ban from job", "FAdmin/icons/changeteam", Color(200, 0, 0, 255),
	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "rp_commands", ply) end, teamban)

	local function teamunban(ply, button)
		local menu = DermaMenu()
		local Title = vgui.Create("DLabel")
		Title:SetText("  Jobs:\n")
		Title:SetFont("UiBold")
		Title:SizeToContents()
		Title:SetTextColor(color_black)
		local command = "rp_teamunban"

		menu:AddPanel(Title)
		for k,v in SortedPairsByMemberValue(RPExtraTeams, "name") do
			menu:AddOption(v.name, function() RunConsoleCommand(command, ply:UserID(), k) end)
		end
		menu:Open()
	end
	FAdmin.ScoreBoard.Player:AddActionButton("Unban from job", function() return "FAdmin/icons/changeteam", "FAdmin/icons/disable" end, Color(200, 0, 0, 255),
	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "rp_commands", ply) end, teamunban)
end
