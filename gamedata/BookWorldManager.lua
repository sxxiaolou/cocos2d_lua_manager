--[[
******天书世界管理类*******

	-- by Tony
	-- 2017/5/20
]]

local BaseManager = require('lua.gamedata.BaseManager')
local BookWorldManager = class("BookWorldManager", BaseManager)

BookWorldManager.BUILD_UPDATE 				= "BookWorldManager.BUILD_UPDATE"
BookWorldManager.BUILD_ALL_UPDATE 			= "BookWorldManager.BUILD_ALL_UPDATE"
BookWorldManager.CARD_IN_FORMATION 			= "BookWorldManager.CARD_IN_FORMATION"
BookWorldManager.RES_REWARD 				= "BookWorldManager.RES_REWARD"
BookWorldManager.BOOK_RES_UPDATE 			= "BookWorldManager.BOOK_RES_UPDATE"
BookWorldManager.BOOK_WORLD_UPDATE 			= "BookWorldManager.BOOK_WORLD_UPDATE"
BookWorldManager.BOOK_WORLD_INSTITUTE 		= "BookWorldManager.BOOK_WORLD_INSTITUTE"
BookWorldManager.BOOK_WORLD_RED_POINT 		= "BookWorldManager.BOOK_WORLD_RED_POINT"
BookWorldManager.BOOK_WORLD_CANCLE_WORK_RES	= "BookWorldManager.BOOK_WORLD_CANCLE_WORK_RES"

function BookWorldManager:ctor()
	self.super.ctor(self)
end

function BookWorldManager:init()
	self.super.init(self)

	self:restart()
	TFDirector:addProto(s2c.GET_MY_BOOK_WORLD, self, self.onBookWorldInfo)
	TFDirector:addProto(s2c.BOOK_WORLD_BUILDING_LIST, self, self.onBookWorldBuildList)
	TFDirector:addProto(s2c.GET_BOOK_WORLD_SINGLE_RESULT, self, self.onBookWorldSingleResult)
	TFDirector:addProto(s2c.OPEN_AREA_RESULT, self, self.onOpenAreaResult)
	TFDirector:addProto(s2c.GET_BOOK_WORLD_EVENT, self, self.onBookWorldEvent)
	TFDirector:addProto(s2c.GET_BOOK_WORLD_REWARD, self, self.onBookWorldReward)
	TFDirector:addProto(s2c.START_BOOK_WORLD_WORK, self, self.onBookWorldWork)
	TFDirector:addProto(s2c.BUILD_BOOK_WORLD, self, self.onBuildBookWorld)
	TFDirector:addProto(s2c.ACCELERATE_BOOK_WORLD, self, self.onAccelerateBookWorld)
	TFDirector:addProto(s2c.STEAL_BOOK_WORLD_REWARD, self, self.onStealBookWorldReward)
	TFDirector:addProto(s2c.GET_BOOK_WORLD_FRIEND_RESULT, self, self.onBookWorldFriendResult)
	TFDirector:addProto(s2c.GET_ASSISTANT_RESULT, self, self.onAssistantResult)
	TFDirector:addProto(s2c.IN_FORMATION_RESULT, self, self.onInFormationResult)
	TFDirector:addProto(s2c.GET_HIRE_REWARD_RESULT, self, self.onHireRewardResult)
	TFDirector:addProto(s2c.BOOKWORLD_CHANGE, self, self.onBookWorldChange)
	TFDirector:addProto(s2c.GET_RED_POINT_RESULT, self, self.onRedPointResult)
	TFDirector:addProto(s2c.GET_BOOK_WORLD_RES_REWARD, self, self.onBookWorldResRewardResult)
	TFDirector:addProto(s2c.BOOK_WORLD_INSTITUTE_LIST, self, self.onBookWorldInstituteResult) --研究院
	TFDirector:addProto(s2c.CANCEL_WORK_RES, self, self.onBookWorldCancleWorkRes)
end

function BookWorldManager:restart()
	self:resetData()

	self.myCardList = nil
    self.myAssistantList = nil
end

