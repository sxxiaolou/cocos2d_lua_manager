-- 阵型管理类
-- Author: Jin
-- Date: 2016-09-01
--
local FormationManager = class("FormationManager", BaseManager)

FormationManager.UPDATE_FORMATION 	= "FormationManager.UPDATE_FORMATION"
FormationManager.FORMATION_SIZE 	= "FormationManager.FORMATION_SIZE"

function FormationManager:ctor()
	self.super.ctor(self)
end

function FormationManager:init()
	self.super.init(self)
	self.battleSize = 0
	self.oldFormationPower = {}
	for k,type in pairs(EnumFormationType) do
		self.oldFormationPower[type] = 0
	end
	self.formationType = EnumFormationType.PVE
	-- formations = TFMapArray:new() (contains formation)
	-- formation = {
	-- 	type,
	-- 	cells = {} (contains cell)
	-- }
	-- cell = {
	-- 	pos,
	-- 	gmId,
	-- 	slotId
	-- }
	self.formations = TFMapArray:new()
	-- masters = {[type] = {masterId1, masterId2, ...}}
	self.masters = {}
	self:registerEvents()

	self.is_bool = true
end

function FormationManager:restart()
	-- body
	self.formations:clear()
	self.oldFormationPower = {}
	for k,type in pairs(EnumFormationType) do
		self.oldFormationPower[type] = 0
	end
	self.formationType = EnumFormationType.PVE
	self.battleSize = 0
	self.masters = {}
	self.is_bool = true
end

function FormationManager:registerEvents()
	TFDirector:addProto(s2c.GET_ALL_FORMATION, self, self.onReceiveAllFormation)
	TFDirector:addProto(s2c.UPDATE_FORMATION, self, self.onReceiveUpdateFormation)
	TFDirector:addProto(s2c.UPDATE_TO_BATTLE_SIZE, self, self.onReceiveToBattleSize)
	TFDirector:addProto(s2c.CLEAR_FORMATION,self,self.onReceiveClearFormation)
	--TFDirector:addProto(s2c.UPDATE_ALL_MASTER, self, self.onReceiveAllMasterInfo)
	--TFDirector:addProto(s2c.UPDATE_MASTER, self, self.onReceiveUpdateMaster)
end

-- function FormationManager:updateBattleSize(size)
-- 	print("FormationManager:updateBattleSize(size)", size)
-- 	self.battleSize = size
-- end

-- send --================ protocol
function FormationManager:sendToBattle(type, position, roleId)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, type)
	self:send(c2s.TO_BATTLE, type, position, roleId)
end

function FormationManager:sendOutBattle(type, roleId)
	if self:countInBattleByType(type) == 1 then
		toastMessage(localizable.common_less_one_role)
		return
	end
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, type)
	self:send(c2s.OUT_BATTLE, type, roleId)
end

--================  end ===================================

function FormationManager:onReceiveToBattleSize(event)
	local data = event.data
	self.battleSize = data.capacity
	-- print("===============battleSize: ", self.battleSize)
	TFDirector:dispatchGlobalEventWith(FormationManager.FORMATION_SIZE, data.capacity)
end

function FormationManager:onReceiveAllFormation(event)
	local data = event.data
	self:updateFormations(data.formations, true)

	-- print("===============onReceiveAllFormation: ", data)
end

function FormationManager:onReceiveUpdateFormation(event)
	local data = event.data
	self:updateFormations(data.formations)

	-- print("===============onReceive Update Formation: ", data)
	--CardRoleManager:updateAllRoleEquipAttr()
	TFDirector:dispatchGlobalEventWith(FormationManager.UPDATE_FORMATION, 0)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_END, self.formationType)
	TFDirector:dispatchGlobalEventWith("armyLayerPutSpecial", 0)
end

function FormationManager:onReceiveClearFormation( event )
	local data = event.data
	-- print('FormationManager:onReceiveClearFormation:',data)
	if data.type == nil then return end
	self:clearFormationByType(data.type)
end

