
local tbThing = GameMain:GetMod("ThingHelper"):GetThing("Fake_OuterWorld");

local NEED_T = 6000
local ADD_MAXT = 1500
local SUB_MAXT = 1500

function tbThing:Step(dt)
	self.data = self.data or {}
	self.data.passt = (self.data.passt or 0) + dt

	if (self.data.passt < NEED_T) then
		return
	end

	self.data.passt = WorldLua:RandomFloat(0, ADD_MAXT + SUB_MAXT) - ADD_MAXT

	self:Do()
end


function tbThing:OnGetSaveData()
	return self.data;
end

function tbThing:OnLoadData(tbData)
	self.data = tbData or {};
end

local rLabels =  {
    g_emItemLable.Wood,
    g_emItemLable.WoodBlock,
    g_emItemLable.Rock,
    g_emItemLable.RockBlock,
    g_emItemLable.Metal,
    g_emItemLable.Plant,
    g_emItemLable.PlantProduct,
    g_emItemLable.Ingredient,
    g_emItemLable.Meat,
    g_emItemLable.Leather,
    g_emItemLable.Cloth,
    g_emItemLable.Weapon,
    g_emItemLable.Clothes,
    g_emItemLable.Trousers,
    g_emItemLable.Food,
    g_emItemLable.Drug,
    g_emItemLable.Dan,
    g_emItemLable.Tool,
    g_emItemLable.MetalBlock,
    g_emItemLable.LeftoverMaterial,
    g_emItemLable.SpellPaper,
    g_emItemLable.Garbage,
    g_emItemLable.Other,
}

function tbThing:Do()
	local v = WorldLua:RandomFloat(0, 100)
	if (v < 90) then
		local label = rLabels[WorldLua:RandomInt(1, #rLabels + 1)]
		local thing = CS.XiaWorld.ItemRandomMachine.RandomItem(label, 0, 7)
		if (thing ~= nil) then
			Map:DropItem(thing, self.it.Key)
			MessageMgr:AddMessage(82, {self.it})
		end
	elseif (v < 92.5) then
		-- 野兽
		local animals = {"Boar", "Bear", "Snake", "Tiger", "Wolf"}
		local race = animals[WorldLua:RandomInt(1, #animals + 1)]
		Map:AddEnemyAtKey(race, "E", self.it.Key, 0, g_emNpcRichLable.Normal, 0, 100, 3, 0, 0, 41, 0)
		GameEventMgr:TriggerEvent(10124)
	elseif (v < 95) then
		-- 敌人
		if (SchoolMgr.UnLockLevel >= 4) then
			local level = WorldLua:GetScoreEnemeyLevel()
			Map:AddEnemyAtKey("Human", "E", self.it.Key, level, g_emNpcRichLable.Normal, 0, 100, 3, 0, 0, 41, 0)
			GameEventMgr:TriggerEvent(10126)
		end
	elseif (v < 97.5) then
		-- 妖兽
		if (SchoolMgr.UnLockLevel >= 5) then
			local jyanimals = {"JYRabbit", "JYWolf", "JYSnake", "JYBoar", "JYBear", "JYFrog", "JYTurtle"}
			local level = WorldLua:GetScoreEnemeyLevel()
			local jyrace = jyanimals[WorldLua:RandomInt(1, #jyanimals + 1)]
			NpcMgr:CreateEliteEnemysAtKey(jyrace, self.it.Key, Map, 3, level, 0, -1, nil, false)
			GameEventMgr:TriggerEvent(10125)
		end
	else
		-- 行商
		local key = Map:GetWalkableAround(self.it.Key, 20)
		TradeMgr.WalkTrader:AddSpecialTrader(key)
	end
end
