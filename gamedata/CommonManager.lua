--[[
******公共管理类*******

    -- by haidong.gan
    -- 2013/12/27
]]

local CommonManager = class("CommonManager")

CommonManager.TryReLoginFailTimes = 0

CommonManager.TRY_RECONNECT_NET        = "CommonManager.TRY_RECONNECT_NET"    --网络重连

local RECONNECT_MAX_COUNT = 30
local HEART_BEAT_TIME = 25

function CommonManager:ctor()
    TFDirector:addProto(s2c.UPDATE_PLAYER_NAME_RESULT, self, self.onReNameCom)
    TFDirector:addProto(s2c.RE_CONNECT_START, self, self.onReconnectSta)
    TFDirector:addProto(s2c.RE_CONNECT_COMPLETE, self, self.onReconnectCom)
    -- TFDirector:addProto(s2c.BUY_TIME_RESULT, self, self.onReceiveReplyResult)
    TFDirector:addProto(s2c.RELOGON_NOTIFY, self, self.onReloginNotify)
    TFDirector:addProto(s2c.HEART_BEAT_RESULT, self, self.onHeartBeat)
end

--心跳
function CommonManager:onHeartBeat(event)
    -- print("*****HeartBeat*****",event.data.idx)
end

function CommonManager:startHeartBeat()
    print("*****CommonManager:startHeartBeat*****")
    local tid,func = nil,nil
    self.idx = 0
    func = function ( ... )
        self.idx = self.idx + 1
        if self.idx > 2147483647 then self.idx = 1 end
        TFDirector:send(c2s.HEART_BEAT, { self.idx } )
    end
    tid = TFDirector:addTimer(HEART_BEAT_TIME * 60000, -1, nil, func)
    self.HBtid = tid
    self.HBfunc = func
end

function CommonManager:stopHeartBeat()
    print("*****CommonManager:stopHeartBeat*****")
    self.idx = 0
    TFDirector:removeTimer(self.HBtid)
    self.HBtid = nil
    self.HBfunc = nil
end

-- function CommonManager:onReceiveReplyResult( event )
--     print("onReceiveReplyResult")

--     hideLoading();
--     -- toastMessage("购买成功！");
--     toastMessage(localizable.common_buy_suc)

--     AlertManager:close();
-- end

function CommonManager:reply(type)
    showLoading();
    TFDirector:send(c2s.BUY_CHALLENGE_TIMES, { type,1 } );
end

function CommonManager:restart()

end

function CommonManager:showReplyLayer(type, isadd)
        if isadd == nil then
            isadd = true;
        end
        
        local timesInfo = MainPlayer:GetChallengeTimesInfo(type);
        local resConfigure = PlayerResConfigure:objectByID(type)
   
        if type == EnumRecoverableResType.PUSH_MAP then
            local item = ItemData:objectByID( 30010 );
            local num = BagManager:getItemNumById( 30010 );
            if num > 0 then
                local layer = self:showOperateSureLayer(
                        function()
                            BagManager:useBatchItem( item.id,num )
                            -- toastMessage("体力增加" .. item.usable * num)
                            toastMessage(stringUtils.format(localizable.CommonManager_tili_zengjia, item.usable * num))
                        end,
                        nil,
                        {
                        uiconfig = "lua.uiconfig_mango_new.common.UseCoinComfirmLayer",
                        -- title = item.name .. num .. "个",
                        -- msg = "可兑换" .. item.usable * num
                        title = stringUtils.format(localizable.CommonManager_good_num_desc, item.name, num),
                        msg = stringUtils.format(localizable.CommonManager_good_duihuan, item.usable * num)
                        
                        }
                )
                local img1 = TFDirector:getChildByPath(layer, 'img1');
                local img2 = TFDirector:getChildByPath(layer, 'img2');
      
                img1:setTexture(item:GetPath());
                img2:setTexture(GetResourceIconForGeneralHead(HeadResType.PUSH_MAP))
                return;
            end   

            local item = ItemData:objectByID( 30018 );
            local num = BagManager:getItemNumById( 30018 );
            if num > 0 then
                local layer = self:showOperateSureLayer(
                        function()
                            BagManager:useBatchItem( item.id,num )
                            --toastMessage("体力增加" .. item.usable * num)
                            toastMessage(stringUtils.format(localizable.CommonManager_tili_zengjia, item.usable * num))
                        end,
                        nil,
                        {
                        uiconfig = "lua.uiconfig_mango_new.common.UseCoinComfirmLayer",
                        --title = item.name .. num .. "个",
                        --msg = "可兑换" .. item.usable * num
                        title = stringUtils.format(localizable.CommonManager_good_num_desc, item.name, num),
                        msg = stringUtils.format(localizable.CommonManager_good_duihuan, item.usable * num)
                        }
                )
                local img1 = TFDirector:getChildByPath(layer, 'img1');
                local img2 = TFDirector:getChildByPath(layer, 'img2');
    
                img1:setTexture(item:GetPath());
                img2:setTexture(GetResourceIconForGeneralHead(HeadResType.PUSH_MAP))
                return;
            end   

            --vip限制功能
            if MainPlayer:getVipLevel() < ConstantData:getValue("Challenge.Time.Chapter.NeedVIP") then
                self:showOperateSureLayer(
                        function()
                            PayManager:showPayLayer();
                        end,
                        nil,
                        {
                        --title = isadd and "提升VIP" or "体力不足",
                        title = isadd and localizable.CommonManager_vip_up or localizable.CommonManager_tili_not_enough,
                        -- msg = "VIP" .. ConstantData:getValue("Challenge.Time.Chapter.NeedVIP") .. "方可购买体力。",
                        --msg = "VIP" .. ConstantData:getValue("Challenge.Time.Chapter.NeedVIP") .. "方可购买体力。\n\n是否前往充值？",
                        msg = stringUtils.format(localizable.CommonManager_need_vip, ConstantData:getValue("Challenge.Time.Chapter.NeedVIP")),
                        uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                        }
                )
                return;

            else
                if timesInfo.dailyMaxBuyTimes - timesInfo.dailyBuyTimes < 1 then
                    --判断是否有没有更高的vip能够增加购买次数
                    local nextUpVip = VipData:getVipNextAddValueVip(2000,MainPlayer:getVipLevel())
                    if nextUpVip then
                        -- local msg = "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可购买" .. nextUpVip.benefit_value .. "次。";
                        --local msg = "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可购买" .. nextUpVip.benefit_value .. "次。\n\n是否前往充值？";
                        local msg = stringUtils.format(localizable.CommonManager_need_up_vip, nextUpVip.vip_level, nextUpVip.benefit_value)
                        self:showOperateSureLayer(
                                function()
                                    PayManager:showPayLayer();
                                end,
                                nil,
                                {
                                --title =  isadd and "购买次数已用完" or "体力不足",
                                title =  isadd and localizable.CommonManager_out_time or localizable.CommonManager_tili_not_enough,
                                msg = msg,
                                uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                                }
                        )
                    else
                        if isadd then
                            --toastMessage("今日购买次数已用完");
                            toastMessage(localizable.CommonManager_out_time_today);
                        else
                            --toastMessage("体力不足，今日购买次数已用完");
                            toastMessage(localizable.CommonManager_out_time_today2)
                        end
                    end
                    return;
                end

            end
        end

        if type == EnumRecoverableResType.CLIMB then
            local item = ItemData:objectByID( 30014 );
            local num = BagManager:getItemNumById( 30014 );
            if num > 0 then
                local layer = self:showOperateSureLayer(
                        function()
                            BagManager:useBatchItem( item.id,num )
                            --toastMessage("无量山石增加" .. item.usable * num)
                            toastMessage(stringUtils.format(localizable.CommonManager_wuliangshanshi_add, item.usable * num))
                        end,
                        nil,
                        {
                        uiconfig = "lua.uiconfig_mango_new.common.UseCoinComfirmLayer",
                        --title = item.name .. num .. "个",
                        title = localizable.format(localizable.CommonManager_good_num_desc, item.name, num),
                        --msg = "可兑换" .. item.usable * num
                        msg = stringUtils.format(localizable.CommonManager_good_duihuan, item.usable * num)
                        }
                )
                local img1 = TFDirector:getChildByPath(layer, 'img1');
                local img2 = TFDirector:getChildByPath(layer, 'img2');
      
                img1:setTexture(item:GetPath());
                img2:setTexture(GetResourceIconForGeneralHead(HeadResType.CLIMB))
                return;
            end   

            --vip限制功能
            if MainPlayer:getVipLevel() < ConstantData:getValue("Challenge.Time.Climb.NeedVIP") then
                self:showOperateSureLayer(
                        function()
                            PayManager:showPayLayer();
                        end,
                        nil,
                        {
                        --title =  isadd and "提升VIP" or "无量山石不足",
                        title = isadd and localizable.CommonManager_vip_up or localizable.CommonManager_wuliangshanshi_not_enough,
                        -- msg = "VIP" .. ConstantData:getValue("Challenge.Time.Climb.NeedVIP") .. "方可购买无量山石。",
                        --msg = "VIP" .. ConstantData:getValue("Challenge.Time.Climb.NeedVIP") .. "方可购买无量山石。\n\n是否前往充值？",
                        msg = stringUtils.format(localizable.CommonManager_need_vip2, ConstantData:getValue("Challenge.Time.Climb.NeedVIP")),
                        uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                        }
                )  
                return;
            else
                --判断是否有没有更高的vip能够增加购买次数
                if timesInfo.dailyMaxBuyTimes - timesInfo.dailyBuyTimes < 1 then
                    local nextUpVip = VipData:getVipNextAddValueVip(2002,MainPlayer:getVipLevel())
                    if nextUpVip then
                        -- local msg = "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可购买" .. nextUpVip.benefit_value .. "次。";
                        --local msg = "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可购买" .. nextUpVip.benefit_value .. "次。\n\n是否前往充值？";
                        local msg = stringUtils.format(localizable.CommonManager_need_up_vip, nextUpVip.vip_level, nextUpVip.benefit_value)
                        self:showOperateSureLayer(
                                function()
                                    PayManager:showPayLayer();
                                end,
                                nil,
                                {
                                --title =  isadd and "购买次数已用完" or "量山石不足",
                                title = isadd and localizable.CommonManager_out_time or localizable.CommonManager_wuliangshanshi_not_enough,
                                msg = msg,
                                uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                                }
                        )
                    else
                        if isadd then
                            --toastMessage("今日购买次数已用完");
                            toastMessage(localizable.CommonManager_out_time_today);
                        else
                            --toastMessage("无量山石不足，今日购买次数已用完");
                            toastMessage(localizable.CommonManager_out_time_today3);
                        end
                    end
                    return;
                end
            end
        end

        if type == EnumRecoverableResType.QUNHAO then
            local item = ItemData:objectByID( 30011 );
            local num = BagManager:getItemNumById( 30011 );
            if num > 0 then
                local layer = self:showOperateSureLayer(
                        function()
                            BagManager:useBatchItem( item.id,num )
                            --toastMessage("挑战令增加" .. item.usable * num)
                            toastMessage(stringUtils.format(localizable.CommonManager_challenge_increase , item.usable * num))
                        end,
                        nil,
                        {
                        uiconfig = "lua.uiconfig_mango_new.common.UseCoinComfirmLayer",
                        --title = item.name .. num .. "个",
                        title = stringUtils.format(localizable.CommonManager_good_num_desc, item.name, num),
                        --msg = "可兑换" .. item.usable * num
                        msg = stringUtils.format(localizable.CommonManager_good_duihuan, item.usable * num)
                        }
                )
                local img1 = TFDirector:getChildByPath(layer, 'img1');
                local img2 = TFDirector:getChildByPath(layer, 'img2');
      
                img1:setTexture(item:GetPath());
                img2:setTexture(GetResourceIconForGeneralHead(HeadResType.QUNHAO))
                return;
            end   
            --vip限制功能
            if MainPlayer:getVipLevel() < ConstantData:getValue("Challenge.Time.Herolist.NeedVIP") then
                self:showOperateSureLayer(
                        function()
                            PayManager:showPayLayer();
                        end,
                        nil,
                        {
                        --title = isadd and "提升VIP" or "挑战令不足",
                        title = isadd and localizable.CommonManager_vip_up or localizable.CommonManager_challenge_not_enough,
                        -- msg = "VIP" .. ConstantData:getValue("Challenge.Time.Herolist.NeedVIP") .. "方可购买挑战令。",
                        --msg = "VIP" .. ConstantData:getValue("Challenge.Time.Herolist.NeedVIP") .. "方可购买挑战令。\n\n是否前往充值？",
                        msg = stringUtils.format(localizable.CommonManager_need_vip3, ConstantData:getValue("Challenge.Time.Herolist.NeedVIP")),
                        uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                        }
                ) 
                return;
            else
                --判断是否有没有更高的vip能够增加购买次数
                if timesInfo.dailyMaxBuyTimes - timesInfo.dailyBuyTimes < 1 then
                    local nextUpVip = VipData:getVipNextAddValueVip(2001,MainPlayer:getVipLevel())
                    if nextUpVip then
                        -- local msg = "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可购买" .. nextUpVip.benefit_value .. "次。";
                        --local msg = "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可购买" .. nextUpVip.benefit_value .. "次。\n\n是否前往充值？";
                        local msg = stringUtils.format(localizable.CommonManager_need_up_vip, nextUpVip.vip_level, nextUpVip.benefit_value)
                        self:showOperateSureLayer(
                                function()
                                    PayManager:showPayLayer();
                                end,
                                nil,
                                {
                                --title =   isadd and "购买次数已用完" or "挑战令不足",
                                title = isadd and localizable.CommonManager_out_time or localizable.CommonManager_challenge_not_enough,
                                msg = msg,
                                uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                                }
                        )
                    else
                        if isadd then
                            --toastMessage("今日购买次数已用完");
                            toastMessage(localizable.CommonManager_out_time_today)
                        else
                            --toastMessage("挑战令不足，今日购买次数已用完");
                            toastMessage(localizable.CommonManager_out_time_today4)
                        end
                    end
                    return;
                end
            end
        end
        if type == EnumRecoverableResType.SKILL_POINT then
            --vip限制功能
            if MainPlayer:getVipLevel() < ConstantData:getValue("Challenge.Time.Skill.NeedVIP") then
                self:showOperateSureLayer(
                        function()
                            PayManager:showPayLayer();
                        end,
                        nil,
                        {
                        --title =  isadd and "提升VIP" or "技能点不足",
                        title = isadd and localizable.CommonManager_vip_up or localizable.CommonManager_skillpoint_not_enough,
                        -- msg = "VIP" .. ConstantData:getValue("Challenge.Time.Skill.NeedVIP") .. "方可使用元宝购买技能点。",
                        --msg = "VIP" .. ConstantData:getValue("Challenge.Time.Skill.NeedVIP") .. "方可使用元宝购买技能点。\n\n是否前往充值？",
                        msg = stringUtils.format(localizable.CommonManager_need_vip4, ConstantData:getValue("Challenge.Time.Skill.NeedVIP")),
                        uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                        }
                ) 
                return;
            else
                --判断是否有没有更高的vip能够增加购买次数
                if timesInfo.dailyMaxBuyTimes - timesInfo.dailyBuyTimes < 1 then
                    local nextUpVip = VipData:getVipNextAddValueVip(2004,MainPlayer:getVipLevel())
                    if nextUpVip then
                        -- local msg = "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可使用元宝购买" .. nextUpVip.benefit_value .. "次。";
                        --local msg = "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可使用元宝购买" .. nextUpVip.benefit_value .. "次。\n\n是否前往充值？";
                        local msg = stringUtils.format(localizable.CommonManager_need_up_vip2, nextUpVip.vip_level, nextUpVip.benefit_value)
                        self:showOperateSureLayer(
                                function()
                                    PayManager:showPayLayer();
                                end,
                                nil,
                                {
                                --title = isadd and "购买次数已用完" or "技能点不足",
                                title = isadd and localizable.CommonManager_out_time or localizable.CommonManager_skillpoint_not_enough,
                                msg = msg,
                                uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                                }
                        )
                    else
                        if isadd then
                            --toastMessage("今日购买次数已用完");
                            toastMessage(localizable.CommonManager_out_time_today)
                        else
                            --toastMessage("技能点不足，今日购买次数已用完");
                            toastMessage(localizable.CommonManager_out_time_today5)
                        end
                    end
                    return;
                end
            end
        end

    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.ReplyLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
    layer:setType(type,isadd);
    AlertManager:show()
