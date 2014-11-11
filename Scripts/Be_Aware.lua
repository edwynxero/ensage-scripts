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
			- Techies Mines Info

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
config:SetParameter("detectTechiesMines", true)
config:Load()

--SETTINGS
local detect_Mirana        = config.detectMirana
local detect_TechiesMines  = config.detectTechiesMines
local detect_Spirit_Charge = config.detectSpiritCharge

--CODE
local registered = nil

--[[            Spirit Breaker          ]]
	local mode_bara = false
	local isCharged = false

--[[                Mirana              ]]
	local mode_mirana      = false
	local isMiranaUltimate = false

--[[                Techies             ]]
	local MS        = {}
	local TS        = {}
	local table     = {}
	local MinesInfo = {}
	MinesInfo["npc_dota_techies_land_mine"]   = 150
	MinesInfo["npc_dota_techies_stasis_trap"] = 450
	MinesInfo["npc_dota_techies_remote_mine"] = 425

--[[Loading Script...]]
function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then
			script:Disable()
		else
			registered = true
			script:RegisterEvent(EVENT_TICK,Tick)
			script:UnregisterEvent(Load)
		end
	end
end

function Tick(tick)
	if not SleepCheck() then return end
	local me = entityList:GetMyHero() if not me then return end

	-- Get visible enemies / teammates --
	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO, visible = true, alive = true, team = me:GetEnemyTeam()})
	local teamies = entityList:GetEntities({type=LuaEntity.TYPE_HERO, visible = true, alive = true, team = me.team})


	for i,v in ipairs(enemies) do
		if v.classId == CDOTA_Unit_Hero_Mirana and detect_Mirana then checkMirana(enemies) end
		if v.classId == CDOTA_Unit_Hero_SpiritBreaker and detect_Spirit_Charge then checkCharge(teamies) end
		if v.classId == CDOTA_Unit_Hero_Techies and detect_TechiesMines then checkMines(me.team) end
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

function checkMines(team)
	if SleepCheck("min") then
		local mines = entityList:GetEntities({classId=CDOTA_NPC_TechiesMines})
		local clear = false

		for i,v in ipairs(mines) do
			if v.team ~= team then
				if not MS[v.handle] and v.alive then
					MS[v.handle] = {}
					MS[v.handle].map = drawMgr:CreateRect(0,0,35,35,0x000000FF,drawMgr:GetTextureId("NyanUI/other/"..v.name))
					MS[v.handle].map.entity = v MS[v.handle].map.entityPosition = Vector(0,0,v.healthbarOffset)
					MS[v.handle].eff = Effect(v.position,"range_display")
					MS[v.handle].eff:SetVector(1, Vector(MinesInfo[v.name],0,0))
					MS[v.handle].eff:SetVector(0, v.position)
					local minimap = MapToMinimap(v.position.x,v.position.y)
					MS[v.handle].minmap = drawMgr:CreateRect(minimap.x-10,minimap.y-10,18,18,0x000000FF,drawMgr:GetTextureId("NyanUI/other/"..v.name))
					table.insert(table,v.handle)
				elseif MS[v.handle] and not v.alive then
					clear = true
					MS[v.handle] = nil
				end
			end
		end

		for i,v in ipairs(table) do
			if MS[v] then
				local st = entityList:GetEntity(v)
				if not st or not st.alive then
					MS[v] = nil
					table.remove(table, i)
					clear = true
				end
			end
		end
		if clear then
			collectgarbage("collect")
		end
		Sleep(250,"min")
	end
end

function GenerateSideMessage(heroName,spellName)
	local test = sideMessage:CreateMessage(200,60)
	test:AddElement(drawMgr:CreateRect(10,10,72,40,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/heroes_horizontal/"..heroName)))
	test:AddElement(drawMgr:CreateRect(85,16,62,31,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/other/arrow_usual")))
	test:AddElement(drawMgr:CreateRect(150,11,40,40,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/spellicons/"..spellName)))
end

function GameClose()
	collectgarbage("collect")
	if registered then
		script:UnregisterEvent(Tick)

		------------Techies-------------
		MS   = {}	TS        = {}
		table = {}	MinesInfo = {}
		--------------------------------

		registered = false
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)
