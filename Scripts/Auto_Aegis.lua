--[[
	---------------------------------------
	| Automatic Aegis Script by edwynxero |
	---------------------------------------
	============= Version 1.0 =============
	
	Description:
	------------
		Heroes TO DO :
			===Steal===
			- Earth Spirit Combo
			- Spectre(Haunt -> Reality illusion closest to aegis->steal->spectral dagger out)
			====Deny===
			- Lycan         (Invisible Wolves)
			- Broodmother   (Spiderlings)
			- Enigma        (Demonic Conversions)
			- Invoker       (Forged Spirits)
			- Lone Druid    (Bear)
			- Naga Siren    (Illusions)
			- Nature Profet (Nature Call)
			- Shadow Shaman (Serpent ward)
			- TerrorBlade   (Illusions)
			- Visage        (Familiars)
			- Warlock       (Chaotic Offering Roshan-pit)

		Stealing:
			- Blink Dagger
			- Antimage      (Blink)
			- Clockwork     (Hookshot)
			- Ember Spirit  (Slight of Fist)
			- Faceless Void (Timewalk)
			- Magnus        (Skeewer)
			- Morphling     (Waveform)
			- Naga Siren    (Song of the Siren)
			- Sand King     (Blink Dagger / Burrowstrike / Combo)
			- Storm Spirit  (Ball Lightning)
			- Queen of Pain (Blink)

		Deny:
			- Sniper(shrapnel, deny)
			- Spawn Plague Ward and Deny
]]--

--LIBRARIES
require("libs.Utils")
require("libs.ScriptConfig")

--CONFIG
local config = ScriptConfig.new()
config:SetParameter("ToggleKey", "J", config.TYPE_HOTKEY)
config:Load()

--SETTINGS
local monitor    = client.screenSize.x/1600
local toggleKey  = config.ToggleKey
local active     = false
local registered = false

--CODE
local F14        = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText = drawMgr:CreateText(10*monitor,590*monitor,-1,"( Key: " .. string.char(toggleKey) .. " ) Steal Aegis: OFF",F14)
local aegisLoc   = Vector(4164,-1831,0)
local eFistLoc   = Vector(4077,-2143,0)

local hotkeyText -- toggleKey might be a keycode number, so string.char will throw an error!!
if string.byte("A") <= toggleKey and toggleKey <= string.byte("Z") then
	hotkeyText = string.char(toggleKey)
else
	hotkeyText = ""..toggleKey
end

--[[Loading Script...]]
function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then
			script:Disable()
		else
			registered = true
			script:RegisterEvent(EVENT_TICK,Tick)
			script:RegisterEvent(EVENT_KEY,Key)
			script:RegisterEvent(EVENT_DOTA,Roshan) 
			script:UnregisterEvent(Load)
		end
	end
end

--check if toggleKey is pressed
function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if IsKeyDown(toggleKey) then
		active = not active
		if active then
			statusText.text = "( Key: " .. hotkeyText .. " ) Steal Aegis: ON"
		else
			statusText.text = "( Key: " .. hotkeyText .. " ) Steal Aegis: OFF"
		end
	end
end

function Tick(tick)
	if not SleepCheck() then return end
	
	local me = entityList:GetMyHero()
	if not (me and active) then return end
	
	local myID = me.classId
	local blinkDagger = me:FindItem("item_blink")
	
	if blinkDagger or myID == CDOTA_Unit_Hero_EmberSpirit or myID == CDOTA_Unit_Hero_AntiMage or myID == CDOTA_Unit_Hero_Rattletrap or myID == CDOTA_Unit_Hero_FacelessVoid or myID == CDOTA_Unit_Hero_Magnataur or myID == CDOTA_Unit_Hero_SandKing or myID == CDOTA_Unit_Hero_QueenOfPain or myID == CDOTA_Unit_Hero_Morphling or myID == CDOTA_Unit_Hero_Naga_Siren or myID == CDOTA_Unit_Hero_StormSpirit or myID == CDOTA_Unit_Hero_Sniper or myID == CDOTA_Unit_Hero_Venomancer then
		statusText.visible = true
	end
	
	if me.alive and not me:IsChanneling() then
		local items = entityList:GetEntities({type=LuaEntity.TYPE_ITEM_PHYSICAL})
		for i,v in ipairs(items) do
			local IH = v.itemHolds
			if IH.name == "item_aegis" and GetDistance2D(v,me) <= 400 then
				entityList:GetMyPlayer():TakeItem(v)
				break
			end
		end
	end
end

