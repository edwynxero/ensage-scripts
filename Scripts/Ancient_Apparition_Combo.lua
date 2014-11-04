--[[
	------------------------------------------------
	| Ancient Apparition Combo Script by edwynxero |
	------------------------------------------------
	================== Version 1.0 =================
	 
	Description:
	------------
		Ancient Apparition Ultimate Combo
			- Cold Feet
			- Cyclone (Eul Scepter)
			- Ice Vortex
			- Chilling Touch
			- Ice Blast
		Features
			- Excludes Illusions
			- One Key Combo Toggle
]]--

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
local comboKey       = config.ComboKey
local useMysticFlare = config.UseMysticFlare
local getLeastHP     = config.TargetLeastHP
local registered	 = false
local range          = 650

--CODE
local sleepTick   = 0
local currentTick = 0
local comboState  = 0
local target      = nil
local active      = false

--[[Loading Script...]]
function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_AncientApparition then
			script:Disable()
		else
			registered = true
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
		if active then
			comboState = 0
		end
	end
end

function Tick(tick)
	currentTick = tick
	if not SleepCheck() then return end Sleep(200)
	
	local me = entityList:GetMyHero()
	if not (me and active) then return end
	
	-- Get hero abilities --
	local ColdFeet      = me:GetAbility(1)
	local IceVortex     = me:GetAbility(2)
	local ChillingTouch = me:GetAbility(3)
	local IceBlast      = me:GetAbility(4)
	
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
	if target and me.alive and not SleepCheck() then
		if comboState == 0 then
			CastSpell(ColdFeet,target)
			comboState = 1
			Sleep(850)
        elseif comboState == 1 then
			CastSpell(me:FindItem("item_cyclone"),target)
			CastSpell(IceVortex,target.position,true)
			CastSpell(ChillingTouch,me.position,true)
			comboState = 2
			Sleep(2500)
		else
			comboState = comboState + 1
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

function Sleep(duration)
	sleepTick = currentTick + duration
end
 
function SleepCheck()
	return sleepTick == nil or currentTick > sleepTick
end

function GameClose()
	collectgarbage("collect")
	if registered then
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		registered = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
