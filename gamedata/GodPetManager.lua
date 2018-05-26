-- 宠物管理类
-- Author: sunyunpeng
-- Date: 2017-09-12
--

local BaseManager = require('lua.gamedata.BaseManager')
local GodPetManager = class("GodPetManager", BaseManager)

GodPetManager.MINING_UPDATE             = "GodPetManager.MINING_UPDATE"
GodPetManager.MINING_REWARD_UPDATE      = "GodPetManager.MINING_REWARD_UPDATE"
GodPetManager.MINING_GOD_PET			= "GodPetManager.MINING_GOD_PET"
GodPetManager.UPDATE_MY_GOD_PET			= "GodPetManager.UPDATE_MY_GOD_PET"
GodPetManager.UPDATE_GOD_PET_MALL       = "GodPetManager.UPDATE_GOD_PET_MALL"
GodPetManager.UPDATE_GOD_PET_PUT_SELL   = "GodPetManager.UPDATE_GOD_PET_PUT_SELL"
GodPetManager.UPDATE_GOD_PET_DOWN_SELL  = "GodPetManager.UPDATE_GOD_PET_DOWN_SELL"
GodPetManager.UPDATE_MALL_BUY_SUCCEED   = "GodPetManager.UPDATE_MALL_BUY_SUCCEED"
GodPetManager.UPDATE_MINING_INFO_RESULT = "GodPetManager.UPDATE_MINING_INFO_RESULT"
GodPetManager.UPDATE_GOD_PET_VIEW_RESULT= "GodPetManager.UPDATE_GOD_PET_VIEW_RESULT"
GodPetManager.UPDATE_GOD_PET_HISTORY    = "GodPetManager.UPDATE_GOD_PET_HISTORY"
function GodPetManager:ctor()
	self.super.ctor(self)
end

function GodPetManager:init()
	self.super.init(self)
	self.petRoleList = TFArray:new()
   
    self.is_mining = false
    self.isMining = false

    self.isHave = false
	self.owner = ""
    self.bestPrice = 0

    self.miningRewardList = {}
    self.nextTime = 0
    self.miningGodPetPetCode = nil
    self.offSellPetNum = 0
    self.myGodPetList = MEMapArray:new()
    self.mallGodPetList = MEMapArray:new()
    self.allPage = 0
    self.is_send_my_god_pet = false
    self.is_open_my_pet = false
    self.is_open_mall = true
    self.is_open_history = false

    self.mallMaxCost = 2000000
    self.mallMinCost = 2000000--ConstantData:getValue("GodPet.Sell.Price.Min") or 20000

    self.is_show_out_line = false
    self.outLineTime = {}
	self:registerEvents()
end

function GodPetManager:registerEvents()
	--挖矿
	TFDirector:addProto(s2c.MINING_RESP, self, self.onMiningResp)
	--挖矿奖励
	TFDirector:addProto(s2c.MINING_REWARD_RESULT, self, self.onMiningRewardResult)
	--挖到矿  神宠
	TFDirector:addProto(s2c.MINING_GOT, self, self.onMiningGod)
	--集市信息目前只有神宠 
    TFDirector:addProto(s2c.WORLD_MALL, self, self.onWorldMall)
    --神宠上架、跨服 
    TFDirector:addProto(s2c.PUT_GOD_PET_SELL_RES, self, self.onPutGodPetSellRes)
    --神宠下架、取出
    TFDirector:addProto(s2c.OFF_GOD_PET_RES, self, self.onOffGodPetRes)
    --我的神宠
    TFDirector:addProto(s2c.MY_GOD_PET_RESULT, self, self.onMyGodPetResult) 
    --神宠购买成功 
    TFDirector:addProto(s2c.MALL_BUY_SUCCEED, self, self.onMallBuySucceed)
    --下发挖矿情况
    TFDirector:addProto(s2c.MINING_INFO_RESULT, self, self.onMiningInfoResult)
    --神宠外显返回
    TFDirector:addProto(s2c.REQ_GOD_PET_VIEW_RESULT, self, self.onReqGodPetViewResult)
    --挖矿历史
    TFDirector:addProto(s2c.MINING_HISTORY_RESP, self, self.onMiningHistoryResp)
    --神宠离线 
    TFDirector:addProto(s2c.GOD_PET_OUT_LINE_TIME, self, self.onGodPetOutLineTime)
end

