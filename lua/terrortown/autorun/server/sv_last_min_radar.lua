local last_min_radar_triggered = false

local function IsInSpecDM(ply)
	if SpecDM and (ply.IsGhost and ply:IsGhost()) then
		return true
	end
	
	return false
end

local function GetNumParticipatingPlayers()
	local n = 0
	for _, ply in ipairs(player.GetAll()) do
		if ply:Alive() and not ply:IsSpec() and not IsInSpecDM(ply) then
			n = n + 1
		end
	end
	
	return n
end

local function LastMinuteRadar()
	--If LastMinuteRadar() is called from the timer, it will still "exist", but TimeLeft will be nil.
	local timeout = (not timer.Exists("LastMinRadar") or timer.TimeLeft("LastMinRadar") == nil or timer.TimeLeft("LastMinRadar") == 0)
	local threshold_hit = timeout and GetNumParticipatingPlayers() <= GetConVar("ttt2_last_min_radar_min_plys"):GetInt()
	
	if GetRoundState() ~= ROUND_ACTIVE or last_min_radar_triggered or not threshold_hit then
		return
	end
	
	last_min_radar_triggered = true
	local evil_only = GetConVar("ttt2_last_min_radar_evil_only"):GetBool()
	for _, ply in ipairs(player.GetAll()) do
		if ply:Alive() and not ply:IsSpec() and not IsInSpecDM(ply) and (not evil_only or (ply:GetTeam() ~= TEAM_INNOCENT and ply:GetTeam() ~= TEAM_NONE)) then
			ply:GiveEquipmentItem("item_ttt_radar")
		end
		
		LANG.Msg(ply, "last_min_radar_desc", {t = GetConVar("ttt2_last_min_radar_timeout"):GetInt(), n = GetConVar("ttt2_last_min_radar_min_plys"):GetInt()}, MSG_MSTACK_PLAIN)
	end
	
	events.Trigger(EVENT_LAST_MIN_RADAR)
end

hook.Add("TTTBeginRound", "LastMinRadarBeginRound", function()
	last_min_radar_triggered = false
	
	local t = GetConVar("ttt2_last_min_radar_timeout"):GetInt()
	if t > 0 then
		timer.Create("LastMinRadar", t, 1, function()
			LastMinuteRadar()
		end)
	end
end)

hook.Add("TTT2PostPlayerDeath", "LastMinRadarTTT2PostPlayerDeath", function(victim, inflictor, attacker)
	LastMinuteRadar()
end)

hook.Add("TTTEndRound", "LastMinRadarEndRound", function()
	if timer.Exists("LastMinRadar") then
		timer.Remove("LastMinRadar")
	end
	last_min_radar_triggered = false
end)