function FormationManager:onReceiveAllMasterInfo(event)
	local data = event.data
	-- print("====onReceiveAllMasterInfo===",data)
	-- data.master = {[1] = {type=1, masterId={[1]=10150}}}
	self:updateAllMaster(data.master)
	
end

function FormationManager:onReceiveUpdateMaster(event)
	local data = event.data
	-- print("====onReceiveUpdateMaster===",data )
	self:updateMaster(data)
	
end

-- api
function FormationManager:openFormationLayer(formationType)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.army.ArmyLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:setArmyType(formationType)
	print('uuuuuuuuuuuuuuuuu',formationType)
	self.formationType = formationType or EnumFormationType.PVE
    AlertManager:show()
end

function FormationManager:openFormationVSLayer(opponent, armyType)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.army.FormationVSLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
    layer:loadData(opponent, armyType)
	self.formationType = armyType or EnumFormationType.PVE
    AlertManager:show()
end

-- b_bool false:equipment true:formation
function FormationManager:setArmyLayerType( b_bool )
	self.is_bool = b_bool
end

function FormationManager:getArmyLayerType()
	return self.is_bool
end

function FormationManager:openMasterLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.FormationMasterLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
    layer:setArmyType(1)
	self.formationType = 1
    AlertManager:show()
end

--获取阵型
function FormationManager:getFormationType( ... )
	return self.formationType  
end
-- 根据类型获取阵型
function FormationManager:getFormationByType(type)
	return self.formations:objectByID(type)
end

-- 清除阵型
function FormationManager:clearFormationByType( type )
	self.formations:removeById(type)
end

-- 可上阵人数
function FormationManager:getToBattleSize()
	return self.battleSize
end

-- 阵型上的人数
function FormationManager:countInBattleByType(type)
	local formation = self.formations:objectByID(type)
	local cnt = 0
	if formation then
		for _, cell in pairs(formation.cells) do
			if cell.gmId ~= "0" then cnt = cnt + 1 end
		end
	end
	return cnt
end

-- 获取阵型战力
function FormationManager:calcFormationPower(type)
	local formation = self.formations:objectByID(type)
	local totalPower = 0
	if formation then
		for _, cell in pairs(formation.cells) do
			local roleCard = CardRoleManager:getRoleByGmId(cell.gmId)
			if roleCard then
				totalPower = totalPower + roleCard:getPower()
			end
		end
	end
	return totalPower
end

-- 获取装备位信息
function FormationManager:getEquipSlot(type, index)
	local formation = self.formations:objectByID(type)
	if formation then
		return formation.cells[index]
	end

	return nil
end

-- 是否出战
function FormationManager:inFormation(type, gmId)
	local formation = self:getFormationByType(type)
	if formation then
		for _, cell in pairs(formation.cells) do
			if cell.gmId == gmId then
				return true
			end
		end
	end

	return false	
end

function FormationManager:inAnyFormation(gmId)
	for k,vType in pairs(EnumFormationType) do
		if self:inFormation(vType, gmId) then
			return true
		end
	end

	return false
end

function FormationManager:getInAnyFormationImg(gmId)
	local f_type = nil
	local formation = {}
	for k,vType in pairs(EnumFormationType) do
		formation[vType] = k
	end
	
	for i,v in ipairs(formation) do
		if self:inFormation(i, gmId) then
			f_type = i
			break
		end
	end

	if f_type == EnumFormationType.PVE then
		return "ui/recycle/tip_shangzhen.png"
	elseif f_type == EnumFormationType.PVP then
		return "ui/recycle/tip_fengshen.png"
	elseif f_type == EnumFormationType.BloodyWar then
		return "ui/recycle/tip_jianmu.png"
	elseif f_type == EnumFormationType.SCORE_MATCH_1V1 
		or f_type == EnumFormationType.SCORE_MATCH_3V3_1
		or f_type == EnumFormationType.SCORE_MATCH_3V3_2
		or f_type == EnumFormationType.SCORE_MATCH_3V3_3 then

		return "ui/recycle/tip_lunjian.png"
	end

	if BookWorldManager:inBookWorldIsUseById(gmId) then
		return "ui/recycle/tip_tianshu.png"
	end
	return "ui/recycle/tip_shangzhen.png"
