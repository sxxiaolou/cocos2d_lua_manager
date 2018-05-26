-- 神器管理类
-- Author: Tony
-- Date: 2017-03-07
--

local ArtifactManager = class("ArtifactManager", BaseManager)

-- message ArtifactInfo{
-- 	required string id = 1;			//神器实例id
-- 	required int32 tplId = 2;		//神器模版id
-- 	repeated string roleId = 3;		//装备的卡牌id
-- 	required int32 level = 4;		//等级
--  template  模板
-- }

ArtifactManager.ARTIFACT_UPDATE			= "ArtifactManager.ARTIFACT_UPDATE"  		--神器更新
ArtifactManager.ARTIFACT_EQUIP 			= "ArtifactManager.ARTIFACT_EQUIP"	 		--神器装备	

ArtifactManager.ARTIFACT_ATTR_LEVEL 	= "ArtifactManager.ARTIFACT_ATTR_LEVEL"	 	--神器强化升级	
ArtifactManager.ARTIFACT_SKILL_LEVEL 	= "ArtifactManager.ARTIFACT_SKILL_LEVEL"	--神器技能升级	

function ArtifactManager:ctor()
	self.super.ctor(self)
end

function ArtifactManager:init()
	self.super.init(self)

	self.artifactList = {}
	self.artifactEquipInfo = {}
	self.artifactType = 0
	self.isAction = true

	TFDirector:addProto(s2c.GET_ARTIFACT_LIST, self, self.onArtifactList)-- 神器信息 全部 登陆下发
	TFDirector:addProto(s2c.ARTIFACT_EQUIP_INFO, self, self.onArtifactEquipInfoResult)-- 神器装备 
	TFDirector:addProto(s2c.ARTIFACT_INFO, self, self.onArtifactInfoResult)	-- 神器合成/升级 

	TFDirector:addProto(s2c.ARTIFACT_ATTR_LV_UP, self, self.onArtifactAttrLvUp)	-- 法宝强化升级
	TFDirector:addProto(s2c.ARTIFACT_SKILL_LV_UP, self, self.onArtifactSkillLvUp)	-- 法宝技能升级
end

function ArtifactManager:restart()
	for k,v in pairs(self.artifactList) do
		v = nil
	end
	self.artifactList = {}

	for k,v in pairs(self.artifactEquipInfo) do
		v = nil
	end
	self.artifactEquipInfo = {}

	self.artifactType = 0
	self.isAction = true
end

--下发神器列表
function ArtifactManager:onArtifactList(event)
	local list = event.data.list or {}
	self.artifactList = {}
	for _, artifact in pairs(list) do
		self.artifactList[#self.artifactList + 1] = self:onCreateArtifact( artifact )
		if artifact.roleId ~= "0" then
			self.artifactEquipInfo[artifact.roleId] = artifact.tplId
		end
	end
	CardRoleManager:updateArtifactAttr()
end

function ArtifactManager:onCreateArtifact( data )
	local artifact = {}
	artifact.tplId = data.tplId						--神器模版id
	artifact.uuid = data.tplId						--神器模版id
	artifact.level = data.level						--进化等级
	artifact.roleId = data.roleId or "0"			--装备的角色id
	artifact.attrLevel = data.attrLevel or 1		--强化等级
	artifact.skillLevel = data.skillLevel or 1  	--技能等级
	artifact.combValue = data.combValue or 1		--当前等级暴击次数
	artifact.curExp = data.curExp or 0				--当前经验
	local template = GoodsArtifactData:objectByID(data.tplId)
	if not template then 
		assert("not artifact -- template")
	end
	artifact.template = template
	artifact.template.getIconPath = function ( )
		return GetArtifactImgIconById(artifact.template.display)
	end
	return artifact
end

--更新神器装备信息
function ArtifactManager:onArtifactEquipInfoResult(event)
	hideLoading()

	local tplId = event.data.tplId
	local roleId = event.data.roleId
	
	if tplId == 0 then
		local artifact = self:findArtifactByID(self.artifactEquipInfo[roleId])
		if artifact then
			artifact.roleId = "0"
		end
		
		self.artifactEquipInfo[roleId] = nil
	else
		local artifact = self:findArtifactByID(tplId)
		if artifact then
			artifact.roleId = roleId
		end

		self.artifactEquipInfo[roleId] = tplId
	end

	CardRoleManager:updateRoleArtifactAttr(roleId)
	TFDirector:dispatchGlobalEventWith(ArtifactManager.ARTIFACT_EQUIP, 0)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_END, 0)
end

