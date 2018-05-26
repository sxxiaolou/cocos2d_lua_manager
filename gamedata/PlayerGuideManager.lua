--
-- Author: Tony
-- Date: 2016-10-27 11:24:29
--

local PlayerGuideManager = class("PlayerGuideManager")

local tGetTriggerFunction = require('lua.gamedata.TriggerFunction')

local TiaoguoTime = 180

local tTriggerFunctions = {
	["level"]		= tGetTriggerFunction.getLevel,				--当前等级
	["minLevel"]	= tGetTriggerFunction.getMinLevel,			--最低等级
	["maxLevel"]	= tGetTriggerFunction.getMaxLevel,			--最高等级
	["step"]		= tGetTriggerFunction.getStep,				--当前步骤
	["maxStep"]		= tGetTriggerFunction.getMaxStep,			--最大步骤
	["martial"]		= tGetTriggerFunction.getMartial,			--秘籍可进阶
	["curMission"]	= tGetTriggerFunction.getCurMission,		--当前关卡
	["passMission"] = tGetTriggerFunction.getPassMission,		--通关关卡	
	["roleFrag"] 	= tGetTriggerFunction.getRoleFrag, 			--角色可突破
	["roleNum"]		= tGetTriggerFunction.getRoleNum,			--拥有人数满足
	["roleCompose"] = tGetTriggerFunction.getRoleCompose,    	--角色合成
	["targetMission"] = tGetTriggerFunction.getTargetMission,     --目标任务 
	["pet"] 		 = tGetTriggerFunction.getPet,				--是否有宠物   
	["team"] 		 = tGetTriggerFunction.getTeam, 			--是否在组队中  
	["role"]  		 = tGetTriggerFunction.getRole, 			--拥有某角色触发
	["maxRole"]		 = tGetTriggerFunction.getMaxRole,			--拥有某角色不触发  
	["movieStep"]    = tGetTriggerFunction.getMovieStep, 		--剧情完成触发
	["maxMovieStep"] = tGetTriggerFunction.getMaxMovieStep,
	["worldBoss"] 	 = tGetTriggerFunction.getWorldBoss, 		--世界boss是否开启
	["goldenLotCoin"]= tGetTriggerFunction.getGoldenLotCoin,	--拥有抽卡金签数量
	["needItem"]     = tGetTriggerFunction.getNeedItem,			--需要道具数量  
	["eyeTime"] 	 = tGetTriggerFunction.getEyeTime, 			--异色之瞳剩余时间
	["scoreMatch"]   = tGetTriggerFunction.getScoreMatch, 		--积分赛是否开启    
	["serverSwitch"] = tGetTriggerFunction.getServerSwitch, 	--服务器开关      
}

PlayerGuideManager.SpecialSymbol = "<c7>"
PlayerGuideManager.Special = "<font color='#ffe600' fontSize = '22'>"
PlayerGuideManager.EndSymbol = "<c>"
PlayerGuideManager.End = "</font>"

function PlayerGuideManager:ctor()
	self.bOpenGuide = true
    
	self.maxFunctionId = 0
	self.functionId = 0
	self.now_step = 0
	self.next_step = 0
	self.m_guideInfo = {}
	self.clickHandleFunction = {}

	self.guideLayers = {}
end

function PlayerGuideManager:restart()
	self:reset()
	self.guideLayers = {}
end

function PlayerGuideManager:reset()
	if self.nTimerId then
		TFDirector:removeTimer(self.nTimerId)
        self.nTimerId = nil
	end
	if self.delayTimerId then
		TFDirector:removeTimer(self.delayTimerId)
		self.delayTimerId = nil
	end
	self:removeNotClickBg()
	self:removePanelBg()
	self.functionId = 0
	self.now_step = 0
	self.next_step =  0
	self.m_guideInfo = {}
end

function PlayerGuideManager:isPlayGuide()
	if not self.bOpenGuide then
		return false
	end
	if self.m_guideInfo and self.m_guideInfo.guidePanel_bg then
		return true
	end
	if self.next_step == 0 then
		return false
	end
	return true
end

function PlayerGuideManager:initGuideLayers()
	self.guideLayers = {}
	for info in PlayerGuideData:iterator() do
		if info.trigger_layer and not self:isFunctionOpen(info.id) then
			self.guideLayers[info.trigger_layer] = self.guideLayers[info.trigger_layer] or {}
			table.insert(self.guideLayers[info.trigger_layer], info)
		end
	end
end

function PlayerGuideManager:removeGuideLayers(id)
	local guideInfo = PlayerGuideData:objectByID(id)
	if guideInfo == nil or self.guideLayers[guideInfo.trigger_layer] == nil then
		return
	end
	local num = #self.guideLayers[guideInfo.trigger_layer]
	for i=1,num do
		if self.guideLayers[guideInfo.trigger_layer][i].id == id then
			table.remove(self.guideLayers[guideInfo.trigger_layer], i)
			return
		end
	end
end

function PlayerGuideManager:getByLayerName(layer_name)
	return self.guideLayers[layer_name]
end

function PlayerGuideManager:getTopLayer()
	local currentScene = Public:currentScene()
	if currentScene and currentScene.getTopLayer then
		return currentScene:getTopLayer()
	end
	return nil
end