end


function CommonManager:showErrorLayer(msg)
   local layer = self:showOperateSureLayer(
            function()
                restartLuaEngine()
                -- SettingManager:gotoUpdateLayer()
            end,
            nil,
            {
            --title = "出错啦",
            title = localizable.common_wrong,

            --msg = "这位大侠，游戏好像傲娇了，你只要轻轻点击“重新登录”就好啦。",
            msg = localizable.CommonManager_relogin,
            --okText = "重新登录",
            okText = localizable.common_relogin,
            showtype = AlertManager.BLOCK_AND_GRAY,
            uiconfig = "lua.uiconfig_mango_new.common.OperateSure2"
            }
    )
   layer.isCanNotClose = true;
end
function CommonManager:showFightPluginErrorLayer()
    local systemVersion = TFDeviceInfo.getSystemVersion() or "NULL"
    if systemVersion == "6.0" then
        return
    end
    self.showPluginTime = self.showPluginTime or 0
    if self.showPluginTime > 0 then
        return
    end
    self.showPluginTime = self.showPluginTime + 1
    local pluginTimer = TFDirector:addTimer(1000,1,nil,function ()
        TFDirector:removeTimer(pluginTimer)
        pluginTimer = nil
        TFDirector:pause()
    end)

    local machineName = TFDeviceInfo.getMachineName() or "NULL"
    local systemName = TFDeviceInfo.getSystemName() or "NULL"
    local deviceId = TFDeviceInfo.getMachineOnlyID() or "NULL"
    local str = "machineName = "..machineName..",systemName = "..systemName..",systemVersion ="..systemVersion..",deviceId = "..deviceId
    ErrorCodeManager:reportErrorMsg(str)

    local layer = self:showOperateSureLayer(
            function()
                if pluginTimer then
                    TFDirector:removeTimer(pluginTimer)
                    pluginTimer = nil
                end
                    self.showPluginTime = 0

                    AlertManager:clearAllCache()
                    CommonManager:closeConnection()
                    restartLuaEngine("CompleteUpdate")

            end,
            nil,
            {
            title = localizable.common_wrong, --"出错啦",
            -- msg = TFLanguageManager:getString(ErrorCodeData.illegal_Third_party),--"这位大侠，游戏好像傲娇了，你只要轻轻点击“重新登录”就好啦。",
            msg = localizable.illegal_Third_party,--"这位大侠，游戏好像傲娇了，你只要轻轻点击“重新登录”就好啦。",
            okText = localizable.common_relogin, --"重新登录",
            showtype = AlertManager.BLOCK_AND_GRAY,
            uiconfig = "lua.uiconfig_mango_new.common.OperateSure2"
            }
    )
   layer.isCanNotClose = true;
end

function CommonManager:showNeedUpdateLayer(clientViesion,serverViesion)
    local layer = self:showOperateSureLayer(
            function()
                SettingManager:gotoUpdateLayer()
            end,
            nil,
            {
            --title = "更新资源啦",
            title = localizable.CommonManager_update_version1,
            --msg = "更新资源啦，\n\n当前版本：" .. clientViesion .. ";最新版本：" .. serverViesion,
            msg = stringUtils.format(localizable.CommonManager_update, clientViesion, serverViesion),
            --okText = "立即更新",
            okText = localizable.CommonManager_update_now,
            showtype = AlertManager.BLOCK_AND_GRAY,
            uiconfig = "lua.uiconfig_mango_new.common.OperateSure2"
            }
    )
    layer.isCanNotClose = true;
end

