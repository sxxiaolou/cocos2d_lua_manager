--	人物走动
--  sunyunpeng
-- 	Date: 2017-09-25
--

local MainRoleRunManager = class("MainRoleRunManager")

local LayerZOrder = 
{
	UI = 1000,
	Near = 900,	--self.panel_jin
	Floor = 500,	--self.panel_di
	Far = 0,
}

------------------------player
local TPlayers = {
	playerId 		= nil,
	showId 			= nil,
	model 			= nil,
	state 			= nil,
	startPos 		= nil,
	endPos 			= nil,
	name 			= nil,
	quality 		= nil,
	level 			= nil,
	power 			= nil,
	emojiTime		= nil,
}
TPlayers.__index = TPlayers
-- 创建类
TPlayers.new = function()
    local self 		= {}            
    setmetatable(self, TPlayers)
    self.playerId 	= nil
    self.model 		= nil
    self.state 		= nil
    self.startPos 	= nil
	self.endPos 	= nil
	self.name 		= nil
	self.quality 	= nil
	self.level 		= nil
	self.power 		= nil
	self.emojiTime	= 0
    return self
end

--======================NPC
local TSystems = {
	model 			= nil,
	name 			= nil,
	is_touch 		= false,
	path1			= TFArray:new(),
	path2			= TFArray:new(),
	mainPath		= TFArray:new(),
	is_direc 		= true,
	topTime 		= 0,
	addTime 		= 0,
	is_stop			= false,
	touch_time		= 0,				--点击之后暂停时间
	rotation_Y		= 0,
	is_guide 		= false, 
}
TSystems.__index = TSystems
TSystems.new = function (model, name,data)

	local self = {}
	setmetatable(self, TSystems)
	self.model 		= model or nil
	self.name 		= name or ""
	self.is_touch 	= data.is_touch or false
	self.path1		= TFArray:new()
	self.path2		= TFArray:new()
	self.mainPath	= TFArray:new()
	self.is_direc 	= true
	self.topTime 	= 0
	self.addTime 	= 0
	self.is_stop	= data.is_stop or false
	self.touch_time	= 0
	self.rotation_Y	= data.npcRotationY or 0
	return self
end
--======================
function MainRoleRunManager:ctor()
	self.players = MEMapArray:new()
	self.MainRole_MoveSpeed = MainPlayer:getSpeed() --MainRolePos and MainRolePos.Speed or 350 			-- 主角每秒钟移动的速度  单位:像素/秒
	--上传位置时间间隔
	self.intervalTime		= 0
	
	self:registerEvents()
end

function MainRoleRunManager:registerEvents()

	self.onTimerUpdated = function(timer)
		self:refreshTimer(timer)
	end

    if not self.mainRoleTimerId then
    	self.mainRoleTimerId = TFDirector:addTimer(10,-1,nil,self.onTimerUpdated)
	end
	
	
	self.someoneEnterScene = function(events) 
		self:onSomeoneEnterScene(events) end
	TFDirector:addMEGlobalListener(SyncPosManager.SYNC_ENTER_SCENE, self.someoneEnterScene)

    self.someoneExitScene = function(events) self:onSomeoneExitScene(events) end
	TFDirector:addMEGlobalListener(SyncPosManager.SYNC_EXIT_SCENE, self.someoneExitScene)

    self.someoneMove = function(events) self:onSomeoneMove(events) end
	TFDirector:addMEGlobalListener(SyncPosManager.SYNC_POS, self.someoneMove)

end

function MainRoleRunManager:dispose()
	if self.mainRoleTimerId then
    	TFDirector:removeTimer(self.mainRoleTimerId)
    	self.mainRoleTimerId = nil
    	self.onTimerUpdated = nil
	end
	
	TFDirector:removeMEGlobalListener(SyncPosManager.SYNC_ENTER_SCENE, self.someoneEnterScene)
	self.someoneEnterScene = nil

	TFDirector:removeMEGlobalListener(SyncPosManager.SYNC_EXIT_SCENE, self.someoneExitScene)
    self.someoneExitScene = nil

	TFDirector:removeMEGlobalListener(SyncPosManager.SYNC_POS, self.someoneMove)
	self.someoneMove = nil

	self.logic = nil
	self.zOrderFunc = nil
	self.players:clear()
	self.other_player_panel = nil
end

