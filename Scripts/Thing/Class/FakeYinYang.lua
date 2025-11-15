
local tbThing = GameMain:GetMod("ThingHelper"):GetThing("Fake_YinYang");

local CMDName= "MoveToCanWu";

function tbThing:OnPutDown()
	self.it:ClearBtnData()
	self.bd = self.it:AddSaveBtnData(XT("参悟"), "res/Sprs/ui/icon_lianbao01", "bind.luaclass:GetTable():TryCanWu()", XT("前往参悟"), CMDName)
	self.bd.graydesc = XT("看起来无法进行参悟")
end

function tbThing:TryCanWu()
	local cmd = self.it:CheckCommandSingle(CMDName)
	if (cmd ~= nil) then
		self.it:RemoveCommand(CMDName)
		return
	end
	
	if (not self:CheckNextT()) then
		return
	end

	CS.Wnd_SelectNpc.Instance:Select(
		WorldLua:GetSelectNpcCallback(function(rs) 
			if (rs == nil or rs.Count == 0) then
				return
			end
			local npcid = rs[0]
			self.it:AddCommandIfNotExist(CMDName, 0, 0, npcid)
		end), 
		g_emNpcRank.Disciple, 1, 1, nil, 
		WorldLua:GetNpcCondition(function (npc)
			if (npc.GongKind == g_emGongKind.Dao) then
				return true
			end
		end), 
		XT("指定参悟角色"))
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

function tbThing:OnStep(dt)
	local prevCanCanWu = self:GetV("prevCanCanWu", nil)
	local canCanWu = self:CheckNextT()
	self:UpdateGrayState(not canCanWu)
	
	if (canCanWu ~= prevCanCanWu and prevCanCanWu ~= nil) then
		MessageMgr:AddMessage(80, {self.it})
	end
	self:SetV("prevCanCanWu", canCanWu)	
end

function tbThing:CanWu(me)
	local WorldT = CS.XiaWorld.World
	self:AddNextT(16800)
	if (me:GetGLevel()<=3) then
		me:AddMsg(XT("[NAME]观摩良久，似乎略有所悟"));
		me:AddTreeExp(WorldT.RandomRange(3000, 6000), true);
	elseif (me:GetGLevel()<=6) then
		me:AddMsg(XT("[NAME]静坐观想，从中参悟良多"));
		me:AddTreeExp(WorldT.RandomRange(8000, 12000), true);
	elseif (me:GetGLevel()<=9) then
		me:AddMsg(XT("[NAME]的元神随着阴阳流转，对其中蕴含的大道有了更深的体悟"));
		me:AddTreeExp(WorldT.RandomRange(40000, 60000), true);
	else
		me:AddMsg(XT("[NAME]神识沉浸其中，霎那犹如千年，从中悟出万千大道"));
		me:AddTreeExp(WorldT.RandomRange(80000, 120000), true);
	end
	GameEventMgr:TriggerEvent(30008);
end
