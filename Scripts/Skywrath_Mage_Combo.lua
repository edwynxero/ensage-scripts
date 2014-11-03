--<< The epic Skywrath Mage Combo! >>

--===================--
--     LIBRARIES     --
--===================--
require("libs.ScriptConfig")
require("libs.TargetFind")

--===================--
--      CONFIG       --
--===================--
config = ScriptConfig.new()
config:SetParameter("ComboKey", "D", config.TYPE_HOTKEY)
config:SetParameter("UseMysticFlare", false)
config:SetParameter("GetTargetWithLeastHP", false)
config:Load()

local combokey 		= config.ComboKey
local gethpconfig 	= config.GetTargetWithLeastHP
local useultimate 	= config.UseMysticFlare
local range 		= 900

--===================--
--       CODE        --
--===================--
local target 	= nil
local sleepTick = nil
local activated = false

-- define ability names
local ArcaneBolt 		= nil
local ConcussiveShot	= nil
local AncientSeal 		= nil
local MysticFlare 		= nil

function Tick( tick )
	if not client.connected or client.loading or client.console or (sleepTick and sleepTick > tick) or not activated then
		--"Script Not Activated!"
		return
	end
 
	local me = entityList:GetMyHero()
	if not me then return end Sleep(125)
 
	if me.classId ~= CDOTA_Unit_Hero_Skywrath_Mage then
		--"Script Disabled!"
		script:Disable()
	else
		-- Get Hero Abilities
		ArcaneBolt 		= me:GetAbility(1)
		ConcussiveShot 	= me:GetAbility(2)
		AncientSeal 	= me:GetAbility(3)
		MysticFlare 	= me:GetAbility(4)
		
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
			
			if target then
				CastCombo(target) 
				return	
			end
		end
		sleepTick = tick + 300
	end
end

function CastCombo(victim)
	if ArcaneBolt.state == LuaEntityAbility.STATE_READY then
		entityList:GetMyPlayer():UseAbility(ArcaneBolt,victim)
		Sleep(125)
	end
	if AncientSeal.state == LuaEntityAbility.STATE_READY then
		entityList:GetMyPlayer():UseAbility(AncientSeal,victim)
		Sleep(125)
	end
	if ConcussiveShot.state == LuaEntityAbility.STATE_READY then
		entityList:GetMyPlayer():UseAbility(ConcussiveShot)
		Sleep(125)
	end
	if MysticFlare.state == LuaEntityAbility.STATE_READY and useultimate then
		entityList:GetMyPlayer():UseAbility(MysticFlare,victim.position)
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
