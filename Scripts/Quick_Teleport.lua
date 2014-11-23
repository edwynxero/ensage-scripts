--<<Quick Teleport to Base | Version: 1.0>>
--[[
	--------------------------------------
	| Quick Teleport Script by edwynxero |
	--------------------------------------
	============= Version 1.0 ============

	Description:
	------------
		Teleports your hero to base when pressed

		Note: Be sure that you don't bind a key you generally will use for something else.
]]--

--LIBRARIES
require("libs.ScriptConfig")

--CONFIG
local config = ScriptConfig.new()
config:SetParameter("TeleportBind", "T", config.TYPE_HOTKEY)
config:Load()

--SETTINGS
local teleportKey = config.TeleportBind
local registered  = false

--CODE
local baseLoc        = nil
local teleportActive = false

--[[Loading Script...]]
function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then
			script:Disable()
		else
			registered = true

			if me.team == LuaEntity.TEAM_RADIANT then
				baseLoc = Vector(-7188,-6708,398)
			else
				baseLoc = Vector(7033,6418,391)
			end

			script:RegisterEvent(EVENT_TICK,Main)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(onLoad)
		end
	end
end

--check if teleportKey is pressed
function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if code == teleportKey then
		teleportActive = (msg == KEY_DOWN)
	end
end

function Main(tick)
	if not SleepCheck() then return end Sleep(200)

	local me = entityList:GetMyHero()
	if not (me and teleportActive) then return end

	local teleport_scroll = me:FindItem("item_tpscroll")
	local boots_of_travel = me:FindItem("item_travel_boots")

	if me.alive and not me:IsChanneling() then
		if teleport_scroll then
			CastItem(teleport_scroll,baseLoc)
		elseif boots_of_travel then
			CastItem(boots_of_travel,baseLoc)
		end
		return
	end
end

function CastItem(item,position)
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
