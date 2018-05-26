-- Created by ZZTENG on 2017/09/12.
-- 新神器管理

local NewArtifactManager = class("NewArtifactManager", BaseManager)
NewArtifactManager.UPDATE_STATUS = "NewArtifactManager.UPDATE_STATUS"
NewArtifactManager.UPDATE_OPEN_STATUS = 'NewArtifactManager.UPDATE_OPEN_STATUS'

function NewArtifactManager:ctor()
	self.super.ctor(self)
end

function NewArtifactManager:init()
    self.super.init(self)
    
    self.updateInfos = {}
    self.shenQiStatus = {}
    self.rewardList = {}
    self.shenQiData = TFArray:new()
    self.itemList = {}
    self.keysList = {'GodWeapon.Id.Anger','GodWeapon.Id.AttackStrike','GodWeapon.Id.CatchPet','GodWeapon.Id.Move','GodWeapon.Id.RoundTask.AddOdds'}
    self.dachengList = {}
    self.collectCount = 0
    TFDirector:addProto(s2c.GOD_WEAPON_STATUS, self, self.onReceiveInfo)
    TFDirector:addProto(s2c.GOD_WEAPON_UPDATE, self, self.onReceiveUpdateInfo)
    TFDirector:addProto(s2c.SPIRIT_LEVEL_SUCCESS, self, self.onReceiveSpiritLevelSuccess)

    self.updateNewAritfactAttr = function ( ... )
        self:showEffect()
    end
    TFDirector:addMEGlobalListener(FormationManager.UPDATE_FORMATION, self.updateNewAritfactAttr)
end

function NewArtifactManager:restart()
    -- 清除数据
    if self.itemIndex then
        self.itemIndex = nil
    end
    if self.subTab then
        self.subTab = nil
    end
    if self.shenQiStatus then
        self.shenQiStatus = {}
    end
    if self.updateInfos then
        self.updateInfos = {}
    end
    if self.rewardList then
        self.rewardList = {}
    end
    if self.itemList then
        self.itemList = {}
    end

    if self.shenQiData then
        self.shenQiData:clear()
    end
    self.dachengList = {}
    self.shenQiUnitData = nil
    self.shenAttr = nil
    self.hunAttr = nil
    self.lingAttr = nil
    self.collectCount = 0
end

function NewArtifactManager:openNewArtifactMainLayer( tabType )
    -- 打开神器UI
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shenqi.NewShenQiLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
    AlertManager:show()
end

function NewArtifactManager:openNewShenQiOpenLayer()
    print("============ openNewShenQiOpenLayer ==")
    -- 获得神器UI
    local data = self.shenQiData:popFront()
    if data then
        self.shenQiUnitData = data
        local layer = AlertManager:getLayerByName('lua.logic.shenqi.NewShenQiOpenLayer')
        if not layer then
            local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shenqi.NewShenQiOpenLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
            AlertManager:show()
        else
            TFDirector:dispatchGlobalEventWith(NewArtifactManager.UPDATE_OPEN_STATUS)
        end
    end
end

function NewArtifactManager:getShenQiUnitData( )
    return self.shenQiUnitData
end

function NewArtifactManager:onReceiveInfo( event )
    -- print('NewArtifactManager:onReceiveInfo:',event.data)
    local data = event.data
    for k,info in pairs(data.infos or {}) do
       info.object = stringToNumberTable(info.object, '_')
       if #info.object == 0 then
          info.object = {0}
       end
       info.spirit = stringToNumberTable(info.spirit ,'_')
       if #info.spirit == 0 then
          info.spirit = {0}
       end
       info.soul = stringToNumberTable(info.soul ,'_')
       if #info.soul == 0 then
          info.soul = {0}
       end
       info.spiritFinish = stringToNumberTable(info.spiritFinish, '_')
       if #info.spiritFinish == 0 then
          info.spiritFinish = {0}
       end
    end
    -- print('77777777777777777777777',data.infos)
    self.itemList = data.infos or {}
    self:sureShenQiStatus()
    self:sort()
    self:showEffect()
