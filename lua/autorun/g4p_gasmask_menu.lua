if CLIENT then
	AddCSLuaFile()
	
	CreateClientConVar("g4p_gasmask_sndtype", "1", true, false)
	CreateClientConVar("g4p_gasmask_drawtpmodel", 1, true, false)
	CreateClientConVar("g4p_gasmask_drawhudmodel", 1, true, false)
	
	local function G4P_GASMASK_MENU_PANEL(panel)
		panel:ClearControls()
		
		panel:AddControl("Label", {Text = "\nGas Mask settings"})
		
		local label = vgui.Create("DLabel", panel)
		label:SetText("To use the gas mask, bind 'g4p_gasmask_toggle' to a key")
		label:SetTextColor(Color(0,180,250,255))
		panel:AddItem(label)
		
		local slider = vgui.Create("DNumSlider", panel)
		slider:SetDecimals(0)
		slider:SetMin(0)
		slider:SetMax(5)
		slider:SetConVar("g4p_gasmask_sndtype")
		slider:SetValue(GetConVar("g4p_gasmask_sndtype"):GetInt())
		slider:SetText("Breathing sound")
		slider:SetTooltip("0 disables the sound")
		panel:AddItem(slider)

		panel:AddControl("CheckBox", {Label = "Draw first person (HUD) mask model?", Command = "g4p_gasmask_drawhudmodel"})
		
		panel:AddControl("CheckBox", {Label = "Draw third person mask model (on player's face)?", Command = "g4p_gasmask_drawtpmodel"})
	end
	
	local function G4P_GASMASK_PopulateToolMenu()
		spawnmenu.AddToolMenuOption("Utilities", "Gmod4phun", "G4P_GASMASK_MENU", "Gas Mask", "", "", G4P_GASMASK_MENU_PANEL)
	end
	
	hook.Add("PopulateToolMenu", "G4P_GASMASK_PopulateToolMenu", G4P_GASMASK_PopulateToolMenu)
	
	cvars.RemoveChangeCallback("g4p_gasmask_sndtype", "g4p_gasmask_sndtype_change")
	cvars.AddChangeCallback("g4p_gasmask_sndtype", function(cvar, old, new)
		local ply = LocalPlayer()
		if ply.GASMASK_BreathSound then
			ply.GASMASK_BreathSound:Stop()
			ply.GASMASK_BreathSound = nil
		end
	end, "g4p_gasmask_sndtype_change")
	
	cvars.RemoveChangeCallback("g4p_gasmask_drawtpmodel", "g4p_gasmask_drawtpmodel_change")
	cvars.AddChangeCallback("g4p_gasmask_drawtpmodel", function(cvar, old, new)
		LocalPlayer():SetNWBool("GASMASK_DrawTPModel", tobool(new))
	end, "g4p_gasmask_drawtpmodel_change")
end
