--<<The epic Skywrath Mage Combo!>>

--LIBRARIES
require("libs.ScriptConfig")
require("libs.TargetFind")

--CONFIG
config = ScriptConfig.new()
config:SetParameter("ComboKey", "D", config.TYPE_HOTKEY)
config:SetParameter("UseMysticFlare", false)
config:SetParameter("TargetLeastHP", false)
config:Load()

--SETTINGS
local comboKe		 = config.ComboKey
local useMysticFlare = config.UseMysticFlare
local getLeastHP	 = config.TargetLeastHP
local rang			 = 900

--CODE
local target 	= nil
local active 	= false

--[[Loading Script...]]
function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Skywrath_Mage then
			script:Disable()
		else
			reg = true
			script:RegisterEvent(EVENT_TICK,Tick)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
	end
end

--check if comboKey is pressed
function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if IsKeyDown(comboKey) then
		active = not active
	end
end

function Tick(tick)
	if not SleepCheck() then return end Sleep(200)
	
	local me = entityList:GetMyHero()
	if not (me and active) then return end
	
	-- Get hero abilities --
	local ArcaneBolt 	 = me:GetAbility(1)
	local ConcussiveShot = me:GetAbility(2)
	local AncientSeal 	 = me:GetAbility(3)
	local MysticFlare 	 = me:GetAbility(4)
	
	-- Get visible enemies --
	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO, visible = true, alive = true, team = me:GetEnemyTeam(), illusion=false})
	
	for i,v in ipairs(enemies) do
		local distance = GetDistance2D(v,me)
		
		-- Get a valid target in range --
		if not target and distance < range then
			target = v
		end
		
		-- Get the closest / least health target --
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
	
	-- Do the combo! --
	if target and me.alive then
		CastSpell(ArcaneBolt,target)
		CastSpell(AncientSeal,target)
		CastSpell(ConcussiveShot,nil)
		if useMysticFlare then CastSpell(MysticFlare,target.position) end
		me:Attack(target)
		return
	end

end

function CastSpell(spell,victim)
	if spell.state == LuaEntityAbility.STATE_READY then
		if victim == nil then
			entityList:GetMyPlayer():UseAbility(spell)
		else
			entityList:GetMyPlayer():UseAbility(spell,victim)
		end
	end
end

function GameClose()
	collectgarbage("collect")
	if reg then
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		reg = false
		statusText.visible = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
