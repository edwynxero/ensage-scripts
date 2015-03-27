--<<Epic Phantom Assassin Combo | Version: 1.2>>
--[[
	------------------------------------------
	→ Script : Phantom Assassin Combo
	→ Version: 1.2
	→ Made By: edwynxero
	-------------------------------------------
	
	Description:
	------------
		Phantom Assassin Ultimate Combo
			» Stifling Dagger
			» Phantom Strike
			» Abbysal Blade (work in progress)
		Features
			» Excludes Illusions
			» One Key Combo Initiator (keep key pressed to continue combo)

	Change log:
	-----------
		» Version 1.2
		» Version 1.1
		» Version 1.0 : Initial Release
]]--

--→ LIBRARIES
require("libs.ScriptConfig")
require("libs.TargetFind")

--→ CONFIGURATION
config = ScriptConfig.new()
config:SetParameter("ComboKey", "R", config.TYPE_HOTKEY)
config:SetParameter("TargetLeastHP", false)
config:Load()

--→ SETTINGS
local comboKey 		= config.ComboKey
local getLeastHP 	= config.TargetLeastHP
local registered	= false
local range 		= 1000

--→ CODE
local target	    = nil
local active	    = false

--→ Load Script
function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_PhantomAssassin then
			script:Disable()
		else
			registered = true
			script:RegisterEvent(EVENT_TICK,Main)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(onLoad)
		end
	end
end

--→ check if "combo key" is pressed
function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if code == comboKey then
		active = (msg == KEY_DOWN)
	end
end

function Main(tick)
	if not SleepCheck() then return end

	local me = entityList:GetMyHero()
	local myPlayer = entityList:GetMyPlayer().selection[1]
	if not (me and active) then return end

	--→ get hero abilities
	local StiflingDagger = me:GetAbility(1)
	local PhantomStrike = me:GetAbility(2)

	--→ get visible enemies
	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO, visible = true, alive = true, team = me:GetEnemyTeam(), illusion=false})

	for i,v in ipairs(enemies) do
		local distance = GetDistance2D(v,me)

		--→ get a valid target in range
		if not target and distance < range then
			target = v
		elseif distance > range then
			target = nil
		end

		--→ get the lowest health, if not get closest
		if target then
			if target.alive and target.visible then
				if getLeastHP then
					target = targetFind:GetLowestEHP(range,"phys")
				elseif distance < GetDistance2D(target,me) then
					target = v
				end
			else
				target = nil
			end
		end
	end

	--→ Do the combo!
	if target and me.alive and not me:IsChanneling() then
		if myPlayer and myPlayer.handle == me.handle then
			CastSpell(StiflingDagger,target)
			CastSpell(PhantomStrike,target)
			me:Attack(target)
		end
		Sleep(200)
		return
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
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		registered = false
	end
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
