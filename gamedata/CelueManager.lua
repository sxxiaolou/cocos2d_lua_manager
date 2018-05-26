-- Created by ZZTENG on 2017/10/18.
--技能策略管理

local CelueManager = class("CelueManager", BaseManager)
CelueManager.UPDATE_STATUS = "CelueManager.UPDATE_STATUS"

function CelueManager:ctor()
	self.super.ctor(self)
end

function CelueManager:init()
    self.super.init(self)
    
    TFDirector:addProto(s2c.CUSTOM_SKILL_AI, self, self.onReceiveCustomSkillInfo)
    TFDirector:addProto(s2c.CUSTOM_SKILL_SUCCESS, self, self.onReceiveCustomSkillSuccess)
end

function CelueManager:restart()
    -- 清除数据
    self.customSkillInfoList = {}
end

function CelueManager:openCelueMainLayer( ... )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.celue.CelueMainLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function CelueManager:openCelueHpLayer( godsList )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.celue.CelueHpLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
    return layer
end

function CelueManager:openCelueTiShiLayer( ... )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.celue.CelueTiShiLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
    return layer
end

function CelueManager:skillInfoByformationType( formationType )
    local customSkillInfo = nil
    if type(self.customSkillInfoList) ~= 'table' then self.customSkillInfoList = {} end
    for k,v in pairs(self.customSkillInfoList) do
        if v.formationType == formationType then
              customSkillInfo = self.customSkillInfoList[k]
              break
        end
    end
    if customSkillInfo == nil then
          customSkillInfo = {}
          customSkillInfo.formationType = formationType
          customSkillInfo.isUse = false
          table.insert(self.customSkillInfoList,customSkillInfo)
    end

    if type(customSkillInfo.battleAI) ~= 'table' then customSkillInfo.battleAI = {} end
    if type(customSkillInfo.battleAI.baseOrders) ~= 'table' then customSkillInfo.battleAI.baseOrders = {} end
    if type(customSkillInfo.battleAI.specialOrders) ~= 'table' then customSkillInfo.battleAI.specialOrders = {} end
    
    while #customSkillInfo.battleAI.specialOrders < 5 do
        table.insert(customSkillInfo.battleAI.specialOrders,0)
    end
    return customSkillInfo
end

function CelueManager:onReceiveCustomSkillInfo( event )
    hideLoading()
    local data = event.data.infos
    print('onReceiveCustomSkillInfo:',data)
    self.customSkillInfoList = data or {}
    -- TFDirector:dispatchGlobalEventWith(CelueManager.UPDATE_STATUS, 0)
end

function CelueManager:onReceiveCustomSkillSuccess( event )
    hideLoading()
    local data = event.data.formationType
    print('customSkillSuccess:',data)
    TFDirector:dispatchGlobalEventWith(CelueManager.UPDATE_STATUS, 0)
end

function CelueManager:sendUpdateCustomSkill( customSkillInfo )
    --去除掉SpecialOrder数据不全
    -- local specialOrders = customSkillInfo.battleAI.specialOrders
    -- local removePos = nil
    -- local func = function ( ... )
    --     if type(specialOrders) == 'table' then
    --       for i,v in ipairs(specialOrders) do
    --          if type(v) ~= 'table' then  return true end
    --          if not v.unitId or v.unitId == 0 or not v.specialOrderType then
    --               removePos = i
    --               return true
    --          end
    --       end
    --     end
    --     return false
    -- end
    -- while func() do
    --     table.remove(specialOrders,removePos)
    -- end
    print('sendUpdateCustomSkill:',customSkillInfo)
    self:sendWithLoading(c2s.UPDATE_CUSTOM_SKILL, self:packSendData(customSkillInfo))
end

function CelueManager:packSendData(customSkillInfo)
    local function islegal(v) --合法
        --v.unitId, v.specialOrderType, v.va lue, v.checkBuff
        if v == 0 or not v.unitId or v.unitId == 0 or not v.specialOrderType then
           return false
        end
        return true
    end
    local baseOrders,specialOrders = {},{}
    customSkillInfo.battleAI.baseOrders = customSkillInfo.battleAI.baseOrders or {}
    for k,v in pairs(customSkillInfo.battleAI.baseOrders) do
        if v ~= 0 then
           baseOrders[#baseOrders+1] = {v.unitId,v.staticId}
        end
    end
    customSkillInfo.battleAI.specialOrders = customSkillInfo.battleAI.specialOrders or {}
    for k,v in pairs(customSkillInfo.battleAI.specialOrders) do 
        if islegal(v) then
            specialOrders[#specialOrders+1] = {v.unitId, v.specialOrderType, v.value, v.checkBuff,v.staticId}
        end
    end
    print('packSendData:',customSkillInfo.formationType, customSkillInfo.isUse, {baseOrders, specialOrders, false})
    return customSkillInfo.formationType, customSkillInfo.isUse, {baseOrders, specialOrders, false}
end

return CelueManager:new()