end

function FormationManager:getInAnyFormationType(gmId)
	local formation = {}
	for k,vType in pairs(EnumFormationType) do
		formation[vType] = k
	end

	
	for i,v in ipairs(formation) do
		if self:inFormation(i, gmId) then
			return i
		end
	end

	if BookWorldManager:inBookWorldIsUseById(gmId) then
		return 666
	end

	return 0
end

-- local
function FormationManager:updateFormations(formations, init)
	formations = formations or {}
	for _, formation in pairs(formations) do
		self:updateFormation(formation)
	end
	if init then
		self.initFormations = formations
	end
end

function FormationManager:updateFormation(data)
	local formation = self.formations:objectByID(data.type)
	if not formation then 
		formation = {}
		formation.type = data.type
		formation.cells = {}
		self.formations:pushbyid(data.type, formation)
	end

	data.cells = data.cells or {}
	for _, eachPos in pairs(data.cells) do
		if eachPos.roleId and eachPos.roleId == "0" then
			formation.cells[eachPos.position] = nil
		else
			formation.cells[eachPos.position] = {pos = eachPos.position, gmId = eachPos.roleId}
		end
	end
end

--for manual saving formation, 
function FormationManager:saveFormation()
	local formation
	for _, form in pairs(self.initFormations) do
		if form.type == EnumFormationType.PVP then
			formation = form
			break
		end
	end

	local formation_new = self.formations:objectByID(EnumFormationType.PVP)
	for _, cell_new in pairs (formation_new.cells) do
		local to_add = true
		local to_modify = false
		for _, cell in pairs (formation.cells) do
			if cell.roleId == cell_new.gmId then
				to_add = false
				if cell.position ~= cell_new.pos then
					to_modify = true
				end
				cell.is_in = true
			end
		end
		
		if to_add or (not to_add and to_modify) then
			--new or modify
			self:sendToBattle(EnumFormationType.PVP, cell_new.pos, cell_new.gmId)
		end
	end

	for _, cell in pairs(formation.cells) do
		if not cell.is_in then
			--delete
			self:sendOutBattle(EnumFormationType.PVP, cell.roleId)
		end
	end
end

-- 获取卡牌在阵型上的位置
function FormationManager:getPosInFromation(fightType, gmId)
	local formation = self.formations:objectByID(fightType)
	if formation then
		for _, eachPos in pairs(formation.cells) do
			if eachPos.gmId == gmId then 
				return eachPos.pos
			end
		end
	end
	return -1
end

function FormationManager:updateAllMaster(allMaster)
	if not allMaster then return end

	for _, masterData in pairs(allMaster) do
		self:updateMaster(masterData)
	end
end

