--<<Beautiful: Clockwork Combo | Version: 1.0>>
--[[
    ---------------------------------------
    | Clockwork Combo Script by edwynxero |
    ---------------------------------------
    ============= Version 1.0 =============

    Description:
    ------------
        Auto hookshot with prediction:
            - When hotkey pressed Clockwork will auto hookshot enemy whithin hookshot range and with lowest HP.
            - Excludes Illusions
        Auto combo after a succesfull hookshot:
            - Clockwork will auto Power Cogs + Battery Assault + Blade Mail (If there).
        To-do:
            - If enemy can escape check.
            - If enemy use cyclone after being hooked, Clockwork will automaticly do the combo after landing.
]]--

--LIBRARIES
require("libs.ScriptConfig")
require("libs.TargetFind")
require("libs.SkillShot")

--CONFIG
config = ScriptConfig.new()
config:SetParameter("Hotkey", "F", config.TYPE_HOTKEY)
config:SetParameter("HookshotKey", "D", config.TYPE_HOTKEY)
config:SetParameter("StopKey", "S", config.TYPE_HOTKEY)
config:SetParameter("HookshotTolerancy", 150)
config:Load()

--SETTINGS
local togglekey   = config.Hotkey
local hookshotKey = config.HookshotKey
local active      = true
local registered  = false
local myFont      = drawMgr:CreateFont("Clockwork","Tahoma",14,550)
local statusText  = drawMgr:CreateText(-40,-20,-1,"Hookshot'em!",myFont);

--CODE
local xyz            = nil
local victim         = nil
local blindxyz       = nil
local targetHandle   = nil
local hooked         = false
local hookshotCoolD  = {70,55,40}
local hookshotDamage = {100,200,300}
local hookshotRange  = {2000,2500,3000}
local hookshotSpeed  = {4000,5000,6000}

--[[Loading Script...]]
function onLoad()
    if PlayingGame() then
        local me = entityList:GetMyHero()
        if not me or me.classId ~= CDOTA_Unit_Hero_Rattletrap then
            script:Disable()
        else
            statusText.visible = true
            registered = true
            script:RegisterEvent(EVENT_TICK,Main)
            script:RegisterEvent(EVENT_KEY,Key)
            script:RegisterEvent(EVENT_MODIFIER_ADD, ModifierAdd)
            script:RegisterEvent(EVENT_MODIFIER_REMOVE, ModifierRemove)
            script:UnregisterEvent(onLoad)
        end
    end
end

function Key(msg,code)
    if client.chat or not PlayingGame() then return end
    if msg == KEY_UP then
        if code == togglekey then
            if not active then
                active = true
                statusText.text = "Hookshot'em!"
            else
                active = false
                statusText.text = "Script: off!"
            end
            if xyz then
                xyz = nil
            end
        elseif code == config.StopKey and (xyz or targetHandle) then
            xyz = nil
            active = false
        end
    end
end