function MainRoleRunManager:clearPlayer()
	self.players:clear()
end

function MainRoleRunManager:setOterPlayerPanel( sceneType, other_player_panel, logic)
	self.sceneType = tostring(sceneType)
	self.other_player_panel = other_player_panel
	self.logic = logic or self
	self.zOrderFunc = self.zOrderFunc or self.updateZOrder
	for k,v in pairs(SyncPosManager.players) do
		self:onAddPlayer(v, self.sceneType)
	end
end

function MainRoleRunManager:setZOrderFunc(func)
	self.zOrderFunc = func
end

function MainRoleRunManager:getPlayers()
	return self.players
end

function MainRoleRunManager:onAddNPC(model, name, data)
	return TSystems.new(model,name,data)
end

function MainRoleRunManager:onAddPlayer(playerData, sceneType)
	if playerData and playerData.scene == sceneType then
		local player = TPlayers.new()
		local skeleton = GameResourceManager:getRoleAniById(playerData.showId, 0.8)
		if skeleton then
			player.playerId = playerData.playerId
			player.showId = playerData.showId
			player.state = 1
			player.startPos = ccp(playerData.x, playerData.y)
			player.endPos = ccp(playerData.x, playerData.y)
			player.name = playerData.name 
			player.quality = playerData.quality 
			player.level = playerData.level
			player.power = playerData.power
			player.modelDemo = self:createPanel(skeleton, player.startPos, self.other_player_panel)
			player.modelDemo.txt_name:setText(player.name)
			-- self:updateZOrder(player.modelDemo)
			self.zOrderFunc(self.logic, player.modelDemo)
		end
		self.players:pushbyid(player.playerId, player)
	end
end

function MainRoleRunManager:createPanel(skeleton, pos, parentPanel)

	local panel = createUIByLuaNew("lua.uiconfig.common.PlayerItem")
	-- local panel = TFDirector:getChildByPath(playerItem, "Panel_MainRole")
	-- panel:removeFromParent()

	parentPanel:addChild(panel)
	panel:setAnchorPoint(ccp(0.5, 0))
	panel:setPosition(pos)
	panel.skeleton = skeleton
	panel.txt_name = TFDirector:getChildByPath(panel, "txt_name")
	panel:addChild(skeleton)

	self:addModelShadow(panel)
	return panel
end

function MainRoleRunManager:addModelShadow(panel,s_scale)
	local shadowImg = TFImage:create("ui/fight/shadow.png")
	local p_scale = s_scale or 1
    shadowImg:setPosition(ccp(0,0))
	shadowImg:setZOrder(-1001)
	shadowImg:setScale(p_scale)
	panel.shadowImg = shadowImg
	panel:addChild(shadowImg)
end

function MainRoleRunManager:onRemovePlayer(playerData)

	local item = self.players:objectByID(playerData.playerId)
	if item then
		item.modelDemo:removeFromParent()
		item.modelDemo = nil
		self.players:removeById(playerData.playerId)		
	end
end

function MainRoleRunManager:onMovePlayer(playerData)
	local item = self.players:objectByID(playerData.playerId)
	if item then
		item.endPos = ccp(playerData.x,playerData.y)
	end
end

function MainRoleRunManager:refreshTimer( timer )

	-- if self.sceneType == "1" or self.sceneType == "2" or self.sceneType == "3" then
		self:refreshMainRolePos(timer)
	-- end
	
	self:refreshPlayerPos(timer)
end

function MainRoleRunManager:refreshPlayerPos(timer)
	for item in self.players:iterator() do

		if item.modelDemo.emoji then
			item.emojiTime = item.emojiTime + timer
			if item.emojiTime >= 5 then
				item.emojiTime = 0
				item.modelDemo.emoji:removeFromParent()
				item.modelDemo.emoji = nil
			end
		end

		if item.startPos ~= item.endPos then
			local targetPos = item.endPos
			local rolePos = item.modelDemo:getPosition()
			local timeIntel = math.floor(timer*1000)

			-- 计算两点的距离
			local xDis = math.abs(rolePos.x - targetPos.x)
			local yDis = math.abs(rolePos.y - targetPos.y)
			local targetDis = math.sqrt(xDis*xDis + yDis*yDis)

			-- 到达目地的用时
			local targetTime = targetDis * 1000 / self.MainRole_MoveSpeed  --单位毫秒
			-- 直接到达
			if(targetTime <= timeIntel) then
				self:setPlayerPos(item.modelDemo,targetPos)
				item.startPos = item.endPos
				Utils:playSkeletonAni(item.modelDemo)
				return
			end

			-- 每次更新需要移动的跑离
			local moveX = (targetPos.x - rolePos.x)*timeIntel/targetTime
			local moveY = (targetPos.y - rolePos.y)*timeIntel/targetTime
			local nextX = math.floor(rolePos.x + moveX)
			local nextY = math.floor(rolePos.y + moveY)
			self:setPlayerPos(item.modelDemo,ccp(nextX, nextY))		
		end
	end
