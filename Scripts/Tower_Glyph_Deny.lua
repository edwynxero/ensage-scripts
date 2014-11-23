--<<Uses Glyph and Deny Tower(s) | Version: 1.0>>
--[[
	---------------------------------------
	| Auto Tower Deny Script by edwynxero |
	---------------------------------------
	============= Version 1.0 =============

	Description:
	------------
		- Uses Glyph of Fortification when tower in range and attack it!

		Note: Be sure that you don't bind a key you generally will use for something else.
]]--

--LIBRARIES
require("libs.ScriptConfig")

--CONFIG
local config = ScriptConfig.new()
config:SetParameter("Tower_deny_bind", "K", config.TYPE_HOTKEY)
config:Load()

--SETTINGS
local monitor    = client.screenSize.x/1600
local denyKey    = config.Tower_deny_bind
local registered = false

--CODE
local denyTower  = nil
local denyActive = false
local glyphState = 0

local hotkeyText -- toggleKey might be a keycode number, so string.char will throw an error!!
if string.byte("A") <= denyKey and denyKey <= string.byte("Z") then
	hotkeyText = string.char(denyKey)
else
	hotkeyText = ""..denyKey
end

local F14        = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor)
local statusText = drawMgr:CreateText(10*monitor,610*monitor,-1,"( Key: " .. hotkeyText .. " ) Deny Towers In Range: OFF",F14)

--[[Loading Script...]]
function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then
			script:Disable()
		else
			registered = true
			script:RegisterEvent(EVENT_TICK,Main)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(onLoad)
		end
	end
end

--check if denyKey is pressed
function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if IsKeyDown(denyKey) then
		denyActive = not denyActive
		if denyActive then
			statusText.text = "( Key: " .. hotkeyText .. " ) Deny Towers In Range: ON"
		else
			statusText.text = "( Key: " .. hotkeyText .. " ) Deny Towers In Range: OFF"
		end
	end
end

function Main(tick)
	if not SleepCheck() then return end Sleep(200)

	local me = entityList:GetMyHero()
	if not (me and denyActive) then return end

	local towers = entityList:FindEntities({classId=CDOTA_BaseNPC_Tower, alive=true})

	for i,v in ipairs(towers) do

		if not denyTower and v.health < (GetHeroDamage(me)*(1-v.dmgResist))+88 then
			denyTower = v
		end

		if denyTower and GetDistance2D(denyTower,me) < me.attackRange then
			denyTower = v
		end
	end

	if me.alive and not me:IsChanneling() and denyTower and not SleepCheck() then
		if glyphState == 0 and client:GetGlyphCooldown(me.team) == 0 then
			entityList:GetMyPlayer():UseGlyph()
			glyphState = 1
			Sleep(5000)
		else
			glyphState = 1
			me:Attack(denyTower)
		end
	end
end

function GetHeroDamage(me)
	local damage =  me.dmgMin + me.dmgBonus
	return damage
end

function CastGlyph(item,position)
	if item.state == LuaEntityAbility.STATE_READY then
		entityList:GetMyPlayer():UseAbility(item,position)
	end
end

function onClose()
	collectgarbage("collect")
	if registered then
		script:UnregisterEvent(Key)
		script:UnregisterEvent(Main)
		registered = false
	end
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
