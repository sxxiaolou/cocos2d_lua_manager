-- Created by ZZTENG on 2017/11/07.
--通用界面管理

local CommonUiManager = class("CommonUiManager")
CommonUiManager.UPDATE_LAYER_STATE = 'CommonUiManager.UPDATE_LAYER_STATE'

function CommonUiManager:ctor( ... )
    self.right_state = false
    self.left_state = false
    --运营icon数量
    if self.activityIcons == nil then
	   self.activityIcons = TFArray:new()
	end
	self.activityIcons:clear()
end

function CommonUiManager:restart( ... )
    self.right_state = false
    self.left_state = false
    if self.activityIcons == nil then
	   self.activityIcons = TFArray:new()
	end
	self.activityIcons:clear()

    --运营系统涉及到服务器开关
    self.serverSwitch = function ( events )
		--print('2222222222222222222',events.data[1])
        self:addActivityIcon(EnumActivityType.FuLi)
        self:addActivityIcon(EnumActivityType.VIPEnter)
        self:addActivityIcon(EnumActivityType.FirstPay,not ServerSwitchManager:isPayOpen())
        self:addActivityIcon(EnumActivityType.Weixin,not ServerSwitchManager:isWeChatOpen())
        self:addActivityIcon(EnumActivityType.CustomerServices,not ServerSwitchManager:isCustomerServicesOpen())
        self:addActivityIcon(EnumActivityType.OnlineActivity, not ServerSwitchManager:isOnlineActivityOpen())
        self:addActivityIcon(EnumActivityType.Wudaohui, not ServerSwitchManager:isOpenWudaohui())
        self:addActivityIcon(EnumActivityType.MonthCardEnter, not ServerSwitchManager:isMonthCardOpen())
        self:addActivityIcon(EnumActivityType.RedPacketRain, not ServerSwitchManager:isLuckyRainOpen())
        self:addActivityIcon(EnumActivityType.GuildWar, not ServerSwitchManager:isGuildWarOpen())
        TFDirector:dispatchGlobalEventWith("refresh_yunyin")
	end
	TFDirector:addMEGlobalListener(ServerSwitchManager.AllServerSwitchChange, self.serverSwitch)
end

function CommonUiManager:setRightState( state )
    self.right_state = state
end

function CommonUiManager:getRightState( ... )
    return self.right_state
end

function CommonUiManager:setLeftState( state )
    self.left_state = state
end
function CommonUiManager:getLeftState( ... )
    return self.left_state
end

function CommonUiManager:getSceneType( ... )
    return self.sceneType
end

--增加icon，remove是否移除
function CommonUiManager:addActivityIcon(id, remove, state)
	for icon in self.activityIcons:iterator() do
		if icon == id then 
			if remove then
				self.activityIcons:removeObject(icon)
                TFDirector:dispatchGlobalEventWith("refresh_yunyin")
			end
			return
		end
	end
    if not remove then
	    self.activityIcons:push(id)
        self.activityIcons:sort()
    end
end

function CommonUiManager:addCommonUiLayer( logic,zOrder ,sceneType)
    zOrder = zOrder or 99999;
    self.sceneType = sceneType
    local CommonUiLayer    = require('lua.logic.common.CommonUiLayer'):new()
    CommonUiLayer:setLogic(logic)
    CommonUiLayer:setPosition(ccp(0,0))
    CommonUiLayer:setZOrder(zOrder)
    CommonUiLayer:setName("CommonUiLayer")
    logic.ui:addChild(CommonUiLayer)
     return CommonUiLayer;
end

function CommonUiManager:addTaskMainLayer( logic ,zOrder)
    zOrder = zOrder or 1;
    local taskMainLayer    = require('lua.logic.common.TaskMainLayer'):new()
    logic.taskMainLayer = taskMainLayer
    taskMainLayer:setLogic(logic)
    taskMainLayer:setPosition(ccp(0,0))
    taskMainLayer:setZOrder(zOrder)
    taskMainLayer:setName("TaskMainLayer")

    local panel_task      = TFDirector:getChildByPath(logic, 'panel_task');
    panel_task:addChild(taskMainLayer)
    -- logic.ui:addChild(taskMainLayer)

    return taskMainLayer;
end

function CommonUiManager:addCommonLeftLayer( logic,zOrder )
    zOrder = zOrder or 1;
    local commonLeftLayer    = require('lua.logic.common.CommonLeftLayer'):new()
    logic.commonLeftLayer = commonLeftLayer
    commonLeftLayer:setLogic(logic)
    commonLeftLayer:setPosition(ccp(0,0))
    commonLeftLayer:setZOrder(zOrder)
    commonLeftLayer:setName("CommonLeftLayer")

    local panel_left      = TFDirector:getChildByPath(logic, 'panel_left');
    panel_left:addChild(commonLeftLayer)
    -- logic.ui:addChild(commonLeftLayer)

    return commonLeftLayer;
end

