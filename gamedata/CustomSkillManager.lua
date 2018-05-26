--[[
******技能策略管理类*******

	-- by Jing
	-- 2017/6/22
]]

local BaseManager = require('lua.gamedata.BaseManager')
local CustomSkillManager = class("CustomSkillManager", BaseManager)

local CardRole = require('lua.gamedata.base.CardRole')

CustomSkillManager.UpdateCustomSkill			= "CustomSkillManager.UpdateCustomSkill" 			--技能策略更新

function CustomSkillManager:ctor()
	self.super.ctor(self)
end

function CustomSkillManager:init()
	self.super.init(self)

	self.CustomSkillInfo = {}
	self.UpdateSkillInfo = {}

	TFDirector:addProto(s2c.CUSTOM_SKILL_AI, self, self.onGetCustomSkillAIInfo)
	TFDirector:addProto(s2c.CUSTOM_SKILL_SUCCESS, self, self.onCustomSkillSuc)
end

function CustomSkillManager:restart()
	self.CustomSkillInfo = {}
	self.UpdateSkillInfo = {}
end

function CustomSkillManager:onGetCustomSkillAIInfo(event)
	local data = event.data
	for k,info in pairs(data.infos) do
		self.CustomSkillInfo[info.formationType] = self:copyCustomSkillInfo(info)
	end
end

function CustomSkillManager:copyCustomSkillInfo(info)
	local copyInfo = {}
	copyInfo.isUse = info.isUse or false
	copyInfo.battleAI = {}
	copyInfo.battleAI.baseOrders = {}
	copyInfo.battleAI.specialOrders = {}
	for k,v in pairs(info.battleAI.baseOrders) do
		copyInfo.battleAI.baseOrders[#copyInfo.battleAI.baseOrders + 1] = v
	end
	for k,v in pairs(info.battleAI.specialOrders) do
		copyInfo.battleAI.specialOrders[#copyInfo.battleAI.specialOrders + 1] = {
			unitId=v.unitId,
			specialOrderType=v.specialOrderType,
			value=v.value,
			checkBuff=v.checkBuff,
		}
	end
	return copyInfo
end

function CustomSkillManager:onCustomSkillSuc(event)
	local data = event.data
	if data==nil or data.formationType==nil then return end
	self.CustomSkillInfo[data.formationType] = self:copyCustomSkillInfo(
		self.UpdateSkillInfo[data.formationType])
end

-- protocol
function CustomSkillManager:sendUpdateCustomSkill(id, materials)
	-- TFDirector:dispatchGlobalEventWith(CustomSkillManager.ROLE_CHUAN_GONG_BEGIN, 0)
	-- self:sendWithLoading(c2s.CARD_LEVEL_UP, materials, id)
end

return CustomSkillManager:new()