end

--神器状态：1,2,3-->收集，未收集，未开启
function NewArtifactManager:getShenQiStatusById( id )
    local item = table.findOne(self.itemList,function ( v )
        if v.id == id then
            return true
        else 
            return false
        end
    end)
    if item ~= nil and item.data then
        if item.data.objectget_value ~= 0 then
            if item.have then
                return 1
            else
                return 2
            end
        else
            return 3
        end
    end
    return 3
end

--数据初始化，神器排序，激活在前面，为激活在后面
function NewArtifactManager:sort()
    for data in GodWeaponData:iterator() do
        --itemlist 是否存在某个神器id
        local item = table.findOne(self.itemList,function ( v )
            if v.id == data.id then
                return true
            else 
                return false
            end
        end)
        if item ~= nil then
            item.data = data
        else
            --初始化数据
            local newItem = {}
            newItem.id = data.id
            newItem.object = {0}
            newItem.objectStatus = 1
            newItem.spirit = {0}
            newItem.spiritLevel = 0
            newItem.spiritStatus = 1
            newItem.soul = {0}
            newItem.soulStatus = 1
            newItem.spiritFinish = {0}
            newItem.data = data
            self.itemList[#self.itemList + 1] = newItem
        end
    end
    table.sort(self.itemList,function ( a,b )
        -- if not a.have and b.have then
        --     return true
        -- elseif a.have and not b.have then
        --     return false
        -- end
        return a.data.sort < b.data.sort
    end)
end

--神器id魄是否可以升级
function NewArtifactManager:isLevelUpById( id )
    local can_level_up = true
    for _,itemInfo in ipairs(self.itemList) do
        if itemInfo.id == id and itemInfo.spiritLevel ~= 5 then
            local hunData = GodWeaponHunData:getDataByIdAndLevel(itemInfo.id,itemInfo.spiritLevel + 1)
            if hunData == nil then return false end
            local kindList = stringToNumberTable(hunData.kind,',')
            for i=1,#kindList do
                local achievement = AchievementData:objectByID(kindList[i])
                local jindu = nil
                jindu = achievement.target
                -- if achievement.target2 ~= 0 then
                --     jindu = achievement.target2
                -- end
                if itemInfo.spirit[i] == nil then
                    itemInfo.spirit[i] = 0
                end
                if itemInfo.spiritFinish[i] == nil then
                    itemInfo.spiritFinish[i] = 0
                end
                -- if itemInfo.spirit[i] < jindu then
                --     can_level_up = false
                -- end
                if itemInfo.spiritFinish[i] ~= 2 then
                    can_level_up = false
                end
            end
            return can_level_up  
        end
    end
    return false
end

--游戏中达成列表
function NewArtifactManager:updateDachengList( data )
    if data.actType == EnumNewShenQiShuXing.Shen then
        local god_weapon_data = GodWeaponData:objectByID(data.id)
        print('7777777777',data.id,data.value[1],god_weapon_data.objectget_value)
        if data.value[1] >= god_weapon_data.objectget_value then
            if self.dachengList[data.id] == nil then
                self.dachengList[data.id] = {}
            end
            self.dachengList[data.id].shen = 1   --1达成特效，0没有
        end
    elseif data.actType == EnumNewShenQiShuXing.Hun then
        if data.level == 5 then return end
        local god_weapon_hun_data = GodWeaponHunData:getDataByIdAndLevel(data.id,data.level + 1)
        local kindList = stringToNumberTable(god_weapon_hun_data.kind,',')
        if self.dachengList[data.id] == nil then
            self.dachengList[data.id] = {}
        end
        if self.dachengList[data.id].hun == nil then
            self.dachengList[data.id].hun = {}
        end
        local dacheng_unit_data = self.dachengList[data.id].hun
        for i,achievementId in ipairs(kindList) do
            -- if data.value[i] == nil then data.value[i] = 0 end
            if data.spiritFinish[i] == nil then data.spiritFinish[i] = 0 end
            local achievement = AchievementData:objectByID(achievementId)
            local jindu = nil
            jindu = achievement.target
            -- if achievement.target2 ~= 0 then jindu = achiivement.target2 end
            -- print('9999999999999',achievementId,data.value[i],jindu)
            -- if data.value[i] >= jindu then  
            --     dacheng_unit_data[i] = 1 
            -- else
            --     dacheng_unit_data[i] = 0
            -- end
            local itemInfo = self:findItemById(data.id)
            if itemInfo then
                if itemInfo.spiritFinish[i] == nil then
                    itemInfo.spiritFinish[i] = 0
                end
            end
            if data.spiritFinish[i] == 2  and itemInfo.spiritFinish[i] ~= 2 then
                dacheng_unit_data[i] = 1 
            end
        end
    elseif data.actType == EnumNewShenQiShuXing.Ling then
        local god_weapon_data = GodWeaponData:objectByID(data.id)
        print('88888888888888888888',data.id,data.value[1],god_weapon_data.soulget_value)
        if data.value[1] >= god_weapon_data.soulget_value then
            if self.dachengList[data.id] == nil then
                self.dachengList[data.id] = {}
            end
            self.dachengList[data.id].ling = 1
        end
    end
end

function NewArtifactManager:getDaChengDataByIdAndType( id,type )
    local data = nil
    if self.dachengList[id] ~= nil then
        if type == EnumNewShenQiShuXing.Shen then
            data = self.dachengList[id].shen
        elseif type == EnumNewShenQiShuXing.Hun then
            data = self.dachengList[id].hun
        elseif type == EnumNewShenQiShuXing.Ling then
            data = self.dachengList[id].ling
        end
    end
    return data
end

--确定神器激活状态
function NewArtifactManager:sureShenQiStatus( ... )
    self.collectCount = 0
    for _,item in ipairs(self.itemList) do
       local data =  GodWeaponData:objectByID(item.id)
       if not data then return end
       --自动激活改为手动激活
    --    local objectget_value = tonumber(data.objectget_value)
       --身激活
    --    if objectget_value ~= 0 and item.object[1] and item.object[1] >= objectget_value then
        if item.objectStatus and item.objectStatus == 3 then
            item.have = true
            item.shenJiHuo = true
            self.collectCount = self.collectCount + 1
       else
            item.have = false
            item.shenJiHuo = false
       end
       --魄激活
       if item.spiritLevel and item.spiritLevel ~= 0 then
           item.hunJiHuo = true
       else
           item.hunJiHuo = false
       end
       --灵激活
    --    local soulget_value = tonumber(data.soulget_value)
    --    if soulget_value ~= 0 and item.soul[1 and item.soul[1] >= soulget_value then
       if item.soulStatus and item.soulStatus == 3 then
            item.lingJiHuo = true
       else
            item.lingJiHuo = false
       end
    end
end

--神器id，神器属性type,神器属性进度
function NewArtifactManager:canJiHuo( id,type,value,level)
    print('==========canjihuo',id,type,value,level)
    local open = false
    for i,item in ipairs(self.itemList) do
        if item.id == id and value[1] then
            if type == EnumNewShenQiShuXing.Shen and value[1] >= item.objectget_value then
                open = true
            end
            -- if type == EnumNewShenQiShuXing.Hun and item.spiritLevel == 0 and level > 0 then
            --     open = true
            -- end 
            -- if type == EnumNewShenQiShuXing.Ling and value[1] >= item.soulget_value then
            --     open = true
            -- end
       end
    end
    --神器打开界面数据
    --神器获得由剧情打开
    -- if open then
    --     --轩辕剑，炼妖壶由剧情播放，过滤下
    --     if id == 3 or id == 9 then
    --         return
    --     end
    --     self:setNewArtifact( true )
    --     local data = {}
    --     data.id = id
    --     data.type = type
    --     self.shenQiData:push(data)
    -- end
end

--更新神器信息
function NewArtifactManager:updateInfo(  )
    for k,updateInfo in pairs(self.updateInfos) do
      local id = updateInfo.id
      for _,item in ipairs(self.itemList) do
        if item.id == id then
            if updateInfo.actType == EnumNewShenQiShuXing.Shen then
                item.object = updateInfo.value
                item.objectStatus = updateInfo.status or 1
            elseif updateInfo.actType == EnumNewShenQiShuXing.Hun then
                item.spirit = updateInfo.value
                item.spiritStatus = updateInfo.status or 1
                item.spiritLevel = updateInfo.level or 0
                item.spiritFinish = updateInfo.spiritFinish or {0}
            elseif updateInfo.actType == EnumNewShenQiShuXing.Ling then
                item.soul = updateInfo.value
                item.soulStatus = updateInfo.status or 1
            end
        end
      end
  end
end

--通过神器id，找constant key
function NewArtifactManager:findKeyById( id )
    --神器常量key
    for _,key in pairs(self.keysList) do
        if ConstantData:getResType(key) == id then return key end
    end
    assert('not find key by id')
    return nil
end
--通过神器id，找神器值
function NewArtifactManager:findItemById( id )
    for k,v in pairs( self.itemList) do
        if v.id == id then
            return v
         end
    end
    assert('not find item by id')
    return nil
end

--增加收集效果
function NewArtifactManager:showEffect( )
    --身的效果，所有角色属性
    --魄的效果，上阵pve角色属性or pvp
    --灵的效果,主角
    self.shenAttr = {}
    self.hunAttr = {}
    for _,itemInfo in ipairs(self.itemList) do
        if itemInfo.shenJiHuo then
            local attr = GetAttrByStringForExtra(itemInfo.data.objectreward_value)
            for k,v in pairs(attr) do
                if self.shenAttr[k] then
                    self.shenAttr[k] = self.shenAttr[k] + v
                else
                    self.shenAttr[k] = v
                end
            end
        end
        itemInfo.spiritLevel = itemInfo.spiritLevel or 0
        if itemInfo.spiritLevel > 0 then
            local hunData = GodWeaponHunData:getDataByIdAndLevel(itemInfo.id,itemInfo.spiritLevel )
            local attr = GetAttrByStringForExtra(hunData.effect)
            for k,v in pairs(attr) do
                if self.hunAttr[k] then
                    self.hunAttr[k] = self.hunAttr[k] + v
                else
                    self.hunAttr[k] = v
                end
            end
        end
    end

    --以前属性少，服务器提出方法，减少遍历
    --可以不用，看服务器是否改动，跟服务器保持一致
    self.lingAttr = {}
    local rewardList = {}
    for _,key in pairs(self.keysList) do
        local res_type = ConstantData:getResType(key)
        local value  = ConstantData:getValue(key)   -- 1：身 2： 魄 3： 灵
        local itemInfo =self:findItemById(res_type)
        if value == 3 then
           if itemInfo.lingJiHuo then
                 rewardList[key] = itemInfo.soulreward_value
           end
        end
    end
    for k,v in pairs(rewardList) do
        if k == 'GodWeapon.Id.Anger' then  --怒力值
        elseif k == 'GodWeapon.Id.AttackStrike' then   --主角物穿、法穿
            self.lingAttr[EnumAttributeType.PhyPenetrate] = v * 100
            self.lingAttr[EnumAttributeType.MagicPenetrate] = v * 100
        elseif k == 'GodWeapon.Id.CatchPet' then     --捉宠时可出现高品质条
        elseif k == 'GodWeapon.Id.Move' then    --角色移动速度
              MainPlayer:addSpeed(v)
        elseif k == 'GodWeapon.Id.RoundTask.AddOdds' then  --增加降妖伏魔任务奖励
        end
    end
    print('NewArtifactManager:showEffect',self.shenAttr,self.hunAttr,self.lingAttr)
    CardRoleManager:updateNewArtifactAttr()
end

function NewArtifactManager:onReceiveUpdateInfo( event )
    hideLoading()
    -- print('NewArtifactManager:onReceiveUpdateInfo:',event.data)
    local data = event.data or {}
    local id = data.id
    local type = data.actType
    local value = stringToNumberTable(data.value,'_')
    data.value = value
    if #value == 0 then
        data.value = {0}
    end
    data.status = data.status or 1
    data.level = data.level or 0
    if data.spiritFinish == nil then
        data.spiritFinish = {0}
    else
        data.spiritFinish = stringToNumberTable(data.spiritFinish,'_')
    end
    -- local status = data.status or 1
    -- local level = data.level or 0
    if id == nil then
        return
    end
    self.updateInfos[id] = data
    self:updateDachengList(data)
    -- self:canJiHuo(id,type,value,level)
    self:updateInfo()
    self:sureShenQiStatus()
    self:sort()
    self:showEffect()
    -- local currentScene = Public:currentScene()
    
    -- print('7777777777777777777777onReceiveUpdateInfo')
    -- if currentScene and currentScene.__cname ~= "BattleScene" then
    --     print('77777777777777777777not battleScene')
    --     self:isNeedopenNewShenQiOpenLayer()
    -- end

    TFDirector:dispatchGlobalEventWith(NewArtifactManager.UPDATE_STATUS,id)
    TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_END, 0)
end

function NewArtifactManager:onReceiveSpiritLevelSuccess( event )
    hideLoading()
    print('NewArtifactManager:onReceiveSpiritLevelSuccess')
    -- local layer = AlertManager:getLayerByName('lua.logic.shenqi.NewShenQiLayer')
    -- if layer then layer:addHunLevelUpEffect() end
end

--send
--查看红点
function NewArtifactManager:sendGodWeaponStatus( id,actType )
    TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, 0)
    self:sendWithLoading(c2s.GOD_WEAPON_STATUS,id,actType)
