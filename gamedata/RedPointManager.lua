--	红点系统
--  Tony
-- 	Date: 2016-08-30
--

local FunctionManager = class("FunctionManager")
--local FunctionData = require("lua.logic.redPoint.FunctionData")

function FunctionManager:ctor()
	
end

return FunctionManager:new()

-- function RedPointManager:ctor()
-- 	self:registerEvents()
-- 	self:restart()
-- 	self:createAutoFlushTimer()
-- 	self:bindFunctionCheckData()
-- end

-- function RedPointManager:bindFunctionCheckData()
-- 	FunctionCheckData.FunctionType = {}

-- 	function FunctionCheckData:arrayByType(type)
-- 		if FunctionCheckData.FunctionType[type] then
-- 			return FunctionCheckData.FunctionType[type]
-- 		end
-- 		FunctionCheckData.FunctionType[type] = TFArray:new()
-- 		return FunctionCheckData.FunctionType[type]
-- 	end

-- 	local item_mt = {}
-- 	item_mt.__index = item_mt
-- 	function item_mt:getType()
-- 		if self.type_number then
-- 			return self.type_number
-- 		end
-- 		self.type_number = stringToNumberTable(self.type, ',')
-- 		return self.type_number
-- 	end

-- 	function item_mt:getResType()
-- 		if self.res_type_number then
-- 			return self.res_type_number
-- 		end
-- 		self.res_type_number = stringToNumberTable(self.res_type, ',')
-- 		return self.res_type_number
-- 	end

-- 	for item in FunctionCheckData:iterator() do
-- 		item.__index = item_mt
-- 		setmetatable(item, item_mt)

-- 		for _,v in pairs(item:getType()) do
-- 			if FunctionCheckData.FunctionType[v] == nil then
-- 				FunctionCheckData.FunctionType[v] = TFArray:new()
-- 			end
-- 			FunctionCheckData.FunctionType[v]:push(item)
-- 		end
-- 		-- for _,v in pairs(item:getResType()) do
-- 		-- 	if FunctionData.FunctionType[v] == nil then
-- 		-- 		FunctionData.FunctionType[v] = TFArray:new()
-- 		-- 	end
-- 		-- 	print("v=====", v)
-- 		-- 	FunctionData.FunctionType[v]:push(item)
-- 		-- end
-- 	end

-- 	for item in FunctionData:iterator() do
-- 		local children = stringToNumberTable(item.children, ",")
-- 		for _,v in pairs(children) do
-- 			local data = FunctionData:objectByID(v)
-- 			if data then
-- 				data.parent = item.id
-- 			end
-- 		end
-- 	end
-- end

-- function RedPointManager:restart()
-- 	self.stateList = {}

-- 	if self.updateList then
-- 		self.updateList:clear()
-- 	else
-- 		self.updateList = MEMapArray:new()
-- 	end

-- 	self:removeTimer()
-- end

-- function RedPointManager:removeTimer()
-- 	TFDirector:removeTimer(self.nTimerId)
--     self.nTimerId = nil
-- end

-- function RedPointManager:registerEvents()
-- 	--TFDirector:addProto(s2c.ALL_FUNCTION_STATE, self, self.receiveAllFunctionsState)

-- 	self.resourceChangeListener = function(events) self:resourceChange(events.data[1]) end
-- 	TFDirector:addMEGlobalListener(RedPointManager.ResourceChange, self.resourceChangeListener)
-- end

-- function RedPointManager:removeEvents()
-- 	TFDirector:removeMEGlobalListener(RedPointManager.ResourceChange, self.resourceChangeListener)
-- 	self.resourceChangeListener = nil
-- end

-- function RedPointManager:dispose()
-- 	self:restart()
-- 	self:removeEvents()
-- end

-- function RedPointManager:resourceChange(data)
-- -- 	EnumResourceType = {
-- -- 	Material 					= 1,					--秘籍
-- -- 	MaterialFrag 				= 2,					--秘籍碎片
-- -- 	Prop 						= 3,					--道具
-- -- 	RoleFrag 					= 4,					--角色碎片
-- -- 	Equipment 					= 5,					--装备
-- -- 	EquipMaterial 				= 6,					--装备升品材料
-- -- 	Coin 						= 51,     				--铜币
-- -- 	Sycee 						= 52,					--元宝 
-- -- }

-- 	local function addToList(type)
-- 		local states = FunctionCheckData:arrayByType(type)
-- 		print("states===:", states, type)
-- 		for v in states:iterator() do
-- 			if self.updateList[v.id] == nil then
-- 				self.updateList:push(v)
-- 			end
-- 		end
-- 	end

-- 	self:removeTimer()
-- 	for _,v in pairs(data) do
-- 		local str_id = tostring(v)
--     	local goodsType = string.sub(str_id, 1, 1)
--     	local numType = tonumber(goodsType)
-- 		if numType ~= nil and numType ~= 0 then
-- 			addToList(numType)
-- 		end
-- 	end
	
