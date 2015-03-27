--<<Epic Skyrath Mage Combo | Version: 1.2>>
--[[
	------------------------------------------
	→ Script : Skywrath Combo
	→ Version: 1.2
	→ Made By: edwynxero
	------------------------------------------- 

	Description:
	------------
		Skywrath Mage Ultimate Combo
			» Arcane Bolt
			» Ancient Seal
			» Concussive Shot
			» Rod of Atos (if MysticFlare enabled)
			» Mystic Flare (if enabled)
		Features
			» Excludes Illusions
			» One Key Combo Toggle
		*Has enabling function for using ultimate in combo, but currently works perfectly only on static heroes (i.e. stunned)

	Change log:
	-----------
		» Version 1.2
		» Version 1.1
		» Version 1.0 : Initial Release
]]--

--→ LIBRARIES
require("libs.ScriptConfig")
require("libs.TargetFind")

--→ CONFIG
config = ScriptConfig.new()
config:SetParameter("ComboKey", "D", config.TYPE_HOTKEY)
config:SetParameter("UseMysticFlare", false)
config:SetParameter("TargetLeastHP", false)
config:Load()

--→ SETTINGS
local comboKey       = config.ComboKey
local useMysticFlare = config.UseMysticFlare
local getLeastHP     = config.TargetLeastHP
local registered	 = false
local range          = 900

--→ CODE
local sleepMain     = 0
local currentMain   = 0
local target        = nil
local active        = false

--→ Load Script
function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Skywrath_Mage then
			script:Disable()
		else
			registered = true
			script:RegisterEvent(EVENT_TICK,Main)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(onLoad)
		end
	end
end

--→  check if "combo key" is pressed
function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if code == comboKey then
		active = (msg == KEY_DOWN)
	end
end

function Main(tick)
	currentMain = tick
	if not SleepCheck() then return end Sleep(200)

	local me = entityList:GetMyHero()
	if not (me and active) then return end

	--→ get hero abilities
	local ArcaneBolt     = me:GetAbility(1)
	local ConcussiveShot = me:GetAbility(2)
	local AncientSeal    = me:GetAbility(3)
	local MysticFlare    = me:GetAbility(4)

	--→ et visible enemies
	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO, visible = true, alive = true, team = me:GetEnemyTeam(), illusion=false})

	for i,v in ipairs(enemies) do
		local distance = GetDistance2D(v,me)

		--→ get a valid target in range
		if not target and distance < range then
			target = v
		end

		--→ get the closest / least health target
		if target then
			if getLeastHP and distance < range then
				target = targetFind:GetLowestEHP(range,"magic")
			elseif distance < GetDistance2D(target,me) and target.alive then
				target = v
			elseif GetDistance2D(target,me) > range or not target.alive then
				target = nil
				active = false
			end
		end
	end

	--→ do the combo!
	if target and me.alive then
		CastSpell(ArcaneBolt, target)
		CastSpell(AncientSeal, target)
		CastSpell(ConcussiveShot)
		if useMysticFlare then
			if me:FindItem("item_rod_of_atos") then
				CastSpell(me:FindItem("item_rod_of_atos"), target)
			end
			CastSpell(MysticFlare, target.position, true)
		end
		return
	end

end

function CastSpell(spell,victim, isQueued)
	if spell.state == LuaEntityAbility.STATE_READY then
		if victim == nil then
			entityList:GetMyPlayer():UseAbility(spell)
		elseif isQueued == nil then
			entityList:GetMyPlayer():UseAbility(spell, victim)
		else
			entityList:GetMyPlayer():UseAbility(spell, victim, isQueued)
		end
	end
end

function onClose()
	collectgarbage("collect")
	if registered then
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		registered = false
	end
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