end

--魄升级
function NewArtifactManager:sendSpiritLevel( id,level )
    TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, 0)
    self:sendWithLoading(c2s.SPIRIT_LEVEL,id,level)
end

function NewArtifactManager:getItemList( ... )
    return self.itemList
end

function NewArtifactManager:setItemIndex( index )
    self.itemIndex = index
end

function NewArtifactManager:getItemIndex( ... )
    return self.itemIndex
end

function NewArtifactManager:setSubType( type )
    self.subTab = type
end

function NewArtifactManager:getSubType( ... )
    return self.subTab
end

function NewArtifactManager:setNewArtifact( is_bool )
    self.isHave_newArt = is_bool
end

function NewArtifactManager:getNewArtifact()
    return self.isHave_newArt
end

function NewArtifactManager:isNeedopenNewShenQiOpenLayer()
    -- 获得神器UI
    if self:getNewArtifact() then
        self:setNewArtifact( false )
        self:openNewShenQiOpenLayer()
    end  
end

--有神器身待激活
function NewArtifactManager:canActiveObject(  )
    for i,itemInfo in ipairs(self.itemList) do
        if itemInfo.objectStatus == 2 then
            return true
        end
    end
    return false
end

--红点
function NewArtifactManager:updateAllRedPoint( ... )
    for i,itemInfo in ipairs(self.itemList) do
       local redStatus = self:updateRedPointById(itemInfo.id)
       if redStatus then return true end
    end
    return false
end

function NewArtifactManager:updateRedPointById( id )
    local itemInfo = table.findOne(self.itemList,function ( v )
        if v.id == id then
            return true
        else 
            return false
        end
    end)
    if itemInfo == nil then 
        assert('shenqi id not exit')
        return false
    end
    local redStatus = nil
    if itemInfo.objectStatus == 2 or (itemInfo.shenJiHuo and (self:isLevelUpById( itemInfo.id ) or itemInfo.spiritStatus == 2)) or 
     (itemInfo.shenJiHuo and  itemInfo.soulStatus == 2 )then
        redStatus = true
    else
        redStatus = false
    end
    return redStatus
end

return NewArtifactManager:new()