function CommonManager:checkServerVersion(serverViesion)
    if TF_DEBUG_UPDATE_FLAG == 1 or CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
        return true;
    end
    
    local clientViesion = TFClientUpdate:getCurVersion();

    print("clientViesion",clientViesion)
    print("serverViesion",serverViesion)

    if serverViesion == "" or  serverViesion == nil then
        return true;
    end

    if clientViesion < serverViesion then
        self:showNeedUpdateLayer(clientViesion,serverViesion);
        return false;
    end
    
    return true;
end

function CommonManager:showNeedGemComfirmLayer()
    self:showOperateSureLayer(
            function()
                MallManager:openMallLayer()
            end,
            nil,
            {
            uiconfig = "lua.uiconfig_mango_new.common.NeedGemComfirmLayer",
            }
    )

end

function CommonManager:showNeedRoleComfirmLayer()
    self:showOperateSureLayer(
            function()
                -- MallManager:openMallLayer()
                MallManager:openRecruitLayer()
            end,
            nil,
            {
            uiconfig = "lua.uiconfig_mango_new.common.NeedRoleComfirmLayer",
            }
    )

end

function CommonManager:showNeedEquipComfirmLayer()
    self:showOperateSureLayer(
            function()
                MissionManager:showHomeLayer()
            end,
            nil,
            {
            uiconfig = "lua.uiconfig_mango_new.common.NeedEquipComfirmLayer",
            }
    )
end
function CommonManager:showNeedCoinComfirmLayer()
    local item = ItemData:objectByID( 30003 );
    local num = BagManager:getItemNumById( 30003 );
    if num > 0 then
        BagManager:useItem( 30003 ,false)
    else
        -- self:showBuyCoinComfirmLayer()
        self:showBuyCoinLayer()
    end
end

function CommonManager:showBuyCoinComfirmLayer()
    local item = ItemData:objectByID( 30003 );
     MallManager:openItemShoppingLayer(30003,
    function()
        local num = BagManager:getItemNumById( 30003 );
        self:showOperateSureLayer(
                function()
                    BagManager:useBatchItem( item.id,num )
                end,
                nil,
                {
                uiconfig = "lua.uiconfig_mango_new.common.BuyCoinResultLayer",
                --title = num .. "个",
                title = stringUtils.format(localizable.CommonManager_number, num),
                --msg = "可兑换" ..  item.usable * num
                msg = stringUtils.format(localizable.CommonManager_good_duihuan , item.usable * num)
                }
        )

    end,true);
end

function CommonManager:showOperateSureLayer(okhandle,cancelhandle,param)

    local flieName = "lua.logic.common.OperateSure"
    -- local _layer = AlertManager:getLayerByName( flieName )
    -- if  _layer ~= nil then
    --     AlertManager:closeLayer(_layer)
    -- end
    param = param or {}

    param.showtype = param.showtype or AlertManager.BLOCK_AND_GRAY_CLOSE
    param.tweentype = param.tweentype or AlertManager.TWEEN_1

    param.uiconfig = param.uiconfig or "lua.uiconfig.common.OperateSure"


    local layer = AlertManager:addLayerByFile(flieName,param.showtype,param.tweentype)
    layer.toScene = Public:currentScene()
    layer:setUIConfig(param.uiconfig)

    layer:setBtnHandle(okhandle, cancelhandle)
    layer:setData(param.data)
    layer:setTitle(param.title)
    layer:setMsg(param.msg)
    layer:setTitleImg(param.titleImg)

    layer:setBtnOkText(param.okText)
    layer:setBtnCancelText(param.cancelText)

    AlertManager:show()

    return layer
end

function CommonManager:showOperateSureTipLayer(okhandle,cancelhandle,param)
    param = param or {}

    param.showtype = param.showtype or AlertManager.BLOCK_AND_GRAY_CLOSE;
    param.tweentype = param.tweentype or AlertManager.TWEEN_1;

    param.uiconfig = param.uiconfig or "lua.uiconfig_mango_new.common.OperateSureTip";


    local layer = AlertManager:addLayerByFile("lua.logic.common.OperateSureTip",param.showtype,param.tweentype);
    layer.toScene = Public:currentScene();

    layer:setUIConfig(param.uiconfig);

    layer:setBtnHandle(okhandle, cancelhandle);
    layer:setData(param.data);
    layer:setTitle(param.title);
    layer:setMsg(param.msg);
    layer:setTitleImg(param.titleImg);

    layer:setBtnOkText(param.okText);
    layer:setBtnCancelText(param.cancelText);

    AlertManager:show()

    return layer;
end

function CommonManager:addLayerToCache()

end

function CommonManager:addLayerToCache()

end



--[[
更新控件状态，包括是否开放，点击时的提示信息绑定，是否显示红点
@widget UI控件
@functionId 功能ID，详情查看function_offset表 、t_s_functionopen表定义
@visiable 红点是否可见
]]
function CommonManager:updateRedPointWithState(widget,visiable,functionId,manualOffest)
    --未开启，没有红点
    local can_jump = JumpToManager:isCanJump(functionId)
    if not can_jump then
        visiable = false
    end
    
    local offset = nil
    if not functionId then
        self:updateRedPoint(widget,visiable,offset)
        return
    end
    local func_offset = FunctionData:objectByID(functionId)
    if func_offset then offset = ccp(func_offset.offsetX, func_offset.offsetY) end
    
    local configure = FunctionOpenConfigure:objectByID(functionId)
    if not configure then
        self:updateRedPoint(widget,visiable,offset)
        return
    end

    if manualOffest then
        offset = manualOffest
    end

    -- if PlayerGuideManager.bOpenGuide == false then
    --     self:updateRedPoint(widget,visiable,offset)
    --     return
    -- end 

    local teamLevel = MainPlayer:getLevel()
    local missionId = configure.mission_id
    configure.level = configure.level or 0

    local clickCallback = widget:getMEListener(TFWIDGET_CLICK)
    local function _addListener()
        if clickCallback and widget then
            widget:removeMEListener(TFWIDGET_CLICK)
            TFFunction.call(clickCallback, widget)
            widget:addMEListener(TFWIDGET_CLICK, clickCallback)
        end
    end
    -- print("CommonManager:updateWidgetState : ",teamLevel,configure.level)
    if configure.level > teamLevel then --功能没有达到开放条件
        local function showNotEnoughTeamLevelTips()
            -- toastMessage('此功能在团队等级达到[' .. configure.level .. ']后开放')
            if configure.level <= MainPlayer:getLevel() then
                _addListener()
            else
                toastMessage(stringUtils.format(localizable.common_function_openlevel, configure.level, configure.desc))
                if widget.changeBtnStateToNormal then
                    widget:changeBtnStateToNormal()
                end
            end
        end
        widget:removeMEListener(TFWIDGET_CLICK)       --移除原来的监听方法
        --绑定点击监听方法
        widget:addMEListener(TFWIDGET_CLICK, audioClickfun(showNotEnoughTeamLevelTips, play_tishi),1)

        --设置控件为上锁状态
        --widget:setGrayEnabled(true)
    elseif missionId ~= nil and missionId ~= 0 and MissionManager:getStarLevelByMissionId(missionId) == 0 then
        local function showNotEnoughMissionTips()
            if MissionManager:getStarLevelByMissionId(missionId) ~= 0 then
                _addListener()
            else
                local mission = MissionData:objectByID(missionId)
                -- local chapter = ChapterData:objectByID(mission.chapter)

                local str = mission.brief
                toastMessage(stringUtils.format(localizable.commom_function_openmission, str, configure.desc))
                if widget.changeBtnStateToNormal then
                    widget:changeBtnStateToNormal()
                end
            end
        end
        widget:removeMEListener(TFWIDGET_CLICK)       --移除原来的监听方法
        --绑定点击监听方法
        widget:addMEListener(TFWIDGET_CLICK, audioClickfun(showNotEnoughMissionTips, play_tishi),1)
    else
        --widget:setGrayEnabled(false)
        if widget.clickCallback then                    --如果控件原来绑定了点击回调事件重新绑定一下，依赖使用者自己赋值
            widget:addMEListener(TFWIDGET_CLICK, clickCallback)
        end
        self:updateRedPoint(widget,visiable,offset)
    end
end

--[[
更新红点状态
@widget UI控件
@visiable 红点是否可见
@offset 红点的相对于UI控件的偏移坐标
]]
function CommonManager:updateRedPoint(widget,visiable,offset)
    if not visiable then
        self:removeRedPoint(widget)
        return
    end

    self:addRedPoint(widget,offset)
end

--[[
删除控件的红点
@widget UI控件
]]
function CommonManager:removeRedPoint(widget)
    if not widget then
        return
    end

    local redPoint = widget:getChildByName("RedPoint")
    if not redPoint then
        return
    end
    redPoint:setVisible(false);
end

--[[
往控件添加红点
@widget UI控件
@offset 红点的相对于UI控件的偏移坐标
]]
function CommonManager:addRedPoint(widget,offset)
    if not widget then
        return
    end

    local redPoint = widget:getChildByName("RedPoint")
    if redPoint then
        redPoint:setVisible(true)
        -- redPoint:stop()
        -- redPoint:resume()
    else
        -- local redPoint = GameResourceManager:getEffectAniById("redPoint",1, 1,"bofang")
        -- if not redPoint then return end 

        redPoint = TFImage:create("ui/common/icon_red.png")
        redPoint:setName("RedPoint") 
        offset = offset or ccp(10,10)
        local widgetSize = widget:getSize()
        local pointSize = redPoint:getSize()
        local pos = ccp(widgetSize.width/2 - pointSize.width/2 + offset.x ,widgetSize.height/2 - pointSize.width/2 + offset.y)
        redPoint:setPosition(pos)
        widget:addChild(redPoint,100)
    end
end


