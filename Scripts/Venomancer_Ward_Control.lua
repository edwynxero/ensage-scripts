--<<(Deny / Last Hit) Creeps, debuffs enemy with Plague Ward(s) | Version: 1.1>>
--[[
	------------------------------------------
	→ Script : Venomancer Wards Control
	→ Version: 1.1
	→ Made By: edwynxero
	-------------------------------------------
	
	Description:
	------------
		Venomancer Plague Wards
			» Attacks Hero without de-buff
			» Deny ally creeps
			» Last Hit enemy creeps
		Features
			» Excludes Illusions
			» Enable / Disable feature for all procs

	Change log:
	-----------
		» Version 1.1
		» Version 1.0 : Initial Release
]]--

--→ LIBRARIES
require("libs.ScriptConfig")
require("libs.Utils")

--→ CONFIG
config = ScriptConfig.new()
config:SetParameter("SlowEnemies", true)
config:SetParameter("DenyWithWards", true)
config:SetParameter("LastHitWithWards", true)
config:Load()

--→ SETTINGS
local slowEnemy   = config.SlowEnemies
local wardLastHit = config.LastHitWithWards
local wardDeny    = config.DenyWithWards
local registered  = false

--→ CODE
local damage      = {10,19,29,38}
damage[0] 	      = 0

--→ Load Script
function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Venomancer then
			script:Disable()
		else
			registered = true
			script:RegisterEvent(EVENT_TICK,Main)
			script:UnregisterEvent(onLoad)
		end
	end
end

function Main(tick)
	if not SleepCheck() then return end

	local me = entityList:GetMyHero()
	if not me then return end Sleep(125)

	--→ get hero abilities
	local abilityName = me:FindSpell("venomancer_plague_ward")

	--→ get visible enemies
	local enemies     = entityList:GetEntities({type=LuaEntity.TYPE_HERO,visible = true, alive = true, team = me:GetEnemyTeam(),illusion=false})
	--→ get creeps in range
	local creeps      = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane,alive=true,visible=true})
	--→ get visible Plague Wards
	local ward        = entityList:GetEntities({classId=CDOTA_BaseNPC_Venomancer_PlagueWard,alive = true,visible = true,controllable=true})

	for i,v in ipairs(enemies) do
		if not v:DoesHaveModifier("modifier_venomancer_poison_sting_ward") and v.health > 0 and slowEnemy then
			for l,k in ipairs(ward) do
				if GetDistance2D(v,k) < k.attackRange and SleepCheck(k.handle) then
					k:Attack(v)
					Sleep(1000,k.handle)
					break
				end
			end
		end
	end

	for i,v in ipairs(creeps) do
		local OnScreen = client:ScreenPosition(v.position)
		if OnScreen then
			local offset = v.healthbarOffset
			if offset == -1 then return end
			if v.visible and v.alive then
				if v.team ~= me.team and wardLastHit and v.health > 0 and v.health < (damage[abilityName.level]*(1-v.dmgResist)+20) then
					for l,k in ipairs(ward) do
						if GetDistance2D(v,k) < k.attackRange and SleepCheck(k.handle) then
							k:Attack(v)
							Sleep(1000,k.handle)
							break
						end
					end

				elseif v.team == me.team and wardDeny and v.health > (damage[abilityName.level]*(1-v.dmgResist)) and v.health < (damage[abilityName.level]*(1-v.dmgResist))+88 then
					for l,k in ipairs(ward) do
						if GetDistance2D(v,k) < k.attackRange and SleepCheck(k.handle) then
							k:Attack(v)
							Sleep(1000,k.handle)
							break
						end
					end
				end
			end
		end
	end
end

function onClose()
	collectgarbage("collect")
	if registered then
		script:UnregisterEvent(Main)
		registered = false
	end
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