function BookWorldManager:resetData()
	self:resetTimer()

	self.ownerId = nil
	self.bookWorld = nil
	self.openedArea = nil
	self.hasRedPoint = 0

	self.assistantList = nil
	self.friendList = nil
	self.bookWorldEvent = nil
	
	if not self.buildList then
		self.buildList = TFArray:new()
	end
	self.buildList:clear()
end

function BookWorldManager:resetTimer()
	if self.timeId then
		TFDirector:removeTimer(self.timeId)
		self.timeId = nil
	end
end

function BookWorldManager:addTimer()
	local function update(delta)
		if self.hasRedPoint == 0 then
        	self:sendRedPoint()
        else
        	self:resetTimer()
        end
    end
	self:resetTimer()
	update()
    local interval = ConstantData:getValue("BookWorld.RedPoint.Interval") or 300
    self.timeId = TFDirector:addTimer(interval * 1000, -1, nil, update)
end

function BookWorldManager:isHaveRedPoint()
	local is_can = JumpToManager:isCanJump(FunctionManager.BookWorld)
	if is_can and self.hasRedPoint and self.hasRedPoint > 0 then 
		return true 
	end
	return false
end

--天书数据
function BookWorldManager:onBookWorldInfo(event)
	hideLoading()

	self.bookWorld = event.data
	-- print("===== BookWorldManager:onBookWorldInfo =====", self.bookWorld)
	TFDirector:dispatchGlobalEventWith(BookWorldManager.BOOK_RES_UPDATE, 0)
end

--天书建筑列表更新
function BookWorldManager:onBookWorldBuildList(event)
	hideLoading()

	self.buildList:clear()
	local building = event.data.building or {}
	self.ownerId = event.data.ownerId or MainPlayer.playerId
	for _, data in pairs(building) do
		self:addBuild(data)
	end
	-- print("===== BookWorldManager:onBookWorldBuildList ===", building, ", ownerId:", self.ownerId)
	if not self.noEnterSence then
		self:enterBookWorld()
	end
	self.noEnterSence = false

	TFDirector:dispatchGlobalEventWith(BookWorldManager.BUILD_ALL_UPDATE, 0)
end

--查看天书世界单个更新
function BookWorldManager:onBookWorldSingleResult(event)
	hideLoading()

	local data = event.data.building
	self.ownerId = event.data.ownerId or MainPlayer.playerId
	self:addBuild(data)
	-- print("===== BookWorldManager:onBookWorldSingleResult =====", data)

	TFDirector:dispatchGlobalEventWith(BookWorldManager.BUILD_UPDATE, data.instance_id)
end

--开放区域
function BookWorldManager:onOpenAreaResult(event)
	hideLoading()

	local data = event.data
	self.openedArea = data.opened_area
end

--请求天书事件
function BookWorldManager:onBookWorldEvent(event)
	hideLoading()

	self.bookWorldEvent = event.data.eventList or {}
	self:openBookWorldEventLayer()
end

--收取
function BookWorldManager:onBookWorldReward(event)
	hideLoading()

end

--工作
function BookWorldManager:onBookWorldWork(event)
	hideLoading()

	TFDirector:dispatchGlobalEventWith(BookWorldManager.BOOK_WORLD, 0)
end

--建造升级
function BookWorldManager:onBuildBookWorld(event)
	hideLoading()

	TFDirector:dispatchGlobalEventWith(BookWorldManager.BOOK_UP_LEVEL, 0)
end

--加速
function BookWorldManager:onAccelerateBookWorld(event)
	hideLoading()

end

--偷奖励
function BookWorldManager:onStealBookWorldReward(event)
	hideLoading()

end

--获得可拜访的好友列表
function BookWorldManager:onBookWorldFriendResult(event)
	hideLoading()

	self.friendList = event.data.friendList

	for _, v in pairs(self.friendList) do
		v.weight = v.bookworld_lv
		if v.canSteal then
			v.weight = v.weight + 1000
		end
		if v.canAccelerate then
			v.weight = v.weight + 500
		end
	end
	table.sort(self.friendList, function (a1, a2)
		return a1.weight > a2.weight
	end)
	self:openBookWorldFriendListLayer()
end