--更新神器进阶
function ArtifactManager:onArtifactInfoResult(event)
	hideLoading()

	local data = event.data
	local tplId = data.tplId
	local artifact = self:findArtifactByID(tplId)
	if artifact then
		local oldArtifact = {tplId = artifact.tplId, level = artifact.level, roleId = artifact.roleId,
							 attrLevel = artifact.attrLevel, skillLevel = artifact.skillLevel, combValue = artifact.combValue,
							 curExp = artifact.curExp, template = artifact.template
							}
		artifact.level = data.level				--进化等级
		artifact.roleId = data.roleId			--装备的角色id
		artifact.attrLevel = data.attrLevel		--强化等级
		artifact.skillLevel = data.skillLevel  	--技能等级
		artifact.combValue = data.combValue		--当前等级暴击次数
		artifact.curExp = data.curExp			--当前经验
		if artifact.level > oldArtifact.level then
			self:openShenqiUpLayer( oldArtifact, artifact )
		end
	else
		local newArtifact = self:onCreateArtifact( data )
		self.artifactList[#self.artifactList + 1] = newArtifact
		if newArtifact.level == 0 then
			self:openShenqiOpenLayer(newArtifact)
		end
	end

	local roleId = self:findRoleIDsByID(tplId)
	-- for _, roleId in pairs(roleIds) do
		CardRoleManager:updateRoleArtifactAttr(roleId)
	-- end
	TFDirector:dispatchGlobalEventWith(ArtifactManager.ARTIFACT_UPDATE, 0)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_END, 0)
end

--法宝强化升级
function ArtifactManager:onArtifactAttrLvUp(event)
	hideLoading()

	TFDirector:dispatchGlobalEventWith(ArtifactManager.ARTIFACT_ATTR_LEVEL, 0)
end
--法宝技能升级
function ArtifactManager:onArtifactSkillLvUp(event)
	hideLoading()

	TFDirector:dispatchGlobalEventWith(ArtifactManager.ARTIFACT_SKILL_LEVEL, 0)
end
-------=================================   send =========================================

--神器装备      
function ArtifactManager:sendEquipArtifact(artifactId, roleId)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, 0)
	self:sendWithLoading(c2s.EQUIP_ARTIFACT, artifactId, roleId)
end


--神器合成、进阶    
function ArtifactManager:sendArtifactLvUp(artifactId)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, 0)
	self:sendWithLoading(c2s.ARTIFACT_LV_UP, artifactId)
end

--法宝强化升级
function ArtifactManager:sendArtifactAttrLevelUp(artifactId, times, cirt)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, 0)
	self:sendWithLoading(c2s.ARTIFACT_ATTR_LV_UP, artifactId, times, cirt)
end

--法宝技能升级
function ArtifactManager:sendArtifactSkillLevelUp(artifactId)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, 0)
	self:sendWithLoading(c2s.ARTIFACT_SKILL_LV_UP, artifactId)
end

--======================================== proto ========================================
--查找神器
function ArtifactManager:findArtifactByID(tplId)
	if tplId == nil then return nil end

	for _, artifact in pairs(self.artifactList) do
		if artifact and artifact.tplId == tplId then
			return artifact
		end
	end
	return nil
end

function ArtifactManager:getArtifactListToRebirth()
	local artifactList = TFArray:new()

	for _, artifact in pairs(self.artifactList) do
		artifactList:push(artifact)
	end

	return artifactList
end
--通关角色id 获取装备的神器
function ArtifactManager:findArtifactByRoleID(roleId)
	local tplId = self.artifactEquipInfo[roleId]
	return self:findArtifactByID(tplId)
end

--通过神器模板id 获取角色
function ArtifactManager:findRoleIDsByID(id)
	local role_Id = 0
	for roleId, tplId in pairs(self.artifactEquipInfo) do
		if tplId == id then
			role_Id = roleId
		end
	end
	return role_Id
end

function ArtifactManager:getArtifactEquipInfo()
	return self.artifactEquipInfo
end

