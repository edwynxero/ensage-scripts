--[[
	-----------------------------------------
	| Enemy Item Notification by DeadlyLone |
	-----------------------------------------
	============== Version 1.0 ==============
	
	Description:
	------------
		Shows enemy items on side screen (same as item buying shown for team-mates)
]]--

--CODE
local item = {}

function Items(event)    
    if event.name == "dota_inventory_changed" then
        local me = entityList:GetMyHero()
        if me then
            local enemy = entityList:FindEntities(function (en) return en.item and not en.recipe and en.abilityData.itemCost >= 1000 and en.purchaser ~= nil and not en.owner.illusion and en.owner.name ~= "npc_dota_hero_roshan" and en.purchaser.team ~= me.team and not item[en.handle] end)
            for i,v in ipairs(enemy) do
                item[v.handle] = true
                GenerateSide(v.purchaser.name:gsub("npc_dota_hero_",""),v.name:gsub("item_",""))
            end
        end
    end
end

function GenerateSide(heroName,itemName)
    local test = sideMessage:CreateMessage(200,60)
    test:AddElement(drawMgr:CreateRect(10,10,72,40,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/heroes_horizontal/"..heroName)))
    test:AddElement(drawMgr:CreateRect(80,16,60,30,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/other/arrow_item_bought")))
    test:AddElement(drawMgr:CreateRect(140,13,70,35,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/items/"..(itemName))))
end

function GameClose()    
    item = {}
    collectgarbage("collect")
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_DOTA,Items)