function CommonUiManager:addCommonHeadLayer( logic,zOrder )
     zOrder = zOrder or 1;
    local commonHeadLayer    = require('lua.logic.common.CommonHeadLayer'):new()
    logic.commonHeadLayer = commonHeadLayer
    commonHeadLayer:setLogic(logic)
    commonHeadLayer:setPosition(ccp(0,0))
    commonHeadLayer:setZOrder(zOrder)
    commonHeadLayer:setName("commonHeadLayer")

    local panel_head      = TFDirector:getChildByPath(logic, 'panel_head');
    panel_head:addChild(commonHeadLayer)
    -- logic.ui:addChild(commonLeftLayer)

    return commonHeadLayer;
end

function CommonUiManager:addCommonChatLayer( logic,zOrder )
     zOrder = zOrder or 1;
    local commonChatLayer    = require('lua.logic.common.CommonChatLayer'):new()
    logic.commonChatLayer = commonChatLayer
    commonChatLayer:setLogic(logic)
    commonChatLayer:setPosition(ccp(0,0))
    commonChatLayer:setZOrder(zOrder)
    commonChatLayer:setName("CommonChatLayer")

    local panel_chat      = TFDirector:getChildByPath(logic, 'panel_chat');
    panel_chat:addChild(commonChatLayer)
    -- logic.ui:addChild(commonLeftLayer)

    return commonChatLayer;
end

function CommonUiManager:addCommonRightLayer( logic,zOrder,hides )
     zOrder = zOrder or 1;
    local commonRightLayer    = require('lua.logic.common.CommonRightLayer'):new()
    logic.commonRightLayer = commonRightLayer
    commonRightLayer:setLogic(logic)
    commonRightLayer:setBtnHides(hides)
    commonRightLayer:setPosition(ccp(0,0))
    commonRightLayer:setZOrder(zOrder)
    commonRightLayer:setName("CommonRightLayer")

    local panel_right      = TFDirector:getChildByPath(logic, 'panel_right');
    panel_right:addChild(commonRightLayer)
    -- logic.ui:addChild(commonLeftLayer)

    return commonRightLayer;
end

function CommonUiManager:addQuickJumpLayer(logic, zOrder)
    zOrder = zOrder or 1

    local jumpLayer    = require('lua.logic.common.QuickJumpLayer'):new()
    jumpLayer:setLogic(logic)
    jumpLayer:setPosition(ccp(0,0))
    jumpLayer:setZOrder(zOrder)

    local panel = TFDirector:getChildByPath(logic, "panel_activity")
    panel:addChild(jumpLayer)
    return jumpLayer
end

function CommonUiManager:addCommonYunYingLayer( logic,zOrder )
    zOrder = zOrder or 1

    local yunYingLayer    = require('lua.logic.common.CommonYunYingLayer'):new()
    yunYingLayer:setLogic(logic)
    yunYingLayer:setPosition(ccp(0,0))
    yunYingLayer:setZOrder(zOrder)

    local panel = TFDirector:getChildByPath(logic, "panel_huodong")
    panel:addChild(yunYingLayer)
    return yunYingLayer
end

function CommonUiManager:addEyeLayer(logic, zOrder)
    zOrder = zOrder or 1 

    local panel_eye      = TFDirector:getChildByPath(logic, 'panel_eye')
    logic.panel_eye = panel_eye

    local panel_tx      = TFDirector:getChildByPath(panel_eye, 'panel_tx')
    panel_tx.bar = TFDirector:getChildByName(panel_tx, "bar")
    panel_tx.sp_panel = TFDirector:getChildByName(panel_tx, "sp_panel")
    panel_tx:setVisible(false)
    logic.panel_tx = panel_tx

    local eyeLayer    = require('lua.logic.common.EyeLayer'):new()
    logic.eyeLayer = eyeLayer
    eyeLayer:setLogic(logic)
    eyeLayer:setPosition(ccp(0,0))
    eyeLayer:setZOrder(zOrder)

    local eye = TFDirector:getChildByPath(logic, "eye")
    eye:addChild(eyeLayer)
    return eyeLayer
end

function CommonUiManager:addCommonGetLayer( logic,zOrder )
    zOrder = zOrder or 1

    local commonGetLayer    = require('lua.logic.common.CommonGetLayer'):new()
    logic.commonGetLayer = commonGetLayer
    commonGetLayer:setLogic(logic)
    commonGetLayer:setPosition(ccp(0,0))
    commonGetLayer:setZOrder(zOrder)

    local panel = TFDirector:getChildByPath(logic, "panel_get")
    panel:addChild(commonGetLayer)
    return commonGetLayer
end

--打开底部菜单栏
function CommonUiManager:setLayerState( state )
    print('222222222222222',state)
    self.right_state = state
    self.left_state = state
    
    TFDirector:dispatchGlobalEventWith(CommonUiManager.UPDATE_LAYER_STATE, 0)
end

--打开任务栏
function CommonUiManager:setTaskMainLayer( state )
    print('222222222222222',state)
    TaskMainManager:setOpenState(state)

    TFDirector:dispatchGlobalEventWith(CommonUiManager.UPDATE_LAYER_STATE, 0)
end

return CommonUiManager:new()