--获得我方卡牌和援助卡牌
function BookWorldManager:onAssistantResult(event)
	hideLoading()
----------------------------------------------------
	local data = event.data
	self.myCardList = data.myCardList or {}
	self.myAssistantList = data.myAssistantList or {}
	self.assistantList = data.assistantList or {}

	TFDirector:dispatchGlobalEventWith(BookWorldManager.CARD_IN_FORMATION, 0)

end

--天枢保存阵容上阵
function BookWorldManager:onInFormationResult(event)
	hideLoading()

end

--领取雇佣奖励
function BookWorldManager:onHireRewardResult(event)
	hideLoading()

end

--通知天书世界变化
function BookWorldManager:onBookWorldChange(event)
	hideLoading()

	local type = event.data.type

	local str = localizable.bookworld_change[type]
	if str ~= nil and str ~= "" then
		toastMessage(str)
	end

	if type == 2 or type == 3 or type == 8 or type == 10 then
		local currentScene = Public:currentScene()
		if currentScene and currentScene.__cname == "BookWorldScene" then
			self:sendBookWorld(MainPlayer.playerId)
		end
	end

	TFDirector:dispatchGlobalEventWith(BookWorldManager.BOOK_WORLD_UPDATE, type)
end

function BookWorldManager:onRedPointResult(event)
	self.hasRedPoint = event.data.hasRedPoint

	TFDirector:dispatchGlobalEventWith(BookWorldManager.BOOK_WORLD_RED_POINT)
end

function BookWorldManager:onBookWorldResRewardResult(event)
	local data = event.data

	data.id = data.instance_id
	TFDirector:dispatchGlobalEventWith(BookWorldManager.RES_REWARD, data)
end

function BookWorldManager:onBookWorldInstituteResult(event)
	local data = event.data

	self.instituteList = data.instituteList
	TFDirector:dispatchGlobalEventWith(BookWorldManager.BOOK_WORLD_INSTITUTE, 0)
end

function BookWorldManager:onBookWorldCancleWorkRes(event)
	local data = event.data

	if not data then return end
	TFDirector:dispatchGlobalEventWith(BookWorldManager.BOOK_WORLD_CANCLE_WORK_RES, data.instance_id)
end

--=============================== proto =======================================
--请求天书 
function BookWorldManager:sendBookWorld(playerId)
	self:sendWithLoading(c2s.GET_BOOK_WORLD, playerId)
end

--请求天书事件
function BookWorldManager:sendBookWorldEvent()
	self:sendWithLoading(c2s.GET_BOOK_WORLD_EVENT, false)
end

--收取  
function BookWorldManager:sendBookWorldReward(auto, id)
	self:sendWithLoading(c2s.GET_BOOK_WORLD_REWARD, auto, id)
end

--一键工作  
function BookWorldManager:sendStartBookWorldWorkAuto()
	self:sendWithLoading(c2s.START_BOOK_WORLD_WORK_AUTO, false)
end

--建造升级
function BookWorldManager:sendBuildBookWorld(id)
	self:sendWithLoading(c2s.BUILD_BOOK_WORLD, id)
end

--加速 
function BookWorldManager:sendAccelerateBookWorld(id, ownerId)
	self:sendWithLoading(c2s.ACCELERATE_BOOK_WORLD, id, ownerId)
end

--偷奖励
function BookWorldManager:sendStealBookWorldReward(id, ownerId)
	self:sendWithLoading(c2s.STEAL_BOOK_WORLD_REWARD, id, ownerId)
end

--获得可拜访的好友列表
function BookWorldManager:sendBookWorldFriend()
	self:sendWithLoading(c2s.GET_BOOK_WORLD_FRIEND, false)
end

--获得我方卡牌和援助卡牌
function BookWorldManager:sendAssistant()
	self:sendWithLoading(c2s.GET_ASSISTANT, false)
end

--工作
function BookWorldManager:sendStartBookWorldWork(id, double, cardIds, assistant, cardOwner, quality)
	self:sendWithLoading(c2s.START_BOOK_WORLD_WORK, id, double, cardIds, assistant, cardOwner, quality)
end

