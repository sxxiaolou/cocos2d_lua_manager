--[[
******游戏设置管理类*******

	-- by Tony
	-- 2016/9/2
]]

local BaseManager = require("lua.gamedata.BaseManager")
local SettingManager = class("SettingManager", BaseManager)

SettingManager.SCENE_PLAYER_CHANGE      = "SettingManager.SCENE_PLAYER_CHANGE"
SettingManager.SETTING_FEED_BACK_RESP   = "SettingManager.SETTING_FEED_BACK_RESP"

function SettingManager:ctor(data)
	self.super.ctor(self)
end

function SettingManager:init()
	self.super.init(self)

    self.isShowReview = false

	TFDirector:addProto(s2c.SETTING_CONFIG, self, self.onReceiveSettingConfig)
    TFDirector:addProto(s2c.SETTING_SAVE_CONFIG_RESULT, self, self.onReceiveSaveConfigResult)
    --评分反馈成功
    TFDirector:addProto(s2c.FEED_BACK_RESP, self, self.onFeedBackResp)
    --显示评论
    TFDirector:addProto(s2c.SHOW_REVIEW, self, self.onShowReview)
    
	self.pushList  = require("lua.table.event_s")

    local isOpenMusic = CCUserDefault:sharedUserDefault():getIntegerForKey("isOpenMusic", 1)
    local isOpenVolume = CCUserDefault:sharedUserDefault():getIntegerForKey("isOpenVolume", 1)

    TFAudio.setMusicVolume(isOpenMusic == 1 and 0.6 or 0.0)
    TFAudio.setEffectsVolume(isOpenVolume == 1 and 1 or 0.0)
end

function SettingManager:restart()
    -- body

    self.isShowReview = false
end

function SettingManager:onReceiveSettingConfig( event )
    print("onReceiveSettingConfig")
    print(event.data)

    hideLoading()

    self.settingConfig = self.settingConfig or {}
    self.settingConfig.isOpenMusic = event.data.openMusic == 1 and 1 or 0
	self.settingConfig.isOpenVolume = event.data.openVolume == 1 and 1 or 0
	self.settingConfig.isOpenChat = event.data.openChat == 1 and 1 or 0

    self.bShowVip = event.data.vipVisible == 1 and true or false

    self:loadConfigFromFile()
end

function SettingManager:onReceiveSaveConfigResult( event )
    print("onReceiveSaveConfigResult")
    print(event.data)

    hideLoading();

    -- if event.data.isSuccess then        
    --     if self:isVipShow() then 
    --         self:changeVipShow()          
    --         toastMessage(localizable.settingManager_text_not_show_vip)
    --     else
    --         self:changeVipShow()
    --         toastMessage(localizable.settingManager_text_show_vip)
    --     end
    -- else
    --     toastMessage(localizable.settingManager_change_fail)
    -- end
end

function SettingManager:onFeedBackResp( event )
    hideLoading()

    TFDirector:dispatchGlobalEventWith(SettingManager.SETTING_FEED_BACK_RESP)
end

function SettingManager:onShowReview( event )
    print("==========onShowReview=============")
    print("==========onShowReview=============")
    print("==========onShowReview=============")
    print("==========onShowReview=============")
    print("==========onShowReview=============")
    print("==========onShowReview=============")
    self.isShowReview = true
end

function SettingManager:setIsShowReview(is_bool)
    self.isShowReview = is_bool
end

function SettingManager:getIsShowReview()
    return self.isShowReview or false
end

--protocol
function SettingManager:sendSettingSaveConfig()
	local music = self.settingConfig.isOpenMusic == 1 and 1 or 0
	local effect = self.settingConfig.isOpenVolume == 1 and 1 or 0
	local chat = self.settingConfig.isOpenChat == 1 and 1 or 0
	local vip = self.bShowVip == 1 and 1 or 0

	self:sendWithLoading(c2s.SETTING_SAVE_CONFIG, vip,music, effect, chat)
end

