--<<Epic Ancient Apparition Combo | Version: 1.0>>
--[[
	------------------------------------------
	→ Script : Ancient Apparition Combo Script
	→ Version: 1.0
	→ Made By: edwynxero
	-------------------------------------------

	Description:
	------------
		Performs Ancient Apparition Ultimate Combo in following steps:
			» Cold Feet
			» Cyclone (Eul Scepter) - if available
			» Ice Vortex
			» Chilling Touch
			» Ice Blast
		Features
			» Excludes Illusions
			» One Key Combo Toggle

	Change log:
	-----------
		» Version 1.0 : Initial release
]]--

--→ LIBRARIES
require("libs.ScriptConfig")
require("libs.TargetFind")

--→ CONFIG
config = ScriptConfig.new()
config:SetParameter("ComboKey", "D", config.TYPE_HOTKEY)
config:SetParameter("TargetLeastHP", false)
config:Load()

--→ SETTINGS
local comboKey       = config.ComboKey
local getLeastHP     = config.TargetLeastHP
local registered     = false
local range          = 650

--→ CODE
local sleepTick   = 0
local currentTick = 0
local comboState  = 0
local target      = nil
local active      = false

--→ Load Script!
function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_AncientApparition then
			script:Disable()
		else
			registered = true
			script:RegisterEvent(EVENT_TICK,Main)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(onLoad)
		end
	end
end

--→ check if comboKey is pressed
function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if IsKeyDown(comboKey) then
		active = not active
		if active then
			comboState = 0
		end
	end
end

function Main(tick)
	currentTick = tick
	if not SleepCheck() then return end Sleep(200)

	local me = entityList:GetMyHero()
	if not (me and active) then return end

	--→ get hero abilities
	local ColdFeet      = me:GetAbility(1)
	local IceVortex     = me:GetAbility(2)
	local ChillingTouch = me:GetAbility(3)
	local IceBlast      = me:GetAbility(4)

	--→ get visible enemies
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

	--→ perform the combo!
	if target and me.alive and not SleepCheck() then
		if comboState == 0 then
			CastSpell(ColdFeet,target)
			comboState = 1
			Sleep(850)
        elseif comboState == 1 then
			CastSpell(IceVortex,target.position,true)
			CastSpell(ChillingTouch,me.position,true)
			if me:FindItem("item_cyclone") then
				CastSpell(me:FindItem("item_cyclone"),target)
				comboState = 2
				Sleep(2500)
			else
				comboState = 2
			end
		else
			CastSpell(IceBlast,target.position)
		end
		return
	end
end

function CastSpell(spell, victim, isQueued)
	if spell.state == LuaEntityAbility.STATE_READY then
		if isQueued == nil then
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
