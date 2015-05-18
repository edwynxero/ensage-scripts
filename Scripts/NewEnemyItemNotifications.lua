--[[
	------------------------------------------
    → Script : Enemy Item Notification
    → Version: 1.0
    → Made By: DeadlyLone
    -------------------------------------------

	Description:
	------------
		Shows enemy items on side screen (same as item buying shown for team-mates)
]]--

--→ CODE
local item = {}

function Items(event)
    if event.name == "dota_inventory_changed" then
        local me = entityList:GetMyHero()
        if me then
            local enemy = entityList:FindEntities(function (en) return en.item and not en.recipe and en.abilityData.itemCost >= 1000 and en.purchaser ~= nil and not en.owner.illusion and en.owner.name ~= "npc_dota_hero_roshan" and en.purchaser.team ~= me.team and not item[en.handle] end)
            for i,v in ipairs(enemy) do
                item[v.handle] = true
                GenerateSideMSG(v.purchaser.name:gsub("npc_dota_hero_",""),v.name:gsub("item_",""))
            end
        end
    end
end

function GenerateSideMSG(heroName,itemName)
    local sideMSG = sideMessage:CreateMessage(180,48)
    sideMSG:AddElement(drawMgr:CreateRect(006,06,72,36,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/heroes_horizontal/"..heroName)))
    sideMSG:AddElement(drawMgr:CreateRect(078,12,64,32,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/other/arrow_item_bought")))
    sideMSG:AddElement(drawMgr:CreateRect(142,06,72,36,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/items/"..(itemName))))
end

function GameClose()
    item = {}
    collectgarbage("collect")
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_DOTA,Items)