function CommonManager:setRedPoint(parent,isshow,key,offset,functionId)
    if parent then
        local redPoint = parent:getChildByName("RedPoint");
        if redPoint and redPoint.key == key then
            redPoint:removeFromParent();
        end

        if functionId == nil or (functionId and PlayerGuideManager:isFunctionOpen(functionId)) then
            if isshow then
                local redPoint = parent:getChildByName("RedPoint");
                if not redPoint then
                    redPoint = TFImage:create("ui/common/splats.png");
                    redPoint:setName("RedPoint");
                    redPoint.key = key;
                    
                    offset = offset or ccp(0,0);
                    local pos = ccp(parent:getSize().width/2 - redPoint:getSize().width/2 + offset.x ,parent:getSize().height/2 - redPoint:getSize().width/2 + offset.y);

                    redPoint:setPosition(pos);

                    parent:addChild(redPoint,100);
                else
                    redPoint:setVisible(isshow)
                    redPoint.key = key;
                end
                redPoint.isshow = isshow;
            end
        end
    end
end

function CommonManager:reName(name)
    showLoading();
    TFDirector:send(c2s.UPDATE_PLAYER_NAME, {name} );
end

function CommonManager:onReNameCom(event)
    -- print("CardRoleManager:onReNameCom" )
    -- print(event.data)
    hideLoading();
    --MainPlayer.name = event.data.name;
    --修改为设置玩家名称方法，以兼容以前代码
    print("---- onReNameCom---------",event.data)
    MainPlayer:setName(event.data.name)
    -- toastMessage("更名成功")
    toastMessage(localizable.CommonManager_change_name)

    AlertManager:close();

    if HeitaoSdk then
        HeitaoSdk.roleNameChanged(MainPlayer.name)
    end
end

--add by david.dai
--是否掉线自动重连
local autoConnect = true
--重登录累计次数
local reConnectServerSum = 0
--连接状态，0：无连接；1：连接活动中
local connection_status = 0
local disableDisconnectLayerShow = false

function CommonManager:closeConnection()
    print("[网络调试]: 关闭连接")
    self:stopHeartBeat()
    self:setAutoConnect(false)
    LoginManager.firstLoginMark = true
    disableDisconnectLayerShow = true
    TFDirector:closeSocket()
    connection_status = 0
    disableDisconnectLayerShow = false
end

function CommonManager:setAutoConnect(enabled)
    autoConnect = enabled
end

function CommonManager:loginServer()
    -- print("CommonManager:loginServer connection_status:", connection_status)
    if connection_status == 0 then
        print("[网络调试]: 准备开始连接,当前无连接")
        if autoConnect then
            self:connectServer(true)
        end
    else
        print("[网络调试]: 准备开始连接,当前有连接,无效")
    --     if LoginManager.firstLoginMark then
    --         self:sendLogin()
    --     else
    --         self:sendRelogin()
    --     end
    end
end

--连接服务器
function CommonManager:connectServer(requestLogin)
    print("**********& connectServer 1:", connection_status)
    if connection_status ~= 0 then
        return
    end
    
    local serverInfo = SaveManager:getCurrentSelectedServer()

    print("=============serverInfo",serverInfo)
    if serverInfo == nil then
        toastMessage(localizable.CommonManager_choose_server) --请选择服务器
        return
    end

    print("[网络调试]: 服务器信息", serverInfo)

    for i=1,100 do
        showLongLoading()
    end

    local addressTable = string.split(serverInfo.address,":")
    local ip = addressTable[1]
    local port = addressTable[2]

    print("[网络调试]: 准备开始连接服务器",ip,port)
    
    print("[网络调试]: 确保断开Socket")
    TFDirector:closeSocket()

    timeout(function()
        print("[网络调试]: 开始连接Socket")
        TFDirector:connect(ip, port, 
        function (nResult)
            self:connectHandle(nResult,requestLogin)
        end,
        nil,
        function (nResult)
            self:connectionClosedCallback(nResult)
        end)
    end, 0.5)
end

--连接打开的回调方法，当连接创建成功后会由系统调用此方法
function CommonManager:connectHandle(nResult,requestLogin)
    -- print("-- CommonManager:connectHandle nResult = ", nResult)
    -- print("-- CommonManager:connectHandle requestLogin = ", requestLogin)
    TFDirector:setEncodeKeys({ 0xad, 0x68, 0x37, 0xa2, 0xa0, 0x80, 0xdd, 0xf1 })
    if nResult then
        if nResult == 1 then
            print("[网络调试]: 连接Socket成功")
            connection_status = 1
            if requestLogin then
                if LoginManager.firstLoginMark then
                    print("[网络调试]: 开始登录")
                    self:sendLogin()
                else
                    print("[网络调试]: 开始重登")
                    self:sendRelogin()
                end
            end

            -- 网络重连时通知前端
            TFDirector:dispatchGlobalEventWith(CommonManager.TRY_RECONNECT_NET, {})
            
        -- 连接失败
        elseif nResult == -2 or nResult == -1 then
            print("[网络调试]: 连接Socket失败")

            if FightManager.fightBeginInfo then 
                local fightType = FightManager.fightBeginInfo.fighttype
--************************************************************************************todo!
                if FightManager.fightBeginInfo.bGuideFight == true and fightType == 1  then

                    print("[网络调试]: 连接Socket失败后,需要处理战斗")
                    toastMessage(localizable.common_net_wrong) --网络连接失败
                    FightManager:cleanFight(true)
                    AlertManager:clear()
                    -- AlertManager:changeSceneForce(SceneType.LOGIN)
                    AlertManager:changeScene(SceneType.LOGIN)
                    return
                end
            end

            local currentScene = Public:currentScene()
            if currentScene ~= nil and currentScene.getTopLayer then
                if currentScene:getTopLayer().__cname == "LoginNoticePage" then
                    print("[网络调试]: 连接Socket失败后,当前登录界面")
                    hideAllLoading()
                    toastMessage(localizable.common_net_wrong) --连接服务器失败

                -- 创建角色界面
                elseif currentScene:getTopLayer().__cname == "CreatePlayerNew" then
                    print("[网络调试]: 连接Socket失败后,当前创角界面")
                    hideAllLoading()
                    toastMessage(localizable.common_net_desc) --连接服务器失败,请检查你的网络稍后再试
                else
                    self:showDisconnectDialog()
                end
            else
                self:showDisconnectDialog()
            end

        -- elseif nResult == -1 then
        --     print("连接服务器失败111")
        end
        -- self.TryReLoginFailTimes = 0
    else
        self:showDisconnectDialog()
    end
end

function CommonManager:showDisconnectDialog()
    print("[网络调试]: 处理连接失败的提示")

    hideAllLoading()
    if LoginManager.firstLoginMark then
        if disableDisconnectLayerShow then
            print("[网络调试]: toast提示")
            toastMessage(localizable.common_net_wrong) --连接服务器失败
        end
    else
        local currentScene = Public:currentScene()
        if currentScene ~= nil and currentScene.getTopLayer and currentScene:getTopLayer().__cname == "ReconnectLayer" then
            if disableDisconnectLayerShow then
                print("[网络调试]: toast提示")
                toastMessage(localizable.common_net_wrong) --连接服务器失败
            end
        else
            self.TryReLoginFailTimes = self.TryReLoginFailTimes + 1
            if self.TryReLoginFailTimes >= RECONNECT_MAX_COUNT then
                print("[网络调试]: 超过最大重连次数,开始重启引擎")
                -- restartLuaEngine("CompleteUpdate")
                SettingManager:LoginOut()
            else
                print("[网络调试]: 弹框提示重连")
                self:showReconnectLayer()
            end
        end
    end
end

--发送登录服务器请求
function CommonManager:sendLogin()
    print("[网络调试]: 发起登录")
    -- MainPlayer:restart();
    for i=1,100 do
        showLongLoading()
    end

    local userInfo = SaveManager:getUserInfo()
    local token = getIOSDeviceTokens()
    if not token or token:len() < 1 then
        token = "NULL"
    end
    local machineName = TFDeviceInfo.getMachineName() or "NULL"
    local systemName = TFDeviceInfo.getSystemName() or "NULL"
    local systemVersion = TFDeviceInfo.getSystemVersion() or "NULL"
    local deviceId = TFDeviceInfo.getMachineOnlyID() or "NULL"
    local sdkVerison = "NULL"
    if TFPlugins.getSdkName() then
        sdkVerison = TFPlugins.getSdkVersion() or "NULL"
    end
    
        -- pc
    if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
        deviceId    = "Win32Simulator_001"
        sdkVerison  = "Win32Simulator_V1.0"
        systemName  = "Win32Simulator"
    end

    local validateCode = "LetMeIn!"
    if not IS_TEST_GAME then
        if userInfo.validateLoginTable and userInfo.validateLoginTable.token then
            validateCode = userInfo.validateLoginTable.token
        end
        validateCode = TFPlugins.getCheckServerToken() or validateCode
    end
    
    local account = TFPlugins.getUserID() or userInfo.userName or "NULL"
    local site = 0
    if userInfo.currentServer then
        site = tonumber(userInfo.currentServer)
    end
    local MCC = "NULL"
    local IP = "192.168.3.52"--"NULL"
    if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
        IP = "192.168.3.52"
    end
    local loginMsg =
    {
        account,
        validateCode,
        site,
        token,
        machineName,
        systemName,
        systemVersion,
        TFPlugins.getSdkName() or "NAN", --'168'
        TFPlugins.getSdkName() or "NAN",
        deviceId,           --设备ID唯一标识
        sdkVerison,         --SDK版本
        MCC,                --移动设备国家码
        IP                  --移动设备网络通信地址
    }
    print("[网络调试]: 发起登录,登录数据",loginMsg)
    --TFDirector:send(c2s.LOGIN, loginMsg , 1)    --rsa加密
    local nResult = TFDirector:send(c2s.LOGIN, loginMsg)    --不加密
    print("[网络调试]: 发起登录,调用登录结果",nResult)

    TFDirector:setEncodeKeys({1,2,3,4,5,6,7,8})
    if nResult and nResult < 0 then
        self:showDisconnectDialog()
        return
    end
end


--获取当前的连接状态，true为连接 false为掉线
function CommonManager:getConnectionStatus()
    local status = true
    if CC_TARGET_PLATFORM ~= CC_PLATFORM_WIN32 then
        -- if connection_status == 0 and LoginManager.bIsEnterGame == true then
        if connection_status == 0 then
            status = false
        end
    end
    
    return status