function SettingManager:sendFeedBack(content)
	self:sendWithLoading(c2s.FEED_BACK, content)
end


-----

function SettingManager:backtoUpdate()
    MainPlayer:reset()
    AlertManager:clearAllCache()
    CommonManager:closeConnection()
    restartLuaEngine()
end

function SettingManager:LoginOut()
    AlertManager:clearAllCache()
    CommonManager:closeConnection()

    if TFPlugins.isPluginExist()  then
        TFPlugins.LoginOut()
    else
        if not  self.nTimerIdLoginOut then
                local function loginOut()
                    if HeitaoSdk then
                        MainPlayer:restart()
                        AlertManager:changeScene(SceneType.WAITLOGOUT)
                        -- HeitaoSdk.loginOut()
                    else
                        MainPlayer:restart()
                        AlertManager:changeScene(SceneType.LOGIN)
                    end

                    TFDirector:removeTimer(self.nTimerIdLoginOut)
                    self.nTimerIdLoginOut = nil
                end

            self.nTimerIdLoginOut = TFDirector:addTimer(500, -1, nil, loginOut)
        end
    end

    -- elseif HeitaoSdk then
    --     if not  self.nTimerIdLoginOut then
    --         local function loginOut()
    --             HeitaoSdk.loginOut()

    --             TFDirector:removeTimer(self.nTimerIdLoginOut)
    --             self.nTimerIdLoginOut = nil
    --         end

    --         self.nTimerIdLoginOut = TFDirector:addTimer(500, -1, nil, loginOut)
    --     end
        
    -- else
    --     MainPlayer:restart()
    --     AlertManager:changeSceneForce(SceneType.LOGIN)
    -- end
end

function SettingManager:getIsOpenMusic()
    return self.settingConfig.isOpenMusic
end

function SettingManager:getIsOpenVolume()
    return self.settingConfig.isOpenVolume
end

function SettingManager:getIsOpenChat()
    return self.settingConfig.isOpenChat
end

function SettingManager:isVipShow()
    return self.getConfigPushById(6)
end

function SettingManager:getConfig()
    self:loadConfigFromFile()
end

function SettingManager:saveConfigToFile()
    -- CCUserDefault:sharedUserDefault():setBoolForKey("settingConfig.isOpenMusic",not self.settingConfig.isOpenMusic);
    -- CCUserDefault:sharedUserDefault():setBoolForKey("settingConfig.isOpenVolume",not self.settingConfig.isOpenVolume);
    -- CCUserDefault:sharedUserDefault():setBoolForKey("settingConfig.isOpenChat",not self.settingConfig.isOpenChat);
        
    -- CCUserDefault:sharedUserDefault():flush()
end

function SettingManager:loadConfigFromFile()
    if not self.settingConfig then
    	return
    end

    TFAudio.setMusicVolume(self.settingConfig.isOpenMusic == 1 and 0.6 or 0.0)
    TFAudio.setEffectsVolume(self.settingConfig.isOpenVolume == 1 and 1 or 0.0)

    self.settingConfig.pushSwitch = {}
    for v in self.pushList:iterator() do
        self.settingConfig.pushSwitch[v.id] = CCUserDefault:sharedUserDefault():getBoolForKey(v.key, true)
        if self.settingConfig.pushSwitch[v.id] == nil then
            self.settingConfig.pushSwitch[v.id] = true
        end
    end
end

function SettingManager:saveConfigByKeyVaule(key , vaule)
    CCUserDefault:sharedUserDefault():setIntegerForKey(key,vaule)
    CCUserDefault:sharedUserDefault():flush()
end

function SettingManager:saveConfigPushById(id , vaule)
    local  pushInfo = self.pushList:objectByID(id)
    self.settingConfig.pushSwitch[id] = vaule
    CCUserDefault:sharedUserDefault():setBoolForKey(pushInfo.key,vaule);
    CCUserDefault:sharedUserDefault():flush();
    -- self:setConfigToPush(pushInfo, value)

    print("*****************&&&:; ", self:isShowPlayer())
    if id == EnumPushSwitchType.Show_Player then
        TFDirector:dispatchGlobalEventWith(SettingManager.SCENE_PLAYER_CHANGE)
    end
