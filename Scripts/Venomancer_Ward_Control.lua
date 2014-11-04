--[[
	------------------------------------------------
	| Venomancer Wards Control Script by edwynxero |
	------------------------------------------------
	================== Version 1.0 =================
	 
	Description:
	------------
		Venomancer Plague Wards
			- Attacks Hero without de-buff
			- Deny ally creeps
			- Last Hit enemy creeps
		Features
			- Excludes Illusions
			- Enable / Disable feature for all procs
]]--

--<< (Deny / Last Hit) Creeps | Slow Enemies with Plague Wards >>
--LIBRARIES
require("libs.ScriptConfig")
require("libs.Utils")

--CONFIG
config = ScriptConfig.new()
config:SetParameter("SlowEnemies", true)
config:SetParameter("DenyWithWards", true)
config:SetParameter("LastHitWithWards", true)
config:Load()

--SETTINGS
local slowEnemy 	= config.SlowEnemies
local wardLastHit 	= config.LastHitWithWards
local wardDeny 		= config.DenyWithWards
local registered	= false

--CODE
damage 		= {10,19,29,38}
damage[0] 	= 0

--[[Loading Script...]]
function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Venomancer then
			script:Disable()
		else
			registered = true
			script:RegisterEvent(EVENT_TICK,Tick)
			script:UnregisterEvent(Load)
		end
	end
end

function Tick(tick)
	if not SleepCheck() then return end Sleep(200)
	
	local me = entityList:GetMyHero()
	if not (me and active) then return end
	
	-- Get hero abilities --
	local abilityName = me:FindSpell("venomancer_plague_ward")
	
	-- Get visible enemies --
	local enemies 	= entityList:GetEntities({type=LuaEntity.TYPE_HERO,visible = true, alive = true, team = me:GetEnemyTeam(),illusion=false})
	-- Get creeps in range
	local creeps 	= entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane,alive=true,visible=true})
	-- Get Plague Wards in range
	local ward 		= entityList:GetEntities({classId=CDOTA_BaseNPC_Venomancer_PlagueWard,alive = true,visible = true,controllable=true})
	
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
		
			if v.team ~= me.team and wardLastHit and v.visible and v.alive and v.health > 0 and v.health < (damage[abilityName.level]*(1-v.dmgResist)+20) then	
				for l,k in ipairs(ward) do
					if GetDistance2D(v,k) < k.attackRange and SleepCheck(k.handle) then						
						k:Attack(v)
						Sleep(1000,k.handle)
						break
					end
				end
				
			elseif v.team == me.team and wardDeny and v.visible and v.alive and v.health > (damage[abilityName.level]*(1-v.dmgResist)) and v.health < (damage[abilityName.level]*(1-v.dmgResist))+88 then	
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

function GameClose()
	collectgarbage("collect")
	if registered then
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		registered = false
	end
end

script:RegisterEvent(EVENT_TICK, Tick)