--保存阵容上阵 卡牌id、建筑实例id
function BookWorldManager:sendInFormation(cardIds, id, assistant, cardOwner, noEnterSence)
	self.noEnterSence = noEnterSence
	self:sendWithLoading(c2s.IN_FORMATION, cardIds, id, assistant, cardOwner)
end

--天枢上阵援助
function BookWorldManager:sendInAssistant(cardIds)
	self:sendWithLoading(c2s.IN_ASSISTANT, cardIds, false)
end

--领取雇佣奖励
function BookWorldManager:sendHireReward()
	self:sendWithLoading(c2s.GET_HIRE_REWARD, false)
end

--开放区域
function BookWorldManager:sendOpenArea()
	-- self:sendWithLoading(c2s.OPEN_AREA, false)
	TFDirector:send(c2s.OPEN_AREA, {false})
end

--获取天书系统红点提示
function BookWorldManager:sendRedPoint()
	TFDirector:send(c2s.GET_RED_POINT, {false})
end

--请求单个建筑
function BookWorldManager:sendBookWorldSingle(id)
	TFDirector:send(c2s.GET_BOOK_WORLD_SINGLE, {id, self.ownerId})
end

--研究院研究
function BookWorldManager:sendBookWorldWork(institute_id, cardIds )
	TFDirector:send(c2s.RESEARCH_BOOK_WORLD_WORK, {institute_id, cardIds})
end

--取消建筑工作
function BookWorldManager:sendBookWorldCancelWork( instance_id )
	self:sendWithLoading(c2s.CANCEL_WORK, instance_id)
end

--=============================================================================

function BookWorldManager:addBuild(data)
	local build = self:findBuild(data.instance_id)
	if not build then
		build = {}
		self.buildList:push(build)
	end

	build.id = data.instance_id
	build.buildId = data.builderId
	build.builderId = data.builderId
	build.status   = data.status
	build.stop     = data.stop
	build.instance_id = data.instance_id
	build.waite_need  = data.waite_need
	build.quality     = data.quality
	build.stealNum    = data.stealNum
	build.accelerateNum = data.accelerateNum
	build.canSteal     = data.canSteal
	build.canAccelerate = data.canAccelerate
	build.totalTime    = data.totalTime
	build.isDouble		= data.isDouble
	build.lvup_need		= data.lvup_need
	build.commonInfo		= data.commonInfo
	build.isHub = math.floor(build.buildId/100000) == 2 and true or false
	build.template = build.isHub and BookWorldData:objectByID(build.buildId) or BookWorldBuildData:objectByID(build.buildId)
end

--建筑实例id
--建筑数据
function BookWorldManager:findBuild(id)
	for build in self.buildList:iterator() do
		if build and build.id == id then
			return build
		end
	end
	return nil
end

--通过tmpId获取建筑信息
function BookWorldManager:findBuildByTmpId(type)
	for build in self.buildList:iterator() do
		if build and build.template.kind == type then
			return build
		end
	end
	return nil
end

function BookWorldManager:getHubBuild()
	for build in self.buildList:iterator() do
		if build and build.isHub == true then
			return build
		end
	end
	return nil
end

function BookWorldManager:getBuildLevelByTmpId(type)
	local build = self:findBuildByTmpId(type)
	if build then
		return build.template.level
	end
	return 0
end

function BookWorldManager:inFormation(id)
	for k,v in pairs(self.myCardList) do
		if v and v.cardId == id then
			return v
		end
	end
	return nil
end

--通过id判断卡牌是否在天书中使用
function BookWorldManager:inBookWorldIsUseById(id)
	local cardList = self.myCardList or {}
	for k,v in pairs(cardList) do
		if v and v.cardId == id and (v.status == 2 or v.status == 4) then
			return true
		end
	end

	local assistantList = self.myAssistantList or {}
	for k,v in pairs(assistantList) do
		if v and v.cardId == id then
			return true
		end
	end

	return false
end

