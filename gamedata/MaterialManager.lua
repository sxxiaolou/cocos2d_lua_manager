--[[
	武学管理器，实现了武学系统相关模块的绝大部分逻辑，包括网络相关
	-- @author david.dai
	-- @date 2015/4/20
]]

local BaseManager = require("lua.gamedata.BaseManager")
local MaterialManager = class("MaterialManager", BaseManager)

MaterialManager.Compose 		= "MaterialManager.Compose"
MaterialManager.Study 			= "MaterialManager.Study"
MaterialManager.Promote 		= "MaterialManager.Promote"
MaterialManager.Material 		= "MaterialManager.Material"

function MaterialManager:ctor(data)
	self.super.ctor(self, data)

end

function MaterialManager:init()
	self.super.init(self)

	TFDirector:addProto(s2c.COMPOSE, self, self.onReceiveCompose)
	TFDirector:addProto(s2c.STUDY, self, self.onReceiveStudy)
	TFDirector:addProto(s2c.PROMOTE, self, self.onReceivePromote)
end

function MaterialManager:restart()
	self.cardRole = nil
end

function MaterialManager:onReceiveCompose(event)
	hideLoading()
	
	TFDirector:dispatchGlobalEventWith(MaterialManager.Compose, event.data.cardId)
end

function MaterialManager:onReceiveStudy(event)
	hideLoading()
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_END, 0)
	TFDirector:dispatchGlobalEventWith(MaterialManager.Study, event.data.cardId)
end

function MaterialManager:onReceivePromote(event)
	hideLoading()
	
	self:showBookShowLayer(event.data.cardId)
	TFDirector:dispatchGlobalEventWith(MaterialManager.Promote, event.data.cardId)
end

--===================================== send====
function MaterialManager:sendCompose(roleId, bookId)
	self:sendWithLoading(c2s.COMPOSE, roleId, bookId)
end

function MaterialManager:sendStudy(roleId, bookId, bookPos)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, 0)
	self:sendWithLoading(c2s.STUDY, roleId, bookId, bookPos)
end

function MaterialManager:sendPromote(roleId, bookId)
	self:sendWithLoading(c2s.PROMOTE, roleId, bookId)
end

--================================end ===

function MaterialManager:setPassRole(cardRole)
	self.cardRole = cardRole
end

function MaterialManager:getMaterialById(materialId)
	local material = GoodsMaterialData:objectByID(materialId)
	if material ~= nil then
		return material
	end
	material = GoodsMaterialFragData:objectByID(materialId)
	return material
end