end


--连接关闭的回调方法，当连接关闭后会由系统调用此方法
function CommonManager:connectionClosedCallback(nResult)
    print("[网络调试]: Socket断开回调",nResult)

    connection_status = 0
    hideAllLoading()
    local currentScene = Public:currentScene()
        
    if currentScene ~= nil and currentScene.getTopLayer then
        local topLayer_cname = currentScene:getTopLayer().__cname
        if topLayer_cname == "CreatePlayerNew" or topLayer_cname == "LoginNoticePage" then
            print("[网络调试]: Socket断开回调,当前处在创角或者登录")
            return
        end
    end

    self.TryReLoginFailTimes = self.TryReLoginFailTimes+1

    if self.TryReLoginFailTimes >= 3 then
        print("[网络调试]: 自动重连几次,继续Socket断开回调")
        self:showDisconnectDialog()
        return
    end

    -- if nResult == 4 then
    --     -- autoConnect = false
    --     self:showDisconnectDialog()
    --     return
    -- end
    if  autoConnect then
        print("autoConnect is ture")
    end

    if disableDisconnectLayerShow then
        print("disableDisconnectLayerShow is ture")
    end

    if LoginManager.firstLoginMark  then
        print("LoginManager.firstLoginMark  is ture")
    end

    print("connection_status = ", connection_status)

    if autoConnect and self.TryReLoginFailTimes < 3 then
        print("[网络调试]: Socket断开回调,开始自动重连")
        self:loginServer()
    else
        print("[网络调试]: 自动重连几次,继续Socket断开回调")
        self:showDisconnectDialog()
    end
end

--发送重新连接请求到服务器
function CommonManager:sendRelogin()
    print("[网络调试]: 发起重登")
    for i=1,100 do
        showLongLoading()
    end

    local userInfo = SaveManager:getUserInfo()
    local token = getIOSDeviceTokens() or "NULL"
    local machineName = TFDeviceInfo.getMachineName() or "NULL"
    local systemName = TFDeviceInfo.getSystemName() or "NULL"
    local systemVersion = TFDeviceInfo.getSystemVersion() or "NULL"
    local deviceId = TFDeviceInfo.getMachineOnlyID() or "NULL"
    local sdkVerison = "NULL"
    if TFPlugins.getSdkName() then
        sdkVerison = TFPlugins.getSdkVersion() or "NULL"
    end

    -- pc
    if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
        deviceId    = "Win32Simulator_001"
        sdkVerison  = "Win32Simulator_V1.0"
        systemName  = "Win32Simulator"
    end

    local validateCode = "LetMeIn!"
    if not IS_TEST_GAME then
        if userInfo.validateLoginTable and userInfo.validateLoginTable.token then
            validateCode = userInfo.validateLoginTable.token
        end
        validateCode = TFPlugins.getCheckServerToken() or validateCode
    end
    
    local account = TFPlugins.getUserID() or userInfo.userName or "NULL"
     local site = 0
    if userInfo.currentServer then
        site = tonumber(userInfo.currentServer)
    end
    local MCC = "NULL"
    local IP = "NULL"
    local scene, chapterId, pos_x, pos_y = MainPlayer:getPlayerPos()
    local loginMsg =
    {
        account,
        validateCode,
        site,
        token,
        machineName,
        systemName,
        systemVersion,
        TFPlugins.getSdkName() or "NAN",
        TFPlugins.getSdkName() or "NAN",
        deviceId,        --设备ID唯一标识
        sdkVerison,      --SDK版本
        MCC,             --移动设备国家码
        IP,               --通信地址
        {scene, chapterId, pos_x, pos_y}
    }
    print("[网络调试]: 发起重登,重登数据",loginMsg)

    --TFDirector:send(c2s.RE_CONNECT_REQUEST, loginMsg , 1);  --rsa加密
    local nResult = TFDirector:send(c2s.RE_CONNECT_REQUEST, loginMsg);  --不加密
    TFDirector:setEncodeKeys({1,2,3,4,5,6,7,8})
    print("[网络调试]: 发起重登,调用重登结果",nResult)
    
    if nResult and nResult < 0 then
        self:showDisconnectDialog()
        return
    end
end

--function CommonManager:getuserName()
--    local configTbl = {}
--    configTbl.areaid = CCUserDefault:sharedUserDefault():getStringForKey("login_areaid");
--    configTbl.name = CCUserDefault:sharedUserDefault():getStringForKey("login_name");
--    return configTbl;
--end

function CommonManager:onReconnectSta(event)
    print("[网络调试]: 重登成功开始")

    local serverVersion  = event.data.resVersion
    local TFClientUpdate =  TFClientResourceUpdate:GetClientResourceUpdate()
    local version        =  TFClientUpdate:getCurVersion()

    print("[网络调试]: 检查资源版本号", "local version" .. version .. "server version" .. event.data.resVersion)
    if version~=serverVersion then
        print("[网络调试]: 有新资源要重启了...")
        SettingManager:backtoUpdate()
    end
end

function CommonManager:onReconnectCom(event)
    print("[网络调试]: 重登成功结束")
    hideAllLoading();
    -- if self:checkServerVersion(event.data.resVersion) then
        Public:currentScene():getBaseLayer():onShow();
        Public:currentScene():getBaseLayer():reShow();

        local currentScene = Public:currentScene()
        if currentScene ~= nil and currentScene.getTopLayer and currentScene:getTopLayer().__cname == "ReconnectLayer" then
            AlertManager:close();
        end

        TFDirector:dispatchGlobalEventWith(MainPlayer.RE_CONNECT_COMPLETE , {})
        PlayerGuideManager:doGuide()
    -- end
    self:startHeartBeat()
end

