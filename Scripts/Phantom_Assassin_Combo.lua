--<< Phantom Assassin closest hero bombing! >>

--===================--
--     LIBRARIES     --
--===================--
require("libs.ScriptConfig")
require("libs.TargetFind")

--===================--
--      CONFIG       --
--===================--
config = ScriptConfig.new()
config:SetParameter("ComboKey", "R", config.TYPE_HOTKEY)
config:SetParameter("GetTargetWithLeastHP", false)
config:Load()

local combokey 		= config.ComboKey
local gethpconfig 	= config.GetTargetWithLeastHP
local range 		= 1000

--===================--
--       CODE        --
--===================--
local target = nil
local sleepTick = nil
local activated = false

function Tick( tick )
	if not client.connected or client.loading or client.console or (sleepTick and sleepTick > tick) or not activated then
		--"Script Not Activated!"
		return
	end
 
	local me = entityList:GetMyHero()
	if not me then return end Sleep(125)
 
	if me.classId ~= CDOTA_Unit_Hero_PhantomAssassin then
		--"Script Disabled!"
		script:Disable()
	else
		-- Get Hero Abilities
		local StiflingDagger = me:GetAbility(1)
		local PhantomStrike = me:GetAbility(2)
		
		-- Get Visible Enemies
		local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO, visible = true, alive = true, team = me:GetEnemyTeam(), illusion=false})
		
		for i,v in ipairs(enemies) do
			local distance = GetDistance2D(v,me)
			
			-- Get a valid target in range 
			if not target and distance < range then
				target = v
			end
			
			-- Get the closest / least health target
			if target then
				if gethpconfig and distance < range then
					target = targetFind:GetLowestEHP(range,"phys")
				elseif distance < GetDistance2D(target,me) then
					target = v
				elseif GetDistance2D(target,me) > range or not target.alive then
					target = nil
				end
			end
		end
		
		if target then
			CastSpell(StiflingDagger,target)
			CastSpell(PhantomStrike,target)
			me:Attack(target)
			sleepTick = tick + 300
			return
		end
	end
end

function CastSpell(spell,victim)
	if spell.state == LuaEntityAbility.STATE_READY then
		entityList:GetMyPlayer():UseAbility(spell,victim)
	end
end

function Key( msg, code )
	if client.console or client.chat then return end
	if code == combokey then
		activated = (msg == KEY_DOWN)
	end
end
 
script:RegisterEvent(EVENT_TICK,Tick)
script:RegisterEvent(EVENT_KEY,Key)