function GodPetManager:restart()
	self.petRoleList:clear()

	self.is_mining = false
    self.isMining = false

    self.isHave = false
	self.owner = ""
    self.bestPrice = 0

    self.miningRewardList = {}
    self.nextTime = 0
    self.miningGodPetPetCode = nil
    self.offSellPetNum = 0
    self.myGodPetList:clear()
    self.mallGodPetList:clear()
    self.allPage = 0
    self.is_open_my_pet = false
    self.is_open_mall = true

    self.mallMaxCost = 2000000
    self.mallMinCost = ConstantData:getValue("GodPet.Sell.Price.Min")

    self.is_show_out_line = false
    self.outLineTime = {}
end

-----------------------send--------------------------
--挖矿
function GodPetManager:sendGodPetStartMining()
	self:sendWithLoading(c2s.START_MINING, true)
end

--领取挖矿奖励
function GodPetManager:sendGetGodPetStartMiningReward()
	self:sendWithLoading(c2s.GET_MINING_REWARD, true)
end

--请求集市信息
function GodPetManager:sendGetWorldMall(start, length, tag)
	self:sendWithLoading(c2s.GET_WORLD_MALL, start, length, tag)
end

--神宠上架、跨服
function GodPetManager:sendPutGodPetSell(id, price, type)
	self:sendWithLoading(c2s.PUT_GOD_PET_SELL, id, price, type)
end

--神宠下架、取出
function GodPetManager:sendOffGodPet(id, type)
	self:sendWithLoading(c2s.OFF_GOD_PET, id, type)
end

--神宠购买
function GodPetManager:sendBuyGodPet(id, price)
	self:sendWithLoading(c2s.BUY_GOD_PET, id, price)
end

--请求神宠
function GodPetManager:sendReqGodPet()
	self:sendWithLoading(c2s.REQ_GOD_PET, true)
end


--获取服务器挖矿情况
function GodPetManager:sendGetMiningInfo()
	self:sendWithLoading(c2s.GET_MINING_INFO, true)
end

--请求挖矿奖励
function GodPetManager:sendRewardInfoReq()
	self:sendWithLoading(c2s.REWARD_INFO_REQ, true)
end

--请求神宠外显
function GodPetManager:sendReqGodPetView(id, isShow)
	self:sendWithLoading(c2s.REQ_GOD_PET_VIEW, id, isShow)
end

--最近的挖矿历史
function GodPetManager:sendMiningHistory(from, cnt)
	self:sendWithLoading(c2s.MINING_HISTORY, from, cnt)
end
-----------------------------------------------------
--挖矿
function GodPetManager:onMiningResp(event)
    local data = event.data or {}
    hideLoading()
    self.isMining = data.isMining	    --是否在挖矿
    
    
    TFDirector:dispatchGlobalEventWith(GodPetManager.MINING_UPDATE, 0)
end