function MaterialManager:calcAllMissions(missions)
	local function  findId(id, startIndex)
		local tbl = {}
		for i= startIndex, missions:length() do
			local temp = missions:objectAt(i)
			if temp.id == id then
				tbl[#tbl + 1] = i
			end
		end
		return tbl
	end

	local length = missions:length()
	for i=1, length do
		local temp = missions:objectAt(i)
		if temp then
			local tbl = findId(temp.id, i+1)
			for k,v in pairs(tbl) do
				local data = missions:objectAt(v)
				if data and data.num then
					temp.num = temp.num + data.num
					table.insertTo(temp.show, data.show)
					missions:removeObject(data)
				end
			end

			local material = self:getMaterialById(temp.id)
			if material then
				temp.used = BagManager:getGoodsNumByTypeAndTplId(material.type, material.id)
				temp.num = temp.num + temp.used
			end
		else
			break
		end
	end
	return missions
end

function MaterialManager:getRolePassAllMissions(cardRole)
	cardRole = cardRole or self.cardRole
	if cardRole == nil then return end

	local missions = TFArray:new()
    local promoteLv = cardRole.promoteLv + 1
    local promoteBook = cardRole.promoteBook

    local advanceData  = CardAdvanceData:getObjectByTypeAndLevel(cardRole.template.promote_type, promoteLv)
    local bookList      = advanceData:getMartialTable()
	
	local threeStar, record = nil
	for i=1,#bookList do
        if promoteBook[i] == nil then
            local bookid   = bookList[i]
			local pass, three = self:getPassAllMissions(bookid, record)
			threeStar = three
            for mis in pass:iterator() do
                missions:push(mis)
            end
        end
	end
	
	-- print("&&&&&&&&&&&&&&&&&&&&&")
	-- print(missions.m_list)

	local function  findId(id, startIndex)
		local tbl = {}
		for i= startIndex, missions:length() do
			local temp = missions:objectAt(i)
			if temp.id == id then
				tbl[#tbl + 1] = i
			end
		end
		return tbl
	end

	local length = missions:length()
	for i=1, length do
		local temp = missions:objectAt(i)
		if temp then
			local tbl = findId(temp.id, i+1)
			for k,v in pairs(tbl) do
				local data = missions:objectAt(v)
				if data and data.num then
					temp.num = temp.num + data.num
					table.insertTo(temp.show, data.show)
					missions:removeObject(data)
				end
			end

			local material = self:getMaterialById(temp.id)
			if material then
				temp.used = BagManager:getGoodsNumByTypeAndTplId(material.type, material.id)
				temp.num = temp.num + temp.used
			end
		else
			break
		end
	end
    return missions, threeStar
end

function MaterialManager:getPassAllMissions(materialId, record)
	local missions = TFArray:new()

	local threeStar = nil

	record = record or {}
	local function getPass(material, num, show_num)
		num = num or 1
		show_num = show_num or 1
		if material.need_frags == nil or material.need_frags == "" then
			local acquire = stringToTable(material.acquire, ",")
			local data = {type=material.type, id=material.id, list={},num=num,show={},used=0}
			for i=1, #acquire do
				local tbl = stringToNumberTable(acquire[i], "_")
				if tbl[1] == FunctionManager.MissionMain then
					local missionId = tbl[2]
					if missionId == nil then
						missionId = MissionManager:currentMissionByType(EnumMissionType.Main).template.id
					end
					local mission = MissionManager:findMission(missionId)
					if material and mission and mission.starLevel == 3 and mission.template.challenge_times > mission.challengeCount then
						data.list[#data.list + 1] = missionId
					end
					if not threeStar then
						threeStar = mission and mission.starLevel < 3 and true or nil
					end
				end
			end
			if #data.list > 0 then
				local total = math.ceil(num/show_num)
				for i=1, total do
					if i ~= total then
						data.show[#data.show + 1] = show_num
					else
						data.show[#data.show + 1] = num - show_num*(total-1)
					end
				end
				missions:push(data)
			end
			return
		end
		local frags, index_frags = GetAttrByStringForExtra(material.need_frags)
		for i=1,#index_frags do
			local material = self:getMaterialById(index_frags[i])
			if material then
				local mId = material.id
				local usedNum = BagManager:getGoodsNumByTypeAndTplId(material.type, mId)
				local needNum = frags[index_frags[i]] * num
				record[mId] = record[mId] or 0

				if record[mId] < usedNum then
					record[mId] = record[mId] + needNum
					if usedNum < record[mId] then
						getPass(material, record[mId] - usedNum, frags[index_frags[i]])
					end
				else
					record[mId] = record[mId] + needNum
					getPass(material, needNum, frags[index_frags[i]])
				end
			end
		end
	end

	print("materialId:", materialId)
	local material = self:getMaterialById(materialId)
	if material then
		getPass(material)
	end
	return missions, threeStar
end

--获得扫荡秘籍要重置关卡中消耗最少的关卡id
function MaterialManager:getPassMissionMinCost(cardRole)
	local canChallenge = false
	local function getMinCost(materialId)
		local id_ = nil
		local cost_ = 1000

		local function getPass(material, num)
			num = num or 1
			if material.need_frags == nil or material.need_frags == "" then
				local acquire = stringToTable(material.acquire, ",")
				for i=1, #acquire do
					if canChallenge == true then return end
					local tbl = stringToNumberTable(acquire[i], "_")
					if tbl[1] == FunctionManager.MissionMain then
						local missionId = tbl[2]
						if missionId == nil then
							missionId = MissionManager:currentMissionByType(EnumMissionType.Main).template.id
						end
						local mission = MissionManager:findMission(missionId)
						if material and mission and mission.starLevel == 3 then
							--继续  
							if mission.template.challenge_times ~= mission.challengeCount then
								canChallenge = true
								return
							else
								local usedNum = BagManager:getGoodsNumByTypeAndTplId(material.type, material.id)
								local reset_cost = StageResetData:getResetCost(mission.resetCount)
								if usedNum < num and reset_cost < cost_ and mission.resetCount < 1 then
									id_ = mission.id
									cost_ = reset_cost
								end
							end
						end
					end
				end
				return
			end

			local frags, index_frags = GetAttrByStringForExtra(material.need_frags)
			for i=1,#index_frags do
				if canChallenge == true then return end
				local material = self:getMaterialById(index_frags[i])
				if material then
					local usedNum = BagManager:getGoodsNumByTypeAndTplId(material.type, material.id)
					local needNum = frags[index_frags[i]] * num
					if usedNum < needNum then
						getPass(material, needNum)
					end
				end
			end
		end

		print("min cost materialId:", materialId)
		local material = self:getMaterialById(materialId)
		if material then
			getPass(material)
		end
		return id_, cost_
	end

	cardRole = cardRole or self.cardRole
	if cardRole == nil then return end

	local missions = TFArray:new()
    local promoteLv = cardRole.promoteLv + 1
    local promoteBook = cardRole.promoteBook

    local advanceData  = CardAdvanceData:getObjectByTypeAndLevel(cardRole.template.promote_type, promoteLv)
    local bookList      = advanceData:getMartialTable()
    local id = nil
    local cost = 1000
    for i=1,#bookList do
    	if canChallenge == true then break end
        if promoteBook[i] == nil then
            local bookid   = bookList[i]
            local _id, _cost = getMinCost(bookid)
            if _id and _cost < cost then
            	id = _id
            	cost = _cost
            end
        end
    end
    if canChallenge == true then return end
    return id, cost
end

--[[
判断是否有足够材料合成
@martialId 合成目标武学id
@num 个数
@return 如果有足够材料合成此目标武学返回true，否则返回false
]]
function MaterialManager:isCanSynthesisById(materialId, num, record)
	local material = self:getMaterialById(materialId)
	if not material then
		return false
	end

	-- local curNum = BagManager:getGoodsNumByTplId(materialId)
	-- if curNum >= num then
	-- 	return true
	-- end

	--记录所需材料的数量  
	record = record or {}
	return self:isCanSynthesis(material,num, record)
end

--[[
判断是否有足够材料合成
@material 合成目标武学
@num 个数
@return 如果有足够材料合成此目标武学返回true，否则返回false
]]
function MaterialManager:isCanSynthesis(material,num, record)
	record = record or {}
	local frags,index = material:getMaterialTable()

	if not frags then 			--不可合成
		return false
	end

	local materialNum = 0
	
	--多态适配，没有指定参数则为1
	num = num or 1
	for k,v in pairs(frags) do
		materialNum = materialNum + 1
		--local type = self:getMaterialById(k).type
		local curNum = BagManager:getGoodsNumByTplId(k)
		local needNum = v * num + (record[k] or 0)
		if needNum > curNum then
			record[k] = curNum
			local canMerge = self:isCanSynthesisById(k, needNum - curNum, record)
			if not canMerge then
				return false
			end
		else
			record[k] = needNum
		end
	end

	-- 没有材料列表 则无法合成
	if materialNum == 0 then
		return false
	end
	return true
end

function MaterialManager:isHaveBook(role)
	local promoteLv = role.promoteLv
	local promoteBook = role.promoteBook

	local level = role:getLevel()
	local advanceData  = CardAdvanceData:getObjectByTypeAndLevel(role.template.promote_type, promoteLv+1)
    local bookList      = advanceData:getMartialTable()
    local isAll = true
    for i=1, #bookList do
    	if promoteBook[i] == nil then
    		isAll = false
    		local bookInfo = GoodsMaterialData:objectByID(bookList[i])
    		if level >= bookInfo.level then
    			local bag = BagManager:getGoodsByTypeAndTplId(bookInfo.type, bookInfo.id)
    			if bag and bag.num >= 1 then
    				return true
    			elseif MaterialManager:isCanSynthesisById(bookInfo.id, 1) then
    				return true
    			end
    		end
    	end
    end
    if isAll == true then return true end
    return false
end

function MaterialManager:setPromotePower(power)
	self.power = power
end

function MaterialManager:getPromotePower()
	return self.power or 0
end

function MaterialManager:getBookStatus(bookId, roleLevel)
	-- 0 不存在
    -- 1 背包存在并且可以穿戴
    -- 2 背包存在并且不可以穿戴
    -- 3 可以合成并且可以穿戴
    -- 4 可以合成并且不可以穿戴
    -- 5 已穿戴可升星
    local bookStatus = 0

    local id        = bookId
    local bookInfo = GoodsMaterialData:objectByID(id)
    local bag       = BagManager:getGoodsByTypeAndTplId(bookInfo.type, bookInfo.id)
    local bookLevel = bookInfo.level

    -- 背包中存在
    if bag then
        bookStatus = 1
    else
        if MaterialManager:isCanSynthesisById(id, 1) then
            bookStatus = 3
        end
    end
    
    -- 穿戴等级
    -- 有物品 才判断等级
    if bookLevel > roleLevel and bookStatus > 0 then
        bookStatus = bookStatus + 1
    end

    return bookStatus
end

function MaterialManager:showBookShowLayer(roleId)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleBookShowLayer", AlertManager.BLOCK_AND_GRAY_CLOSE)
    layer:loadData(roleId)
    AlertManager:show()
end

return MaterialManager:new()