function Roshan (kill)
	if PlayingGame() then
		local me          = entityList:GetMyHero()
		local myID        = me.classId
		local blinkDagger = me:FindItem("item_blink")
		
		if kill.name == "dota_roshan_kill" and active then
			if GetDistance2D(aegisLoc,me) <= 1200 and blinkDagger then
				CastSpell(blinkDagger,aegisLoc)
				
			elseif myID == CDOTA_Unit_Hero_EmberSpirit and GetDistance2D(eFistLoc,me) <= 700 then
				local Slight_of_Fist = me:GetAbility(2)
				CastSpell(Slight_of_Fist,eFistLoc)
				
			elseif myID == CDOTA_Unit_Hero_AntiMage and GetDistance2D(aegisLoc,me) <= 1150 then
				local AM_Blink = me:GetAbility(2)
				CastSpell(AM_Blink,aegisLoc)
				
			elseif myID == CDOTA_Unit_Hero_Rattletrap and GetDistance2D(aegisLoc,me) <= 2000 then
				local Hookshot = me:GetAbility(4)
				CastSpell(Hookshot,aegisLoc)
				
			elseif myID == CDOTA_Unit_Hero_FacelessVoid and GetDistance2D(aegisLoc,me) <= 1300 then
				local TimeWalk = me:GetAbility(1)
				CastSpell(TimeWalk,aegisLoc)
				
			elseif myID == CDOTA_Unit_Hero_Magnataur and GetDistance2D(aegisLoc,me) <= 1200 then
				local Skewer = me:GetAbility(3)
				CastSpell(Skewer,aegisLoc)
				
			elseif myID == CDOTA_Unit_Hero_SandKing and GetDistance2D(aegisLoc,me) <= 650 or (blinkDagger and GetDistance2D(aegisLoc,me) <= 1850) then
				local Burrowstrike = me:GetAbility(1)
				if blinkDagger then
					CastSpell(blinkDagger,aegisLoc)
					CastSpell(Burrowstrike,aegisLoc)
				else
					CastSpell(Burrowstrike,aegisLoc)
				end
				
			elseif myID == CDOTA_Unit_Hero_QueenOfPain and GetDistance2D(aegisLoc,me) <= 1150 then
				local QOP_Blink = me:GetAbility(2)
				CastSpell(QOP_Blink,aegisLoc)
				
			elseif myID == CDOTA_Unit_Hero_Morphling and GetDistance2D(aegisLoc,me) <= 1000 then
				local Waveform = me:GetAbility(1)
				CastSpell(Waveform,aegisLoc)
				
			elseif myID == CDOTA_Unit_Hero_Naga_Siren and GetDistance2D(aegisLoc,me) <= 1250 then
				local Song_of_the_siren = me:GetAbility(4)
				CastSpell(Song_of_the_siren,aegisLoc)
				
			elseif myID == CDOTA_Unit_Hero_StormSpirit and GetDistance2D(aegisLoc,me) <= 1000 then
				local Ball_Lightning = me:GetAbility(4)
				CastSpell(Ball_Lightning,aegisLoc)
				
			elseif myID == CDOTA_Unit_Hero_Sniper and GetDistance2D(aegisLoc,me) <= 950 then
				local Sharpnel = me:GetAbility(1)
				local Take_Aim = me:GetAbility(3)
				Take_Aim_Range = {100,200,300,400}
				bonusrange = 0
				if Take_Aim and Take_Aim.level > 0 then
					bonusrange = Take_Aim_Range[Take_Aim.level]
				end
				CastSpell(Sharpnel,aegisLoc)
				if GetDistance2D(aegisLoc,me) <= me.attackRange + bonusrange then
					local items = entityList:GetEntities({type=LuaEntity.TYPE_ITEM_PHYSICAL})
					for i,v in ipairs(items) do
						local IH = v.itemHolds
						if IH.name == "item_aegis" then
							me:Attack(v)
							break
						end
					end
				end
				
			elseif myID == CDOTA_Unit_Hero_Venomancer then
				local PlagueWard = me:GetAbility(3)
				local ward = entityList:GetEntities({classId=CDOTA_BaseNPC_Venomancer_PlagueWard,alive = true,visible = true,controllable=true})
				local items = entityList:GetEntities({type=LuaEntity.TYPE_ITEM_PHYSICAL})

				CastSpell(PlagueWard,shortloc)
				for i,v in ipairs(items) do
					for l,k in ipairs(ward) do
						local IH = v.itemHolds
						if IH.name == "item_aegis" and GetDistance2D(v,me) <= k.castRange then
							k:Attack(v)
						end
					end
				end
			end
		end
	end
end

function CastSpell(spell,victim)
	if spell.state == LuaEntityAbility.STATE_READY then
		entityList:GetMyPlayer():UseAbility(spell,victim)
	end
end

function GameClose()
	collectgarbage("collect")
	if registered then
		script:UnregisterEvent(Roshan)
		script:UnregisterEvent(Key)
		script:UnregisterEvent(Tick)
		statusText.visible = false
		registered = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
