--
-- 人物炼体管理类
-- Author: sjj
-- Date: 2018-1-3
--
local BaseManager = require('lua.gamedata.BaseManager')
local RoleRefineManager = class("RoleRefineManager", BaseManager)

print("++++++++++++sjj+++++RoleRefineManager+++++")
function RoleRefineManager:ctor()
	self.super.ctor(self)
end
RoleRefineManager.RefineAttrChange  = "RoleRefineManager.RefineAttrChange"
function RoleRefineManager:init()
	self.super.init(self)
	self:InitVar()	
	TFDirector:addProto(s2c.REFINE_INFO, self, self.onReceiveRefineAttrChange)--1604
	TFDirector:addProto(s2c.REFINE_INFO_LIST, self, self.onReceiveRefineInfoList)--1605	
	
	RoleRefineManager:InitData()	
end

function RoleRefineManager:InitData()	
	RoleRefineManager.maxLevel = 0
	for item in CardRefineData:iterator() do
		RoleRefineManager.maxLevel=RoleRefineManager.maxLevel+1
	end	
	local mat1Info = CardRefineData:objectByID(1).scheme1_material
	local tbl1 = string.split(mat1Info, '_')
	RoleRefineManager.refineMatID = tbl1[2]

	for i=1,5 do
		RoleRefineManager.attrLockList[i]=false--设置为未上锁
	end

	RoleRefineManager.refineNumMax=ConstantData:getValue("Refine.Num.Max") or 10
end

function RoleRefineManager:restart()--切换账号	
	self:InitVar()		
end
function RoleRefineManager:InitVar()	
	RoleRefineManager.curRefineType=nil--当前的炼体类型，材料1，金币2，元宝3
	RoleRefineManager.curRefineCount=nil--当前的炼体次数，1到10次
	RoleRefineManager.cardRefineInfoList=nil
	RoleRefineManager.cardRefineInfoList={}
	RoleRefineManager.SaveLayer=nil

	RoleRefineManager.RoleRefineLvLayer=nil
	RoleRefineManager.maxLevel=nil
	-- RoleRefineManager.levelMatID=nil
	RoleRefineManager.RedTipHeros={}
	RoleRefineManager.tipsCount=nil
	RoleRefineManager.refineMatID=nil

	RoleRefineManager.attrLockList={}
	RoleRefineManager.refineNumMax=nil
end

function RoleRefineManager:sendRequestRefine(cardId,times,lock,refineType)
	print('**********sjj**********RoleRefineManager***sendRequestRefine*********1604******')
	print(times)--_4	
	print(lock)--_4
	 print(refineType)--_4
	self:sendWithLoading(c2s.CARD_REFINE, cardId..'',times,lock,refineType)	
end

function RoleRefineManager:sendRequestbSaveResult(cardID,isSave)  
	print('**********sjj**********RoleRefineManager***sendRequestbSaveResult*********1605******')
	self:sendWithLoading(c2s.SAVE_RESULT, cardID..'',isSave)	

	if isSave then
		TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, 0)
	end
end

function RoleRefineManager:sendRequestRefineUp(cardID)  
	print('**********sjj**********RoleRefineManager***sendRequestbSaveResult*********1606******',cardID)
	self:sendWithLoading(c2s.REFINE_UP, tostring(cardID) )	
end

function RoleRefineManager:onReceiveRefineAttrChange(event)--1604
	print('**********sjj**********RoleRefineManager***onReceiveRefineAttrChange****1604***********')	
	hideLoading()
	local data = event.data
	RoleRefineManager.cardRefineInfoList[data.cardId]=data
	TFDirector:dispatchGlobalEventWith(RoleRefineManager.RefineAttrChange, data)	
	RoleRefineManager:CalRoleRefineAttr(data.cardId,GetAttrByString(data.attr),data.level)
	
	--print('++data.type++',data.type)
	if data.type==2 then--保留
		--print('+++ROLE_POWER_END+++')
		TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_END, 0)--战斗力弹窗
		TFDirector:dispatchGlobalEventWith(MaterialManager.Study,0)--界面的战力显示刷新
	end	
	if  data.type==4 then
		RoleRefineManager:ShowRefineUpLayer(data.cardId)
		AlertManager:closeLayer(RoleRefineManager.RoleRefineLvLayer)	
	end
	--print('++++1604++++',data.level)
end

function RoleRefineManager:onReceiveRefineInfoList(event)--
	print('**********sjj**********RoleRefineManager***onReceiveRefineAttrChange****1605***********')
	--print('++456++')
	--print('++456++')
	--print('++456++')
	local data = event.data
	if nil~=data.list then
		for k,v in pairs(data.list) do
			RoleRefineManager.cardRefineInfoList[v.cardId]=v			
			--print(v)
			RoleRefineManager:CalRoleRefineAttr(v.cardId, GetAttrByString(v.attr),v.level)
		end
	end