end

function MainRoleRunManager:setPlayerPos(player, pos)
	if player then
		local playerLastPos = player:getPosition()
		player:setPosition(pos)
		Utils:playSkeletonAni(player, playerLastPos, pos, false)
		self.zOrderFunc(self.logic, player)
	end
end

function MainRoleRunManager:updateZOrder(npcPanel, fixY)
	fixY = fixY or 0
	local rolePos = npcPanel:getPosition()
	npcPanel:setZOrder(LayerZOrder.Floor-(rolePos.y+fixY))
end

-------------------------------------------------
function MainRoleRunManager:onSomeoneEnterScene(events)
	local playerData = events.data[1]
	if playerData and playerData.scene == self.sceneType then
		self:onAddPlayer(playerData, self.sceneType)
	end
end

function MainRoleRunManager:onSomeoneExitScene(events)
	local playerData = events.data[1]
	if not playerData then return end
	self:onRemovePlayer(playerData)
end

function MainRoleRunManager:onSomeoneMove(events)
	local playerData = events.data[1]
	if not playerData then return end
	if playerData.scene == self.sceneType then
		self:onMovePlayer(playerData)
	end
end

function MainRoleRunManager:addMainRoleModel(cardID)
	local itemPanel = createUIByLuaNew("lua.uiconfig.common.PlayerItem")
	-- local itemPanel = TFDirector:getChildByPath(playerItem, "Panel_MainRole")
	local panel_MainRole = itemPanel:luaclone()
	
	local MainRole_skeleton = GameResourceManager:getRoleAniById(cardID, 0.8)
	MainRole_skeleton:setPosition(ccp(0,0))
    panel_MainRole:removeAllChildren()
    panel_MainRole.skeleton = MainRole_skeleton
    panel_MainRole:addChild(MainRole_skeleton)
    -- Utils:addSkeletonEvent(MainRole_skeleton)

    local shadowImg = TFImage:create("ui/fight/shadow.png")
    shadowImg:setPosition(ccp(-3,0))
	shadowImg:setZOrder(-1001)
	panel_MainRole:addChild(shadowImg)
	panel_MainRole.shadow = shadowImg
	panel_MainRole.emojiTime = 0	
	return panel_MainRole, MainRole_skeleton, shadowImg 
end