function CommonManager:showReconnectLayer()
    hideAllLoading()
    -- AlertManager:closeAll()
    TFWebView.removeWebView()
    --一键托管中断线重连取消一键托管   
    TFDirector:dispatchGlobalEventWith(MissionManager.OneKeyEnd)

    local layer = AlertManager:addLayerByFile("lua.logic.common.ReconnectLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE);
    layer.toScene = Public:currentScene();
    layer:setZOrder(111111)

    AlertManager:show();
end

function CommonManager:showReNameLayer()
    AlertManager:addLayerByFile("lua.logic.main.ReNameLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
    AlertManager:show();
end

function CommonManager:showLevelUpLayer(info)
    local layer = AlertManager:addLayerByFile("lua.logic.main.MainLevelUpLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
    layer:loadData(info)
    AlertManager:show();
end

function CommonManager:onReloginNotify( event )
    print("[网络调试]: 重复登录通知")
    hideAllLoading();

    autoConnect = false
    -- local layer = self:showOperateSureLayer(
    --     function()
    --         LoginManager.firstLoginMark = true
    --         AlertManager:clear()
    --         AlertManager:changeSceneForce(SceneType.LOGIN)
    --     end,
    --     nil,
    --     {
    --         msg = localizable.CommonManager_other_user_login, -- "您的账号在别处登录！重新登录？",
    --         showtype = AlertManager.BLOCK_AND_GRAY,
    --         tweentype = AlertManager.TWEEN_NONE,
    --         okText = localizable.common_relogin, -- "重新登录",
    --         -- cancelText = "更换账号",
    --         uiconfig = "lua.uiconfig_mango_new.common.OperateSure2"
    --     }
    -- )

    -- layer.__cname = "ReconnectLayer";
    -- layer.isCanNotClose = true
    -- self.TryReLoginFailTimes = 0
end

function CommonManager:addGeneralHead( logic ,zOrder)
    zOrder = zOrder or 1;
    local generalHead    = require('lua.logic.common.GeneralHead'):new()
    generalHead:setLogic(logic)
    generalHead:setPosition(ccp(0,0))
    generalHead:setZOrder(zOrder)

    local panel_head      = TFDirector:getChildByPath(logic, 'panel_head');
    panel_head:addChild(generalHead)

    return generalHead;
end

function CommonManager:addGodPetCard( godPet, parent, pos, zOrder )
    zOrder = zOrder or 1;
    pos = pos or ccp(0,0)
    local godPetCard = require('lua.logic.shenchong.ShenChongCardLayer'):new(godPet)
    godPetCard:setPosition(pos)
    godPetCard:setZOrder(zOrder)
    parent:addChild(godPetCard)
    return godPetCard;
end

function CommonManager:addTaskMainLayer( logic ,zOrder)
    zOrder = zOrder or 1;
    local taskMainLayer    = require('lua.logic.common.TaskMainLayer'):new()
    taskMainLayer:setLogic(logic)
    taskMainLayer:setPosition(ccp(0,0))
    taskMainLayer:setZOrder(zOrder)
    taskMainLayer:setName("TaskMainLayer")

    local panel_task      = TFDirector:getChildByPath(logic, 'panel_task');
    panel_task:addChild(taskMainLayer)

    return taskMainLayer;
end

function CommonManager:addMessageLayer( logic ,zOrder)
    zOrder = zOrder or 1111;
    local messageLayer    = require('lua.logic.common.MessageLayer'):new()
    messageLayer:setLogic(logic)
    messageLayer:setPosition(ccp(0,0))
    messageLayer:setZOrder(zOrder)

    -- local panel_head      = TFDirector:getChildByPath(logic, 'panel_head');
    logic.ui:addChild(messageLayer)

    return messageLayer;
end

function CommonManager:addGamePlayer()
    local gamePlayer = require('lua.gamedata.MainRoleRunManager'):new()
    return gamePlayer
end

function CommonManager:loadLevelAndPowerInfo(logic)
    local panel_head = TFDirector:getChildByPath(logic, 'panel_head')
    local txtPower = TFDirector:getChildByPath(panel_head, 'txt_zhanli_num')
    txtPower:setText(FormationManager:calcFormationPower(EnumFormationType.PVE))
    local txtLevel = TFDirector:getChildByPath(panel_head, 'txt_name')
    txtLevel:setText(MainPlayer:getLevel() .. localizable.role_level)
    local barExp = TFDirector:getChildByPath(panel_head, 'bar')
    local curExp = MainPlayer:getCurExp()
    local maxExp = MainPlayer:getMaxExp()
    if maxExp == 0 then
        barExp:setPercent(100)
    else
        barExp:setPercent(curExp / maxExp * 100)
    end
end

function CommonManager:openNewRoadLayer( ... )
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.main.NewRoadLayer")
    AlertManager:show()
end

function CommonManager:openWarningLayer()
    -- AlertManager:addLayerByFile("lua.logic.common.WarningLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_0);
    -- AlertManager:show();
    
    -- local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.WarningLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_0)
    -- AlertManager:show()
end
function CommonManager:openFirstDrawing()
    if MainPlayer:getTotalRecharge() == 0 then
        AlertManager:addLayerByFile("lua.logic.home.ShowFirstPayLayer",AlertManager.BLOCK,AlertManager.TWEEN_0);
        AlertManager:show();
    end
end

function CommonManager:openSecondDayDrawing()
    if MainPlayer:getRegisterDay() == 1 then
        AlertManager:addLayerByFile("lua.logic.home.ShowSecondDayLayer",AlertManager.BLOCK,AlertManager.TWEEN_0);
        AlertManager:show();
    end
end

function CommonManager:openEverydayNotice()
    if #EverydayNoticeManager:getInfo() <= 0 then
        return
    end
    AlertManager:addLayerByFile("lua.logic.home.EverydayNotice",AlertManager.BLOCK,AlertManager.TWEEN_0);
    AlertManager:show();
end


function CommonManager:openNoticeLayer(on_completed)
    -- if CC_TARGET_PLATFORM ~= CC_PLATFORM_WIN32 then
        local layer = AlertManager:addLayerByFile("lua.logic.login.NoticeLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_0);
        layer:loadData(on_completed)
        AlertManager:show()
    -- end
end

function CommonManager:openFullScreenWebView(url, withNet, title)
    local layer = AlertManager:addLayerByFile("lua.logic.common.FullScreenWebview",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
    layer:setUrl(url, withNet, title)
    AlertManager:show()
end

function CommonManager:openTmall(url)
    -- if CC_TARGET_PLATFORM ~= CC_PLATFORM_WIN32 then

        -- AlertManager:addLayerByFile("lua.logic.home.TmallWebLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_0);

        print("tmall url = ", url)
        local layer = require("lua.logic.home.TmallWebLayer"):new(url)
        AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_0)

        AlertManager:show()
    -- end
end

function CommonManager:openWeixinDrawing()
    -- if ServerSwitchManager:getServerSwitchStatue(ServerSwitchType.WeChat) == true then
    
    -- local bOpen = OperationActivitiesManager:ActivityTypeIsOpen(OperationActivitiesManager.Type_Pay_Back_RedBag)

    local nowTime   = os.time()--MainPlayer:getNowtime()
    local time1     = os.time({year=2015, month=11, day=20, hour=0})
    local time2     = os.time({year=2015, month=11, day=26, hour=23, min=59})
    local bOpen     = false

    if nowTime >= time1 and nowTime <= time2 then
        bOpen = true
    end

    if bOpen then
        AlertManager:addLayerByFile("lua.logic.home.SBAddLayer",AlertManager.BLOCK,AlertManager.TWEEN_0);
        AlertManager:show();
    end
end

function CommonManager:showBuyCoinLayer()
    -- BuyCoinLayer 
    AlertManager:addLayerByFile("lua.logic.mall.BuyCoinLayer",AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1);
    AlertManager:show();
end

function CommonManager:addAssistFightView( logic ,Type, callBack)
    local assistFightView    = require('lua.logic.assistFight.AssistFightEntranceLayer'):new()
    --generalHead:setLogic(logic)
    assistFightView:setPosition(ccp(0,0))
    assistFightView:setZOrder(1)
    assistFightView:setLineUpType(Type, callBack)

    local panel_assist      = TFDirector:getChildByPath(logic, 'panel_assist');
    panel_assist:addChild(assistFightView)

    return assistFightView;
end

function CommonManager:showRuleLyaer( rule_id )
    local layer = AlertManager:addLayerByFile("lua.logic.common.RuleLayer", AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    layer:loadRuleId(rule_id)
    AlertManager:show()
end

function CommonManager:openRewardShowLayer(group_id, index)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.RewardShowLayer", AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    layer:loadData(group_id, index)
    AlertManager:show()
end

function CommonManager:openRewardShowLayer2(rewards)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.RewardShowLayer", AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    layer:loadRewards(rewards)
    AlertManager:show()
end

function CommonManager:openRewardShowLayer3(isReceive, group_id, callFunc, privateData)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.RewardShowLayer", AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    layer:loadData1(isReceive, group_id, callFunc, privateData)
    AlertManager:show()
end

function CommonManager:checkResourceVersion()
    local versionPath = TFPlugins.zipCheckPath       --更新文件检测地址
    local filePath    = TFPlugins.zipCheckPath       --zip下载地址

    if TFClientResourceUpdate == nil then
        print("老版本的资源更新")
        return
    end

    local TFClientUpdate =  TFClientResourceUpdate:GetClientResourceUpdate()

    local function checkNewVersionCallBack()
        local version       =  TFClientUpdate:getCurVersion()
        local LatestVersion =  TFClientUpdate:getLatestVersion()
        local Content       =  TFClientUpdate:GetUpdateContent()
        local totalSize     =  TFClientUpdate:GetTotalDownloadFileSize()

        print("===========find new version===========")
        print("version          = ", version)
        print("LatestVersion    = ", LatestVersion)
        print("Content          = ", Content)
        print("totalSize        = ", totalSize)
        print("=============== end ==================")
        -- TFClientUpdate:startDownloadZip(downloadingRecvData)

        self:showFindNewVersioDiag(LatestVersion)
    end

    local function StatusUpdateHandle(ret)
        -- 更新完成，或者当前版本已经是最新的了
        if ret == 0 then


        elseif ret == 1 then

        elseif ret < 0 then

        end
    end

    print("new--------------------versionPath  = ", versionPath)
    print("new--------------------filePath     = ", filePath)
    TFClientUpdate:CheckUpdate(versionPath, filePath, checkNewVersionCallBack, StatusUpdateHandle)
end

function CommonManager:showFindNewVersioDiag(version)

    local warningMsg = localizable.CommonManager_new_version -- "大侠，发现了一个新版本，是否立即更新？"
    self:showOperateSureLayer(
            function()
                AlertManager:clearAllCache()
                CommonManager:closeConnection()
                restartLuaEngine("Other")
            end,
            nil,
            {
                    msg = warningMsg,
                    title = localizable.CommonManager_update_version1, --"更新资源啦",
                    showtype = AlertManager.BLOCK_AND_GRAY,
                    okText = localizable.CommonManager_update_version2, --"更新",
                    uiconfig = "lua.uiconfig_mango_new.common.OperateSure2"
            }
    )
end


function CommonManager:openIllustrationRole(roleId )
    
    local CardRole      = require('lua.gamedata.base.CardRole')
    local cardRole = CardRole:new(roleId)
    cardRole:setLevel(1)
    cardRole.attribute = {}
    local baseAttr = cardRole.totalAttribute.attribute
    
    local attribute = baseAttr

    for i=1,(EnumAttributeType.Max-1) do
        cardRole.totalAttribute[i] = attribute[i] or 0
    end

    local roleList = TFArray:new()
    roleList:clear()
    roleList:push(cardRole)


   local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role_new.RoleInfoLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
   local selectIndex = roleList:indexOf(cardRole)
   layer:loadOtherData(selectIndex, roleList)
   layer.bShowTuPu = true
   AlertManager:show()
end

--added by wuqi
--打开土豪发言编辑界面
function CommonManager:showTuhaoPopLayer(okhandle, cancelhandle, param)
    local flieName = "lua.logic.main.TuhaoPopLayer"
    param = param or {}
    param.showtype = param.showtype or AlertManager.BLOCK_AND_GRAY_CLOSE;
    param.tweentype = param.tweentype or AlertManager.TWEEN_1;

    local layer = AlertManager:addLayerByFile(flieName,param.showtype,param.tweentype);
    layer:setBtnHandle(okhandle, cancelhandle);
    layer:setTitle(param.title);
    layer:setMsg(param.msg);
	
	
    if not self:isTuhao() then
        layer:setTimesInfo(0)
    else
        if self:getTuhaoFreeTimes() > 0 then
            layer:setTimesInfo(1, self:getTuhaoFreeTimes())
        else
            layer:setTimesInfo(2, self:getTuhaoItemNum(), self:getTuhaoItemId())
        end
    end

    layer:setContectMaxLength(param.MaxLength)
    AlertManager:show()
    return layer;
end

function CommonManager:getTuhaoFreeTimes()
    return 2 - MainPlayer:getVipDeclarationFreeTimes()
end

function CommonManager:getTuhaoItemNum()
	if MainPlayer:getVipLevel() == 16 then
        return BagManager:getItemNumById(30113)
    elseif MainPlayer:getVipLevel() == 17 then
        return BagManager:getItemNumById(30114)
    elseif MainPlayer:getVipLevel() == 18 then
        return BagManager:getItemNumById(30115)
    end

    return 0
end

function CommonManager:getTuhaoItemId()
    if MainPlayer:getVipLevel() == 16 then
        return 30113
    elseif MainPlayer:getVipLevel() == 17 then
        return 30114
    elseif MainPlayer:getVipLevel() == 18 then
        return 30115
    end
end

function CommonManager:isTuhao()
    if MainPlayer:getVipLevel() == 16 or MainPlayer:getVipLevel() == 17 or MainPlayer:getVipLevel() == 18 then
        return true
    end
    return false
end

function CommonManager:setLoginCompleteState( state )
    self.loginCompleteState = state
end

function CommonManager:checkLoginCompleteState()
    if self.loginCompleteState then
        return true
    end
    return false
end

--去获取   
function CommonManager:goToDestination(tbl)
    local type = data[1] * 100
    if type == EnumFunctionType.MISSION then
        local mission = MissionManager:findMission(data[2])
        if mission then
            MissionManager:showMissionLayer(mission.template.chapter)
            MissionManager:openMissionDetailLayer(mission)
        else
            toastMessage(localizable.common_mission_lock)
        end
    elseif type == EnumFunctionType.MALL then
        local subType = data[2]
        local mall_tag = data[3]
        ShopManager:showShopLayer(subType, mall_tag)
    elseif type == EnumFunctionType.LOTTERY then
        LotteryManager:openLotteryLayer()
    elseif type == EnumFunctionType.RECHARGE then
        
    elseif type == EnumFunctionType.ACTIVITY then
        
    elseif type == EnumFunctionType.MISSION_BOX then
        
    end
end

function CommonManager:openAutoUseLayer(target, fun_accept, subtitle, autoTxt, title, fun_cancel)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.AutoUseLayer")
    layer:loadData(target, fun_accept, subtitle, autoTxt, title, fun_cancel)
    AlertManager:show()
end

--- data {type, tplId}
function CommonManager:openResDetailLayer(data)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.ResDetailLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    layer:loadData(data)
    AlertManager:show()
end

-- data {type, tplId}
function CommonManager:openResListLayer(data)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.ResListLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    layer:loadData(data)
    AlertManager:show()
end

--data {type=6,tplId=61009,num=99}
function CommonManager:openGainWayLayer(data)
    --获取途径限制
    local is_can, id, tag, str = JumpToManager:isCanJump(FunctionManager.BagRequire)
    if not is_can then 
        toastMessage(str)
        return
    end
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.GainWayLayer", AlertManager.BLOCK_AND_GRAY_CLOSE)
    layer:loadData(data)
    AlertManager:show()
end


function CommonManager:openCommonBuyLayer(type)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.CommonBuyLayer", AlertManager.BLOCK_AND_GRAY_CLOSE)
    layer:loadType(type)
    AlertManager:show()
end

function CommonManager:openCommonUseLayer(type)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.CommonUseLayer", AlertManager.BLOCK_AND_GRAY)
    layer:loadData(type)
    AlertManager:show()
end

function CommonManager:openPlayerInfoLayer()
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.main.PlayerInfoLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    AlertManager:show()
end

function CommonManager:openHandbookLayer()
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.handbook.NewHandBookMainLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
    -- local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.handbook.HandBookMainLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
    AlertManager:show()
end

function CommonManager:openChoiceLayer()
    -- local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.main.ChoiceLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
    -- AlertManager:show()
    -- AlertManager:changeScene(SceneType.CHALLENGE)
    CommonManager:requestEnterInScene(EnumSceneType.Challenge)
end

function CommonManager:openPlayerRenameLayer()
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.main.RenameLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    AlertManager:show()
end

function CommonManager:openConfirmBuyLayer(data, costType, cost, sureFunc, cancelFunc)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.ConfirmBuyLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    layer:loadData(data, costType, cost, sureFunc, cancelFunc)
    AlertManager:show()
end

function CommonManager:openResBuyLayer(type)
    if type == EnumResourceType.Strengh then
        StatisticsManager:layerJump( FunctionManager.MenuBuyStrengh )
    elseif type == EnumResourceType.Coin then
        StatisticsManager:layerJump( FunctionManager.MenuBuyCoin )
    end

    TFDirector:dispatchGlobalEventWith(AdventureManager.ADVENTURE_CLOSE_AUTO, 0)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.ResBuyLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    layer:loadData(type)
    AlertManager:show()
end

function CommonManager:openQuickGoLayer(type, title_type, toast_str)
    -- local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.GoRechargeLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    -- layer:loadData(type)
    -- AlertManager:show()
    local title_type = title_type or type
    local content = localizable.common_quick_go[title_type]
    local confirmFunc = function (sure)
        if sure then 
            if type == EnumQuickGo.Recharge then
                JumpToManager:jumpToByFunctionId(FunctionManager.MenuPay)
            elseif type == EnumQuickGo.Mission then
                MissionManager:showCurrentChapterMissionLayer()
            elseif type == EnumQuickGo.Vip then
                JumpToManager:jumpToByFunctionId(FunctionManager.MenuPay)
            elseif type == EnumQuickGo.SyceeStore then
                JumpToManager:jumpToByFunctionId(FunctionManager.ShopSycee)
            end
        end
    end
    if type == EnumQuickGo.Vip then
        local maxVipLevel = VipListData:length() - 1
        if MainPlayer.vipLevel >= maxVipLevel then
            if toast_str then
                toastMessage(toast_str)
            end
            return
        end
    end
    self:openNewConfirmLayer(content, localizable.common_btn_cancel, localizable.task_daily_state_goto, confirmFunc, false, nil)
end

function CommonManager:openCommonRuleLayer(id)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.CommonRuleLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    layer:loadData(id)
    AlertManager:show()
end

function CommonManager:openConfirmLayer(content, confirmFunc, cancleFunc, target)
    -- local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.ConfirmLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    -- layer:loadData(content, confirmFunc, cancleFunc, target)
    -- AlertManager:show()
    local func = function (sure)
        if sure then
            TFFunction.call(confirmFunc, target)
        else
            TFFunction.call(cancleFunc, target)
        end
    end
    self:openNewConfirmLayer(content, localizable.common_btn_cancel, localizable.common_btn_ok, func, false, nil)
end

function CommonManager:openNewConfirmLayer(content, leftBtnStr, rightBtnStr, confirmFunc, isReverse,closeFunc)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.NewConfirmLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    layer:loadData(content, leftBtnStr, rightBtnStr, confirmFunc, isReverse,closeFunc)
    AlertManager:show()
end

---------------------------单按钮确认框
function CommonManager:openNewConfirm1(content, btnStr, func, target)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.NewConfirm1",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    layer:loadData(content, btnStr, func, target)
    AlertManager:show()
end

---------------------------通用消耗资源界面
function CommonManager:openCommonAutoUseLayer(callFunc, target, type, title)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.CommonAutoUseLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    layer:loadData(callFunc, target, type, title)
    AlertManager:show()
end

--boss展示界面   
function CommonManager:openBossShowLayer(id, callFunc, target)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.BossShowLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    layer:loadData(id, function ()
        AlertManager:close()
        TFFunction.call(callFunc, target)
    end)
    AlertManager:show()
end

function CommonManager:setEquipmentItem(panel, equip, type, is_bool)
    if not panel or not equip or not equip.template then
        Utils:setVisibleWithTable(false, panel, {"rdad","img_di","img_baoshi_bg1","img_baoshi_bg2","img_baoshi1","img_baoshi2",
                                                "txt_lv","img_star_1","img_star_2","img_star_3","img_star_4","img_star_5"})

        Utils:setTextureNormal(panel, "btn_zhuangbei", GetFormationFullImage(type))
        return
    end
    Utils:setVisibleWithTable(true, panel, {"rdad","img_di","img_baoshi_bg1","img_baoshi_bg2","img_baoshi1","img_baoshi2",
                                                "txt_lv","img_star_1","img_star_2","img_star_3","img_star_4","img_star_5"})
    local template = equip.template
    local txt_name = TFDirector:getChildByPath(panel, "txt_name")
    Utils:setTexture(panel, "img_di", template:getQualityPath())
    Utils:setTexture(panel, "img_qualitybg", GetColorBottomByQuality(equip.template.quality))
    Utils:setTextureNormal(panel, "btn_zhuangbei", template:getIconPath())
    local txt_lv = TFDirector:getChildByPath(panel, "txt_lv")
    txt_lv:setText("+" .. equip.level)

    if txt_name then
        local name = equip.template.name
        if equip.starLv > 0 then name = name .. "+" .. equip.starLv end
        txt_name:setString(name)
        txt_name:setColor(GetColorByQuality(equip.template.quality))
    end

    local gemPos = equip.gemPos

    if gemPos[2] then
        local img_gem_bg = TFDirector:getChildByPath(panel, "img_baoshi_bg1")
        local img_gem = TFDirector:getChildByPath(panel, "img_baoshi1")
        local img_gem_bg2 = TFDirector:getChildByPath(panel, "img_baoshi_bg2")
        -- if img_gem_bg then
        --     if gemPos[2].id == 0 then 
        --         img_gem_bg:setPositionY(img_gem_bg2:getPositionY())
        --         img_gem:setPositionY(img_gem_bg2:getPositionY())
        --     else
        --         img_gem_bg:setPositionY(img_gem_bg2:getPositionY() + img_gem_bg2:getContentSize().height / 2 + 3)
        --         img_gem:setPositionY(img_gem_bg2:getPositionY() + img_gem_bg2:getContentSize().height / 2 + 3)
        --     end       
        -- end
    end

    for i=1,2 do
        local img_gem_bg = TFDirector:getChildByPath(panel, "img_baoshi_bg" .. i)
        local img_gem = TFDirector:getChildByPath(panel, "img_baoshi" .. i)
        local gp = gemPos[i]
        if img_gem_bg then
            if gp then           
                if gp.id and gp.template then
                    img_gem:setVisible(true)
                    img_gem_bg:setVisible(true)
                    img_gem:setTexture(gp.template:getIconPath())
                else
                    img_gem:setVisible(false)
                    img_gem_bg:setVisible(false)
                end
            else
                img_gem_bg:setVisible(false)
                img_gem:setVisible(false)
            end
        end
    end

    local stars = GetEquipmentStarIcons(equip.starLv)
    if is_bool  then
        stars = GetEquipmentStarIcons(equip.starLv + 1)
        local name = equip.template.name .. "+" .. (equip.starLv + 1)
        txt_name:setString(name)
    end
    
    for i=1,5 do
        local img_star = TFDirector:getChildByPath(panel, "img_star_" .. i)
        if not img_star then
            break
        end
        if stars[i] then
            img_star:setVisible(true)
            img_star:setTexture(stars[i])
        else
            img_star:setVisible(false)
        end
    end
end

-- data {tpl, type, num}
function CommonManager:setIconData(panel, data)
    local reward = BaseDataManager:getReward(data)

    CommonManager:setIconReward(panel, reward)
end

function CommonManager:setIconReward(panel, reward)
    Utils:setTexture(panel, "img_icon", reward.path)
    Utils:setTexture(panel, "img_quality", Public:getIconKuangByData(reward))
    local txt_num = TFDirector:getChildByPath(panel, "txt_num")
    local txt_name = TFDirector:getChildByPath(panel, "txt_name")
    if txt_num then
        txt_num:setText(reward.num)
    end

    if txt_name then
        txt_name:setText(reward.name)
        if reward.quality then 
              txt_name:setFontColor(GetColorByQuality(reward.quality)) 
        end
    end

    local btn_bottom = TFDirector:getChildByPath(panel, "btn_bottom")
    btn_bottom:setTextureNormal(GetColorBottomByQuality(reward.quality))
    Public:addResDetail(btn_bottom, reward)
end


function CommonManager:btnJumpToLayer( panel, targetObj, inOutFunc, names, clicks)
    names = names or {"btn_formation", "btn_role", "btn_equipment", "btn_fabao",
    "btn_bag", "btn_friend", "btn_shenqi","btn_chongwu","btn_gonghui"}

    local callBack = 
    {
        [1] = function ( ... )
            JumpToManager:jumpToByFunctionId( FunctionManager.MenuFormation )
        end,
        [2] = function ( ... )
            CardRoleManager:openRoleListLayer()
        end,
        [3] = function ( ... )
            JumpToManager:jumpToByFunctionId( FunctionManager.MenuEquip )
        end,
        [4] = function ( ... )
            JumpToManager:jumpToByFunctionId(FunctionManager.MenuArtifact)
        end,
        [5] = function ( ... )
            JumpToManager:jumpToByFunctionId( FunctionManager.MenuBag )
        end,
        [6] = function ( ... )
            JumpToManager:jumpToByFunctionId(FunctionManager.MenuFriend)
        end,
        [7] = function( ... )
            JumpToManager:jumpToByFunctionId(FunctionManager.MenuNewShenQi)
        end,
        [8] = function ( ... )
            JumpToManager:jumpToByFunctionId(FunctionManager.Pet)
        end,
        [9] = function ( ... )
            JumpToManager:jumpToByFunctionId(FunctionManager.MenuGuild)
        end

    }

    local panel_btndown  = TFDirector:getChildByPath(panel,"panel_btndown")
    local bg_bg = TFDirector:getChildByPath(panel, "bg_bg")
    local btn_show = TFDirector:getChildByPath(panel, "btn_show")
    local btn_hide = TFDirector:getChildByPath(panel, "btn_hide")
    local width = panel_btndown:getContentSize().width
    targetObj.btn_show = btn_show
    targetObj.btn_hide = btn_hide
    targetObj.bg_bg = bg_bg
    targetObj.panel_btndown = panel_btndown
    btn_show.logic = targetObj
    btn_hide.logic = targetObj

    local defaultBool = targetObj and targetObj.__cname == "MenuLayer" and true or false
    local isShow = CCUserDefault:sharedUserDefault():getBoolForKey(targetObj.__cname, defaultBool)
    bg_bg:setVisible(isShow)
    btn_show:setVisible(not isShow)
    btn_show:setTouchEnabled(not isShow)
    btn_hide:setVisible(isShow)
    btn_hide:setTouchEnabled(isShow)
    panel_btndown:setVisible(isShow)
    targetObj.menuBtnAnimation = isShow
    TFFunction.call(inOutFunc, targetObj, not isShow)
    if not isShow and targetObj.ui and targetObj.ui.runAnimation then 
        targetObj.ui:runAnimation("Action0", 1)
    end

    local btns = {}
    for k, name in pairs(names) do
        btns[k] = TFDirector:getChildByPath(panel, name)
        if btns[k] then
            targetObj[name] = btns[k]
            targetObj[name].logic = targetObj
            btns[k].index = k 
        end
    end

    local btnClickHandle = function(sender)
        local target = sender.logic
        if target.menuBtnAnimation then
            local data = {effectId="gongnenglan", name="bofang01", is_remove = true}
            data.onComplete = function ()
                TFFunction.call(inOutFunc, target, true)
                if target.ui and target.ui.runAnimation then
                    target.ui:runAnimation("Action0", 1)
                    target.ui:setAnimationCallBack("Action0", TFANIMATION_END, function() 
                        bg_bg:setVisible(false)
                        btn_hide:setVisible(false)
                        btn_show:setVisible(true)
                        btn_show:setTouchEnabled(true)
                        panel_btndown:setVisible(false)

                        Utils:createEffect(btn_show, {effectId="gongnenglan", name="bofang02", is_remove=true})
                    end)
                end
            end
            btn_hide:setTouchEnabled(false)
            btn_show:setTouchEnabled(false)
            if btn_hide.effect then
                btn_hide.effect:removeFromParent()
                btn_hide.effect = nil
            end
            Utils:createEffect(btn_hide, data)
        else
            local data = {effectId="gongnenglan", name="bofang01", is_remove = true}
            data.onComplete = function ()
                bg_bg:setVisible(true)
                btn_show:setVisible(false)
                btn_hide:setVisible(true)
                panel_btndown:setVisible(true)
                TFFunction.call(inOutFunc, target, false)
                if target.ui and target.ui.runAnimation then
                    target.ui:runAnimation("Action1", 1)
                    target.ui:setAnimationCallBack("Action1", TFANIMATION_END, function() 
                        btn_hide:setTouchEnabled(true)
                    end)
                end
            end
            btn_hide:setTouchEnabled(false)
            btn_show:setTouchEnabled(false)
            if btn_show.effect then
                btn_show.effect:removeFromParent()
                btn_show.effect = nil
            end
            Utils:createEffect(btn_show, data)
        end
        target.menuBtnAnimation = not target.menuBtnAnimation
        CCUserDefault:sharedUserDefault():setBoolForKey(target.__cname, target.menuBtnAnimation)
    end

    local btnCallBack = function (sender)
        local index = sender.index
        if clicks and clicks[1] then
            local func = clicks[index] or clicks[1]
            TFFunction.call(func, targetObj[names[index]])
        elseif callBack[index] then
            TFFunction.call(callBack[index])
        else
            toastMessage(localizable.common_yet_open)
        end
    end

    if btn_show and btn_hide then
        btn_show:addMEListener(TFWIDGET_CLICK, btnClickHandle)
        btn_hide:addMEListener(TFWIDGET_CLICK, btnClickHandle)
        targetObj._btnClickHandle = btnClickHandle
    end
    
    for k, btn in pairs(btns) do
        btn:addMEListener(TFWIDGET_CLICK, btnCallBack)
    end
end

function CommonManager:addEyeLayer(logic, zOrder)
    zOrder = zOrder or 1 
    local eyeLayer    = require('lua.logic.common.EyeLayer'):new()
    eyeLayer:setLogic(logic)
    eyeLayer:setPosition(ccp(0,0))
    eyeLayer:setZOrder(zOrder)

    local panel_eye      = TFDirector:getChildByPath(logic, 'panel_eye')
    local eye = TFDirector:getChildByPath(logic, "eye")
    eye:addChild(eyeLayer)
    logic.panel_eye = panel_eye
    return eyeLayer
end

function CommonManager:addQuickJumpLayer(logic, zOrder)
    zOrder = zOrder or 1

    local jumpLayer    = require('lua.logic.common.QuickJumpLayer'):new()
    jumpLayer:setLogic(logic)
    jumpLayer:setPosition(ccp(0,0))
    jumpLayer:setZOrder(zOrder)

    local panel = TFDirector:getChildByPath(logic, "panel_jump")
    panel:addChild(jumpLayer)
    return jumpLayer
end

--============= 请求进入scene =======================
function CommonManager:requestEnterInScene(scene, chapterId, pos)
    if chapterId and chapterId ~= 0 then
        local pass = MissionManager:checkChapterPass(chapterId)
        if not pass and not TeamManager:ishaveTeam() then
            AlertManager:changeScene(SceneType.MISSION, {chapterId = chapterId})
            return
        end
        if not scene or scene == 0 then
            scene = MissionManager:getPassIdByChapterId(chapterId, pass)
        end
    end
    if not scene or scene == 0 then
        scene = EnumSceneType.Home
    end

    SyncPosManager:sendCheckEnterScene(scene, chapterId, pos)
end

--[[
在组队中哪些控件不能点击，出现提示
    widget: ui控件
    tipType: 提示类型: 
    team_click_tips = {
	 [1] = '降妖伏魔期间请点击右侧面板移动',
	 [2] = '降妖伏魔期间无法使用此功能',
	 [3] = '降妖伏魔期间，由队长控制队伍移动'
     }
    ...
]]
function CommonManager:notClickInTeam( widget,tipType )
    local tipFunc = function ( ... )
        toastMessage(localizable.team_click_tips[tipType])
    end
    local clickCallback = widget:getMEListener(TFWIDGET_CLICK)
    if widget and clickCallback then
        widget:removeMEListener(TFWIDGET_CLICK)
    end
    widget:addMEListener(TFWIDGET_CLICK, audioClickfun(tipFunc),1)
end

------------------通过掉落组Id获取掉落物品
function CommonManager:getRewardByDropsId( dropsId )
    local rewards = {}
    for i,dripId in pairs(dropsId) do
        
        local roundDropId = DropGroupData:getDropId(dripId)
        for _,v in pairs(roundDropId) do
            local data = DropData:objectByID(v)
            if not data then break end
            if rewards[data.id] == nil then
                rewards[data.id] = {tplId = data.res_id, type = data.res_type , minValue = 0, maxValue = 0}
            end
            rewards[data.id].minValue = rewards[data.id].minValue + data.drop_min
            rewards[data.id].maxValue = rewards[data.id].maxValue + data.drop_max
        end
    end

    local itemArray = TFArray:new()
    for i,v in pairs(rewards) do
        itemArray:push(v)
    end
    return itemArray
end

--修复客户端
function CommonManager:showRepairLayer()
    hideAllLoading()
    TFWebView.removeWebView()

    local layer = AlertManager:addLayerByFile("lua.logic.login.LoginXFLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
    layer.toScene = Public:currentScene()
    layer:setZOrder(111110)

    AlertManager:show()
end

return CommonManager:new();