--通过id判断卡牌是否在使用中
function BookWorldManager:cardIsUseById(gmId,buildData,listType)

	local instanceIds = {}
	if buildData.isHub then
		if listType == EnumBookWorldCardType.MyCard then

			if self:inFormation(gmId) then
				return true
			end

			if self:inAssistant(gmId) then
				return false
			end
		elseif listType == EnumBookWorldCardType.InstituteCard then
			if self:inAssistant(gmId) then
				return true
			end
		end
		
	end

	for k,v in pairs(self:getUpFrontByBuildId(buildData.id)) do
		if v.cardId == gmId then
			return false
		end
	end

	local is_bool = false
	is_bool = (self:inFormation(gmId) or self:inAssistant(gmId)) and true or false
	return is_bool
end

--通过建设id获取上阵卡牌
function BookWorldManager:getUpFrontByBuildId(id)
	local itemList = {}
	for k,v in pairs(self.myCardList) do
		if v and v.builderId == id then
			itemList[#itemList + 1] = v
		end
	end
	return itemList
end

--通过建设id获取上阵的援助卡牌
function BookWorldManager:getAssistantByBuildId(id)
	local itemList = {}

	-- print("========================self.assistantList",self.assistantList)
	for k,v in pairs(self.assistantList or {}) do
		if v and v.builderId == id then
			itemList[#itemList + 1] = v
		end
	end
	return itemList
end

--获取未上阵的援助卡牌
function BookWorldManager:getNotUpAssistant()
	local itemList = {}
	for k,v in pairs(self.assistantList) do
		if v.builderId == "0" then
			itemList[#itemList + 1] = v		
		end
	end
	return itemList
end

--获取援助的机器人卡牌
function BookWorldManager:getNotUpRobotAssistant()
	local itemList = {}
	for item in BookWorldRobotData:iterator() do
		local roleData = {cardId = 0, tmpId = 0, power = 0, builderId = 0, ownerId = 0}	
		roleData.cardId = item.id
		roleData.tmpId = item.card_id
		roleData.power = item.power
		roleData.builderId = 0
		roleData.level = item.level
		itemList[#itemList + 1] = roleData
	end
	return itemList
end

--通过研究类型与天书等级获得可研究最高等级
function BookWorldManager:getResearchLvByTypeAndLevel(type,level)
	local maxLevel = 0
	local instituteData = BookWorldInstituteData.InstituteData[type]
	if instituteData then
		for item in instituteData:iterator() do
			if item.main_level <= level then
				maxLevel = item.level
			else
				break
			end
		end
	end
	return maxLevel
end

--通过id判断建筑是否可以升级
function BookWorldManager:buildIsCanUpLevel(data)
	if data.template.level == 0 then return false end
	local maxLv = ConstantData:getValue( "BookWorld.Max.Level" )
	if data.template.level >= maxLv then
		return false
	end

	local is_bool = true
	local bookWorldBuildData = BookWorldBuildData:objectByID(data.template.id + 1)
	if data.isHub then
		bookWorldBuildData = BookWorldData:objectByID(data.template.id + 1)
	end
	if bookWorldBuildData then
		if data.isHub then 
			for k,v in pairs(bookWorldBuildData:geNeedLv()) do
				local itemBuildData = self:findBuildByTmpId(v[1])
				if not itemBuildData or itemBuildData.template.level < v[2] then
					return false
				end
			end
		else
			local hubBuild = self:getHubBuild()
			if hubBuild.template.level < bookWorldBuildData.need_main_lv then
				return false
			end
		end
		
		local nexMaterial = bookWorldBuildData:getMaterial()
		for k,v in pairs(nexMaterial) do
			local number = 0
			if v[1] == EnumResourceType.Coin then
				number = MainPlayer:getCoin()
			elseif v[1] == EnumResourceType.Wood then
				number = self.bookWorld.wood
			elseif v[1] == EnumResourceType.Stone then
				number = self.bookWorld.stone
			elseif v[1] == EnumResourceType.Metal then
				number = self.bookWorld.gold
			end
			if number < v[3] then
				is_bool = false
			end
		end
	end

	return is_bool
end

--通过id判断建筑是否可以运转
function BookWorldManager:buildIsCanWork(buildData)
	local havePower = 0
	local needPower = 0
	
	local upCard = self:getUpFrontByBuildId(buildData.id)	
	for k, v in pairs(upCard) do
		local roleData = CardRoleManager:getRoleByGmId(v.cardId)
		
		if roleData then
			havePower = havePower + roleData.power
		end
	end
	
	
	local assisCard = self:getAssistantByBuildId(buildData.id)
	for k, v in pairs(assisCard) do
		-- local roleData = CardRoleManager:getRoleByGmId(v.cardId)
		
		-- if roleData then
		-- 	havePower = havePower + roleData.power
		-- end
		havePower = havePower + v.power
	end
	

	if buildData.commonInfo then
		local task = buildData.template.task
		if task == 0 then
			return false
		elseif task == 1 then
			needPower = buildData.commonInfo.work_power_need_primary
		elseif task == 2 then
			needPower = buildData.commonInfo.work_power_need_medium
		elseif task == 3 then
			needPower = buildData.commonInfo.work_power_need_senior
		end
		if havePower >= needPower then
			return true
		end
	end
	
	return false
end  

function BookWorldManager:inAssistant(id)
	for k,v in pairs(self.myAssistantList) do
		if v and v.cardId == id then
			return true
		end
	end
	return false
end

function BookWorldManager:isOwner()
	if self.ownerId == MainPlayer.playerId then
		return true
	end
	return false
end

function BookWorldManager:getCurBookWorldName()
	local ownerId = self.ownerId
	for _, friend in pairs(self.friendList) do
		if friend.player_id == ownerId then
			return friend.name
		end
	end
	return ""
end

function BookWorldManager:getOpenArea()
	if self.openedArea == nil or self.openedArea < 1 then
		return 1
	elseif self.openedArea > 4 then
		return 4
	end
	return self.openedArea
end

--推荐阵容 需要的战力 建筑的实例id
function BookWorldManager:recommendFormation(power, id)
	local formation = {}
	local assistant = ""
	local cards = TFArray:new()
	local cardList = CardRoleManager.cardRoleList
	for card in cardList:iterator() do
		local data = self:inFormation(card.gmId)
		if (not data and not self:inAssistant(card.gmId)) or (data and id and data.builderId == id) then
			cards:push(card)
		end
	end
	cards:sort(function (a1, a2)
		return a1.power > a2.power
	end)

	local function getCard()
		local last = nil
		for card in cards:iterator() do
			if card.power > power then
				last = card
			end
			if card.power < power then
				if last then
					return last
				else
					return card
				end
			end
			if card.power == power then
				return card
			end
		end
		return last	
	end
	
	while(power > 0 and cards:length() > 0)
	do
		local card = getCard()
		if card then
			formation[#formation + 1] = card.gmId
			cards:removeObject(card)
			power = power - card.power
		end
	end

	if power > 0 then
		for robot in BookWorldRobotData:iterator() do
			if robot.power > power then
				assistant = tostring(robot.id)
				break
			end
		end
	end
	return formation, assistant
end

function BookWorldManager:enterBookWorld()
	self:resetTimer()
	local currentScene = Public:currentScene()
    if currentScene.__cname == "HomeScene" then
    	AlertManager:changeScene(SceneType.BOOKWORLD, nil)
    elseif currentScene.__cname == "BookWorldScene" then
    	if currentScene.refreshScene then
    		currentScene:refreshScene()
    	end
    else
		AlertManager:changeScene(SceneType.BOOKWORLD)
    end
end

function BookWorldManager:openBookWorldTSLayer(data)  
	if data.isHub then
		local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.bookworld.layer.BookWorldTSLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
		layer:loadData(data)
		AlertManager:show()
	else
		local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.bookworld.layer.BookWorldGSLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
		layer:loadData(data)
		AlertManager:show()
	end
	
end

function BookWorldManager:openBookWorldRoleListLayer(data, type)  
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.bookworld.layer.BookWorldRoleListLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
	layer:loadData(data, type)
	AlertManager:show()	
end


function BookWorldManager:openBookWorldFriendListLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.bookworld.layer.BookWorldFriendListLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function BookWorldManager:openBookWorldEventLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.bookworld.layer.BookWorldEventLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

--=============================================================================

return BookWorldManager:new()