-- 	print("updateList==--:", self.updateList)
-- 	self:createAutoFlushTimer()
-- end

-- function RedPointManager:isRedPointEnabled(functionId)
-- 	if not self.stateList then
-- 		return false
-- 	end

-- 	if self.stateList[functionId] ~= nil then
-- 		return self.stateList[functionId]
-- 	end
-- 	return false
-- end

-- function RedPointManager:updateRedPoint(widget, functionId)
-- 	if not functionId then
--         self:removeRedPoint(widget)
--         return
--     end

--     local configure = FunctionOpenConfigure:objectByID(functionId)
--     if not configure then
--         self:removeRedPoint(widget)
--         return
--     end

--     local redPoint = self:isRedPointEnabled(functionId)
--     if redPoint then
--     	if redPoint.isCache and redPoint.widget == nil then
--     		redPoint.widget = widget
--     	end
--     	self:addRedPoint(widget, ccp(redPoint.offsetX, redPoint.offsetY))
--     else
--     	self:removeRedPoint(widget)
--     end
-- end

-- function RedPointManager:removeRedPoint(widget)
-- 	CommonManager:removeRedPoint(widget)
-- end

-- function RedPointManager:addRedPoint(widget,offset)
-- 	CommonManager:addRedPoint(widget,offset)
-- end

-- function RedPointManager:createAutoFlushTimer()
-- 	if not self.nTimerId then
--         self.nTimerId = TFDirector:addTimer(100, -1, nil, function(event)
-- 			self:update()
-- 		end, "autoFlushRedPointStateTimer"); 
--     end
-- end

-- function RedPointManager:update()
-- 	if self.updateList:length() == 0 then
-- 		self:removeTimer()
-- 		return
-- 	end

-- 	if self.updateList and self.updateList:length() > 0 then
-- 		local data = self.updateList:popFront()
-- 		if data then
-- 			self[data.check](self, data)
-- 		end
-- 	end
-- end

-- function RedPointManager:checkRoleBook(data)
	
-- 	local level = MainLayer:getLevel()
-- 	local roleList = CardRoleManager.cardRoleList
-- 	for role in roleList:iterator() do
-- 		local promoteLv = role.promoteLv
-- 		local promoteBook = role.promoteBook

-- 		local advanceData  = CardAdvanceData:getObjectByTypeAndLevel(role.template.promote_type, promoteLv+1)
--     	local bookList      = advanceData:getMartialTable()
--     	for i=1, #bookList do
--     		if promoteBook[i] == nil then
--     			local bookInfo = GoodsMaterialData:objectByID(bookList[i])
--     			print("redPoint=== 红点", data.id, bookInfo.id)
--     			if level >= bookInfo.level and MaterialManager:isCanSynthesisById(bookInfo.id, 1) then
--     				print("redPoint=== 红点", data.id)
--     				if self.stateList[data.id] == nil then
--     					self.stateList[data.id] = data
--     					self:updateRedRelation(data.id, data.relation)
--     				end
--     				return
--     			end
--     		end
--     	end
-- 	end
-- 	self.stateList[data.id] = nil
-- 	print("shanchu=--- 删除geng")
-- 	self:updateRedRelation(data.id, data.relation)
-- end

-- function RedPointManager:updateRedRelation(id, functionId)
-- 	if functionId == nil or id == nil or id == 0 or functionId == 0 then
-- 		return 
-- 	end

-- 	local data = FunctionData:objectByID(functionId)
-- 	if data == nil then return end

-- 	local children = stringToNumberTable(data.children, ",")
-- 	local num = #children
-- 	-- if num == 0 then
-- 	-- 	if self.stateList[id] then
-- 	-- 		self.stateList[data.id] = data
-- 	-- 	else
-- 	-- 		self.stateList[data.id] = nil
-- 	-- 	end
-- 	-- 	if data.widget then
-- 	-- 		print("==----== 加红点", data.id)
-- 	--  		self:updateRedPoint(data.widget, data.id)
-- 	--  	end
-- 	--  	print("======================= 关系红点", data.id)
-- 	--  	self:updateRedRelation(data.id, data.parent)
-- 	-- 	return
-- 	-- end

-- 	print("-----------====")
-- 	local isCan = false
-- 	for i=1, num do
-- 		if self.stateList[children[i]] then
-- 			isCan = true
-- 			break
-- 		end
-- 	end
-- 	if isCan then
-- 		self.stateList[data.id] = data
-- 	else
-- 		self.stateList[data.id] = nil
-- 	end

-- 	if data.widget then
-- 	 	print("==----== 加红点", data.id)
-- 	 	self:updateRedPoint(data.widget, data.id)
-- 	end
-- 	print("======================= 关系红点", data.id, data.parent)
-- 	self:updateRedRelation(data.id, data.parent)
-- end

-- function RedPointManager:checkStarUp(data)
	
-- 	print("data===:", data)
-- 	print("p1:", p1)
-- 	print("p2:", p2)
-- 	print("p3:", p3)
-- end

-- return RedPointManager:new()