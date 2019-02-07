AddCSLuaFile()

if SERVER then
	util.AddNetworkString("GASMASK_RequestWeaponSelect")
end

if CLIENT then
	net.Receive("GASMASK_RequestWeaponSelect", function()
		local wep = net.ReadEntity()
		if IsValid(wep) then
			input.SelectWeapon(wep)
		end
	end)
end

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

SWEP.HoldType = "camera"

SWEP.DrawCrosshair		= true
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
SWEP.WorldModel			= "models/gmod4phun/w_contagion_gasmask.mdl"
SWEP.UseHands = false

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

function SWEP:DoDrawCrosshair(x, y)
	return true
end

function SWEP:GetViewModelPosition( pos, ang )
	return pos, ang
end

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
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
		
		local vm = ply:GetViewModel()
		if IsValid(vm) then
			vm:SendViewModelMatchingSequence(vm:LookupSequence("idle_holstered"))
		end
		
		ply.GASMASK_Ready = false
		ply:GASMASK_SetEquipped(!ply.GASMASK_Equiped)
		ply:GASMASK_RequestToggle()
		
		timer.Simple(1.8, function()
			if !IsValid(self) then return end
			ply.GASMASK_Ready = true
			self:SelectClientWeapon(ply.GASMASK_LastWeapon)
			ply:StripWeapon(self:GetClass())
		end)
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