--主角移动逻辑 角色在移动状态就要刷新角色位置
function MainRoleRunManager:refreshMainRolePos(timer)

	if not self.logic or self.logic == self then return end

	local logic = self.logic
	-- --====================================上传位置
	-- self.lastSetPosTime = self.lastSetPosTime or os.time()
	-- self.oldSetPos = self.oldSetPos or {}
	-- if (os.time() - self.lastSetPosTime) >= self.intervalTime and 
	-- (self.oldSetPos.x ~= self.logic.MainRoleTargePosX or self.oldSetPos.y ~= self.logic.MainRoleTargePosY) then
	-- 	self.lastSetPosTime = os.time()
	-- 	self.oldSetPos = {x=self.logic.MainRoleTargePosX, y=self.logic.MainRoleTargePosY}
	-- 	SyncPosManager:sendSetPos(self.sceneType, self.logic.MainRoleTargePosX, self.logic.MainRoleTargePosY)
	-- end
	-- --====================================
	-- -- if self.transferDoor then return end
	
	if(self.logic.MainRolePosX ~= self.logic.MainRoleTargePosX or self.logic.MainRolePosY ~= self.logic.MainRoleTargePosY) then
		if(self.logic.MainRole_state ~= self.logic.MainRole_RunState) then
			self.logic.MainRole_skeleton:play(0, "run", 1)
			self.logic.MainRole_state = self.logic.MainRole_RunState
			-- print("playerRun")
		end
		local timeIntel = math.floor(timer*1000)
		--print("timeIntel"..timeIntel)
		-- 先设定主角朝向
		if(self.logic.MainRoleTargePosX < self.logic.MainRolePosX) then
			self.logic.panel_MainRole:setRotationY(180)
		else
			self.logic.panel_MainRole:setRotationY(0)
		end

		-- 计算两点的距离
		local xDis = math.abs(self.logic.MainRolePosX - self.logic.MainRoleTargePosX)
		local yDis = math.abs(self.logic.MainRolePosY - self.logic.MainRoleTargePosY)
		local targetDis = math.sqrt(xDis*xDis + yDis*yDis)

		-- 到达目地的用时
		local targetTime = targetDis*1000/self.MainRole_MoveSpeed   --单位毫秒

		-- 直接到达
		if(targetTime <= timeIntel) then
			self.logic.MainRolePosX = self.logic.MainRoleTargePosX
			self.logic.MainRolePosY = self.logic.MainRoleTargePosY
			self.logic:setMainRolePos(self.logic.MainRolePosX,self.logic.MainRolePosY)
			self.logic.DJ_Effect:setVisible(false)
			
			return
		end

		-- 每次更新需要移动的跑离
		local moveX = (self.logic.MainRoleTargePosX - self.logic.MainRolePosX)*timeIntel/targetTime
		local moveY = (self.logic.MainRoleTargePosY - self.logic.MainRolePosY)*timeIntel/targetTime
		local nextX = math.floor(self.logic.MainRolePosX + moveX)
		local nextY = math.floor(self.logic.MainRolePosY + moveY)

		if tonumber(self.sceneType) == EnumSceneType.Mall then
			if self.logic:checkBackMenu(nextX, nextY) then
				-- AlertManager:changeScene(SceneType.HOME)
				if self.mainRoleTimerId then
					TFDirector:removeTimer(self.mainRoleTimerId)
					self.mainRoleTimerId = nil
					self.onTimerUpdated = nil
				end
				
				self.logic:backToHome()
				return
			end
		end

		-- 如果下一个点是不可行走，则另外寻找行走点
		if(self.logic:checkPointClick(nextX,nextY) == false) then
			if(self.logic:checkPointClick(nextX,self.logic.MainRolePosY) == true) then
				self.logic:setMainRolePos(nextX,self.logic.MainRolePosY)
			else
				if(self.logic:checkPointClick(self.logic.MainRolePosX,nextY)) then
					self.logic:setMainRolePos(self.logic.MainRolePosX,nextY)	
				end
			end
		else
			self.logic:setMainRolePos(nextX,nextY)
		end

		if self.logic.dispatchEvent and self.logic.dispatchEvent == true then
			local diffX = math.abs(self.logic.MainRolePosX - self.logic.MainRoleTargePosX)
			local diffY = math.abs(self.logic.MainRolePosY - self.logic.MainRoleTargePosY)
	
			if diffX < 10 or diffY < 10 then
				TFDirector:dispatchGlobalEventWith("mainRolePutSpecial")
			end
		end
	else
		-- self.logic.DJ_Effect:setVisible(false)
		if(self.logic.MainRole_state ~= self.logic.MainRole_StandState) then
			self.logic.MainRole_skeleton:play(0, "stand", 1)
			self.logic.MainRole_state = self.logic.MainRole_StandState
			-- print("playerStand")
		end

		-- todo
		if tonumber(self.sceneType) == EnumSceneType.Mall then
			if self.logic.clickBuild then
				ShopManager:showShopLayer(self.logic.clickBuild.type, tag)
				self.logic.clickBuild = nil
	
				TFDirector:dispatchGlobalEventWith("MapMoveDisable", nil)
			end
	
			if self.logic.eyeBoxIndex then
				--商业街 异色之瞳宝箱领取
				EyeManager:sendGetEyeBox(self.logic.eyeBoxIndex)
				self.logic.eyeBoxIndex = nil
			end
		else
			if self.logic.is_InNPC then
				self.logic.is_InNPC = false			
				self.logic:getOnCallBack(self.logic.str_name)
	
				TFDirector:dispatchGlobalEventWith("MapMoveDisable", nil)
			end
		end
			
	end	
end

return MainRoleRunManager