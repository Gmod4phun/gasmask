util.AddNetworkString("GASMASK_RequestModelDraw")
util.AddNetworkString("GASMASK_RequestWeaponSelect")

local meta = FindMetaTable("Player")
function meta:GASMASK_RequestModelDraw(b)
	net.Start("GASMASK_RequestModelDraw")
		net.WriteBool(b)
	net.Send(self)
end

hook.Add("PlayerSpawn", "GASMASK_PlayerSpawn", function(ply)
	ply.GASMASK_Ready = true
	ply.GASMASK_Equiped = false
end)

hook.Add("PostPlayerDeath", "GASMASK_PostDeath", function(ply)
	ply:GASMASK_RequestModelDraw(false)
	ply.GASMASK_Equiped = false
end)

local gasmask_class = "g4p_gasmask"
concommand.Add("g4p_gasmask_toggle", function(ply)
	if !ply.GASMASK_Ready then return end

	
	local wep = ply:GetActiveWeapon()
	if !IsValid(wep) then return end
	
	if wep:GetClass() != gasmask_class then
		ply.GASMASK_LastWeapon = wep
		ply:StripWeapon(gasmask_class)
		ply:SetSuppressPickupNotices(true)
		ply:Give(gasmask_class).GASMASK_SignalForDeploy = true
		ply:SetSuppressPickupNotices(false)
		ply:SelectWeapon(gasmask_class)
	end
end)

hook.Add("PlayerShouldTakeDamage", "GASMAK_Damage_no_trigger_hurt", function(ply, attacker)
	if ply.GASMASK_Equiped then
		if (attacker:GetClass() == "trigger_hurt") then
			return false
		end
	end
end)