end

--将修改应用到推送
function SettingManager:setConfigToPush(pushInfo, value)
    if pushInfo.id==self:getTequanId() then
        return
    end
    if value then
        self:startDailyNotification(""..pushInfo.id, pushInfo.desc, pushInfo.date, true)
    else
        self:startDailyNotification(""..pushInfo.id, pushInfo.desc, pushInfo.date, false)
    end
end

function SettingManager:startDailyNotification(key, desc, eventdate , open)
    local nowTime   = os.time()
    local date    = os.date("*t", os.time())
    local nextDate  = getDateByString(eventdate)

    -- 把当前的事件置为每天的目标时间
    date.hour = nextDate.hour
    date.min  = nextDate.min
    date.sec  = nextDate.sec

    local nextTime  = os.time(date)
    if nowTime >= nextTime then -- 今日目的时间已过, 明天再执行
        nextTime = 24 * 3600 + nextTime
    end
    -- if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        if TFPushServer then
          if open then
              TFPushServer.setLocalTimer(nextTime, desc, key)
          else
              TFPushServer.cancelLocalTimer(nextTime, desc, key)
          end
        end
    -- end
end

function SettingManager:getConfigPushById( id )
    return self.settingConfig.pushSwitch[id]
end

function SettingManager:getPushList(index)
    if index == nil then
        return self.pushList
    else
        return self.pushList:objectByID(index)
    end
end

function SettingManager:isShowPlayer()
    return self:getConfigPushById(EnumPushSwitchType.Show_Player)
end

function SettingManager:getTequanId()
    --在t_s_events中的id
    return 6
end

function SettingManager:changeIsOpenMusic()
    if self.settingConfig.isOpenMusic == 1 then
        self.settingConfig.isOpenMusic = 0
    else
        self.settingConfig.isOpenMusic = 1
    end
    
    TFAudio.setMusicVolume((self.settingConfig.isOpenMusic == 1 and 0.6) or 0.0)
    self:saveConfigByKeyVaule("isOpenMusic", self.settingConfig.isOpenMusic)

    if self.settingConfig.isOpenMusic == 1 then
        toastMessage(localizable.SettingManager_music_open)
    else
        toastMessage(localizable.SettingManager_music_close)
    end

    self:sendSettingSaveConfig()
end

function SettingManager:changeIsOpenVolume()
    if self.settingConfig.isOpenVolume == 1 then
        self.settingConfig.isOpenVolume = 0
    else
        self.settingConfig.isOpenVolume = 1
    end
    TFAudio.setEffectsVolume(self.settingConfig.isOpenVolume == 1 and 1 or 0.0)
    self:saveConfigByKeyVaule("isOpenVolume", self.settingConfig.isOpenVolume)

    if self.settingConfig.isOpenVolume == 1 then
        toastMessage(localizable.SettingManager_effect_open)
    else
        toastMessage(localizable.SettingManager_effect_close)
    end

    self:sendSettingSaveConfig()
end

function SettingManager:showSettingLayer()
	AlertManager:addLayerToQueueAndCacheByFile("lua.logic.setting.SettingLayer",AlertManager.BLOCK_AND_GRAY_CLOSE)
    AlertManager:show()
end

function SettingManager:showExchangeLayer()
    AlertManager:addLayerByFile("lua.logic.setting.ExchangeLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    AlertManager:show();
end

---------------------------玩家评论界面
function SettingManager:openJump1Layer()
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.jump.Jump1Layer",AlertManager.BLOCK_AND_GRAY)
        AlertManager:show()
    end  
end

function SettingManager:openJump2Layer()
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.jump.Jump2Layer",AlertManager.BLOCK_AND_GRAY)
    AlertManager:show()
end

return SettingManager:new()