-- 通过Id获得神器合成的碎片类型
function ArtifactManager:getCompositeAtrifactType( id, level )
	local level = level and level or 0
	local tplId = id * 100 + level
	local data = ArtifactEnvolveData:objectByID(tplId)
	local str = data and GetAttrByString(data.need_frags) or {}
	local item = {}
	for k,v in pairs(str) do
		item[#item + 1] = {id = k, value = v}
	end

	table.sort( item, function ( t1, t2 ) return t1.id < t2.id end )
	return item
end

-- 通过Id获得神器是否可解封
function ArtifactManager:CheckAtrifact( id )
	if self:findArtifactByID(id) then return false end
	local is_bool = true
	local strId = self:getCompositeAtrifactType(id)
	for k,v in pairs(strId) do
        local number = BagManager:getGoodsNumByTypeAndTplId(EnumGoodsType.ArtifactFrag, v.id)
        if number == 0 then
            is_bool = false
        end
    end
	return is_bool
end

-- 通过Id获得神器是否可激活
function ArtifactManager:ActivateAtrifact( id )
	local is_bool = false
	if self:findArtifactByID(id) then return false end
	local message = GoodsArtifactData:objectByID(id)
    if not message then return is_bool end
	if MainPlayer:getLevel() >= message.level then
        is_bool = true
    end
	return is_bool
end

-- 通过id跟等级判断是否可进阶
function ArtifactManager:isAdvance(id, level )
	if not self:findArtifactByID(id) then return false end
	local envolve = ArtifactEnvolveData:getArtifactEnvolveByIdAndLevel( id, level)
	if not envolve then return false end
	local factData = self:getCompositeAtrifactType( id, level)
	if not factData then return false end
    local value = 1
    for k,v in pairs(factData) do
        local number = BagManager:getGoodsNumByTypeAndTplId(EnumGoodsType.ArtifactFrag, v.id)
        if number < v.value then
        	return false
        end
	end

    return true
end

-- 通过id跟等级判断是否可能力强化
function ArtifactManager:isRedPointAttrLevel(id, level )
	local curArtifact = self:findArtifactByID(id)
	if not curArtifact then return false end
	local envolve = ArtifactEnvolveData:getArtifactEnvolveByIdAndLevel( id, level )
	if not envolve then return false end
	if curArtifact.attrLevel >= envolve.level_limit then return false end
	--能力强化
	local nextAttrData = ArtifactLevelData:getArtifactByQualityAndLevel(curArtifact.template.quality, curArtifact.attrLevel + 1)
	if nextAttrData then   
		local goods = nextAttrData:getLevelUpGoods()
		for i,item in pairs(goods) do
			local goodItem = GoodsItemData:objectByID(item[1])
			if item[2] > BagManager:getGoodsNumByTypeAndTplId(EnumGoodsType.Prop, item[1]) then
				return false
			end
		end
	else
		return false
	end

	return true
end

-- 通过id跟等级判断是否可技能强化
function ArtifactManager:isRedPointSkillLevel(id, level )
	local curArtifact = self:findArtifactByID(id)
	if not curArtifact then return false end
	local envolve = ArtifactEnvolveData:getArtifactEnvolveByIdAndLevel( id, level)
	if not envolve then return false end
	if curArtifact.skillLevel >= envolve.skilllevel_limit then return false end
	--技能强化
	local nextSkillId = id * 100 + ((curArtifact.skillLevel + 1) - 1) * 10 + 1
	local nextSkillData = ArtifactSkillLevelData:objectByID(nextSkillId)
	if nextSkillData then
		local goods = nextSkillData:getSkillUpLevelGoods()
		for i,item in pairs(goods) do
			local goodItem = GoodsItemData:objectByID(item[1])
			if item[2] > BagManager:getGoodsNumByTypeAndTplId(EnumGoodsType.Prop, item[1]) then
				return false
			end
		end 
		-------------------第二个固定铜币
		if nextSkillData.need_coin > MainPlayer:getCoin() then
			return false
		end
		-------------------
	else
		return false
	end 
	return true
end

-- 获取上一个神器信息
function ArtifactManager:GetLastArtifact( id )
	local atrifact = GoodsArtifactData:objectByID(id)
	local item = {}
	for data in GoodsArtifactData:iterator() do
		if self:findArtifactByID(data.id) or self:CheckAtrifact(data.id) or self:ActivateAtrifact(data.id) then
			if self.artifactType == EnumAtriFactType.All then
				item[#item + 1] = data
			else
				if atrifact.kind == data.kind then
					item[#item + 1] = data
				end
			end	
		end		
	end

    table.sort( item, function ( t1, t2 )
    	local is_bool1 = self:CheckAtrifact( t1.id )
        local is_bool2 = self:CheckAtrifact( t2.id )
        if is_bool1 and is_bool2 then
            if t1.quality == t2.quality then
                return t1.id > t2.id
            else
                return t1.quality > t2.quality
            end
        end

        if is_bool1 and not is_bool2 then return true end
        if not is_bool1 and is_bool2 then return false end

        if not is_bool1 and not is_bool2 then
            local data1 = self:findArtifactByID(t1.id)
            local data2 = self:findArtifactByID(t2.id)
            if data1 and not data2 then
                return true
            elseif not data1 and data2 then
                return false
            elseif data1 and data2 then

            	local roleUid1 = self:findRoleIDsByID(t1.id)
                local roleUid2 = self:findRoleIDsByID(t2.id)

                if roleUid1 ~= 0 and roleUid2 == 0 then
                    return  true
                elseif roleUid1 == 0 and roleUid2 ~= 0 then
                    return false
                end

                if t1.quality == t2.quality then
                    return data1.level > data2.level
                else
                    return t1.quality > t2.quality
                end
            elseif not data1 and not data2 then

                 if t1.quality == t2.quality then
                    return t1.id > t2.id
                else
                    return t1.quality > t2.quality
                end
            end
        end
        return false
    end )

	local index = 0
	for i=1,#item do
		local atrifactData = item[i]
		if atrifactData.id == id then
			index = i
			break
		end
	end
	return item[index - 1]
end

-- 获取下一个神器信息
function ArtifactManager:GetNextArtifact( id )
	local atrifact = GoodsArtifactData:objectByID(id)
	local item = {}
	for data in GoodsArtifactData:iterator() do
		if self:findArtifactByID(data.id) or self:CheckAtrifact(data.id) or self:ActivateAtrifact(data.id) then
			if self.artifactType == EnumAtriFactType.All then
				item[#item + 1] = data
			else 
				if atrifact.kind == data.kind then
					item[#item + 1] = data
				end
			end	
		end
	end

    table.sort( item, function ( t1, t2 )
    	local is_bool1 = self:CheckAtrifact( t1.id )
        local is_bool2 = self:CheckAtrifact( t2.id )
        if is_bool1 and is_bool2 then
            if t1.quality == t2.quality then
                return t1.id > t2.id
            else
                return t1.quality > t2.quality
            end
        end

        if is_bool1 and not is_bool2 then return true end
        if not is_bool1 and is_bool2 then return false end

        if not is_bool1 and not is_bool2 then
            local data1 = self:findArtifactByID(t1.id)
            local data2 = self:findArtifactByID(t2.id)
            if data1 and not data2 then
                return true
            elseif not data1 and data2 then
                return false
            elseif data1 and data2 then
            	local roleUid1 = self:findRoleIDsByID(t1.id)
                local roleUid2 = self:findRoleIDsByID(t2.id)

                if roleUid1 ~= 0 and roleUid2 == 0 then
                    return  true
                elseif roleUid1 == 0 and roleUid2 ~= 0 then
                    return false
                end
                
                if t1.quality == t2.quality then
                    return data1.level > data2.level
                else
                    return t1.quality > t2.quality
                end
            elseif not data1 and not data2 then

                 if t1.quality == t2.quality then
                    return t1.id > t2.id
                else
                    return t1.quality > t2.quality
                end
            end
        end
        return false
    end )
	local index = 0
	for i=1,#item do
		local atrifactData = item[i]
		if atrifactData.id == id then
			index = i
			break
		end
	end
	return item[index + 1]
end

function ArtifactManager:setArtifactAction( is_bool )
	self.isAction = is_bool
end

function ArtifactManager:getArtifactAction()
	return self.isAction
end

function ArtifactManager:setArtifactType(type)
	self.artifactType = type
end

function ArtifactManager:getArtifactType()
	return self.artifactType
end

---============================= redpoint ==========================

function ArtifactManager:isHaveRedPoint()
	--CommonRightLayer 中 展开按钮上的红点判断
	local can_jump = JumpToManager:isCanJump(FunctionManager.MenuArtifact)
    if not can_jump then
        return false
    end
	if self:isHaveRedPointCompose() then return true end
	if self:isHaveRedPointAdvance() then return true end
	return false
end

function ArtifactManager:isHaveRedPointCompose()
	for data in GoodsArtifactData:iterator() do
		if self:CheckAtrifact(data.id) then
			return true
		end
	end
	return false
end

function ArtifactManager:isHaveRedPointAdvance()
	for k,v in pairs(self.artifactList) do
		if self:isAdvance(v.tplId, v.level + 1) then
			return true
		end

		if self:isRedPointAttrLevel(v.tplId, v.level) then
			return true
		end

		if self:isRedPointSkillLevel(v.tplId, v.level) then
			return true
		end
	end
	return false
end

--================================ end =============================

function ArtifactManager:openArtifactMainLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shenqi.ShenqiMainLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function ArtifactManager:openArtifactLayer(id)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shenqi.ShenqiLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:loadData(id)
	AlertManager:show()
end

function ArtifactManager:openArtifactRoleLayer(roldId,id)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shenqi.ShenqiOnOLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
	layer:loadData(roldId,id)
	AlertManager:show()
end

function ArtifactManager:openShenqiOpenLayer( data )
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shenqi.ShenqiOpenLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
	layer:loadData(data)
	AlertManager:show()
end

function ArtifactManager:openShenqiUpLayer( oldData, newData )
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shenqi.ShenqiUpLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
	layer:loadData(oldData, newData)
	AlertManager:show()
end


return ArtifactManager:new()