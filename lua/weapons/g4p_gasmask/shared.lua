AddCSLuaFile()

// sounds
local sndpath = "gmod4phun/gasmask/"
sound.Add({
	name = "GASMASK_OnOff",
	channel = CHAN_AUTO,
	volume = 0.5,
	level = 80,
	pitch = 100,
	sound = sndpath.."unprone.wav"
})

sound.Add({
	name = "GASMASK_DrawHolster",
	channel = CHAN_AUTO,
	volume = 0.5,
	level = 80,
	pitch = 100,
	sound = sndpath.."uni_weapon_holster.wav"
})

sound.Add({
	name = "GASMASK_Foley",
	channel = CHAN_AUTO,
	volume = 0.35,
	level = 80,
	pitch = 100,
	sound = sndpath.."goprone_03.wav"
})

sound.Add({
	name = "GASMASK_Inhale",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 120,
	pitch = {98, 102},
	sound = {sndpath.."focus_inhale_01.wav", sndpath.."focus_inhale_02.wav", sndpath.."focus_inhale_03.wav", sndpath.."focus_inhale_04.wav"}
})

sound.Add({
	name = "GASMASK_Exhale",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 120,
	pitch = {98, 102},
	sound = {sndpath.."focus_exhale_01.wav", sndpath.."focus_exhale_02.wav", sndpath.."focus_exhale_03.wav", sndpath.."focus_exhale_04.wav", sndpath.."focus_exhale_05.wav"}
})

sound.Add({
	name = "GASMASK_BreathingLoop",
	channel = CHAN_AUTO,
	volume = 1,
	level = 100,
	pitch = 100,
	sound = sndpath.."gasmask_breathing_loop.wav"
})

sound.Add({
	name = "GASMASK_BreathingLoop2",
	channel = CHAN_AUTO,
	volume = 1,
	level = 100,
	pitch = 100,
	sound = sndpath.."breathe_mask_loop.wav"
})

SWEP.HoldType = "slam"

SWEP.DrawCrosshair		= false
SWEP.Crosshair			= false
SWEP.DrawAmmo			= false
SWEP.PrintName			= "Gas Mask"
SWEP.Slot 				= 99
SWEP.SlotPos 			= 99
SWEP.IconLetter 		= "G"
SWEP.IconLetterSelect	= "G"
SWEP.ViewModelFOV		= 60
SWEP.SwayScale 			= 0
SWEP.BobScale			= 0

SWEP.Instructions 			= ""
SWEP.Author   				= "Gmod4phun"
SWEP.Contact        		= ""

SWEP.Weight = 0

SWEP.ViewModelFlip		= false

SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.ViewModel			= "models/gmod4phun/c_contagion_gasmask.mdl"
SWEP.WorldModel			= "models/weapons/c_arms_animations.mdl"
SWEP.UseHands = true

SWEP.Primary.Recoil 		= 0
SWEP.Primary.Damage 		= 0
SWEP.Primary.NumShots 		= 0
SWEP.Primary.Cone 			= 0
SWEP.Primary.ClipSize 		= -1
SWEP.Primary.Delay 			= 0
SWEP.Primary.DefaultClip 	= 0
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "none"

SWEP.Secondary.Ammo 			= "none"

function SWEP:GetViewModelPosition( pos, ang )
	return pos, ang
end

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:DelayedFunc(time, func)
	timer.Simple(time, function() if !IsValid(self) then return end func(self) end)
end

function SWEP:PlayAnim(anim)
	local vm = self.Owner:GetViewModel()
	if IsValid(vm) then
		vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
	end
end

function SWEP:SelectClientWeapon(weapon)
	local ply = self.Owner
	if game.SinglePlayer() then
		ply:SelectWeapon(weapon:GetClass())
	else
		net.Start("GASMASK_RequestWeaponSelect")
			net.WriteEntity(weapon)
		net.Send(ply)
	end
end

function SWEP:Deploy()
	if SERVER then
		local ply = self.Owner
		if !self.GASMASK_SignalForDeploy then ply:StripWeapon(self:GetClass()) return end
		
		ply.GASMASK_Ready = false
		ply.GASMASK_Equiped = !ply.GASMASK_Equiped
		
		if ply.GASMASK_Equiped then
			self:PlayAnim("draw")
			self:EmitSound("GASMASK_DrawHolster")
			self:DelayedFunc(0.3, function() self:PlayAnim("put_on") self:EmitSound("GASMASK_Foley") end)
			self:DelayedFunc(0.6, function() self:EmitSound("GASMASK_Inhale") end)
			self:DelayedFunc(1.2, function() ply:ScreenFade(SCREENFADE.OUT, color_black, 0.2, 0.4) self:EmitSound("GASMASK_OnOff") end)
			self:DelayedFunc(1.79, function() ply:GASMASK_RequestModelDraw(true) end)
		else
			self:PlayAnim("take_off")
			self:EmitSound("GASMASK_OnOff")
			ply:GASMASK_RequestModelDraw(false)
			ply:ScreenFade(SCREENFADE.IN, color_black, 0.25, 0.25)
			self:DelayedFunc(0.3, function() self:EmitSound("GASMASK_Foley") end)
			self:DelayedFunc(0.45, function() self:EmitSound("GASMASK_Exhale") end)
			self:DelayedFunc(1.2, function() self:EmitSound("GASMASK_DrawHolster") end)
			self:DelayedFunc(1.25, function() self:PlayAnim("holster") end)
		end
		
		self:DelayedFunc(1.8, function() ply.GASMASK_Ready = true self:SelectClientWeapon(ply.GASMASK_LastWeapon) self:Remove() end)
	end
	
	return false
end

function SWEP:PrimaryAttack()
	return false
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Holster()
	return self.Owner.GASMASK_Ready
end

function SWEP:Think()
	return true
end