--挖矿奖励
function GodPetManager:onMiningRewardResult(event)
    hideLoading()
    local data = event.data or {}

    print("***********************")
    print("***********************")
    print("***********************")
    print("*************onMiningRewardResult**************",data)
    print("***********************")
    print("***********************")
    print("***********************")
    self.miningRewardList = {}
    local dropId = data.dropId or {}
    for i,v in pairs(dropId) do
        self.miningRewardList[#self.miningRewardList + 1] = v
    end
    self.nextTime = data.nextTime
    TFDirector:dispatchGlobalEventWith(GodPetManager.MINING_REWARD_UPDATE, 0)
end

--挖到矿  神宠
function GodPetManager:onMiningGod(event)
    hideLoading()

    local data = event.data or {}
    print("========================",data)
    self.miningGodPetPetCode = data.godPet.petCode
    
    self.myGodPetList:pushbyid(data.petCode,self:setGodPetInfo(data.godPet))
    TFDirector:dispatchGlobalEventWith(GodPetManager.MINING_GOD_PET, nil)

    MessageManager:pushTypeInMessageLayer(EnumMessagePushType.GodPetMining)
    TFDirector:dispatchGlobalEventWith(TeamManager.UPDATE_MESSAGE_STATUS, 0) 
end

--集市信息目前只有神宠 
function GodPetManager:onWorldMall(event)
    hideLoading()

    local data = event.data or {}
    print("=-=--=-=-==-==-=-=-=-")
    print("=========onWorldMall==========",data.allPage)
    print("=-=--=-=-==-==-=-=-=-")
    self.mallGodPetList:clear()
    local godPet = data.godPet or {}
    for i,v in pairs(godPet) do
        self.mallGodPetList:pushbyid( data.petCade,self:setGodPetInfo(v) )
    end

    self.allPage = data.allPage
    
    if self.is_open_mall then
        self.is_open_mall = false
        GodPetManager:openShenChongShopLayer()
    else
        TFDirector:dispatchGlobalEventWith(GodPetManager.UPDATE_GOD_PET_MALL, nil)
    end

end

--神宠上架、跨服 
function GodPetManager:onPutGodPetSellRes(event)
    hideLoading()

    local data = event.data or {}    
    -- print("----------onPutGodPetSellRes---------",data)
    -- local godPet = self.myGodPetList:objectByID(data.id)
    -- if godPet then
    --     godPet.state = data.state
    -- end
    if data.state == 1 then
        local value = ConstantData:getValue("GodPet.Cost") 
        self:openShenChongSJLayer(math.floor( value * 100 / 10000 ))
    end
    
    TFDirector:dispatchGlobalEventWith(GodPetManager.UPDATE_GOD_PET_PUT_SELL, nil) 
    TFDirector:dispatchGlobalEventWith(GodPetManager.UPDATE_MY_GOD_PET, nil)  
end

--神宠下架、取出
function GodPetManager:onOffGodPetRes(event)
    hideLoading()
    local data = event.data or {}
    self.offSellPetNum = data.id
    -- local godPet = self.myGodPetList:objectByID(data.id)
    -- if godPet then
    --     godPet.state = 3
    --     godPet.isCurSever = true
    --     godPet.server = SaveManager:getServerNameByServerId(MainPlayer:getServerId())
    -- end

    TFDirector:dispatchGlobalEventWith(GodPetManager.UPDATE_GOD_PET_DOWN_SELL, nil) 
    TFDirector:dispatchGlobalEventWith(GodPetManager.UPDATE_MY_GOD_PET, nil)
end

--我的神宠
function GodPetManager:onMyGodPetResult(event)
    hideLoading()
    local data = event.data or {}
    self.myGodPetList:clear()
    print("=======onMyGodPetResult=========",data)
    local godpet = data.godPet or {}
    for i,v in pairs(godpet) do
        self.myGodPetList:pushbyid(v.petCode,self:setGodPetInfo(v))
    end

    if self.is_open_my_pet then
        self.is_open_my_pet = false
        GodPetManager:openShenChongMySCLayer()
    end
    TFDirector:dispatchGlobalEventWith(GodPetManager.UPDATE_MY_GOD_PET, nil)
end

--神宠购买成功
function GodPetManager:onMallBuySucceed(event)
    hideLoading()
    local data = event.data or {}

    self.myGodPetList:pushbyid(data.petCode,self:setGodPetInfo(data))
    TFDirector:dispatchGlobalEventWith(GodPetManager.UPDATE_MALL_BUY_SUCCEED, nil)
end

--下发挖矿情况
function GodPetManager:onMiningInfoResult(event)
    hideLoading()
    local data = event.data or {}
    print("***********************")
    print("***********************")
    print("***********************")
    print("*************onMiningResp**************",data)
    print("***********************")
    print("***********************")
    print("***********************")
    self.isHave = data.isHave           --是否有神宠
	self.owner = data.owner	            --上一只神宠主人
    self.bestPrice = data.bestPrice	    --最近7天最高转让

    self.mallMaxCost = data.maxCost     --最高售价
    self.mallMinCost = data.minCost     --最低售价

    TFDirector:dispatchGlobalEventWith(GodPetManager.UPDATE_MINING_INFO_RESULT, nil)
end

--神宠外显返回
function GodPetManager:onReqGodPetViewResult(event)
    hideLoading()
    local data = event.data or {}
    --隐藏
    local petRole1 = PetRoleManager:getPetByGmId(data.hideId)
    if petRole1 then
        petRole1:updateIsShow(false)
    end
    
    --显示
    local petRole2 = PetRoleManager:getPetByGmId(data.showId)
    if petRole2 then
        petRole2:updateIsShow(true)
    end
    
    TFDirector:dispatchGlobalEventWith(GodPetManager.UPDATE_GOD_PET_VIEW_RESULT, nil)
end

--挖矿历史
function GodPetManager:onMiningHistoryResp(event)
    hideLoading()
    local data = event.data or {}
    local historys = data.historys or {}
    local historyPet = {}
    if not self.is_open_history then
        self.is_open_history = true
        for i,v in pairs(historys) do
            historyPet[#historyPet + 1] = {godPet = self:setGodPetInfo(v.godPet), history = v.history}
        end
        self:openShenChongJYLayer(historyPet)
    else
        for i,v in pairs(historys) do
            historyPet[#historyPet + 1] = {godPet = self:setGodPetInfo(v.godPet), history = v.history}
        end
        TFDirector:dispatchGlobalEventWith(GodPetManager.UPDATE_GOD_PET_HISTORY, historyPet)
    end
end

--神宠离线
function GodPetManager:onGodPetOutLineTime(event)
    
    self.is_show_out_line = true

    self.outLineTime = event.data
end

--获取所有神宠
function GodPetManager:getMyGodPetList()
    local godPetList = TFArray:new()
    for item in self.myGodPetList:iterator() do
        if item.state ~= 1 then
            godPetList:push(item)
        end   
    end
    return godPetList
end

function GodPetManager:setIsOpenMyPet(is_bool)
    self.is_open_my_pet = is_bool
end

function GodPetManager:setIsOpenMall( is_bool )
    self.is_open_mall = is_bool
end



--获取当前服上架神宠
function GodPetManager:getMySellGodPetList()
    local petList = {}
    for item in self.myGodPetList:iterator() do
        if item.isCurSever and item.state == 1 then
            petList[#petList + 1] = item
        end
    end
    return petList
end

--获取当前服未上架神宠
function GodPetManager:getMyNoSellGodPetList()
    local petList = {}
    for item in self.myGodPetList:iterator() do
        if item.isCurSever and item.state == 3 then
            petList[#petList + 1] = item
        end
    end
    return petList
end
--通过区块链码获取我的神宠信息
function GodPetManager:getGodPetByPetCode(petCode)
    for item in self.myGodPetList:iterator() do
        if item.petCode == petCode then
            return item
        end
    end
    return nil
end

--通过宠物实例Id取神宠信息
function GodPetManager:getGodPetByPetId(petId)
    for item in self.myGodPetList:iterator() do
        if item.petId == petId then
            return item
        end
    end
    return nil
end

--通过区块链码获取集市神宠信息
function GodPetManager:getMallGodPetByPetCode(petCode)
    for item in self.mallGodPetList:iterator() do
        if item.petCode == petCode then
            return item
        end
    end
    return nil
end

--获取神宠形象
function GodPetManager:getGodPetFigureByViewData(viewData, scale, pos)
    if viewData==nil then return nil end
	local scale = scale or 1
    local pos = pos or ccp(0,0)
    
    local str = "1," .. viewData
    local testpet = require('lua.logic.godpet.GodPetView'):new(str)
    testpet:setPosition(pos)
    testpet:setScale(scale)
    testpet:setTouchEnabled(false)
    return testpet
end

--是否需要重生
function GodPetManager:isRebirthGodPetByPetCode(petCode)
    local godPet = self:getGodPetByPetCode(petCode) or {}
    local pet = PetRoleManager:getPetByGmId(godPet.petId)
    if pet then
        if pet.level > 1 or pet.curExp > 0 or pet.division > 1 then
            return true
        end
    end
    return false
end

--是否需要下阵
function GodPetManager:isBattleGodPetByPetCode(petCode)
    local godPet = self:getGodPetByPetCode(petCode) or {}
    local pet = PetRoleManager:getPetByGmId(godPet.petId)
    if pet then
        if pet.roleId ~= "0" then
            return true
        end
    end
    return false
end

function GodPetManager:setGodPetInfo(godPet)
    local godPetData = {}
	if godPet then
		godPetData.num 		    = godPet.num			--编号
		godPetData.owner 		= godPet.owner			--主人
		godPetData.score 		= godPet.score			--资质
        godPetData.birthTime 	= tonumber(godPet.birthTime) or 0--出生时间
		godPetData.curCost		= godPet.curCost    	--当前售价
		godPetData.maxCost		= godPet.maxCost		--最高售价
		godPetData.lastCost	    = godPet.lastCost		--上次售价
		godPetData.viewData 	= godPet.viewData 		--组件序列号1,2,3,4,5,6,7,8,9
		godPetData.state 		= godPet.state			--状态 1上架交易中 2跨服仓库中 3使用中
		godPetData.server 		= godPet.server			--服务器信息
        godPetData.talk 		= godPet.talk			--一句话  
        godPetData.petName      = godPet.petName	    --名字	
        godPetData.costTime     = godPet.costTime	    --出售时间
        godPetData.petType	    = localizable.pet_god_type[godPet.petType]	    --类型
        godPetData.isCurSever   = godPet.isCurSever     --是否是当前服
        godPetData.petCode      = godPet.petCode        --区块链码
        godPetData.petId        = godPet.petId          --宠物实例Id
        godPetData.petTmpId     = godPet.petTmpId 		--宠物模板Id
        godPetData.quality      = godPet.quality		--品质 
        godPetData.roleTmpId    = godPet.roleTmpId      --角色模板Id
        godPetData.tradeCD      = godPet.tradeCD or 0 	--交易CD 
        godPetData.serverCD     = godPet.serverCD or 0	--跨服CD
        godPetData.level        = godPet.level or 1     --等级
        self:initGodPetAptitude(godPetData, godPet, godPet.attr)
        self:initGodPetSkill(godPetData, godPet.skill)
    end
    return godPetData
end

-- 初始化资质
function GodPetManager:initGodPetAptitude( godPetData, godPet  )
	godPetData.aptitude = {}
    godPetData.allAptitud = 0
    
    local attribute = godPet.attr
    local itemPet = PetRoleManager:getPetByGmId(godPet.petId)
    if godPet.isCurSever and itemPet then
        attribute = itemPet.attr
        godPetData.level = itemPet.level
    end

	local itemAttr = GetAttrByString(attribute)
	for k,attr in pairs(itemAttr) do
		godPetData.aptitude[k] = attr
		godPetData.allAptitud = godPetData.allAptitud + attr
    end
end

-- 初始化技能
function GodPetManager:initGodPetSkill( godPetData, godPetSkill )
    godPetData.skill = {}
    godPetSkill = godPetSkill or {}
	-- for k,skill in pairs(godPetSkill) do
	-- 	godPetData.skill[skill.pos] = skill
    -- end
end

function GodPetManager:getIsMiningType()
	return self.isMining
end

function GodPetManager:getMiningTime()
	return self.nextTime or 0
end

function GodPetManager:getMiningRewardList()
    return self.miningRewardList
end

function GodPetManager:getMallGodPetList()
    return self.mallGodPetList
end

function GodPetManager:getMallMaxCost()
    return self.mallMaxCost or 2000000
end

function GodPetManager:getMallMinCost()
    return self.mallMinCost or ConstantData:getValue("GodPet.Sell.Price.Min")
end

function GodPetManager:setIsOpenHistory(is_history)
    self.is_open_history = is_history
end

function GodPetManager:setIsShowOutLine( is_bool )
    self.is_show_out_line = is_bool
end

function GodPetManager:getIsShowOutLine()
    return self.is_show_out_line
end

-------------------------------------------------神宠
function GodPetManager:openShenChongCatchLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shenchong.ShenChongCatchLayer", AlertManager.BLOCK_AND_GRAY)
	AlertManager:show()
end

function GodPetManager:openShenChongMySCLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shenchong.ShenChongMySCLayer", AlertManager.BLOCK_AND_GRAY)
	AlertManager:show()
end

function GodPetManager:openGodPetMallLayer()
    GodPetManager:sendGetWorldMall(1, 20, 0)
end

function GodPetManager:openShenChongShopLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shenchong.ShenChongShopLayer", AlertManager.BLOCK_AND_GRAY)
	AlertManager:show()
end

function GodPetManager:openShenChongPageLayer(petCode, shopType)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shenchong.ShenChongPageLayer", AlertManager.BLOCK_AND_GRAY)
	layer:loadData(petCode,shopType)
	AlertManager:show()
end

function GodPetManager:openShenChongPage1Layer(gmId, historyPet)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shenchong.ShenChongPage1Layer", AlertManager.BLOCK_AND_GRAY_CLOSE)
	layer:loadData(gmId,historyPet)
	AlertManager:show()
end

function GodPetManager:openShenChongK1Layer(gmId)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shenchong.ShenChongK1Layer", AlertManager.BLOCK_AND_GRAY)
	layer:loadData(gmId)
	AlertManager:show()
end

function GodPetManager:openShenChongK2Layer(gmId)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shenchong.ShenChongK2Layer", AlertManager.BLOCK_AND_GRAY)
	layer:loadData(gmId)
	AlertManager:show()
end

function GodPetManager:openShenChongGetLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shenchong.ShenChongGetLayer", AlertManager.BLOCK_AND_GRAY)
	-- layer:loadData(petCode)
	AlertManager:show()
end

function GodPetManager:openShenChongSJLayer(taxRate)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shenchong.ShenChongSJLayer", AlertManager.BLOCK_AND_GRAY)
	layer:loadData(taxRate)
	AlertManager:show()
end

function GodPetManager:openShenChongJYLayer(data)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shenchong.ShenChongJYLayer", AlertManager.BLOCK_AND_GRAY)
	layer:loadData(data)
	AlertManager:show()
end

function GodPetManager:openLeaveTimeLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.LeaveTimeLayer", AlertManager.BLOCK_AND_GRAY)
	layer:loadData(self.outLineTime)
	AlertManager:show()
end


return GodPetManager:new()