function Main(tick)
    if not SleepCheck() then return end

    local me = entityList:GetMyHero()
    if not me then return end Sleep(125)

    local offset = me.healthbarOffset
    statusText.entity = me
    statusText.entityPosition = Vector(-2,-5,offset)

    -- Get hero abilities --
    local Hookshot        = me:GetAbility(4)

    if active then
        if Hookshot.level > 0 and math.ceil(Hookshot.cd) == math.ceil(Hookshot:GetCooldown(Hookshot.level)) then
            xyz = nil
        end
        if IsKeyDown(config.StopKey) and ((Hookshot.abilityPhase and not SleepCheck("Hookshot")) and math.ceil(Hookshot.cd) ~= math.ceil(Hookshot:GetCooldown(Hookshot.level)) or not SleepCheck("Hookshot")) then
            xyz = nil
            if SleepCheck("stopkey") and not client.chat then
                me:Stop()
                me:Move(client.mousePosition)
                Sleep(client.latency + 200, "stopkey")
                Sleep(client.latency + 200, "testhook")
            end
        end
        if not IsKeyDown(config.StopKey) and ((Hookshot.abilityPhase and not SleepCheck("Hookshot")) and math.ceil(Hookshot.cd) ~= math.ceil(Hookshot:GetCooldown(Hookshot.level)) or not SleepCheck("Hookshot")) and xyz and victim and SleepCheck("testhook") then
            local speed = hookshotSpeed[Hookshot.level]
            local delay = (300+client.latency)
            local testxyz = SkillShot.SkillShotXYZ(me,victim,delay,speed)
            if testxyz and (GetType(testxyz) == "Vector" or GetType(testxyz) == "Vector2D") and GetDistance2D(me,testxyz) <= hookshotRange[Hookshot.level] + 200 and victim.alive then
                if GetDistance2D(testxyz,me) > hookshotRange[Hookshot.level] then
                    testxyz = (testxyz - me.position) * (Hookshot.castRange - 100) / GetDistance2D(testxyz,me) + me.position
                end
                if ((GetDistance2D(testxyz,xyz) > math.max(GetDistance2D(SkillShot.PredictedXYZ(victim,math.max(Hookshot:FindCastPoint()*1000-(GetDistance2D(me,victim)/speed)*1000+client.latency-100+config.HookshotTolerancy, client.latency+Hookshot:FindCastPoint()*1000+100)),victim), 25))) or SkillShot.__GetBlock(me.position,testxyz,victim,100,true) then
                    me:Stop()
                    me:SafeCastAbility(Hookshot, testxyz)
                    xyz = testxyz
                    Sleep(math.max(Hookshot:FindCastPoint()*500 - client.latency,0),"testhook")
                    Sleep(Hookshot:FindCastPoint()*1000+client.latency,"Hookshot")
                    return
                end
            elseif GetDistance2D(me,victim) > hookshotRange[Hookshot.level] + 200 then
                me:Stop()
                Sleep(math.max(Hookshot:FindCastPoint()*500 - client.latency,0),"testhook")
                Sleep(Hookshot:FindCastPoint()*1000+client.latency,"Hookshot")
                return
            end
        end
        for i,v in ipairs(entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive=true})) do
            if v.team ~= me.team and not v:IsIllusion() then
                if not v.visible and Hookshot.level > 0 and me.alive and not victim then
                    local speed = hookshotSpeed[Hookshot.level]
                    local castPoint = (0.35 + client.latency/1000)
                    local blindvictim
                    if not blindvictim or v.health < blindvictim.health or blindvictim.visible then
                        blindvictim = v
                    end
                    blindxyz = SkillShot.BlindSkillShotXYZ(me,blindvictim,speed,castPoint)
                    if blindxyz and blindxyz:GetDistance2D(me) <= hookshotRange[Hookshot.level] + 100 then
                        if IsKeyDown(hookshotKey) and SleepCheck("Hookshot") and not client.chat then
                            me:SafeCastAbility(Hookshot, blindxyz)
                            Sleep(100+client.latency,"hook")
                        end
                    end
                else
                    blindvictim = nil
                end
            end
        end
        if Hookshot.level > 0 then
            victim = targetFind:GetLowestEHP(hookshotRange[Hookshot.level] + 100, magic)
            if victim and victim.visible and Hookshot:CanBeCasted() and SleepCheck("Hookshot") then
                local distance = GetDistance2D(victim, me)
                if distance <= hookshotRange[Hookshot.level] + 100 and victim.visible then
                    if IsKeyDown(hookshotKey) and me.alive and not client.chat then
                        if not victim:DoesHaveModifier("modifier_nyx_assassin_spiked_carapace") then
                            local speed = hookshotSpeed[Hookshot.level]
                            local delay = (300+client.latency)
                            xyz = SkillShot.BlockableSkillShotXYZ(me,victim,speed,delay,100,true)
                            if xyz and (GetType(xyz) == "Vector" or GetType(xyz) == "Vector2D") and GetDistance2D(me,xyz) <= hookshotRange[Hookshot.level] + 200 then
                                if GetDistance2D(xyz,me) > hookshotRange[Hookshot.level] then
                                    xyz = (xyz - me.position) * (Hookshot.castRange - 100) / GetDistance2D(xyz,me) + me.position
                                end
                                me:SafeCastAbility(Hookshot, xyz)
                                Sleep(Hookshot:FindCastPoint()*1000+client.latency,"Hookshot")
                            else
                                xyz = nil
                            end
                        end
                    end
                end
            end
        end
    end
end

function doCombo(tick)
    if not PlayingGame() or client.console or client.paused or not SleepCheck("combo") or not targetHandle then return end
    local me = entityList:GetMyHero()

    local target = entityList:GetEntity(targetHandle)
    -- Get Abilities --
    local Battery_Assault = me:GetAbility(1)
    local Power_Cogs      = me:GetAbility(2)
    local Blade_Mail      = me:FindItem("item_blade_mail")

    if not target or not (GetDistance2D(target,me) < 200) or (not target.alive or target:IsUnitState(LuaEntityNPC.STATE_MAGIC_IMMUNE) or (not hooked) or target:IsIllusion()) or not me.alive or not active then
        targetHandle = nil
        script:UnregisterEvent(Combo)
        return
    end
    CastSpell(Power_Cogs)
    CastSpell(Battery_Assault)
    if Blade_Mail then
        CastSpell(Blade_Mail)
    end
end

function ModifierAdd(v,modifier)
    if not PlayingGame() or client.console then return end
    local me = entityList:GetMyHero()
    if active and modifier.name == "modifier_stunned" then
        print(v.name)
        if v.hero and v.team == me:GetEnemyTeam() and not v:IsIllusion() and isHookshot() then
            targetHandle = v.handle
            hooked = true
            script:RegisterEvent(EVENT_TICK,doCombo)
        end
    end
end

function isHookshot()
    local me       = entityList:GetMyHero()
    local Hookshot = me:GetAbility(4)
    local aghanims = me:FindItem("item_ultimate_scepter")
    if Hookshot:CanBeCasted() then
        return false
    else
        if aghanims then
            if Hookshot.cd > 12 then
                return false
            elseif Hookshot.cd < 12 then
                return true
            end
        elseif Hookshot.cd < hookshotCD[Hookshot.level] and Hookshot.cd > hookshotCD[Hookshot.level]-5 then
            return true
        else
            return false
        end
    end
end

function ModifierRemove(v,modifier)
    if not PlayingGame() or client.console then return end
    local me = entityList:GetMyHero()
    if active and modifier.name == "modifier_stunned" and v.team == me:GetEnemyTeam() then
        hooked = false
    end
end

function CastSpell(spell)
    if spell.state == LuaEntityAbility.STATE_READY then
        entityList:GetMyPlayer():UseAbility(spell)
        Sleep(client.latency, "combo")
        return
    end
end

function onClose()
    collectgarbage("collect")
    if registered then
        xyz          = nil
        victim       = nil
        blindxyz     = nil
        targetHandle = nil
        hooked       = false
        registered   = false
        statusText.visible = false
        script:UnregisterEvent(Main)
        script:UnregisterEvent(Key)
        script:UnregisterEvent(ModifierAdd)
        script:UnregisterEvent(ModifierRemove)
    end
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
