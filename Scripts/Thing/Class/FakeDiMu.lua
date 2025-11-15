
local tbThing = GameMain:GetMod("ThingHelper"):GetThing("Fake_DiMu");

local CMDName= "GoWishDimu";

function tbThing:OnPutDown()
	local ExDesc = XT("地母")
	self.it.ExDesc = ExDesc
	if (self.it.View ~= nil) then
        self.it.View:SendViewMessage("SetTitle", ExDesc);		
	end

	self.it:ClearBtnData()
	self.bd = self.it:AddSaveBtnData(XT("许愿"), "res/Sprs/ui/icon_lianbao01", "bind.luaclass:GetTable():TryWish()", XT("前往地母石碑许愿(需要500灵石)"), CMDName)
	self.bd.graydesc = XT("地母石碑失去了光泽，看起来无法进行许愿")

end

function tbThing:TryWish()
	local cmd = self.it:CheckCommandSingle(CMDName)
	if (cmd ~= nil) then
		self.it:RemoveCommand(CMDName)
		return
	end
	
	if (not self:CheckNextT()) then
		return
	end

	self.it:AddCommandIfNotExist(CMDName)
end

function tbThing:SetV(k, v)
	self.savedata = self.savedata or {}
	self.savedata[k] = v
end

function tbThing:GetV(k, def)
	if (self.savedata == nil) then
		return def
	end
	return self.savedata[k] or def
end

function tbThing:UpdateGrayState(gray)
	local tov = gray and 1 or 0
	if (self.tov == tov) then
		return
	end
	self.bd.gray = tov
	self.tov = tov
end

function tbThing:AddNextT(dif)
	self:SetV("nextt", GameMain:GetNow() + dif)
end

function tbThing:CheckNextT()
	return GameMain:GetNow() >= self:GetV("nextt", 0)
end

function tbThing:OnGetSaveData()
	return self.savedata
end

function tbThing:OnLoadData(tbData)
	self.savedata = tbData
end

function tbThing:FullAroundTerrain(name, c)
	CS.XiaWorld.GridMgr.Inst:DoAroundKeyLua(self.it.Key, 10, 
	function(i, grid)
		local t = Map.Terrain:GetTerrain(grid)
		if (t ~= nil and t.Name ~= name) then
			c = c - 1
			Map.Terrain:FullTerrain(grid, name);
		end
		return c > 0;
	end
	);
end

function tbThing:OnStep(dt)
	local prevCanCanWu = self:GetV("prevCanCanBai", nil)
	local canCanWu = self:CheckNextT()
	self:UpdateGrayState(not canCanWu)
	if (canCanWu ~= prevCanCanWu and prevCanCanWu ~= nil) then
		MessageMgr:AddMessage(81, {self.it})
	end
	self:SetV("prevCanCanBai", canCanWu)	
end

function tbThing:GetLingStone(me)
	self.savedata = self.savedata or {}
	self.savedata.v = (self.savedata.v or 0) + 1
	local vk = self.savedata.v

	local count = math.max(100, WorldLua:RandomInt(700, 1301) - vk * 60)
	Map:DropItems("Item_LingStone", nil, count, self.it.Key, true, true)
	self:FullAroundTerrain("StoneLand", 8 + math.ceil(vk * vk / 5))
	me:AddMsg(XT("灵石伴随附近地面的养分一起被地母石碑收入其中，眨眼之间便凝聚出了{0}枚灵石，同时也多出一丝不祥的气息。"), count);
	
	if (self.savedata.v >= 1) then
		World:SetFlag(g_emWorldFlag.DiMuBuildingEvent1, 1)
		CS.XiaWorld.GameEventMgr.Instance:TriggerEvent(30111);
	end
	
	if (self.savedata.v >= 5) then
		local jyanimals = {"JYSnake", "JYBoar", "JYBear", "JYTurtle", "JYTiger", "JYCattle"}
		local level = self.savedata.v
		local jyrace = jyanimals[WorldLua:RandomInt(1, #jyanimals + 1)]
		local tNpc = NpcMgr:CreateEliteEnemysAtKey(jyrace, self.it.Key, Map, 3, level+5, 0, -1, nil, false)
		if (self.savedata.v > 15) then
			for i = 0, tNpc.Count-1 do
				local npc = tNpc[i]
				if npc then
					npc:AddModifier("FightPowerUp_DiMu", 1, false, level-15);
				end
			end
		end
		GameEventMgr:TriggerEvent(30112) 
	end
	
	if (self.savedata.v == 4) then
		me:AddMsg(XT("附近的妖气愈发浓郁，似乎是地母石碑的不祥之气所致。"), count);
	end
	self:AddNextT(3000)
	self:UpdateGrayState(true)
end

function tbThing:ToNature(me)
	self.savedata = self.savedata or {}
	self.savedata.v = (self.savedata.v or 1) - 1
	self.savedata.v = math.max(self.savedata.v, 0)

	me:AddMsg(XT("灵石化为灵气被吸纳进了地母石碑，附近的土地被灵气滋润了。"));

	if (self.savedata.v == 9) then
		World:SetFlag(g_emWorldFlag.DiMuBuildingEvent1, 0)
	end
	
	if (self.savedata.v == 4) then
		me:AddMsg(XT("地母石碑的不祥之气消散了些许，附近的妖气也随之散去。"), count);
	end
	
	self:FullAroundTerrain("FertileSoil", 4)
	
	self:AddNextT(3000)
	self:UpdateGrayState(true)
end
