--<<Automatic Steal/Deny Aegis (Reworked) | Version: 1.0>>
--[[
	----------------------------------
	→ Script : Automatic Aegis Script 
	→ Version: 1.0
	→ Made By: edwynxero
	----------------------------------

	Description:
	------------
		Steals or Denies the aegis according to skills available and within range from rosh pit.

	Change log:
	-----------
		» Version 1.0 : Intial Release (Rework of old script)

	Other Information:
	------------------
		Stealing using following spell(s):
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

		Denies using following spell(s):
			- Sniper(shrapnel, deny)
			- Spawn Plague Ward and Deny

		Heroes which doesn't works.
			→ Steal
				- Earth Spirit Combo
				- Spectre(Haunt -> Reality illusion closest to aegis->steal->spectral dagger out)
			→ Deny
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
]]--

--→ LIBRARIES
require("libs.Utils")
require("libs.ScriptConfig")

--→ CONFIG
local config = ScriptConfig.new()
config:SetParameter("StealAegis", "J", config.TYPE_HOTKEY)
config:SetParameter("DenyAegis", "K", config.TYPE_HOTKEY)
config:Load()

--→ SETTINGS
local monitor     = client.screenSize.x/1600
local stealKey    = config.StealAegis
local denyKey     = config.DenyAegis
local stealActive = false
local denyActive  = false
local registered  = false

--→ CODE
local hotkeyText -- toggleKey might be a keycode number, so string.char doesn't throws an error!!
if string.byte("A") <= stealKey and stealKey <= string.byte("Z") then
	hotkeyText = string.char(stealKey) .." | "..string.char(denyKey)
else
	hotkeyText = ""..stealKey.." | "..denyKey
end

local F14        = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor)
local statusText = drawMgr:CreateText(10*monitor,590*monitor,-1,"( Key: " .. hotkeyText .. " ) Steal | Deny Aegis: OFF | OFF",F14)
local aegisLoc   = Vector(4164,-1831,0)
local spellLoc   = Vector(4077,-2143,0)
local aegisDeny  = nil

--→ Load Script
function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then
			script:Disable()
		else
			registered = true
			script:RegisterEvent(EVENT_TICK,Main)
			script:RegisterEvent(EVENT_KEY,Key)
			script:RegisterEvent(EVENT_DOTA,Roshan)
			script:UnregisterEvent(onLoad)
		end
	end
end

--→ check if steal/deny Key is pressed
function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if IsKeyDown(stealKey) then
		stealActive = not stealActive
		if stealActive and denyActive then
			statusText.text = "( Key: " .. hotkeyText .. " ) Steal | Deny Aegis: ON | ON"
		elseif stealActive and not denyActive then
			statusText.text = "( Key: " .. hotkeyText .. " ) Steal | Deny Aegis: ON | OFF"
		elseif not stealActive and denyActive then
			statusText.text = "( Key: " .. hotkeyText .. " ) Steal | Deny Aegis: OFF | ON"
		else
			statusText.text = "( Key: " .. hotkeyText .. " ) Steal | Deny Aegis: OFF | OFF"
		end
	elseif IsKeyDown(denyKey) then
		denyActive = not denyActive
		if denyActive and stealActive then
			statusText.text = "( Key: " .. hotkeyText .. " ) Steal | Deny Aegis: ON | ON"
		elseif not denyActive and stealActive then
			statusText.text = "( Key: " .. hotkeyText .. " ) Steal | Deny Aegis: ON | OFF"
		elseif denyActive and not stealActive then
			statusText.text = "( Key: " .. hotkeyText .. " ) Steal | Deny Aegis: OFF | ON"
		else
			statusText.text = "( Key: " .. hotkeyText .. " ) Steal | Deny Aegis: OFF | OFF"
		end
	end
end

function Main(tick)
	if not SleepCheck() then return end Sleep(200)

	local me = entityList:GetMyHero()
	if not me and not (stealActive or denyActive) then return end

	local myID = me.classId
	local blinkDagger = me:FindItem("item_blink")

	if blinkDagger or myID == CDOTA_Unit_Hero_EmberSpirit or myID == CDOTA_Unit_Hero_AntiMage or myID == CDOTA_Unit_Hero_Rattletrap or myID == CDOTA_Unit_Hero_FacelessVoid or myID == CDOTA_Unit_Hero_Magnataur or myID == CDOTA_Unit_Hero_SandKing or myID == CDOTA_Unit_Hero_QueenOfPain or myID == CDOTA_Unit_Hero_Morphling or myID == CDOTA_Unit_Hero_Naga_Siren or myID == CDOTA_Unit_Hero_StormSpirit or myID == CDOTA_Unit_Hero_Sniper or myID == CDOTA_Unit_Hero_Venomancer then
		statusText.visible = true
	end

	if me.alive and not me:IsChanneling() then
		local items = entityList:GetEntities({type=LuaEntity.TYPE_ITEM_PHYSICAL})
		for i,v in ipairs(items) do
			local IH = v.itemHolds
			if IH.name == "item_aegis" and GetDistance2D(v,me) <= 400 and stealActive then
				entityList:GetMyPlayer():TakeItem(v)
				break
			elseif IH.name == "item_aegis" and denyActive and aegisDeny then
				aegisDeny:Attack(v)
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

		if kill.name == "dota_roshan_kill" and stealActive then
			if GetDistance2D(aegisLoc,me) <= 1200 and blinkDagger then
				CastSpell(blinkDagger,aegisLoc)

			elseif myID == CDOTA_Unit_Hero_EmberSpirit and GetDistance2D(spellLoc,me) <= 700 then
				local Slight_of_Fist = me:GetAbility(2)
				CastSpell(Slight_of_Fist,spellLoc)

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
			end
		end
		if kill.name == "dota_roshan_kill" and denyActive then
			if myID == CDOTA_Unit_Hero_Sniper and GetDistance2D(aegisLoc,me) <= 950 then
				local Sharpnel = me:GetAbility(1)
				local Take_Aim = me:GetAbility(3)
				Take_Aim_Range = {100,200,300,400}
				bonusrange = 0
				if Take_Aim and Take_Aim.level > 0 then
					bonusrange = Take_Aim_Range[Take_Aim.level]
				end
				CastSpell(Sharpnel,aegisLoc)
				if GetDistance2D(aegisLoc,me) <= me.attackRange + bonusrange then
					aegisDeny = me
				end

			elseif myID == CDOTA_Unit_Hero_Venomancer and GetDistance2D(aegisLoc,me) <= 950 then
				local PlagueWard = me:GetAbility(3)
				local ward = entityList:GetEntities({classId=CDOTA_BaseNPC_Venomancer_PlagueWard,alive = true,visible = true,controllable=true})
				CastSpell(PlagueWard,spellLoc)
				for l,k in ipairs(ward) do
					aegisDeny = k
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

function onClose()
	collectgarbage("collect")
	if registered then
		script:UnregisterEvent(Roshan)
		script:UnregisterEvent(Key)
		script:UnregisterEvent(Main)
		statusText.visible = false
		registered = false
	end
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
