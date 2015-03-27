--<<Reports gank chances | Version: 1.1>>
--[[
	------------------------------------------
	→ Script : Be Aware
	→ Version: 1.1
	→ Made By: edwynxero
	-------------------------------------------

	Description:
	------------
		Shows warning for different skills!

		Includes:
			» Mirana's Moonlight Shadow

	Change log:
	-----------
		» Version 1.1 : 
		» Version 1.0 : Initial release
]]--

--→ LIBRARIES
require("libs.Utils")
require("libs.ScriptConfig")

--→ CONFIG
config = ScriptConfig.new()
config:SetParameter("detectMirana", true)
config:Load()

--→ SETTINGS
local detect_Mirana = config.detectMirana

--→ CODE
local registered = nil

--→ CODE » Mirana
local isMoonlightCasted = false

--→ CODE » Oracle
local isFortunesEnd     = false

--→ Load Script
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

	--→ get visible cast & heroes
	local cast    = entityList:GetEntities({classId=CDOTA_BaseNPC})
	local heroes  = entityList:GetEntities({type=LuaEntity.TYPE_HERO})

	for i,v in ipairs(heroes) do
		if v.team ~= team and not v:IsIllusion() then
			if v.classId == CDOTA_Unit_Hero_Mirana then MoonlightShadow(heroes, team) Sleep(1000) end
			if v.classId == CDOTA_Unit_Hero_Oracle then FortunesEnd(cast, heroes, team) Sleep(1000) end
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

function FortunesEnd(cast, heroes, team)
	for i,v in ipairs(cast) do
		if v.team ~= team and v.dayVision == 215 and v.unitState == 29901056 then
			GenerateSideMessage("oracle","oracle_fortunes_end")
		end
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