end	
-- CommonManager:updateRedPointWithState(self.breachBtn,CardRoleManager:isHaveRoleStar(self.cardRole),FunctionManager.RoleInfoStar)

function RoleRefineManager:RefreshRedTipHero()
	-- print('+++++RoleRefineManager:RefreshRedTipHero+++++')
	 print('565465465')
	-- print('565465465')
	-- print('565465465')
	RoleRefineManager.RedTipHeros={}
	RoleRefineManager.tipsCount=0
	for role in CardRoleManager.cardRoleList:iterator() do
		if RoleRefineManager:JudgeHeroCanRedTip(role.gmId) then
			RoleRefineManager.RedTipHeros[role.gmId]=true
			RoleRefineManager.tipsCount=RoleRefineManager.tipsCount+1
		end 
	end
end

function RoleRefineManager:IsRefineNeedRedTip()
	if RoleRefineManager.tipsCount>0 then
		return true 
	else 
		return false
	end
end	

function RoleRefineManager:JudgeHeroCanRedTip(gmid)
	print('+++gmid+++',gmid)	
	if nil==gmid then
		return false
	end
	--如果玩家未在阵容里忽略
	if not FormationManager:inAnyFormation(gmid) then
		return false
	end
	
	--判断玩家的等级
	local can_jump = JumpToManager:isCanJump(FunctionManager.RoleRefine )
    if not can_jump then
        return false
    end

	local tempInfo=RoleRefineManager.cardRefineInfoList[gmid]
	local level=1
	if nil~= tempInfo then
		level=tempInfo.level
	end
	local refineInfo=CardRefineData:objectByID(level)
	--如果满阶后并且属性全满了就不显示红点了
	
	if level>=RoleRefineManager.maxLevel then
		--判断当前的值是否都满了
		local limAttr=	GetAttrByString(refineInfo.att_limit)
		local attrData=	GetAttrByString(tempInfo.attr)
		local allFull=true--只要有一个未满就提示红点
		for i=1,5 do
			if attrData[i]<limAttr[i] then
				allFull=false
				break
			end
		end
		if allFull then
			return false
		end
	end
	-- local tempRefineData=RoleRefineManager.cardRefineInfoList[gmid]
	-- local level=1
	-- if nil~= tempRefineData then
	-- 	level=tempRefineData.level
	-- end

	local mat3Info = refineInfo.scheme3_material
	local tbl3 = string.split(mat3Info, ',')
	local Mat3string1=tbl3[1]
	local tbl31 = string.split(Mat3string1, '_')
	local matID =tonumber(tbl31[2]) 
	local matDemand =tonumber(tbl31[3])
	local itemData =  GoodsItemData:objectByID(matID )
	local curNum=BagManager:getGoodsNumByTypeAndTplId(itemData.type, itemData.id)
	if curNum>= matDemand then
		return true
	end	
	return false
end

function RoleRefineManager:CalRoleRefineAttr(gid,tbl,level)
	--当有角色的属性改变
	local cardRole = CardRoleManager:getRoleByGmId(gid)
	cardRole:updateRefineAttribute(tbl)	
	cardRole:setRefineLevel(level)
end

function RoleRefineManager:ClearRefineLevel(gid)
	RoleRefineManager:CalRoleRefineAttr(gid,GetAttrByString('1_0,2_0,3_0,4_0,5_0'),-1)

	local refineDataTemp = RoleRefineManager.cardRefineInfoList[gid]
	if nil~=refineDataTemp then
		refineDataTemp.level=1
		refineDataTemp.attr='1_0,2_0,3_0,4_0,5_0'
		refineDataTemp.incrementAttr='1_0,2_0,3_0,4_0,5_0'
	end
end

function RoleRefineManager:ShowBtnSaveLayer(gid)
	if 	RoleRefineManager.SaveLayer==nil then
		RoleRefineManager.SaveLayer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleBtnLayer",AlertManager.BLOCK, AlertManager.TWEEN_NONE)
		RoleRefineManager.SaveLayer:loadData(gid)
		AlertManager:show()
	end
end

function RoleRefineManager:ShowRefineUpLayer(gid)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleRefineUpLayer",  AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
	layer:loadData( gid )
	AlertManager:show()
end

function RoleRefineManager:ShowRefineLevelLayer(level,list,gmid)
	RoleRefineManager.RoleRefineLvLayer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleRefineLvLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
    RoleRefineManager.RoleRefineLvLayer:loadData(level,list,gmid)
    AlertManager:show()
end

function RoleRefineManager:CloseBtnSaveLayer()
	if nil~=RoleRefineManager.SaveLayer then
		AlertManager:closeLayer(RoleRefineManager.SaveLayer)	
		RoleRefineManager.SaveLayer=nil
	end	
end



return RoleRefineManager:new()

