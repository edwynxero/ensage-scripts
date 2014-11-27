--<<Messages if gank chances | Version: 1.1>>
--[[
	------------------------------------------
	| Be Aware of Skills Script by edwynxero |
	------------------------------------------
	=============== Version 1.1 ==============

	Description:
	------------
		Shows warning for different skills!

		Currently Includes:
			- Mirana's Moonlight Shadow

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
config:Load()

--SETTINGS
local detect_Mirana = config.detectMirana

--CODE
local registered = nil

--[[                Mirana              ]]
	local isMoonlightCasted = false

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
	local team = me.team

	-- Get visible cast & heroes --
	local cast    = entityList:GetEntities({classId=CDOTA_BaseNPC})
	local heroes  = entityList:GetEntities({type=LuaEntity.TYPE_HERO})

	for i,v in ipairs(heroes) do
		if v.team ~= team and not v:IsIllusion() then
			if v.classId == CDOTA_Unit_Hero_Mirana then MoonlightShadow(heroes, team) end
		end
	end
end

function MoonlightShadow(heroes, team)
	local target = nil
	for i,v in ipairs(heroes) do
		if v.team ~= team and v.visible and v.alive then
			if isMoonlightCasted and not v:DoesHaveModifier("modifier_mirana_moonlight_shadow") then
				isMoonlightCasted = not isMoonlightCasted
			elseif not isMoonlightCasted and v:DoesHaveModifier("modifier_mirana_moonlight_shadow") then
				target = v
				isMoonlightCasted = not isMoonlightCasted
			end
		end
	end
	if target then
		GenerateSideMessage("mirana","mirana_invis")
	end
end

function GenerateSideMessage(heroName,spellName)
	local test = sideMessage:CreateMessage(180,50)
	test:AddElement(drawMgr:CreateRect(10,10,54,30,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/heroes_horizontal/"..heroName)))
	test:AddElement(drawMgr:CreateRect(70,12,62,31,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/other/arrow_usual")))
	test:AddElement(drawMgr:CreateRect(140,10,30,30,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/spellicons/"..spellName)))
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
