net.Receive("GASMASK_RequestModelDraw", function()
	local ply = LocalPlayer()
	ply.GASMASK_ShouldDraw = net.ReadBool()
	if !ply.GASMASK_ShouldDraw and ply.GASMASK_BreathSound then
		ply.GASMASK_BreathSound:Stop()
		ply.GASMASK_BreathSound = nil
	end
end)

net.Receive("GASMASK_RequestWeaponSelect", function()
	local wep = net.ReadEntity()
	if IsValid(wep) then
		input.SelectWeapon(wep)
	end
end)

local function GASMASK_CalcHorizontalFromVerticalFOV( num ) // calculates the camera FOV depending on viewmodel FOV
	local r = ScrW() / ScrH() // our resolution
	r =  r / (4/3) // 4/3 is base Source resolution, so we have do divide our resolution by that
	local tan, atan, deg, rad = math.tan, math.atan, math.deg, math.rad
	
	local vFoV = rad(num)
	local hFoV = deg( 2 * atan(tan(vFoV/2)*r) ) // this was a bitch
	
	return hFoV
end

local function GASMASK_DrawInHud()
	local ply = LocalPlayer()
	if !IsValid(ply) then return end
	
	if !ply.GASMASK_HudModel or !IsValid(ply.GASMASK_HudModel) then
		ply.GASMASK_HudModel = ClientsideModel("models/gmod4phun/c_contagion_gasmask.mdl", RENDERGROUP_BOTH)
		ply.GASMASK_HudModel:SetNoDraw(true)
	end
	
	local mask = ply.GASMASK_HudModel
	if !IsValid(mask) then return end
	
	local pos, ang = EyePos(), EyeAngles()
	
	local maskwep = weapons.GetStored("g4p_gasmask")
	local camFOV = GASMASK_CalcHorizontalFromVerticalFOV(maskwep.ViewModelFOV)
	
	cam.Start3D( pos, ang, camFOV, 0, 0, ScrW(), ScrH(), 1, 100)
		cam.IgnoreZ(false)
			render.SuppressEngineLighting( false )
				mask:SetPos(pos)
				mask:SetAngles(ang)
				mask:FrameAdvance(FrameTime())
				mask:SetupBones()
				mask:ResetSequence("idle_on")
				if ply.GASMASK_ShouldDraw and ply:GetViewEntity() == ply then
					mask:DrawModel()
				end
			render.SuppressEngineLighting( false )
		cam.IgnoreZ(false)
	cam.End3D()
end

hook.Add("HUDPaintBackground", "GASMASK_HUDPaintDrawing", function()
	GASMASK_DrawInHud()
end)

local maskbreathsounds = {
	[1] = "GASMASK_BreathingLoop",
	[2] = "GASMASK_BreathingLoop2",
}

local function GASMASK_BreathThink()
	local ply = LocalPlayer()
	if !IsValid(ply) then return end
	
	local sndtype = GetConVar("g4p_gasmask_sndtype"):GetInt()
	
	if !ply.GASMASK_BreathSound and sndtype > 0 then
		ply.GASMASK_BreathSound = CreateSound(ply, maskbreathsounds[sndtype])
	end
	
	local shouldplay = ply.GASMASK_ShouldDraw and sndtype > 0
	
	local snd = ply.GASMASK_BreathSound
	if snd then
		snd:ChangePitch(snd:GetPitch() + 0.01) // fix for stopsound
		snd:ChangePitch(math.Clamp(game.GetTimeScale() * 100, 75, 120))
		snd:ChangeVolume(shouldplay and 1 or 0, 0.5)
	
		if !snd:IsPlaying() and shouldplay then snd:Play() end
	end
end

hook.Add("Think", "GASMASK_BreathSoundThink", function()
	GASMASK_BreathThink()
end)