function PlayerGuideManager:checkSaveCondition()
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	
	local layers = self:getByLayerName(topLayer.__cname)
	if layers == nil then return end

	local tbl, isSave = {}
	for _, guideInfo in pairs(layers) do
		if guideInfo and guideInfo.saveConditions then
			isSave = true
			for i, v in pairs(tTriggerFunctions) do
				if not TFFunction.call(v, nil, guideInfo.saveConditions) then
					isSave = false
					break
				end
			end
			if isSave and guideInfo.id then
				tbl[#tbl + 1] = guideInfo.id
			end
		end
	end
	for _, id in pairs(tbl) do
		self:saveFunctionOpenGuide(id)
	end
end

function PlayerGuideManager:triggerGuide(guideInfo)
	if guideInfo.conditions.cycle and guideInfo.conditions.cycle == true then
	else
		if self:isGuideFunctionOpen(guideInfo.id) then
			return false
		end
	end
	
	-- print("guideInfo", guideInfo)
	for i, v in pairs(tTriggerFunctions) do
		if not TFFunction.call(v, nil, guideInfo.conditions) then
			return false
		end
	end
	return true
end  

--遍历检查当前层是否有可触发  
--return 触发节点 or nil
function PlayerGuideManager:getGuideInfoByTopLayerTrigger()
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return nil
	end
	
	local layers = self:getByLayerName(topLayer.__cname)
	if layers == nil then
		print("not guide info trigger  top layer:", topLayer.__cname)
		return nil
	end
	
	for _, guideInfo in pairs(layers) do
		if self:triggerGuide(guideInfo) then
			self.functionId = guideInfo.id
			local save = false
			if guideInfo.name then
				save = true
			end
			return guideInfo, save
		end
	end
	return nil, false
end

function PlayerGuideManager:doGuide()
	if not self.bOpenGuide or MainPlayer.guideList == nil or self.noRefresh then
		return
	end
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end

	print("======___________________________", self.next_step, ",", self.now_step)
	if self.next_step ~= 0 then
		local guideStepInfo = PlayerGuideStepData:objectByID(self.next_step)
		if guideStepInfo ~= nil and guideStepInfo.layer_name ~= topLayer.__cname then
			local now_guideStepInfo = PlayerGuideStepData:objectByID(self.now_step)
			if now_guideStepInfo == nil or now_guideStepInfo.force == nil or now_guideStepInfo.force ~= false then
				self.isUp = true
				self:setGuideVisible(false)
				print("doGuide topLayer.__cname:", topLayer.__cname)
				return
			end
		end
	end

	if self.isUp then
		self:setGuideVisible(true)
		self.isUp = false
	end

	print("====================+==========+========================")
	--检测saveCondition  保存     
	self:checkSaveCondition()
	if self.next_step == 0 then
		self.now_step = 0
		self.next_step = 0
		local guideInfo, save = self:getGuideInfoByTopLayerTrigger()
		if guideInfo then
			print("doGuide  new guideInfo", guideInfo.process)
			if guideInfo.guiderewardId and guideInfo.guiderewardId ~= 0 then
				self:openGuideJumpLayer(guideInfo)
			else
				self:showGuideLayerByStepId(guideInfo.process, save)
			end
			return
		end
	else --没有触发 继续下一步
		print("next_step", self.next_step)
		self:showGuideLayerByStepId(self.next_step, false)
	end
end

function PlayerGuideManager:showGuideLayerByStepId(stepId, save)
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		print("topLayer == nil stepId:", stepId)
		return
	end
	if not stepId or stepId == 0 then
		print("stepId == ", stepId)
		return
	end
	if self.now_step == stepId then
		print("now_step == stepId", stepId)
		return
	end
	local guideStepInfo = PlayerGuideStepData:objectByID(stepId)
	if guideStepInfo == nil then
		print("guideStepInfo == nil stepId:", stepId)
		return
	end
	if guideStepInfo.layer_name ~= topLayer.__cname then
		print("guideStepInfo.layer_name ~= topLayer.__cname ",topLayer.__cname)
		return
	end

	--取消托管    
	TFDirector:dispatchGlobalEventWith(MissionManager.OneKeyEnd)

	guideStepInfo.guideType = guideStepInfo.guideType or 0
	save = guideStepInfo.save ~= nil and guideStepInfo.save or save
	self:beforeCallBack(guideStepInfo, topLayer)
	if guideStepInfo.guideType == 0 then
		if guideStepInfo.widget_name and guideStepInfo.widget_name ~= "" then
			local widget = self:getWidgetByName(topLayer, guideStepInfo.widget_name)
			if widget == nil then
				print("showGuideLayerByStepId widget == nil",topLayer.__cname, ",", guideStepInfo.widget_name)
				self:delayShowGuideLayerIfWidgetNil(guideStepInfo ,save)
				return
			end
		end
		self:showGuideLayer(guideStepInfo, save)
	end
	self.now_step = stepId
	print("showGuideLayerByStepId stepId", stepId)
end

--显示指引   
function PlayerGuideManager:showGuideLayer(guideStepInfo, save)
	print("PlayerGuideManager:showGuideLayer ====================")
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	print("PlayerGuideManager:showGuideLayer topLayer: , layer_name: ", topLayer.__cname, guideStepInfo.layer_name)
	self:removePanelBg()
	self.m_guideInfo = {}
	self:beginCallBack(guideStepInfo)
	self:saveGuideStepInfo(save)
	MainPlayer:saveStatRecord(guideStepInfo.stat)
	if self:isWidgetRunning(guideStepInfo) then --guideStepInfo and guideStepInfo.delay and guideStepInfo.delay ~= 0 then --
		self:delayShowGuideLayer(guideStepInfo,save)
		return
	end
	self:showAll(guideStepInfo, save)
end

--显示指引的所有层
function PlayerGuideManager:showAll(guideStepInfo, save)
	print("PlayerGuideManager:showAll == ")
	self:removeNotClickBg()
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	print("PlayerGuideManager:showAll == topLayer: layer_name ", topLayer.__cname, guideStepInfo.layer_name)
	local guidePanel_bg = self:getGuidePanelBg()
	
	--把强制引导panel设置到当前界面的父类(例如：天书世界)
	if guideStepInfo.specialCall == 16 and topLayer:getParent() then
		topLayer:getParent():addChild(guidePanel_bg)
	else
		topLayer:addChild(guidePanel_bg)
	end
	
	self.m_guideInfo.guidePanel_bg = guidePanel_bg
	if guideStepInfo.specialCall == 1 then
		self.m_guideInfo.guidePanel_bg:setTouchEnabled(false)
	end
	self.noRefresh = guideStepInfo.noRefresh and true or nil
	self:showForceLayer(guidePanel_bg, guideStepInfo)
	self:showEffect(guidePanel_bg, guideStepInfo)
	self:showEffectByName(guidePanel_bg, guideStepInfo)
	
	if guideStepInfo.sound and guideStepInfo.sound ~= "" then
		self:playEffect(guideStepInfo.sound, guideStepInfo.soundTime * 1000, guideStepInfo.id)
	end
	
	--设置点击事件        
	self:setClickEvents(guideStepInfo)
	self:saveGuideStepInfo(save)
	
	--设置快速进入按钮        
	self:quickCallBack(guideStepInfo, topLayer)
	
	--设置跳过按钮        
	self:setTiaoguoTimer(guideStepInfo, topLayer)
end

function PlayerGuideManager:showForceLayer(guidePanel_bg, guideStepInfo)
	if guideStepInfo.force == false then
		guidePanel_bg:setTouchEnabled(false)
		local topLayer = self:getTopLayer()
		local widget = self:getWidgetByName(topLayer, guideStepInfo.widget_name)
		if widget == nil then
			return
		end

		local pos = widget:getParent():convertToWorldSpaceAR(widget:getPosition())--ccp(widget:get Position().x,widget:getPosition().y))
		pos = guidePanel_bg:convertToNodeSpace(pos)
		local anchorPoint = widget:getAnchorPoint()
		local x = pos.x - anchorPoint.x * widget:getSize().width
		local y = pos.y - anchorPoint.y * widget:getSize().height
	
		local offset = {0,0}
		if guideStepInfo.offset then
			x = x + guideStepInfo.offset[1]
			y = y + guideStepInfo.offset[2]
			offset[1] = guideStepInfo.offset[3] or 0
			offset[2] = guideStepInfo.offset[4] or 0
		end
		local circel = self:createCircleEffect(x, y, widget:getSize().width+offset[1],widget:getSize().height+offset[2])
		if circel then
			guidePanel_bg:addChild(circel)
			guidePanel_bg.layerList = guidePanel_bg.layerList or {}
			guidePanel_bg.layerList[#guidePanel_bg.layerList+1] = circel
		end
	else
		self:getGuideForcePanel(guidePanel_bg, guideStepInfo)
	end
end

--设置点击事件
function PlayerGuideManager:setClickEvents(guideStepInfo)
	if guideStepInfo.force == false then
		self:unForceClick(guideStepInfo)
		self.next_step = guideStepInfo.next_step
		if guideStepInfo.save ~= nil and guideStepInfo.save == true then
			self:saveGuideStepInfo(true)
		end
		if guideStepInfo.next_functionId and guideStepInfo.next_functionId ~= 0 then
			self.functionId = guideStepInfo.next_functionId
		end
	else
		self:forceClick(guideStepInfo)
	end
end

--非强制事件
function PlayerGuideManager:unForceClick(guideStepInfo)
	if guideStepInfo == nil then
		return
	end
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	if guideStepInfo.widget_name and guideStepInfo.widget_name ~= "" then
		local widget = self:getWidgetByName(topLayer, guideStepInfo.widget_name)
		if widget ~= nil then
			local clickHandleFunction = widget:getMEListener(TFWIDGET_CLICK)
			widget:addMEListener(TFWIDGET_CLICK,
			function ()
				if self.now_step ~= 0 then
					self:removePanelBg()
					self:clickCallBack(guideStepInfo, topLayer)
				end
				TFFunction.call(clickHandleFunction, widget)
				if clickHandleFunction then
					widget:addMEListener(TFWIDGET_CLICK, clickHandleFunction)
				else
					widget:removeMEListener(TFWIDGET_CLICK)
				end
			end)
		end
	end
end

--强制事件
function PlayerGuideManager:forceClick(guideStepInfo)
	if guideStepInfo == nil then
		return
	end
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	local layer_name = topLayer.__cname
	if guideStepInfo.widget_name and guideStepInfo.widget_name ~= "" then
		local widget = self:getWidgetByName(topLayer, guideStepInfo.widget_name)
		if widget then
			local clickHandleFunction = widget:getMEListener(TFWIDGET_CLICK)
			if clickHandleFunction and self.m_guideInfo and self.m_guideInfo.guidePanel_bg then
				local function onWidgetClick(sender)
					if not self then return end
					print("PlayerGuideManager forceClick now_step", self.now_step)
					if self.removePanelBg then self:removePanelBg() end
					if self.m_guideInfo and self.m_guideInfo.guidePanel_bg then
						self.m_guideInfo.guidePanel_bg:removeMEListener(TFWIDGET_CLICK)
					end
					if widget == nil or tolua.isnull(widget) or clickHandleFunction == nil then
						if self.saveFunctionOpenGuide and self.functionId then
							self:saveFunctionOpenGuide(self.functionId)
						end
						self.now_step = 0
						self.next_step = 0
						self.functionId = 0
						return
					end
					if self.now_step == 0 then
						TFFunction.call(clickHandleFunction, widget)
						widget:addMEListener(TFWIDGET_CLICK, clickHandleFunction)
						return
					end
					self.next_step = guideStepInfo.next_step
					self.noRefresh = nil
					print("PlayerGuideManager forceClick now_step", self.now_step, "next_step", self.next_step)
					--widget:addMEListener(TFWIDGET_CLICK, clickHandleFunction)
					self:menuLayerClickEnabled(topLayer)
					TFFunction.call(clickHandleFunction, widget)
					self:clickCallBack(guideStepInfo,topLayer)
					if guideStepInfo.next_functionId then
						self.functionId = guideStepInfo.next_functionId
					end
					local next_guideStepInfo = PlayerGuideStepData:objectByID(self.next_step)
					self.next_step = next_guideStepInfo and self.next_step or 0
					if next_guideStepInfo and next_guideStepInfo.layer_name == layer_name then
						self:showGuideLayerByStepId(self.next_step, false)
					elseif guideStepInfo.closeAll and guideStepInfo.closeAll == 1 then
						AlertManager:closeAll()
					end
				end
				--widget:addMEListener(TFWIDGET_CLICK, onWidgetClick)
				self.m_guideInfo.guidePanel_bg:addMEListener(TFWIDGET_CLICK, onWidgetClick)
				return
			end

			local beganHandleFunction = widget:getMEListener(TFWIDGET_TOUCHBEGAN)
			local endHandleFunction = widget:getMEListener(TFWIDGET_TOUCHENDED)
			if not clickHandleFunction and beganHandleFunction and endHandleFunction and self.m_guideInfo and self.m_guideInfo.guidePanel_bg then
				local function onWidgetBeganClick()
					TFFunction.call(beganHandleFunction, widget)
				end

				local function onWidgetEndClick()
					self:clickCallBack(guideStepInfo, topLayer)
					TFFunction.call(endHandleFunction, widget)
				end

				self.m_guideInfo.guidePanel_bg:addMEListener(TFWIDGET_TOUCHBEGAN, onWidgetBeganClick)
				self.m_guideInfo.guidePanel_bg:addMEListener(TFWIDGET_TOUCHENDED, onWidgetEndClick)
				return
			end

			local widgetClassName = widget:getDescription()
			if widgetClassName ~= "TFImage" and widgetClassName ~= "TFLabel" and widgetClassName ~= "TFLabelBMFont" then
				return
			end
		end
	end
	self:panelbgClick(guideStepInfo)
end

function PlayerGuideManager:panelbgClick(guideStepInfo)
	if self.m_guideInfo.guidePanel_bg == nil then
		return
	end
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	local widget = self.m_guideInfo.guidePanel_bg
	widget:setTouchEnabled(true)
	if widget.layerList then
		for i,v in ipairs(widget.layerList) do
			v:setTouchEnabled(false)
		end
	end
	-- print("panelbgClick")
	widget:addMEListener(TFWIDGET_CLICK, 
	function ()
		self:clickCallBack(guideStepInfo, topLayer)
		self.next_step = guideStepInfo.next_step

		print("panelbgClick next_step", self.next_step)
		if guideStepInfo.next_functionId then
			self.functionId = guideStepInfo.next_functionId
		end
		self:removePanelBg()
		self.noRefresh = nil
		local next_guideStepInfo = PlayerGuideStepData:objectByID(guideStepInfo.next_step)
		self.next_step = next_guideStepInfo and self.next_step or 0
		if next_guideStepInfo and next_guideStepInfo.layer_name == topLayer.__cname then
			self:showGuideLayerByStepId(self.next_step, false)
		elseif guideStepInfo.close and guideStepInfo.close == 1 then
			AlertManager:close()
		elseif guideStepInfo.closeAll and guideStepInfo.closeAll == 1 then
			AlertManager:closeAll()
		end
	end)
end

function PlayerGuideManager:clickCallBack(guideStepInfo, topLayer)
	print("clickCallBack---", guideStepInfo)
	-- self:saveGuideStepInfo(guideStepInfo.save)     
	self:endCallBack(guideStepInfo, topLayer)
	self:endBeforeCallBack(guideStepInfo,topLayer)
end

function PlayerGuideManager:menuLayerClickEnabled(topLayer)
	if topLayer == nil or topLayer.__cname ~= "MenuLayer" then return end

	topLayer.clickEnable = true
end

--指引开始前的特殊操作
function PlayerGuideManager:beginCallBack( guideStepInfo )
	local special = guideStepInfo.specialCall
	if special == nil then
		return
	end
	if special == 1 then 			-- 上阵特殊操作
		self:armyLayerPutSpecial(guideStepInfo)
	elseif special == 2 then 		--主角移动操作
		self:mainRolePutSpecial(guideStepInfo)
	elseif special == 3 then 		--主城拖动操作
		self:menuTouchPutSpecial(guideStepInfo)
	elseif special == 4 then 		--领取宝箱禁用关卡点击
		self:missionTouchPutSpecial(guideStepInfo)
	elseif special == 5 then 		--抽卡的特殊操作
		self:lotteryPutSpecial(guideStepInfo)
	elseif special == 6 then
		self:destinyPutSpecial(guideStepInfo)
	elseif special == 7 then 		--设置主城位置
		-- self:menuPosTouchPutSpecial(guideStepInfo)
	elseif special == 8 then
		self:menuPosTouchPutSpecial(guideStepInfo)
	elseif special == 9 then
		self.noRefresh = true
	elseif special == 11 then  --布阵界面点击角色头像进入角色信息界面
		self:armyLayerRoleInfoPutSpecial(guideStepInfo)
	elseif special == 12 then  --异色之瞳持续点击
		self:continueClickPutSpecial(guideStepInfo)
	elseif special == 17 then  --快速完成所有抽签结果动画
		self:quickShowItem()
	elseif special == 18 then   --触发添加屏蔽层     
		self:mapMoveTouchPutSpecialEnd(guideStepInfo)
	end
end

function PlayerGuideManager:endCallBack(guideStepInfo, topLayer)
	local special = guideStepInfo.specialCall
	if special == nil then
		return
	end
	if special == 1 then 					--上阵的特殊操作 
		self:armyLayerPutSpecialEnd()
	elseif special == 2 then
		-- self:mainRolePutSpecialEnd()
	elseif special == 3 then
		-- self:menuTouchPutSpecialEnd()
	elseif special == 4 then
		self:missionTouchPutSpecialEnd(guideStepInfo, topLayer)
	elseif special == 8 then        --地图移动屏蔽操作
		self:mapMoveTouchPutSpecialEnd(guideStepInfo)
	elseif special == 13 then 		--endClick 事件后调用 (非click)
		self:endClickTouchPutSpecialEnd(guideStepInfo, topLayer)
	end
end

function PlayerGuideManager:quickCallBack(guideStepInfo, topLayer)
	local quick = guideStepInfo.quickCall
	if quick == nil then
		return
	end
	if quick == 1 then  			-- 直接进入副本特殊操作
		self:missionLayerPutQuick(guideStepInfo, topLayer)
	elseif quick == 2 then 			-- 直接进入角色界面
		self:roleLayerPutQuick(guideStepInfo, topLayer)
	elseif quick == 3 then 			-- 直接进入布阵界面 
		self:armyLayerPutQuick(guideStepInfo, topLayer)
	end
end

--==  引导触发前 特殊操作

function PlayerGuideManager:beforeCallBack(guideStepInfo, topLayer)
	local before = guideStepInfo.beforeCall
	if not before then
		return
	end
	--触发前的特殊操作
	if before == 1 then 			--挑战引导
		self:choicePutBefore(guideStepInfo)
	elseif before == 2 then 		--神器主界面
		self:artifactPutBefore(guideStepInfo)
	elseif before == 3 then 		--新功能开启奖励
		self:newRoadPutBefore(guideStepInfo)
	elseif before == 4 then 		--关卡引导
		self:missionPutAddBefore(guideStepInfo)
	elseif before == 5 then 		--关卡引导
		self:missionPutRemoveBefore(guideStepInfo)
	elseif before == 6 then 		--打开底部菜单栏
		self:bottomMenuPutBefore(guideStepInfo)
	elseif before == 7 then 		--点击主城npc npc停下
		self:menuNpcPutBefore(guideStepInfo)
	elseif before == 8 then 		--设置主城位置
		self:menuPosTouchPutSpecial(guideStepInfo)
	elseif before == 9 then			--角色列表或者布阵列表
		self:roleListPutBefore(guideStepInfo)
	elseif before == 10 then		--设置宠物抓取速度
		self:setPetCatchSpeed(guideStepInfo)
	elseif before == 11 then		--打开任务栏
		self:taskMainPutBefore(guideStepInfo)
	elseif before == 12 then 		--关卡章节列表 滚动到顶部     
		self:missionChapterPutBefore(guideStepInfo)
	end
end

function PlayerGuideManager:endBeforeCallBack(guideStepInfo, topLayer)
	local before = guideStepInfo.beforeCall
	if not before then
		return
	end
	if before == 4 then 			--挑战引导(删除target)
		self:missionPutRemoveBefore(guideStepInfo)
	end
end

----========================  special  特殊操作 ===================

function PlayerGuideManager:openGuideJumpLayer(guideInfo)
	if not self.bOpenGuide then
		return
	end
	if guideInfo == nil or self:isFunctionOpen(guideInfo.id) then
		return
	end
	
	--取消托管    
	TFDirector:dispatchGlobalEventWith(MissionManager.OneKeyEnd)

	print("doGuide new guideInfo.guiderewardId", guideInfo.guiderewardId)
	self:removeNotClickBg()
	if self.delayTimerId then
		TFDirector:removeTimer(self.delayTimerId)
		self.delayTimerId = nil
	end
	
	local delay = guideInfo.delay or 0
	
	local topLayer = self:getTopLayer()
	if topLayer and delay ~= 0 then
		self.notClickBg = self:createNotClickBg()
		topLayer:addChild(self.notClickBg)
		
		local delayTimerId = TFDirector:addTimer(delay * 1000, 1, nil,
		function()
			if not self then
				TFDirector:removeTimer(delayTimerId)
				return
			end
			TFDirector:removeTimer(delayTimerId)
			self.delayTimerId = nil
			
			self:removeNotClickBg()
			local topLayer = self:getTopLayer()
			if topLayer and topLayer.__cname == "GuideJumpLayer" then
				return
			end
			
			local layer = require("lua.logic.common.GuideJumpLayer"):new(guideInfo)
			AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
			AlertManager:show()
		end)
		
		self.delayTimerId = delayTimerId
	else
		local topLayer = self:getTopLayer()
		if topLayer and topLayer.__cname == "GuideJumpLayer" then
			return
		end
		
		local layer = require("lua.logic.common.GuideJumpLayer"):new(guideInfo)
		AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
		AlertManager:show()
	end
end  

--开启功能指引 
function PlayerGuideManager:beginFunctionOpenGuide(guideInfo)
	--local guideInfo = self:getOpenFunctionGuideInfo()
	if guideInfo ~= nil and guideInfo.guiderewardId ~= nil then
		print("beginFunctionOpenGuide ==========================", guideInfo)
		self.functionId = guideInfo.id
		self.next_step = guideInfo.process or 0
		self:saveGuideStepInfo(true)
		AlertManager:closeAll()
		if guideInfo.sceneId and not CheckCurrentSceneBySceneId(guideInfo.sceneId) then
			CommonManager:requestEnterInScene(guideInfo.sceneId)
		end
		-- self:showGuideLayerByStepId(guideInfo.process, false)
	end
end

function PlayerGuideManager:getOpenFunctionGuideInfo()
	if not self.bOpenGuide then
		return
	end
	for guideInfo in PlayerGuideData:iterator() do
		if guideInfo.name ~= nil and self:triggerGuide(guideInfo) then
			print("getOpenFunctionGuideInfo() ", guideInfo)
			return guideInfo
		end
	end
	return nil
end

--上阵的特殊操作 begin
function PlayerGuideManager:armyLayerPutSpecial( guideStepInfo )
	local topLayer = self:getTopLayer()
	if topLayer == nil or self.guideArmySpecial == true then
		return
	end

	self.updatePutCallBack = function (event)
		self:armyLayerPutSpecialEnd()
	end

	self.updateBeginCallBack = function (event)
		self:removeEffectByName(self.m_guideInfo.guidePanel_bg)
		self.next_step = guideStepInfo.next_step
		self:saveGuideStepInfo(guideStepInfo.save)
		if guideStepInfo.next_functionId then
			self.functionId = guideStepInfo.next_functionId
		end
		local next_guideStepInfo = PlayerGuideStepData:objectByID(self.next_step)
		if next_guideStepInfo and next_guideStepInfo.layer_name == topLayer.__cname then
			self:showGuideLayerByStepId(self.next_step, false)
		end
	end

	self.updateEndCallBack = function (event)
		local guide = event.data[1]
		if guide then
			self.next_step = self.now_step - 1
		else
			self.next_step = self.now_step + 1
		end
		print("==================", self.next_step, ",", guide)
		self:saveGuideStepInfo(guideStepInfo.save)
		if guideStepInfo.next_functionId then
			self.functionId = guideStepInfo.next_functionId
		end
		local next_guideStepInfo = PlayerGuideStepData:objectByID(self.next_step)
		if next_guideStepInfo and next_guideStepInfo.layer_name == topLayer.__cname then
			self:showGuideLayerByStepId(self.next_step, false)
		end
	end

	local nTimerId = TFDirector:addTimer(0, 1, nil,
		function ()
			self.guideArmySpecial = true
			if topLayer.setGuideSpecial then
				topLayer:setGuideSpecial(false)
			end
			self:setGuideArmyPos(guideStepInfo.next_step, topLayer)
			
			TFDirector:addMEGlobalListener("armyLayerBeginSpecial", self.updateBeginCallBack)
			TFDirector:addMEGlobalListener("armyLayerEndSpecial", self.updateEndCallBack)
			TFDirector:addMEGlobalListener("armyLayerPutSpecial", self.updatePutCallBack)
		end)
end

function PlayerGuideManager:setGuideArmyPos(next_step, topLayer)
	local guideStepInfo = PlayerGuideStepData:objectByID(next_step)
	if guideStepInfo == nil or topLayer == nil then
		return
	end

	local widgetList, length = stringToTable(guideStepInfo.widget_name,"|")
	if length == 0 then
		return
	end

	local name = widgetList[length]
	name = string.sub(name, string.len(name))
	local idx = tonumber(name)
	if idx > 0 and idx < 10 and topLayer.setGuideArmyPos ~= nil then
		topLayer:setGuideArmyPos(idx)
	end
end

--上阵的特殊操作  end
function PlayerGuideManager:armyLayerPutSpecialEnd()
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end

	if topLayer.__cname ~= "ArmyLayer" and topLayer.__cname ~= "FormationVSLayer" then
		print("topLayer.__cname ~= ArmyLayer", topLayer.__cname)
		return
	end

	if topLayer.setGuideArmyPos ~= nil then
		topLayer:setGuideArmyPos(nil)
	end
	if topLayer.setGuideSpecial then
		topLayer:setGuideSpecial(true)
	end
	self:saveGuideStepInfo(true)
	self.guideArmySpecial = false
	TFDirector:removeMEGlobalListener("armyLayerEndSpecial", self.updateEndCallBack)
	TFDirector:removeMEGlobalListener("armyLayerBeginSpecial", self.updateBeginCallBack)
	TFDirector:removeMEGlobalListener("armyLayerPutSpecial", self.updatePutCallBack)
	self.updateEndCallBack = nil
	self.updateBeginCallBack = nil
	self.updatePutCallBack = nil
end

--主角移动特殊操作
function PlayerGuideManager:mainRolePutSpecial(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil or topLayer.guideForcePanel ~= nil then
		return
	end

	local updatePosCallBack = function(event)
		TFDirector:removeMEGlobalListener("mainRolePutSpecial", updatePosCallBack)
		self:mainRolePutSpecialEnd()
		self.next_step = guideStepInfo.next_step
		self:saveGuideStepInfo(guideStepInfo.save)
		if guideStepInfo.next_functionId then
			self.functionId = guideStepInfo.next_functionId
		end
		local next_guideStepInfo = PlayerGuideStepData:objectByID(self.next_step)
		if next_guideStepInfo and next_guideStepInfo.layer_name == topLayer.__cname then
			self:showGuideLayerByStepId(self.next_step, false)
		end
	end

	local guideForcePanel = self:getGuideForcePanelAll()
	guideForcePanel:setBackGroundColorOpacity(0)
	guideForcePanel:setZOrder(10001)
	topLayer:addChild(guideForcePanel)
	topLayer.guideForcePanel = guideForcePanel

	topLayer:setDispatchEvent(true)
	topLayer:setMainRoleTargetPos(guideStepInfo.tip_pos[1], guideStepInfo.tip_pos[2])

	TFDirector:addMEGlobalListener("mainRolePutSpecial", updatePosCallBack)
end

function PlayerGuideManager:mainRolePutSpecialEnd()
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end

	if topLayer.__cname ~= "MenuLayer" then
		print("topLayer.__cname ~= MenuLayer", topLayer.__cname)
		return
	end
	topLayer:setDispatchEvent(false)
	if topLayer.guideForcePanel then
		topLayer.guideForcePanel:removeFromParent()
		topLayer.guideForcePanel = nil
	end
end

--拖动主城界面
function PlayerGuideManager:menuTouchPutSpecial(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil or topLayer.guideForcePanel ~= nil then
		return
	end

	local updatePosCallBack = function(event)
		if topLayer == nil or guideStepInfo == nil then
			TFDirector:removeTimer(self.menuTimer)
			self.menuTimer = nil
			TFDirector:removeMEGlobalListener("menuTouchPutSpecial", updatePosCallBack)
			return
		end

		local menu_move = guideStepInfo.menu_move or 1200
		local diff = math.floor(math.abs(topLayer.panel_di:getPosition().x + menu_move))
		if diff > 20 then
			return
		end

		TFDirector:removeTimer(self.menuTimer)
		self.menuTimer = nil
		TFDirector:removeMEGlobalListener("menuTouchPutSpecial", updatePosCallBack)
		self:menuTouchPutSpecialEnd()
		self.next_step = guideStepInfo.next_step
		self:saveGuideStepInfo(guideStepInfo.save)
		if guideStepInfo.next_functionId then
			self.functionId = guideStepInfo.next_functionId
		end
		local next_guideStepInfo = PlayerGuideStepData:objectByID(self.next_step)
		if next_guideStepInfo and next_guideStepInfo.layer_name == topLayer.__cname then
			self:showGuideLayerByStepId(self.next_step, false)
		end
	end

	local guideForcePanel = self:getGuideForcePanelAll()
	guideForcePanel:setBackGroundColorOpacity(0)
	guideForcePanel:setZOrder(10001)
	topLayer:addChild(guideForcePanel)
	topLayer.guideForcePanel = guideForcePanel

	topLayer:setDispatchEvent(true)
	topLayer:SetPanelDiPosition(topLayer.DefaultPosX,topLayer)

	self.menuTimer = TFDirector:addTimer(math.floor(guideStepInfo.diff[1]*1000), -1, nil,
	function ()
		if self.menuTimer == nil then return end
		if topLayer == nil or guideStepInfo == nil then
			TFDirector:removeTimer(self.menuTimer)
			self.menuTimer = nil
			return
		end

		local prePos = topLayer.panel_di:getPosition().x
		local menu_move = guideStepInfo.menu_move or 1200
		if math.abs(prePos) ~= menu_move then
			topLayer:SetPanelDiPosition(prePos - guideStepInfo.diff[2], topLayer)
		else
			updatePosCallBack()
		end
	end)

	TFDirector:addMEGlobalListener("menuTouchPutSpecial", updatePosCallBack)
end

function PlayerGuideManager:menuTouchPutSpecialEnd()
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end

	topLayer:setDispatchEvent(false)
	if topLayer.guideForcePanel then
		topLayer.guideForcePanel:removeFromParent()
		topLayer.guideForcePanel = nil
	end
	if topLayer.__cname ~= "MenuLayer" then
		print("topLayer.__cname ~= MenuLayer", topLayer.__cname)
		return
	end
end

function PlayerGuideManager:missionTouchPutSpecial(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	local widgetList, length = stringToTable(guideStepInfo.widget_name,"|")
	if length <= 1 then
		return
	end
	local name = widgetList[1]
	local widget = self:getWidgetByName(topLayer, name)
	if widget and widget.setTouchEnabled then
		widget:setTouchEnabled(false)
	end
end

function PlayerGuideManager:missionTouchPutSpecialEnd(guideStepInfo, topLayer)
	if topLayer == nil then
		return
	end
	local widgetList, length = stringToTable(guideStepInfo.widget_name,"|")
	if length <= 1 then
		return
	end
	local name = widgetList[1]
	local widget = self:getWidgetByName(topLayer, name)
	if widget and widget.setTouchEnabled then
		widget:setTouchEnabled(true)
	end
end

function PlayerGuideManager:lotteryPutSpecial(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil or topLayer.__cname ~= guideStepInfo.layer_name then
		return
	end

	if topLayer.getBtnBack then
		local btn = topLayer:getBtnBack()
		if btn then btn:setVisible(not btn:isVisible()) end
	end

	if topLayer and topLayer.__cname == "LotteryChoiceLayer" then
		self.lotteryPutCallBack = function ()
			TFDirector:removeMEGlobalListener(LotteryManager.UpdateQianNum, self.lotteryPutCallBack)
			self.lotteryPutCallBack = nil
	
			if self.functionId and self.saveFunctionOpenGuide then
				self:saveFunctionOpenGuide(self.functionId)
			end
		end
		TFDirector:addMEGlobalListener(LotteryManager.UpdateQianNum, self.lotteryPutCallBack)
	end
end

function PlayerGuideManager:destinyPutSpecial(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil or topLayer.guideForcePanel ~= nil then
		return
	end

	self.guideRoleDestiny = function ()
		TFDirector:removeMEGlobalListener("GuideRoleDestiny", self.guideRoleDestiny)
		self.guideRoleDestiny = nil

		if topLayer and topLayer.guideForcePanel then
			topLayer.guideForcePanel:removeFromParent()
			topLayer.guideForcePanel = nil
		end
	end

	local guideForcePanel = self:getGuideForcePanelAll()
	guideForcePanel:setBackGroundColorOpacity(1)
	guideForcePanel:setZOrder(10001)
	topLayer:addChild(guideForcePanel)
	topLayer.guideForcePanel = guideForcePanel

	TFDirector:addMEGlobalListener("GuideRoleDestiny", self.guideRoleDestiny)
end

--设置主城  
function PlayerGuideManager:menuPosTouchPutSpecial(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	
	if guideStepInfo.defaultPos then
		local defaultPos = guideStepInfo.defaultPos
		if topLayer and topLayer.setMainRolePos then
			topLayer.MainRoleTargePosX = defaultPos[1]
			topLayer.MainRoleTargePosY = defaultPos[2]
			topLayer:setMainRolePos(defaultPos[1], defaultPos[2])
		end
	end
end 

function PlayerGuideManager:roleListPutBefore(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil or topLayer.guideForcePanel ~= nil then
		return
	end

	if topLayer.moveToIndex and guideStepInfo.widget_name then
		local name = guideStepInfo.widget_name
		local index = string.find(name, "_")
		index = tonumber(string.sub(name, index+1))
		topLayer:moveToIndex(index)
	end
end

function PlayerGuideManager:setPetCatchSpeed(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	
	if guideStepInfo and guideStepInfo.petCatchSpeed then
		topLayer:setPetCatchSpeed(guideStepInfo.petCatchSpeed)
	end
end

function PlayerGuideManager:taskMainPutBefore(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	
	CommonUiManager:setTaskMainLayer(true)
end

function PlayerGuideManager:missionChapterPutBefore(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil or topLayer.__cname ~= guideStepInfo.layer_name then
		return
	end
	if topLayer.scrollViewToBegin then
		topLayer:scrollViewToBegin()
	end
end

function PlayerGuideManager:armyLayerRoleInfoPutSpecial(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil or topLayer.__cname ~= "ArmyLayer" then
		return
	end
	
	local widget = self:getWidgetByName(topLayer, guideStepInfo.widget_name)
	if widget then
		widget.event = 1
	end
end

function PlayerGuideManager:continueClickPutSpecial(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end

	self.guideContinueClick = function ()
		TFDirector:removeMEGlobalListener("continueClick", self.guideContinueClick)
		self.guideContinueClick = nil

		self:removePanelBg()
		self.next_step = guideStepInfo.next_step
		self:saveGuideStepInfo(guideStepInfo.save)
		if guideStepInfo.next_functionId then
			self.functionId = guideStepInfo.next_functionId
		end
		local next_guideStepInfo = PlayerGuideStepData:objectByID(self.next_step)
		if next_guideStepInfo and next_guideStepInfo.layer_name == topLayer.__cname then
			self:showGuideLayerByStepId(self.next_step, false)
		end
	end

	TFDirector:addMEGlobalListener("continueClick", self.guideContinueClick)
end

function PlayerGuideManager:quickShowItem(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end

	if topLayer.guideQuickShowItem then
		topLayer:guideQuickShowItem()
	end
end

function PlayerGuideManager:mapMoveTouchPutSpecialEnd(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil or topLayer.guideForcePanel ~= nil then
		return
	end

	self.mapMoveDisable = function ()
		TFDirector:removeMEGlobalListener("MapMoveDisable", self.mapMoveDisable)
		self.mapMoveDisable = nil

		if topLayer and topLayer.guideForcePanel and not tolua.isnull(topLayer.guideForcePanel) then
			topLayer.guideForcePanel:stopAllActions()
			topLayer.guideForcePanel:removeFromParent()
			topLayer.guideForcePanel = nil
		end
	end

	local guideForcePanel = self:getGuideForcePanelAll()
	guideForcePanel:setBackGroundColorOpacity(1)
	guideForcePanel:setZOrder(10001)
	guideForcePanel:setTouchEnabled(true)
	topLayer:addChild(guideForcePanel)
	topLayer.guideForcePanel = guideForcePanel
	topLayer.guideForcePanel:runAction(Utils:delayTimeToFunc(10, function ()
		if not self then return end
		TFDirector:removeMEGlobalListener("MapMoveDisable", self.mapMoveDisable)
		self.mapMoveDisable = nil

		if topLayer and topLayer.guideForcePanel and not tolua.isnull(topLayer.guideForcePanel) then
			topLayer.guideForcePanel:stopAllActions()
			topLayer.guideForcePanel:removeFromParent()
			topLayer.guideForcePanel = nil
		end
	end))

	TFDirector:addMEGlobalListener("MapMoveDisable", self.mapMoveDisable)
end

function PlayerGuideManager:endClickTouchPutSpecialEnd(guideStepInfo, topLayer)
	if topLayer == nil then
		return
	end

	self:removePanelBg()
	self.next_step = guideStepInfo.next_step
	self:saveGuideStepInfo(guideStepInfo.save)
	if guideStepInfo.next_functionId then
		self.functionId = guideStepInfo.next_functionId
	end
	local next_guideStepInfo = PlayerGuideStepData:objectByID(self.next_step)
	if next_guideStepInfo and next_guideStepInfo.layer_name == topLayer.__cname then
		self:showGuideLayerByStepId(self.next_step, false)
	end
end

---======================================================================

function PlayerGuideManager:battleFinishCleanGuide()
	if not self.m_guideInfo or not self.m_guideInfo.guidePanel_bg then
		return
	end
	local topLayer = self:getTopLayer()
	if topLayer == nil or topLayer.__cname ~= "BattleUiLayer" then
		return
	end

	local guideStepInfo = PlayerGuideStepData:objectByID(self.now_step)
	if not guideStepInfo or guideStepInfo.layer_name ~= "BattleUiLayer" then return end

	self:clickCallBack(guideStepInfo, topLayer)
	self.next_step = guideStepInfo.next_step

	print("battleFinishCleanGuide next_step", self.next_step)
	if guideStepInfo.next_functionId then
		self.functionId = guideStepInfo.next_functionId
	end
	self:removePanelBg()
	self.noRefresh = nil
	local next_guideStepInfo = PlayerGuideStepData:objectByID(guideStepInfo.next_step)
	self.next_step = next_guideStepInfo and self.next_step or 0
	if next_guideStepInfo and next_guideStepInfo.layer_name == topLayer.__cname then
		self:showGuideLayerByStepId(self.next_step, false)
	elseif guideStepInfo.close and guideStepInfo.close == 1 then
		AlertManager:close()
	elseif guideStepInfo.closeAll and guideStepInfo.closeAll == 1 then
		AlertManager:closeAll()
	end
end

function PlayerGuideManager:choicePutBefore(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end

	if topLayer.__cname ~= "ChoiceLayer" then
		print("topLayer.__cname ~= ChoiceLayer", topLayer.__cname)
		return
	end

	if topLayer.changeChoiceTrun then
		local name = guideStepInfo.widget_name
		local index = string.find(name, "_")
		index = tonumber(string.sub(name, index+1))
		topLayer:changeChoiceTrun(index)
	end
end

function PlayerGuideManager:artifactPutBefore(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end

	if topLayer.__cname ~= "ShenqiMainLayer" then
		print("topLayer.__cname ~= ShenqiMainLayer", topLayer.__cname)
		return
	end

	if topLayer.moveToEnd then
		local name = guideStepInfo.widget_name
		local index = string.find(name, "_")
		index = tonumber(string.sub(name, index+1))
		topLayer:moveToEnd(index)
	end
end

function PlayerGuideManager:newRoadPutBefore(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end

	if topLayer.__cname ~= "NewRoadLayer" then
		print("topLayer.__cname ~= NewRoadLayer", topLayer.__cname)
		return
	end

	if topLayer.locationIndex then
		local name = guideStepInfo.widget_name
		local index = string.find(name, "_")
		index = tonumber(string.sub(name, index+1))
		topLayer:locationIndex(index, guideStepInfo.location)
	end
end

--新手引导添加引导panel
function PlayerGuideManager:missionPutAddBefore(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end

	if topLayer.__cname ~= guideStepInfo.layer_name then
		print("topLayer.__cname ~= ", guideStepInfo.layer_name, topLayer.__cname)
		return
	end

	local startIndex = string.find(guideStepInfo.widget_name, "|" .. guideStepInfo.name)
	local widget_name = string.sub(guideStepInfo.widget_name, 1, startIndex - 1)
	local widget = self:getWidgetByName(topLayer, widget_name)
	if not widget then
		return
	end

	local panel = TFPanel:create()
	panel:setSize(CCSize(100, 80))
	panel:setPosition(guideStepInfo.pos[1], guideStepInfo.pos[2])
	panel:setName(guideStepInfo.name)
	widget:addChild(panel)
	panel:addMEListener(TFWIDGET_CLICK, function ()
		topLayer.isTriggering = false
		topLayer:findPathWithWalkable(ccp(guideStepInfo.pos[1], guideStepInfo.pos[2]))
	end)
end

--新手引导删除引导panel
function PlayerGuideManager:missionPutRemoveBefore(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end

	if topLayer.__cname ~= guideStepInfo.layer_name then
		print("topLayer.__cname ~= ", guideStepInfo.layer_name, topLayer.__cname)
		return
	end

	local widget = self:getWidgetByName(topLayer, guideStepInfo.name)
	if not widget then
		return
	end
	widget:removeMEListener(TFWIDGET_CLICK)
	widget:removeFromParent()
	widget = nil
end

function PlayerGuideManager:bottomMenuPutBefore(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end

	-- if not topLayer.menuBtnAnimation then
	-- 	TFFunction.call(topLayer._btnClickHandle, topLayer.btn_show)
	-- end
	CommonUiManager:setLayerState(true)
end

function PlayerGuideManager:menuNpcPutBefore(guideStepInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end

	if topLayer.onSetNpcStopByName then
		topLayer:onSetNpcStopByName("panel_tianshu")
	end
end

--=========================================================================

--直接进入副本
function PlayerGuideManager:missionLayerPutQuick(guideStepInfo, topLayer)
	print("PlayerGuideManager:missionLayerPutQuick ========= ")
	if self.m_guideInfo == nil or self.m_guideInfo.guidePanel_bg == nil then
		return
	end
	local button = self:createButton()
	local guidePanel_bg = self.m_guideInfo.guidePanel_bg
	guidePanel_bg:addChild(button)

	local pos = guidePanel_bg:convertToNodeSpace(ccp(GameConfig.WS.width, 0))
	button:setPosition(ccp(pos.x-70, pos.y+130))
	button:addMEListener(TFWIDGET_CLICK, 
	function()
		self:removePanelBg()
		self:endCallBack(guideStepInfo, topLayer)
		self.m_guideInfo = {}
		self.functionId = 0
		self.now_step = 0
		self.next_step = 0
		AlertManager:closeAll()
		MissionManager:openChapterAndCurMissionLayer(EnumMissionType.Main)
	end)
end

--直接进入角色信息
function PlayerGuideManager:roleLayerPutQuick(guideStepInfo, topLayer)
	print("PlayerGuideManager:roleLayerPutQuick ========")
	if self.m_guideInfo == nil or self.m_guideInfo.guidePanel_bg == nil then
		return
	end
	local button = self:createButton()
	local guidePanel_bg = self.m_guideInfo.guidePanel_bg
	guidePanel_bg:addChild(button)

	local pos = guidePanel_bg:convertToNodeSpace(ccp(GameConfig.WS.width, 0))
	button:setPosition(ccp(pos.x-70, pos.y+130))
	button:addMEListener(TFWIDGET_CLICK, 
	function ()
		self:removePanelBg()
		self:endCallBack(guideStepInfo, topLayer)
		self.m_guideInfo = {}
		self.functionId = 0
		self.now_step = 0
		self.next_step = 0
		AlertManager:closeAll()
		CardRoleManager:showRoleInfoLayer(guideStepInfo.roleId, guideStepInfo.roleType)
	end)
end

-- 直接进入布阵界面
function PlayerGuideManager:armyLayerPutQuick(guideStepInfo, topLayer)
	print("PlayerGuideManager:armyLayerPutQuick ========")
	if self.m_guideInfo == nil or self.m_guideInfo.guidePanel_bg == nil then
		return
	end
	local button = self:createButton()
	local guidePanel_bg = self.m_guideInfo.guidePanel_bg
	guidePanel_bg:addChild(button)

	local pos = guidePanel_bg:convertToNodeSpace(ccp(GameConfig.WS.width, 0))
	button:setPosition(ccp(pos.x-70, pos.y+130))
	button:addMEListener(TFWIDGET_CLICK,
	function ()
		self:removePanelBg()
		self:endCallBack(guideStepInfo, topLayer)
		self.m_guideInfo = {}
		self.functionId = 0
		self.now_step = 0
		self.next_step = 0
		AlertManager:closeAll()
		FormationManager:openFormationLayer(nil, 2)
	end)
end

---=========================== save =======================

function PlayerGuideManager:isFunctionOpen(functionId)
	if not self.bOpenGuide then
		return true
	end
	return self:isGuideFunctionOpen(functionId)
end

--功能是否开放
function PlayerGuideManager:isGuideFunctionOpen(functionId)
	if MainPlayer:isGuideFunctionOpen(functionId) then
		return true
	end
	if MainPlayer:isGuideFunctionOpen(MainPlayer.MAX_GUIDE_ID) then
		return true
	end
	return false 
end

function PlayerGuideManager:saveGuideStepInfo(save)
	if save then
		self:saveFunctionOpenGuide(self.functionId)
	end
end

--保存功能开放
function PlayerGuideManager:saveFunctionOpenGuide(functionId)
	if self:isGuideFunctionOpen(functionId) then
		return
	end
	print("saveFunctionOpenGuide", functionId)
	
	self:removeGuideLayers(functionId)
	--发送服务器保存   
	MainPlayer:sendRequestGuideRecord(functionId)

	-- CCUserDefault:sharedUserDefault():setStringForKey("player_guide",MainPlayer.guideList)
 --    CCUserDefault:sharedUserDefault():flush()
end

function PlayerGuideManager:saveGuideStep_test()
	self:saveFunctionOpenGuide(MainPlayer.MAX_GUIDE_ID)
end

--======================================   延迟执行 新手引导 ======================= 

---- 判断widget是否显示及执行action
function PlayerGuideManager:isWidgetRunning( guideInfo )
	if guideInfo.widget_name and guideInfo.widget_name ~= "" then
		local topLayer = self:getTopLayer()
		if topLayer == nil then
			return false
		end
		local widget = self:getWidgetByName(topLayer, guideInfo.widget_name)
		if widget == nil then
			return false
		end

		while(widget and widget:getName() ~= topLayer.__cname)
		do
			local num = CCDirector:sharedDirector():getActionManager():numberOfRunningActionsInTarget(widget)
			if num ~= 0 or widget:isVisible() == false then
				return true
			end
			if widget.ui and widget.ui:getMEListener(TFWIDGET_ENTERFRAME) ~= nil then
				return true
			end
			widget = widget:getParent()
		end
	end
	return false
end

function PlayerGuideManager:removeNotClickBg()
	if self.notClickBg and not tolua.isnull(self.notClickBg) then
		self.notClickBg:stopAllActions()
		self.notClickBg:removeFromParent()
		self.notClickBg = nil
	end
end

function PlayerGuideManager:createNotClickBg()
	self:removeNotClickBg()
	local function callFunc()
		if not self then return end
		if self.removeNotClickBg then
			self:removeNotClickBg()
		end
		if self.saveFunctionOpenGuide and self.functionId then
			self:saveFunctionOpenGuide(self.functionId)
		end
		if self.removePanelBg then self:removePanelBg() end
		self.now_step = 0
		self.next_step = 0
		self.functionId = 0
    end

	local bg = self:getGuidePanelBg()
	local delay = DelayTime:create(8)
	local cal = CallFunc:create(callFunc)
	local seq = Sequence:createWithTwoActions(delay, cal)
	local rep = Repeat:create(seq,1)
	bg:runAction(rep)
	return bg
end

-- 延迟指引界面的显示，通过定时器判断widget是否显示或执行action
function PlayerGuideManager:delayShowGuideLayer(guideStepInfo, save)
	print("=========== delay show guide layer")

	--防止运动界面可点击   
	local topLayer = self:getTopLayer()
	if topLayer ~= nil then
		self.notClickBg = self:createNotClickBg()
		topLayer:addChild(self.notClickBg)
	end

	if self.delayTimerId then
		TFDirector:removeTimer(self.delayTimerId)
		self.delayTimerId = nil
	end
	local delay = 0.02  --guideStepInfo.delay or 0
	self.delayTimerId = TFDirector:addTimer(delay * 1000, -1, nil,
	function()
		local topLayer = self:getTopLayer()
		if topLayer == nil or guideStepInfo.layer_name ~= topLayer.__cname then
			TFDirector:removeTimer(self.delayTimerId)
			self.delayTimerId = nil

			self:removeNotClickBg()
			return
		end
		self:updateShow(guideStepInfo,save)
	end)
end

-- 定时器
function PlayerGuideManager:updateShow( guideStepInfo ,save )
	if self:isWidgetRunning(guideStepInfo) then
		return
	end
	if self.delayTimerId then
		TFDirector:removeTimer(self.delayTimerId)
        self.delayTimerId = nil
	end
	self:showAll(guideStepInfo,save)
end

-- 延迟指引界面的显示，通过定时器判断widget是否为空
function PlayerGuideManager:delayShowGuideLayerIfWidgetNil(guideStepInfo,save)
	if self.delayTimerId then
		TFDirector:removeTimer(self.delayTimerId)
        self.delayTimerId = nil
	end
	local delay = guideStepInfo.delay or 0
	self.delayTimerId = TFDirector:addTimer(delay * 1000, -1, nil,
		function()
			self:updateShowIfWidgetNil(guideStepInfo,save)
		end)
end

-- 定时器
function PlayerGuideManager:updateShowIfWidgetNil( guideStepInfo ,save)
	local num = self:isCancelUpdateByWidgetNil(guideStepInfo)
	if num == 1 then
		return
	elseif num == 2 then
		if self.delayTimerId then
			TFDirector:removeTimer(self.delayTimerId)
			self.delayTimerId = nil
		end
		self.now_step = guideStepInfo.id
		self:showGuideLayer(guideStepInfo,save)
	else
		if self.delayTimerId then
			TFDirector:removeTimer(self.delayTimerId)
			self.delayTimerId = nil
		end
	end
end

--判断是否取消定时器
function PlayerGuideManager:isCancelUpdateByWidgetNil( guideStepInfo )
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return 0
	end
	if self.now_step == guideStepInfo.id then
		return 0
	end
	if guideStepInfo.layer_name ~= topLayer.__cname then
		return 0
	end
	if guideStepInfo.widget_name and guideStepInfo.widget_name ~= "" then
		local widget = self:getWidgetByName(topLayer , guideStepInfo.widget_name)
		if widget == nil then
			return 1
		else
			return 2
		end
	end
	return 0
end


--============================  animation effect === =================

--显示动画或者特效
function PlayerGuideManager:showEffect(panelbg, guideInfo )
	local widgetPos = ccp(0,0)
	local size = nil
	if guideInfo.widget_name and guideInfo.widget_name ~= "" then
		local topLayer = self:getTopLayer()
		local widget = self:getWidgetByName(topLayer, guideInfo.widget_name)
		if widget ~= nil then
			local pos = widget:getParent():convertToWorldSpaceAR(widget:getPosition())
			-- local pos = widget:convertToWorldSpace(ccp(0,0))
			widgetPos = panelbg:convertToNodeSpace(pos);
			size = widget:getSize()
		end
	end
	if guideInfo.widget_rect then
		widgetPos = ccp(guideInfo.widget_rect[1],guideInfo.widget_rect[2])
	end

	if guideInfo.tip ~= nil and guideInfo.tip ~= "" then
		local bgImgName = nil
		local textLen = string.utf8len(guideInfo.tip)
		-- if textLen <= 30 then
		-- 	if guideInfo.right then
		-- 		bgImgName = "ui/playerguide/smallguidebg_r.png"
		-- 	else
		-- 		bgImgName = "ui/playerguide/smallguidebg_l.png"
		-- 	end
		-- else
		-- 	if guideInfo.right then
		-- 		bgImgName = "ui/playerguide/bigguidebg_r.png"
		-- 	else
		-- 		bgImgName = "ui/playerguide/bigguidebg_l.png"
		-- 	end
		-- end
		if guideInfo.right then
			bgImgName = "ui/playerguide/bigguidebg_r.png"
		else
			bgImgName = "ui/playerguide/bigguidebg_l.png"
		end

		local textPanel = TFImage:create(bgImgName)
		textPanel:setPosition(ccp(guideInfo.tip_pos[1], guideInfo.tip_pos[2]))
		--setPosition(ccp(widgetPos.x+guideInfo.tip_pos[1], widgetPos.y+guideInfo.tip_pos[2]))
		textPanel:setZOrder(10)
		textPanel:setTag(100)
		panelbg:addChild(textPanel)

		-- local textLabel = TFTextArea:create()
		-- textLabel:setAnchorPoint(ccp(0.5, 0.5))
	 	-- if guideInfo.right then
	 	-- 	textLabel:setPosition(-110, -50)
	 	-- else
	 	-- 	textLabel:setPosition(110, -50)
	 	-- end
	 	-- textLabel:setTextHorizontalAlignment(kCCTextAlignmentLeft)
	 	-- textLabel:setTextAreaSize(CCSizeMake(240, 90))
	    -- textLabel:setFontSize(20)
	    -- textLabel:setColor(ccc3(255,255,255))
	    -- textLabel:setText(guideInfo.tip)
	    -- textLabel:setFontName(DEFAULT_FONT)
		-- textPanel:addChild(textLabel)
		
		local richtext = TFRichText:create(CCSize(240, 90))
		richtext:setFontSize(20)
		richtext:setAnchorPoint(ccp(0.5, 0.5))
		if guideInfo.right then
			richtext:setPosition(-110, -50)
		else
			richtext:setPosition(110, -50)
		end
		local tip = self:replaceSpace(guideInfo.tip)
		richtext:setText(RichTextFont(tip, nil, 22))
		textPanel:addChild(richtext)
	end
    self:showhandEffect(panelbg, guideInfo,widgetPos, size)
end

function PlayerGuideManager:replaceSpace(msg)
	msg = string.gsub(msg, PlayerGuideManager.EndSymbol, PlayerGuideManager.End)
	msg = string.gsub(msg, PlayerGuideManager.SpecialSymbol, PlayerGuideManager.Special)
	return msg
end

function PlayerGuideManager:showhandEffect(panelbg, guideInfo ,widget_pos, size)
	if guideInfo.hand_eff == "no" then
		return
	end
	local effectName = guideInfo.hand_eff and guideInfo.hand_eff or "guide"
	local effect = GameResourceManager:getEffectAniById(effectName, nil, nil, "click1")
	if effect == nil then
		return
	end
	local hand_pos = guideInfo.hand_pos or {0,0}
	local effectPosX = widget_pos.x + hand_pos[1]
	local effectPosY = widget_pos.y + hand_pos[2]
	if guideInfo.rotation then
		effect:setRotation(guideInfo.rotation)
	end
	effect:setPosition(ccp(effectPosX, effectPosY))
	effect:setZOrder(12)
	panelbg:addChild(effect)
	effect:stop()
	effect:setVisible(false)
	self.effect_hand = effect
end

function PlayerGuideManager:createCircleEffect(x, y, width, height)
	local effectName = "guide"
	local effect = GameResourceManager:getEffectAniById(effectName, nil, nil, "click2")
	if effect == nil then
		return
	end
	local pos_x = x + width / 2
	local pos_y = y + height / 2
	effect:setPosition(ccp(pos_x, pos_y)) --ccp(effectPosX, effectPosY))
	return effect
end

function PlayerGuideManager:showEffectByName(panelbg, guideInfo)
	if panelbg == nil or guideInfo == nil or guideInfo.effectName == nil or guideInfo.actionName == nil then
		return 
	end

	if guideInfo.widget_name and guideInfo.widget_name ~= "" then
		local topLayer = self:getTopLayer()
		local widget = self:getWidgetByName(topLayer, guideInfo.widget_name)
		if widget ~= nil then
			local pos = widget:getParent():convertToWorldSpaceAR(widget:getPosition())
			-- local pos = widget:convertToWorldSpace(ccp(0,0))
			widgetPos = panelbg:convertToNodeSpace(pos);
		end
	end
	if guideInfo.widget_rect then
		widgetPos = ccp(guideInfo.widget_rect[1],guideInfo.widget_rect[2])
	end

	effectName = guideInfo.effectName or "guide"
	actionName = guideInfo.actionName or "drag"
	local resPath = "effect/".. effectName ..".json"
	if not TFFileUtil:existFile(resPath) then
		return
	end
	local effect = GameResourceManager:getEffectAniById(effectName)
	if effect == nil then
		return
	end
	effect:setTimeScale(GameConfig.SPINE_TIMESCALE)
	effect:play(0, actionName, 1)
	effect:setTag(guideInfo.id)
	if guideInfo.rotation then
	 	effect:setRotation(guideInfo.rotation)
	end

	local hand_pos = guideInfo.hand_pos or {0,0}
	local effectPosX = widgetPos.x + hand_pos[1]
	local effectPosY = widgetPos.y + hand_pos[2]
	effect:setPosition(ccp(effectPosX, effectPosY))
	effect:setZOrder(100)
	panelbg:addChild(effect)
end

function PlayerGuideManager:removeEffectByName(panelbg, guideInfo)
	if panelbg == nil or guideInfo == nil then return end
	panelBg:removeChildByTag(guideInfo.id)
end

function PlayerGuideManager:playEffect( effect , effectTime, id)
	if id == self.effect_step_id then return end

	self.effect_step_id = id
	if self.effectHandle ~= nil then
		TFAudio.stopEffect(self.effectHandle)
		self.effectHandle = nil
	end
	if self.effectTimer then
		TFDirector:removeTimer(self.effectTimer)
		self.effectTimer = nil
	end
	self.effectHandle = TFAudio.playEffect("sound/guide/".. effect .. ".mp3",false)
	--RoleSoundData:stopEffect()
	if effectTime and effectTime > 0 then
		self.effectTimer = TFDirector:addTimer(effectTime ,1,nil ,function ()
			TFDirector:removeTimer(self.effectTimer)
			self.effectTimer = nil

			TFAudio.stopEffect(self.effectHandle)
			self.effectHandle = nil
		end)
	end
end

----================== layer ===============================

function PlayerGuideManager:addGuideKuang( pos , anp )
	local pic = TFImage:create()
	pic:setTexture("ui/playerguide/guide_kuang.png")
	pic:setAnchorPoint(anp)
	pic:setPosition(pos)
	return pic
end

function PlayerGuideManager:getWidgetByName(parent, widget_name)
	if widget_name == nil or widget_name == "" then
		return nil
	end
	local widgetList, length = stringToTable(widget_name,"|")
	if length == 0 then
		return nil
	end
	local widget = parent
	for i=1,length do
		widget = TFDirector:getChildByPath(widget, widgetList[i])
	end
	return widget
end

function PlayerGuideManager:setGuideVisible(visible)
	if self.m_guideInfo and self.m_guideInfo.guidePanel_bg and not tolua.isnull(self.m_guideInfo.guidePanel_bg) then
		self.m_guideInfo.guidePanel_bg:setVisible(visible)
	end
end

--移除
function PlayerGuideManager:removePanelBg()
	if self.buttonTimerId then
		TFDirector:removeTimer(self.buttonTimerId)
		self.buttonTimerId = nil
	end
	if self.moreBtnTimerId then
		TFDirector:removeTimer(self.moreBtnTimerId)
		self.moreBtnTimerId = nil
	end
	if self.effect_hand then
		self.effect_hand = nil
	end

	if self.m_guideInfo then
		for k,v in pairs(self.m_guideInfo) do
			if not tolua.isnull(v) then
				v:removeFromParent()
				v = nil
			end
		end
	end

	self.m_guideInfo = {}
end

--创建指引Panel背景
function PlayerGuideManager:getGuidePanelBg()
	local guidePanel_bg = TFPanel:create()
	guidePanel_bg:setAnchorPoint(ccp(0, 0))
	guidePanel_bg:setSize(CCSize(GameConfig.WS.width , GameConfig.WS.height))
	guidePanel_bg:setZOrder(10000)
	--guidePanel_bg:setTouchEnabled(false)
	guidePanel_bg:setTouchEnabled(true) -- test
	return guidePanel_bg
end

--创建强制指引黑层panel
function PlayerGuideManager:getGuideForcePanel(guidePanel_bg, guideStepInfo)
	if guideStepInfo == nil then
		return
	end
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	if self:getGuideForcePanelbyRect(guidePanel_bg, guideStepInfo) then
		return
	end
	if self:getGuideForcePanelbyWidget(guidePanel_bg, guideStepInfo) then
		return
	end
	local guideForcePanel = self:getGuideForcePanelAll()
	if guideForcePanel then
		guidePanel_bg:addChild(guideForcePanel)
		guidePanel_bg.layerList = guidePanel_bg.layerList or {}
		guidePanel_bg.layerList[#guidePanel_bg.layerList+1] = guideForcePanel
	end
end

-- 添加中间有白块的黑层
function PlayerGuideManager:getGuideForcePanelOut(pos_x,pos_y,width,height)
	local win_width = GameConfig.WS.width
	local win_height = GameConfig.WS.height
	local guideForcePanelList = {}
	guideForcePanelList[1] = self:createLeftUpForceLayer(pos_x + width , pos_y + height, pos_x + width , win_height - (pos_y + height))
	--guideForcePanelList[5] = self:addGuideKuang(ccp(pos_x + width+15, pos_y + height+15),ccp(0,1))
	--guideForcePanelList[5]:setScaleX(-1)

	guideForcePanelList[2] = self:createLeftDownForceLayer( pos_x,pos_y + height ,pos_x , pos_y + height )
	--guideForcePanelList[6] = self:addGuideKuang(ccp(pos_x-15,pos_y + height+15),ccp(0,1))

	guideForcePanelList[3] = self:createRightUpForceLayer(pos_x + width, pos_y ,win_width - (pos_x + width) , win_height - pos_y )
	--guideForcePanelList[7] = self:addGuideKuang(ccp(pos_x + width+15, pos_y-15),ccp(0,1))
	--guideForcePanelList[7]:setScale(-1)

	guideForcePanelList[4] = self:createRightDownForceLayer(pos_x, pos_y,win_width - pos_x , pos_y )
	--guideForcePanelList[8] = self:addGuideKuang(ccp(pos_x-15, pos_y-15),ccp(0,1))
	--guideForcePanelList[8]:setScaleY(-1)

	guideForcePanelList[5] = self:createCircleEffect(pos_x, pos_y, width, height)
	return guideForcePanelList
end

-- 添加中间露出控件的黑层
function PlayerGuideManager:getGuideForcePanelWidget(panelBg , widget , guideInfo)
	if widget == nil or panelBg == nil then
		return
	end
	local topLayer = self:getTopLayer()
	local pos = widget:getParent():convertToWorldSpaceAR(widget:getPosition())--ccp(widget:get Position().x,widget:getPosition().y))
	pos = panelBg:convertToNodeSpace(pos);
	local anchorPoint = widget:getAnchorPoint()
	x = pos.x - anchorPoint.x * widget:getSize().width
	y = pos.y - anchorPoint.y * widget:getSize().height

	local offset = {0,0}
	if guideInfo.offset then
		x = x + guideInfo.offset[1]
		y = y + guideInfo.offset[2]
		offset[1] = guideInfo.offset[3] or 0
		offset[2] = guideInfo.offset[4] or 0
	end	
	local guideForcePanelList = self:getGuideForcePanelOut(x,y,widget:getSize().width+offset[1],widget:getSize().height+offset[2])
	for i=1,8 do
		if guideForcePanelList[i] then
			panelBg:addChild(guideForcePanelList[i])
			panelBg.layerList = panelBg.layerList or {}
			panelBg.layerList[#panelBg.layerList+1] = guideForcePanelList[i]
		end
	end
	--return guideForcePanelList
end

--通过widget来添加控件黑层
function PlayerGuideManager:getGuideForcePanelbyWidget( panelBg  , guideInfo )
	local topLayer = self:getTopLayer()
	if guideInfo.widget_name and guideInfo.widget_name ~= "" then
		local widget = self:getWidgetByName(topLayer, guideInfo.widget_name)
		if widget ~= nil then
			self:getGuideForcePanelWidget(panelBg , widget , guideInfo)
		else
			-- print("widget == nil widget_name ==",guideInfo.widget_name)
			local guideForcePanel = self:getGuideForcePanelAll()
			if guideForcePanel then
				panelBg:addChild(guideForcePanel)
				panelBg.layerList = panelBg.layerList or {}
				panelBg.layerList[#panelBg.layerList+1] = guideForcePanel
			end
		end
		return true
	end
	return false
end

--通过区域来添加控件黑层
function PlayerGuideManager:getGuideForcePanelbyRect(panelBg , guideInfo)
	if panelBg and guideInfo.widget_rect then
		local x = guideInfo.widget_rect[1]
		local y = guideInfo.widget_rect[2]
		local offset = {0,0}
		if guideInfo.offset then
			x = x + guideInfo.offset[1] or 0
			y = y + guideInfo.offset[2] or 0
			offset[1] = guideInfo.offset[3] or 0
			offset[2] = guideInfo.offset[4] or 0
		end	
		local guideForcePanelList = self:getGuideForcePanelOut(x,y,guideInfo.widget_rect[3]+offset[1],guideInfo.widget_rect[4]+offset[2])
		for i=1,8 do
			if guideForcePanelList[i] then
				panelBg:addChild(guideForcePanelList[i])
				panelBg.layerList = panelBg.layerList or {}
				panelBg.layerList[#panelBg.layerList+1] = guideForcePanelList[i]
			end
		end
		return true
	end
	return false
end

-- 添加全屏黑层
function PlayerGuideManager:getGuideForcePanelAll()
	local guideForcePanel = TFPanel:create()
	guideForcePanel:setAnchorPoint(ccp(0.5, 0.5))
	guideForcePanel:setSize(CCSize(GameConfig.WS.width , GameConfig.WS.height))
	guideForcePanel:setPosition(ccp(GameConfig.WS.width/2 , GameConfig.WS.height/2))
	guideForcePanel:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
	guideForcePanel:setBackGroundColorOpacity(1)
	guideForcePanel:setBackGroundColor(ccc3(0,0,0))
	guideForcePanel:setTouchEnabled(true)
	return guideForcePanel
end

-- 添加中间有白块的黑层(左上)
function PlayerGuideManager:createLeftUpForceLayer( pos_x , pos_y ,width , height )
	-- print("PlayerGuideManager:createLeftUpForceLayer( width , height )",width , height )
	local guideForcePanel = TFPanel:create()
	guideForcePanel:setAnchorPoint(ccp(1, 0))
	guideForcePanel:setSize(CCSize(width+200 , height+200))
	guideForcePanel:setPosition(ccp( pos_x , pos_y))
	guideForcePanel:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
	guideForcePanel:setBackGroundColorOpacity(1)
	guideForcePanel:setBackGroundColor(ccc3(0,0,0))
	guideForcePanel:setTouchEnabled(true)
	self:setForceLayerClickHandle(guideForcePanel)
	return guideForcePanel
end

-- 添加中间有白块的黑层(左下)
function PlayerGuideManager:createLeftDownForceLayer( pos_x , pos_y ,width , height )
	-- print("PlayerGuideManager:createLeftDownForceLayer( width , height )",width , height )
	local guideForcePanel = TFPanel:create()
	guideForcePanel:setAnchorPoint(ccp(1, 1))
	guideForcePanel:setSize(CCSize(width+200 , height+200))
	guideForcePanel:setPosition(ccp( pos_x , pos_y))
	guideForcePanel:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
	guideForcePanel:setBackGroundColorOpacity(1)
	guideForcePanel:setBackGroundColor(ccc3(0,0,0))
	guideForcePanel:setTouchEnabled(true)
	self:setForceLayerClickHandle(guideForcePanel)
	return guideForcePanel
end

-- 添加中间有白块的黑层(右上)
function PlayerGuideManager:createRightUpForceLayer( pos_x , pos_y ,width , height )
	-- print("PlayerGuideManager:createRightUpForceLayer( width , height )",width , height )
	local guideForcePanel = TFPanel:create()
	guideForcePanel:setAnchorPoint(ccp(0, 0))
	guideForcePanel:setSize(CCSize(width+200 , height+200))
	guideForcePanel:setPosition(ccp( pos_x, pos_y))
	guideForcePanel:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
	guideForcePanel:setBackGroundColorOpacity(1)
	guideForcePanel:setBackGroundColor(ccc3(0,0,0))
	guideForcePanel:setTouchEnabled(true)
	self:setForceLayerClickHandle(guideForcePanel)
	return guideForcePanel
end

-- 添加中间有白块的黑层(右下)
function PlayerGuideManager:createRightDownForceLayer( pos_x , pos_y ,width , height )
	-- print("PlayerGuideManager:createRightDownForceLayer( width , height )",width , height )
	local guideForcePanel = TFPanel:create()
	guideForcePanel:setAnchorPoint(ccp(0, 1))
	guideForcePanel:setSize(CCSize(width+200 , height+200))
	guideForcePanel:setPosition(ccp( pos_x , pos_y))
	guideForcePanel:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
	guideForcePanel:setBackGroundColorOpacity(1)
	guideForcePanel:setBackGroundColor(ccc3(0,0,0))
	guideForcePanel:setTouchEnabled(true)
	self:setForceLayerClickHandle(guideForcePanel)
	return guideForcePanel
end

function PlayerGuideManager:setForceLayerClickHandle(guideForcePanel)
	local function onForceClickHandle(sender)
		if self.effect_hand then
			self.effect_hand:setVisible(true)
			self.effect_hand:resume()
			self.effect_hand = nil
		end
	end

	guideForcePanel.logic = self
	guideForcePanel:removeMEListener(TFWIDGET_CLICK)
	guideForcePanel:addMEListener(TFWIDGET_CLICK, audioClickfun(onForceClickHandle))
end

--添加跳过新手引导功能     
function PlayerGuideManager:setTiaoguoTimer(guideStepInfo, topLayer)
	if self.functionId == nil or self.functionId < 1 then
		return
	end
	if self.buttonTimerId then
		TFDirector:removeTimer(self.buttonTimerId)
		self.buttonTimerId = nil
	end
	self.buttonTimerId = TFDirector:addTimer(TiaoguoTime*1000, 1, nil,
	function ()
		if self:getTopLayer() ~= topLayer or not self.m_guideInfo or not self.m_guideInfo.guidePanel_bg or tolua.isnull(self.m_guideInfo.guidePanel_bg) then
			print("self:getTopLayer() ~= topLayer", self:getTopLayer().__cname, ",", topLayer.__cname)
			if self.buttonTimerId then
				TFDirector:removeTimer(self.buttonTimerId)
				self.buttonTimerId = nil
			end
			return
		end
		local button = TFButton:create()
		local guidePanel_bg = self.m_guideInfo.guidePanel_bg
		guidePanel_bg:addChild(button)
		button:setTextureNormal("ui/common/icon_tiaoguo.png")
		button:setAnchorPoint(ccp(1,1))

		local pos = guidePanel_bg:convertToNodeSpace(ccp(GameConfig.WS.width, GameConfig.WS.height))
		button:setPosition(pos)
		button:setZOrder(100)
		button:addMEListener(TFWIDGET_CLICK, 
		function()
			self:removePanelBg()
			self:endCallBack(guideStepInfo, topLayer)
			self.m_guideInfo = {}
			self.functionId = 0
			self.now_step = 0
			self.next_step = 0
			self:saveGuideStep_test()
		end)
	end)
end

function PlayerGuideManager:createButton(txture_normal)
	txture_normal = txture_normal or "uicommon/btn/btn_174_shiyong.png"
	local button = TFButton:create()
	button:setTextureNormal(txture_normal)
	button:setAnchorPoint(ccp(1,1))
	button:setZOrder(100)
	return button
end

function PlayerGuideManager:getFirstBattleData()
	local GuideData = require("lua.table.stage_guide_s.lua")
	local guideData = GuideData:objectByID(1)

	local data = {}
	data.fighttype = 9
	data.missionId = guideData.stage_id
	data.angerSelf = guideData.my_anger
	data.angerEnemy = guideData.enemy_anger
	data.unitList = {}

	local unit = nil
	local formation = stringToTable(guideData.my_formation, ",")
	for k,v in pairs(formation) do
		if v and tonumber(v) ~= 0 then
			unit = {}
			unit.typeId = 2
			unit.staticId = tonumber(v)
			unit.unitId = unit.staticId
			unit.posindex = k - 1
			data.unitList[#data.unitList + 1] = unit
		end
	end
	formation = stringToTable(guideData.enemy_formation, ",")
	for k,v in pairs(formation) do
		if v and tonumber(v) ~= 0 then
			unit = {}
			unit.typeId = 2
			unit.staticId = tonumber(v)
			unit.unitId = unit.staticId
			unit.posindex = k + 8
			data.unitList[#data.unitList + 1] = unit
		end
	end

	return data
end

return PlayerGuideManager:new()