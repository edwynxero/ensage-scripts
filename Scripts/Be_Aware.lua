--<<Messages if gank chances | Version: 1.0>>
--[[
	------------------------------------------
	| Be Aware of Skills Script by edwynxero |
	------------------------------------------
	=============== Version 1.0 ==============

	Description:
	------------
		Shows warning for different skills!

		Currently Includes:
			- Mirana's Moonlight Shadow
			- Spirit Breaker's Charge

		To-Do:
			- Much More....

		*NOTE: You won't be warned if skill casted in fog of war!
]]--

--LIBRARIES
require("libs.Utils")
require("libs.ScriptConfig")

--CONFIG
config = ScriptConfig.new()
config:SetParameter("detectMirana", true)
config:SetParameter("detectSpiritCharge", true)
config:Load()

--SETTINGS
local detect_Mirana        = config.detectMirana
local detect_Spirit_Charge = config.detectSpiritCharge

--CODE
local registered = nil

--[[            Spirit Breaker          ]]
	local mode_bara = false
	local isCharged = false

--[[                Mirana              ]]
	local mode_mirana      = false
	local isMiranaUltimate = false

--[[Loading Script...]]
function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then
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
	local me = entityList:GetMyHero() if not me then return end

	-- Get visible enemies / teammates --
	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO, visible = true, alive = true, team = me:GetEnemyTeam()})
	local teamies = entityList:GetEntities({type=LuaEntity.TYPE_HERO, visible = true, alive = true, team = me.team})


	for i,v in ipairs(enemies) do
		if v.classId == CDOTA_Unit_Hero_Mirana and detect_Mirana then checkMirana(enemies) end
		if v.classId == CDOTA_Unit_Hero_SpiritBreaker and detect_Spirit_Charge then checkCharge(teamies) end
	end
end

function checkCharge(players)
	local target = nil
	for i,v in ipairs(players) do
		if mode_bara then
			if v.visible == true and not v:DoesHaveModifier("modifier_spirit_breaker_charge_of_darkness_vision") then
				mode_bara = false
			end
		elseif not isCharged then
			if v:DoesHaveModifier("modifier_spirit_breaker_charge_of_darkness_vision") then
				target = v
				isCharged = true
				mode_bara = true
			end
		end
	end

	if isCharged and target then
		GenerateSideMessage(target.name:gsub("npc_dota_hero_",""),"spirit_breaker_charge_of_darkness")
		isCharged = not isCharged
	end
end

function checkMirana(players)
	for i,v in ipairs(players) do
		if mode_mirana then
		 	if v.visible == true and not v:DoesHaveModifier("modifier_mirana_moonlight_shadow") then
				mode_mirana = false
			end
		elseif not isMiranaUltimate then
			if v:DoesHaveModifier("modifier_mirana_moonlight_shadow") then
				isMiranaUltimate = true
				mode_mirana = true
			end
		end
	end

	if isMiranaUltimate then
		GenerateSideMessage("mirana","mirana_invis")
		isMiranaUltimate = not isMiranaUltimate
	end
end

function GenerateSideMessage(heroName,spellName)
	local test = sideMessage:CreateMessage(200,60)
	test:AddElement(drawMgr:CreateRect(10,10,72,40,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/heroes_horizontal/"..heroName)))
	test:AddElement(drawMgr:CreateRect(85,16,62,31,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/other/arrow_usual")))
	test:AddElement(drawMgr:CreateRect(150,11,40,40,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/spellicons/"..spellName)))
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