function FormationManager:updateMaster(masterData)
	local masters = {}
	self.masters[masterData.type] = masters

	if masterData.masterId then
		for _, masterId in pairs(masterData.masterId) do

			local master = CardMasterData:objectByID(masterId)
			masters[#masters + 1] = master
		end
	end
	self:updateCardRoleAttrs(masterData.type)


	-- if #masterData.masterId > 0 then
	-- 	self:updateCardRoleAttrs(masterData.type)
	-- end
end

-- 更新卡牌布阵大师信息
function FormationManager:updateCardRoleAttrs(type)
	local formation = self.formations:objectByID(type)
	for _, cell in pairs(formation.cells) do
		CardRoleManager:updateFormationMasterAttrs(type, cell.gmId)
	end
end

FormationManager.SORT_TYPE_POS     = 1
FormationManager.SORT_TYPE_POWER   = 2
FormationManager.SORT_TYPE_QUALITY = 3
function FormationManager:setSortStrategyForPower(fightType, cardRoleList)
	self.sort_type = FormationManager.SORT_TYPE_POWER
	self:reSortStrategy(fightType, cardRoleList)
end

function FormationManager:setSortStrategyForQuality(fightType, cardRoleList)
	self.sort_type = FormationManager.SORT_TYPE_QUALITY
	self:reSortStrategy(fightType, cardRoleList)
end

function FormationManager:reSortStrategy(fightType, cardRoleList)
	fightType = fightType or EnumFormationType.PVE
	cardRoleList = cardRoleList or CardRoleManager.cardRoleList.m_list

	local mainRole = MainPlayer:getMainRole()
	local maleId = ConstantData:getValue("Card.Role.Male")
	local femaleId = ConstantData:getValue("Card.Role.Female")
	local formationManager = self
	local cmpFun = nil
	if self.sort_type == FormationManager.SORT_TYPE_POWER then
		cmpFun = function(cardRole1, cardRole2)
			local pos1 = formationManager:getPosInFromation(fightType, cardRole1.gmId)
			local pos2 = formationManager:getPosInFromation(fightType, cardRole2.gmId)

			-- if cardRole1.id == mainRole.id then return true end
			-- if cardRole2.id == mainRole.id then return true end
			if (cardRole1.id == maleId or cardRole1.id == femaleId) and (cardRole2.id == maleId or cardRole2.id == femaleId) then return false end
			if cardRole1.id == maleId or cardRole1.id == femaleId then return true end
			if cardRole2.id == maleId or cardRole2.id == femaleId then return false end
			if cardRole1.power == cardRole2.power then
				if cardRole1.id == cardRole2.id then return false end
				return cardRole1.id < cardRole2.id
			else
				return cardRole1.power > cardRole2.power
			end
			-- if pos1 == pos2 then
			-- 	if cardRole1.power == cardRole2.power then
			-- 		return cardRole1.id < cardRole2.id
			-- 	else
			-- 		return cardRole1.power > cardRole2.power
			-- 	end
			-- else
			-- 	if pos1 == -1 then return false end
			-- 	if pos2 == -1 then return true end
			-- 	return pos1 < pos2
			-- end
		end
	else
		cmpFun = function(cardRole1, cardRole2)
			local pos1 = formationManager:getPosInFromation(fightType, cardRole1.gmId)
			local pos2 = formationManager:getPosInFromation(fightType, cardRole2.gmId)

			-- if cardRole1.id == mainRole.id then return true end
			-- if cardRole2.id == mainRole.id then return true end
			if (cardRole1.id == maleId or cardRole1.id == femaleId) and (cardRole2.id == maleId or cardRole2.id == femaleId) then return false end
			if cardRole1.id == maleId or cardRole1.id == femaleId then return true end
			if cardRole2.id == maleId or cardRole2.id == femaleId then return false end

			if cardRole1.quality == cardRole2.quality then
				if cardRole1.id == cardRole2.id then return false end
				return cardRole1.id < cardRole2.id
			else
				return cardRole1.quality > cardRole2.quality
			end
			-- if pos1 == pos2 then
			-- 	if cardRole1.quality == cardRole2.quality then
			-- 		return cardRole1.id < cardRole2.id
			-- 	else
			-- 		return cardRole1.quality > cardRole2.quality
			-- 	end
			-- else
			-- 	if pos1 == -1 then return false end
			-- 	if pos2 == -1 then return true end
			-- 	return pos1 < pos2
			-- end
		end
	end
	-- cardRoleList:sort(cmpFun)
	table.sort( cardRoleList, cmpFun)
end


function FormationManager:setOldFormationPower( value,type )
	self.oldFormationPower[type or EnumFormationType.PVE] = value or 0
end

function FormationManager:getOldFormationPower(type)
	return self.oldFormationPower[type or EnumFormationType.PVE] or 0
end

--==================================  红点系统 =========================

function FormationManager:isHaveRed()
	local totalSize = self:getToBattleSize()
	local curSize = self:countInBattleByType(EnumFormationType.PVE)
	return totalSize > curSize and CardRoleManager.cardRoleList:length() > curSize
end

--======================================================================

return FormationManager:new()
